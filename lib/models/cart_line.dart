import 'gas_cylinder.dart';

class CartLine {
  const CartLine({required this.cylinder, required this.quantity});

  final GasCylinder cylinder;
  final int quantity;

  double get subtotal => cylinder.price * quantity;

  CartLine copyWith({GasCylinder? cylinder, int? quantity}) {
    return CartLine(
      cylinder: cylinder ?? this.cylinder,
      quantity: quantity ?? this.quantity,
    );
  }
}
