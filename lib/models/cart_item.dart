import '../models/platillo.dart';

class CartItem {
  final Platillo platillo;
  int cantidad;
  double precioUnitario;
  int contExtras;
  List<ProductoExtra> extras;

  CartItem({
    required this.platillo,
    this.cantidad = 1,
    required this.precioUnitario,
    this.contExtras = 0,
    this.extras = const [],
  });

  double get subtotal => precioUnitario * cantidad;
}

// Clase para los extras de productos
class ProductoExtra {
  int id;
  String nombre;
  double precio;
  int cantidad;

  ProductoExtra({
    required this.id,
    required this.nombre,
    required this.precio,
    this.cantidad = 1,
  });

  double get subtotal => precio * cantidad;
}