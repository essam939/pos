part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object> get props => [];
}
/// Triggered to add an item or increment its quantity.
class AddItem extends CartEvent {
  final Item item;
  const AddItem(this.item);
  @override
  List<Object> get props => [item];
}
/// Triggered to completely remove an item from the cart.

class RemoveItem extends CartEvent {
  final String itemId;
  const RemoveItem(this.itemId);
  @override
  List<Object> get props => [itemId];
}

class ChangeQty extends CartEvent {
  final String itemId;
  final int quantity;
  const ChangeQty(this.itemId, this.quantity);
  @override
  List<Object> get props => [itemId, quantity];
}

class ChangeDiscount extends CartEvent {
  final String itemId;
  final double discount;
  const ChangeDiscount(this.itemId, this.discount);
  @override
  List<Object> get props => [itemId, discount];
}

class ClearCart extends CartEvent {}
class UndoAction extends CartEvent {}

class RedoAction extends CartEvent {}
