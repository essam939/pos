import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pos/src/item_model.dart';
import '../cart_line.dart';

part 'cart_event.dart';
part 'cart_state.dart';

/// BLoC that manages cart actions, totals calculation, undo/redo, and state persistence via hydrated_bloc.
class CartBloc extends HydratedBloc<CartEvent, CartState> {
  CartBloc() : super(const CartState(lines: [], totals: CartTotals(subtotal: 0, vat: 0, grandTotal: 0))) {
    on<AddItem>(_wrapWithUndo(_onAddItem));
    on<RemoveItem>(_wrapWithUndo(_onRemoveItem));
    on<ChangeQty>(_wrapWithUndo(_onChangeQty));
    on<ChangeDiscount>(_wrapWithUndo(_onChangeDiscount));
    on<ClearCart>(_wrapWithUndo(_onClearCart));
    on<UndoAction>(_onUndo);
    on<RedoAction>(_onRedo);
  }

  final List<CartState> _undoStack = [];
  final List<CartState> _redoStack = [];

  void Function(E, Emitter<CartState>) _wrapWithUndo<E extends CartEvent>(
      void Function(E, Emitter<CartState>) handler,
      ) {
    return (event, emit) {
      _undoStack.add(state);
      _redoStack.clear();
      handler(event, emit);
    };
  }

  void _onAddItem(AddItem event, Emitter<CartState> emit) {
    final existingIndex = state.lines.indexWhere((line) => line.item.id == event.item.id);
    List<CartLine> updatedLines = List.from(state.lines);

    if (existingIndex == -1) {
      updatedLines.add(CartLine(item: event.item, quantity: 1, discount: 0.0));
    } else {
      final updatedLine = updatedLines[existingIndex].copyWith(
        quantity: updatedLines[existingIndex].quantity + 1,
      );
      updatedLines[existingIndex] = updatedLine;
    }

    emit(CartState(lines: updatedLines, totals: _calculateTotals(updatedLines)));
  }

  void _onRemoveItem(RemoveItem event, Emitter<CartState> emit) {
    final updatedLines = state.lines.where((line) => line.item.id != event.itemId).toList();
    emit(CartState(lines: updatedLines, totals: _calculateTotals(updatedLines)));
  }

  void _onChangeQty(ChangeQty event, Emitter<CartState> emit) {
    final updatedLines = state.lines.map((line) {
      if (line.item.id == event.itemId) {
        return line.copyWith(quantity: event.quantity);
      }
      return line;
    }).toList();

    emit(CartState(lines: updatedLines, totals: _calculateTotals(updatedLines)));
  }

  void _onChangeDiscount(ChangeDiscount event, Emitter<CartState> emit) {
    final updatedLines = state.lines.map((line) {
      if (line.item.id == event.itemId) {
        return line.copyWith(discount: event.discount);
      }
      return line;
    }).toList();

    emit(CartState(lines: updatedLines, totals: _calculateTotals(updatedLines)));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState(lines: [], totals: CartTotals(subtotal: 0, vat: 0, grandTotal: 0)));
  }

  void _onUndo(UndoAction event, Emitter<CartState> emit) {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(state);
      emit(_undoStack.removeLast());
    }
  }

  void _onRedo(RedoAction event, Emitter<CartState> emit) {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(state);
      emit(_redoStack.removeLast());
    }
  }

  CartTotals _calculateTotals(List<CartLine> lines) {
    final subtotal = lines.fold(0.0, (sum, line) => sum + line.lineNet);
    final vat = subtotal * 0.15;
    final grandTotal = subtotal + vat;

    return CartTotals(
      subtotal: double.parse(subtotal.toStringAsFixed(2)),
      vat: double.parse(vat.toStringAsFixed(2)),
      grandTotal: double.parse(grandTotal.toStringAsFixed(2)),
    );
  }

  @override
  CartState? fromJson(Map<String, dynamic> json) {
    try {
      final lines = (json['lines'] as List).map((e) {
        final item = Item(
          id: e['itemId'],
          name: e['name'],
          price: (e['price'] as num).toDouble(),
        );
        return CartLine(
          item: item,
          quantity: e['quantity'],
          discount: (e['discount'] as num).toDouble(),
        );
      }).toList();

      return CartState(
        lines: lines,
        totals: CartTotals(
          subtotal: (json['subtotal'] as num).toDouble(),
          vat: (json['vat'] as num).toDouble(),
          grandTotal: (json['grandTotal'] as num).toDouble(),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(CartState state) {
    return {
      'lines': state.lines.map((line) => {
        'itemId': line.item.id,
        'name': line.item.name,
        'price': line.item.price,
        'quantity': line.quantity,
        'discount': line.discount,
      }).toList(),
      'subtotal': state.totals.subtotal,
      'vat': state.totals.vat,
      'grandTotal': state.totals.grandTotal,
    };
  }
}
