
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pos/src/cart/bloc/cart_bloc.dart';
import 'package:pos/src/catalog/receipt.dart';
import 'package:pos/src/util/constants.dart';
import 'package:pos/src/util/money.dart';

import 'src/item_model.dart';

/// Entry point for the Mini POS Checkout Core logic-only application.
/// This initializes the hydrated storage, loads catalog data, simulates
/// cart events, and prints a receipt using pure business logic.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent storage for hydrated_bloc
  final dir = await getApplicationDocumentsDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: dir,
  );

  try {
    // Load static product catalog from JSON asset
    final jsonStr = await rootBundle.loadString(AppConstants.catalogFile);
    final List<dynamic> decoded = json.decode(jsonStr);
    final items = decoded.map((e) => Item.fromJson(e)).toList();

    final cartBloc = CartBloc();

    // Simulate business events
    cartBloc.add(AddItem(items[0])); // Coffee
    cartBloc.add(AddItem(items[1])); // Bagel
    cartBloc.add(ChangeQty(items[0].id, 2)); // Coffee x2
    cartBloc.add(ChangeDiscount(items[1].id, 0.2)); // Bagel 20% off

    // Listen and print final cart receipt after processing
    final subscription = cartBloc.stream.listen((state) {
      final receipt = buildReceipt(state, DateTime.now());
      printReceipt(receipt);
    });

    // Wait to allow events to be processed
    await Future.delayed(const Duration(seconds: 1));
    await subscription.cancel();
    await cartBloc.close();
  } catch (e) {
    print('❌ Failed to load catalog or process cart: $e');
  }
}

/// Prints the receipt to the console in a formatted layout.
void printReceipt(Receipt receipt) {
  print('\n🧾 Receipt at ${receipt.timestamp}');
  for (var line in receipt.lines) {
    print(
      '- ${line.qty} x ${line.name} @ \$${line.price.asMoney}'
          ' (discount: ${(line.discount * 100).toStringAsFixed(0)}%)'
          ' → \$${line.lineNet.asMoney}',
    );
  }
  print('Subtotal: \$${receipt.subtotal.asMoney}');
  print('VAT: \$${receipt.vat.asMoney}');
  print('Total: \$${receipt.grandTotal.asMoney}\n');
}
