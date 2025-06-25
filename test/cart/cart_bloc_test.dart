// ignore_for_file: unused_import

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:pos/src/cart/cart_line.dart';
import 'package:pos/src/cart/bloc/cart_bloc.dart';
import 'package:pos/src/item_model.dart';


void main() {
  late Item coffee;
  late Item tea;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hydrated_bloc_test');
    HydratedBloc.storage = await HydratedStorage.build(storageDirectory: dir);
  });

  setUp(() async {
    await HydratedBloc.storage.clear();
    coffee = Item(id: 'p01', name: 'Coffee', price: 10.0);
    tea = Item(id: 'p02', name: 'Tea', price: 5.0);
  });
  group('CartBloc', () {
    blocTest<CartBloc, CartState>(
      '1. Add two different items → correct totals',
      build: () => CartBloc(),
      act: (bloc) => bloc
        ..add(AddItem(coffee))
        ..add(AddItem(tea)),
      expect: () => [
        isA<CartState>().having((s) => s.totals.grandTotal, 'grandTotal', closeTo(11.5, 0.01)),
        isA<CartState>().having((s) => s.totals.grandTotal, 'grandTotal', closeTo(17.25, 0.01)),
      ],
    );

    blocTest<CartBloc, CartState>(
      '2. Changing qty & discount updates totals',
      build: () => CartBloc(),
      act: (bloc) => bloc
        ..add(AddItem(coffee))
        ..add(ChangeQty(coffee.id, 2))       // 2 × 10 = 20
        ..add(ChangeDiscount(coffee.id, 0.5)), // 50% خصم → 10
      expect: () => [
        isA<CartState>().having((s) => s.totals.grandTotal, 'g1', closeTo(11.5, 0.01)),
        isA<CartState>().having((s) => s.totals.grandTotal, 'g2', closeTo(23.0, 0.01)),
        isA<CartState>().having((s) => s.totals.grandTotal, 'g3', closeTo(11.5, 0.01)),
      ],
    );

    blocTest<CartBloc, CartState>(
      '3. Clearing cart resets state',
      build: () => CartBloc(),
      act: (bloc) => bloc
        ..add(AddItem(coffee))
        ..add(ClearCart()),
      expect: () => [
        isA<CartState>().having((s) => s.lines.length, 'lines', 1),
        const CartState(
          lines: [],
          totals: CartTotals(subtotal: 0, vat: 0, grandTotal: 0),
        )
      ],
    );

    blocTest<CartBloc, CartState>(
      'Undo returns to previous state',
      build: () => CartBloc(),
      act: (bloc) => bloc
        ..add(AddItem(coffee))
        ..add(AddItem(tea))
        ..add(UndoAction()),
      expect: () => [
        isA<CartState>().having((s) => s.lines.length, 'after add coffee', 1),
        isA<CartState>().having((s) => s.lines.length, 'after add tea', 2),
        isA<CartState>().having((s) => s.lines.length, 'after undo', 1),
      ],
    );

    blocTest<CartBloc, CartState>(
      'Redo re-applies last undone state',
      build: () => CartBloc(),
      act: (bloc) => bloc
        ..add(AddItem(coffee))
        ..add(AddItem(tea))
        ..add(UndoAction())
        ..add(RedoAction()),
      expect: () => [
        isA<CartState>().having((s) => s.lines.length, '1st add', 1),
        isA<CartState>().having((s) => s.lines.length, '2nd add', 2),
        isA<CartState>().having((s) => s.lines.length, 'undo', 1),
        isA<CartState>().having((s) => s.lines.length, 'redo', 2),
      ],
    );
    test('CartBloc hydration (toJson/fromJson)', () {
      final bloc = CartBloc();
      bloc.add(AddItem(Item(id: '1', name: 'Test', price: 100.0)));

      // Wait for state to change
      expectLater(
        bloc.stream,
        emits(isA<CartState>()),
      ).then((_) {
        final json = bloc.toJson(bloc.state);
        final restored = bloc.fromJson(json!);
        expect(restored, bloc.state);
      });
    });
    test('CartEvent equality', () {
      expect(AddItem(Item(id: 'x', name: 'X', price: 1.0)), AddItem(Item(id: 'x', name: 'X', price: 1.0)));
      expect(ChangeQty('x', 2), ChangeQty('x', 2));
      expect(ChangeDiscount('x', 0.1), ChangeDiscount('x', 0.1));
      expect(UndoAction(), UndoAction());
      expect(RedoAction(), RedoAction());
      expect(ClearCart(), ClearCart());
    });


  });
}
