import 'package:flutter/material.dart';

import '../core/row_reader.dart';

class GasCylinder {
  const GasCylinder({
    required this.id,
    required this.name,
    required this.sizeKg,
    required this.price,
    required this.stock,
    required this.colorHex,
    required this.description,
    required this.active,
    this.imageUrl,
    this.createdAt,
  });

  final String id;
  final String name;
  final int sizeKg;
  final double price;
  final int stock;
  final String colorHex;
  final String description;
  final bool active;
  final String? imageUrl;
  final DateTime? createdAt;

  Color get color => _colorFromHex(colorHex);

  factory GasCylinder.fromRow(Map<String, dynamic> row) {
    return GasCylinder(
      id: RowReader.text(row, ['cylinder_id', 'id']),
      name: RowReader.text(row, ['cylinder_name', 'name']),
      sizeKg: RowReader.integer(row, ['size_kg', 'kg', 'size']),
      price: RowReader.decimal(row, ['cylinder_price', 'price']),
      stock: RowReader.integer(row, ['stock', 'quantity_available']),
      colorHex: RowReader.text(
        row,
        ['color_hex', 'color'],
        fallback: '#ff4b14',
      ),
      description: RowReader.text(
        row,
        ['cylinder_description', 'description'],
        fallback: 'Gas cylinder for home and business delivery.',
      ),
      active: RowReader.boolean(row, ['is_active', 'active'], fallback: true),
      imageUrl: RowReader.text(row, ['image_url', 'image', 'photo_url'], fallback: ''),
      createdAt: RowReader.date(row, ['created_at', 'created']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'size_kg': sizeKg,
      'price': price,
      'stock': stock,
      'color_hex': colorHex,
      'description': description,
      'is_active': active ? 1 : 0,
      'image_url': imageUrl,
    };
  }

  GasCylinder copyWith({
    String? id,
    String? name,
    int? sizeKg,
    double? price,
    int? stock,
    String? colorHex,
    String? description,
    bool? active,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return GasCylinder(
      id: id ?? this.id,
      name: name ?? this.name,
      sizeKg: sizeKg ?? this.sizeKg,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      colorHex: colorHex ?? this.colorHex,
      description: description ?? this.description,
      active: active ?? this.active,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static Color _colorFromHex(String value) {
    final cleaned = value.replaceAll('#', '').trim();
    final hex = cleaned.length == 6 ? 'ff$cleaned' : cleaned;
    return Color(int.tryParse(hex, radix: 16) ?? 0xffff4b14);
  }
}
