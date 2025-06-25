import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:equatable/equatable.dart';
import 'package:pos/src/item_model.dart';
import 'package:pos/src/util/constants.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

/// Loads the product catalog from a JSON asset.
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final AssetBundle bundle;

  CatalogBloc({AssetBundle? bundle})
      : bundle = bundle ?? rootBundle, super(CatalogInitial()) {
    on<LoadCatalog>(_onLoadCatalog);
  }

  /// Fired to load the product catalog.
  Future<void> _onLoadCatalog(
      LoadCatalog event, Emitter<CatalogState> emit) async {
    try {
      final jsonString = await bundle.loadString(AppConstants.catalogFile);
      final List<dynamic> decoded = json.decode(jsonString);
      final items = decoded.map((e) => Item.fromJson(e)).toList();
      emit(CatalogLoaded(items));
    } catch (e) {
      emit(CatalogError('Failed to load catalog'));
    }
  }
}
