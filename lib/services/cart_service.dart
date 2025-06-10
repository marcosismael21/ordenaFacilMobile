import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pedido.dart';
import '../models/platillo.dart';
import '../models/cart_item.dart';

class CartService extends ChangeNotifier {
  List<CartItem> _items = [];
 
  List<CartItem> get items => [..._items];
 
  int get itemCount => _items.length;
 
  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart');
      if (cartData != null) {
        // Implementar la lógica para cargar el carrito desde SharedPreferences
        // Esto puede requerir almacenar los platillos completos o sus IDs
        // y luego obtenerlos de nuevo de la API al cargar
        notifyListeners();
      }
    } catch (e) {
      print('Error al cargar carrito: $e');
    }
  }




  void addItem(Platillo platillo, {int cantidad = 1}) {
    final existingIndex = _items.indexWhere((item) => item.platillo.id == platillo.id);
   
    if (existingIndex >= 0) {
      // El producto ya está en el carrito, actualizar cantidad
      _items[existingIndex].cantidad += cantidad;
    } else {
      // Agregar nuevo producto al carrito
      _items.add(
        CartItem(
          platillo: platillo,
          cantidad: cantidad,
          precioUnitario: platillo.precio,
        ),
      );
    }
   
    notifyListeners();
  }

  void removeItem(int platilloId) {
    _items.removeWhere((item) => item.platillo.id == platilloId);
    notifyListeners();
  }

  void updateItemQuantity(int platilloId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(platilloId);
      return;
    }
   
    final existingIndex = _items.indexWhere((item) => item.platillo.id == platilloId);
    if (existingIndex >= 0) {
      _items[existingIndex].cantidad = newQuantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items = [];
    notifyListeners();
  }

  // Método para convertir el carrito en un objeto Pedido
  Pedido toPedido({
    int? clienteId,
    int? colaboradorId,
    int? mesaId,
    int? tipoPedidoId,
    int? direccionId,
    double descuentoPedido = 0.0,
    int estadoId = 1,
  }) {
    // Extraer listas de datos del carrito
    final platilloIds = _items.map((item) => item.platillo.id!).toList();
    final cantidades = _items.map((item) => item.cantidad).toList();
    final precios = _items.map((item) => item.precioUnitario).toList();
    final contExtras = _items.map((item) => item.contExtras).toList();
   
    // Listas para los extras (pueden estar vacías si no hay extras)
    final List<int> productoIds = [];
    final List<int> cantidadExtras = [];
    final List<double> precioUnitarioExtras = [];
   
    // Poblar las listas de extras
    for (var item in _items) {
      for (var extra in item.extras) {
        productoIds.add(extra.id);
        cantidadExtras.add(extra.cantidad);
        precioUnitarioExtras.add(extra.precio);
      }
    }
   
    return Pedido(
      clienteId: clienteId!,
      colaboradorId: colaboradorId!,
      tipoPedidoId: tipoPedidoId!,
      direccionId: direccionId,
      mesaId: mesaId,
      descuentoPedido: descuentoPedido,
      platilloIds: platilloIds,
      cantidadPedidoDetalles: cantidades,
      precioUnitarioPedidoDetalles: precios,
      contExtras: contExtras,
      productoIds: productoIds,
      cantidadExtras: cantidadExtras,
      precioUnitarioExtras: precioUnitarioExtras,
      estadoId: estadoId,
    );
  }
}