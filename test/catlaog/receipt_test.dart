import 'package:flutter_test/flutter_test.dart';
import 'package:pos/src/cart/cart_line.dart';
import 'package:pos/src/cart/bloc/cart_bloc.dart';
import 'package:pos/src/catalog/receipt.dart';
import 'package:pos/src/item_model.dart';

void main() {
  group('Receipt Builder', () {
    test('buildReceipt creates valid receipt from CartState', () {
      final now = DateTime(2025, 6, 25, 12, 30);

      final coffee = Item(id: 'p01', name: 'Coffee', price: 10.0);
      final line = CartLine(item: coffee, quantity: 2, discount: 0.1); // 10 * 2 * 0.9 = 18.0

      final cartState = CartState(
        lines: [line],
        totals: CartTotals(
          subtotal: 18.0,
          vat: 2.7,
          grandTotal: 20.7,
        ),
      );

      final receipt = buildReceipt(cartState, now);

      expect(receipt.timestamp, now);
      expect(receipt.subtotal, 18.0);
      expect(receipt.vat, 2.7);
      expect(receipt.grandTotal, 20.7);
      expect(receipt.lines.length, 1);

      final receiptLine = receipt.lines.first;
      expect(receiptLine.name, 'Coffee');
      expect(receiptLine.qty, 2);
      expect(receiptLine.price, 10.0);
      expect(receiptLine.discount, 0.1);
      expect(receiptLine.lineNet, 18.0);
    });
  });
}
