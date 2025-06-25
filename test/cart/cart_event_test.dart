import 'package:flutter_test/flutter_test.dart';
import 'package:pos/src/cart/bloc/cart_bloc.dart';
import 'package:pos/src/item_model.dart';

void main() {
  group('CartEvent', () {
    final item = Item(id: '1', name: 'Test Item', price: 5.0);

    test('AddItem event supports value equality', () {
      expect(AddItem(item), AddItem(item));
    });

    test('RemoveItem event supports value equality', () {
      expect(RemoveItem('1'), RemoveItem('1'));
    });

    test('ChangeQty event supports value equality', () {
      expect(ChangeQty('1', 2), ChangeQty('1', 2));
    });

    test('ChangeDiscount event supports value equality', () {
      expect(ChangeDiscount('1', 0.1), ChangeDiscount('1', 0.1));
    });

    test('ClearCart event supports value equality', () {
      expect( ClearCart(),  ClearCart());
    });

    test('UndoAction event supports value equality', () {
      expect( UndoAction(),  UndoAction());
    });

    test('RedoAction event supports value equality', () {
      expect( RedoAction(),  RedoAction());
    });
  });
}
