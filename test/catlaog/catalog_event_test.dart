import 'package:flutter_test/flutter_test.dart';
import 'package:pos/src/catalog/bloc/catalog_bloc.dart';

void main() {
  test('LoadCatalog supports equality', () {
    expect(LoadCatalog(), LoadCatalog());
  });
}
