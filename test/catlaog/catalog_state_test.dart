
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/src/catalog/bloc/catalog_bloc.dart';
import 'package:pos/src/item_model.dart';

void main() {
  test('CatalogInitial supports equality', () {
    expect(CatalogInitial(), CatalogInitial());
  });

  test('CatalogError supports equality', () {
    expect(const CatalogError('x'), const CatalogError('x'));
  });

  test('CatalogLoaded supports equality', () {
    final item = Item(id: 'p01', name: 'Item', price: 1.0);
    expect(CatalogLoaded([item]), CatalogLoaded([item]));
  });
}
