part of 'cart_bloc.dart';

class CartState extends Equatable {
  final List<CartLine> lines;
  final CartTotals totals;

  const CartState({required this.lines, required this.totals});

  @override
  List<Object> get props => [lines, totals];
}
