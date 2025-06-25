import 'package:pos/src/cart/bloc/cart_bloc.dart';


class Receipt {
  final DateTime timestamp;
  final List<ReceiptLine> lines;
  final double subtotal;
  final double vat;
  final double grandTotal;

  const Receipt({
    required this.timestamp,
    required this.lines,
    required this.subtotal,
    required this.vat,
    required this.grandTotal,
  });
}

class ReceiptLine {
  final String name;
  final int qty;
  final double price;
  final double discount; // e.g., 0.10 means 10%
  final double lineNet;

  const ReceiptLine({
    required this.name,
    required this.qty,
    required this.price,
    required this.discount,
    required this.lineNet,
  });
}

Receipt buildReceipt(CartState cart, DateTime now) {
  final receiptLines = cart.lines.map((line) {
    return ReceiptLine(
      name: line.item.name,
      qty: line.quantity,
      price: line.item.price,
      discount: line.discount,
      lineNet: line.lineNet,
    );
  }).toList();

  return Receipt(
    timestamp: now,
    lines: receiptLines,
    subtotal: cart.totals.subtotal,
    vat: cart.totals.vat,
    grandTotal: cart.totals.grandTotal,
  );
}
