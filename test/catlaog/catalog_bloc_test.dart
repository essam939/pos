import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:pos/src/catalog/bloc/catalog_bloc.dart';

class FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '[{"id":"p01","name":"Test Item","price":1.5}]';
  }

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError();
  }
}
class FailingAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) {
    throw Exception('load failed');
  }

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CatalogBloc', () {
    blocTest<CatalogBloc, CatalogState>(
      'emits CatalogLoaded when LoadCatalog is added',
      build: () => CatalogBloc(bundle: FakeAssetBundle()),
      act: (bloc) => bloc.add(LoadCatalog()),
      expect: () => [
        isA<CatalogLoaded>()
            .having((s) => s.items.length, 'item count', 1)
            .having((s) => s.items.first.name, 'item name', 'Test Item')
            .having((s) => s.items.first.price, 'item price', 1.5),
      ],
    );
    blocTest<CatalogBloc, CatalogState>(
      'emits CatalogError when loading fails',
      build: () => CatalogBloc(bundle: FailingAssetBundle()),
      act: (bloc) => bloc.add(LoadCatalog()),
      expect: () => [
        isA<CatalogError>().having((e) => e.message, 'error message', 'Failed to load catalog'),
      ],
    );

  });
}
