import 'package:equatable/equatable.dart';

/// Represents a single product item in the catalog.
class Item extends Equatable {
  final String id;
  final String name;
  final double price;

  const Item({required this.id, required this.name, required this.price});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'],
    name: json['name'],
    price: (json['price'] as num).toDouble(),
  );

  @override
  List<Object> get props => [id, name, price];
}
