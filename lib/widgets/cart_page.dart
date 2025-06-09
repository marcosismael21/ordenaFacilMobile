import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/pedido_service.dart';
import '../services/auth_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final items = cartService.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito', style: TextStyle(fontSize: 25)),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, size: 40),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text(
                          'Vaciar carrito',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: const Text(
                          '¿Estás seguro de vaciar el carrito?',
                          style: TextStyle(fontSize: 20),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              cartService.clearCart();
                              Navigator.of(ctx).pop();
                            },
                            child: const Text(
                              'Aceptar',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                );
              },
            ),
        ],
      ),
      body:
          items.isEmpty
              ? _buildEmptyCart()
              : Column(
                children: [
                  // Lista de productos del carrito
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder:
                          (ctx, i) => CartItemWidget(cartItem: items[i]),
                    ),
                  ),

                  // Separador
                  const Divider(height: 1, thickness: 1),

                  // Total y botón de pedir
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: L.${cartService.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              () => _mostrarDialogoConfirmarPedido(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            'Realizar Pedido',
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos para comenzar tu pedido',
            style: TextStyle(fontSize: 25, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.blue,
            ),
            child: const Text('Ver Menú', style: TextStyle(fontSize: 25)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoConfirmarPedido(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(
              'Confirmar Pedido',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              '¿Deseas realizar el pedido?',
              style: TextStyle(fontSize: 25),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar', style: TextStyle(fontSize: 25)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _procesarPedido(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Confirmar', style: TextStyle(fontSize: 25)),
              ),
            ],
          ),
    );
  }

  Future<void> _procesarPedido(BuildContext context) async {
    final cartService = Provider.of<CartService>(context, listen: false);
    final authService = AuthService();
    final pedidoService = PedidoService();

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.blue),
                SizedBox(height: 20),
                Text("Procesando pedido...", style: TextStyle(fontSize: 30)),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Crear objeto Pedido a partir del carrito con valores por defecto
      final pedido = cartService.toPedido(
        clienteId: 1, // Consumidor final
        colaboradorId: 8,
        tipoPedidoId: 1, // Restaurante por defecto
        direccionId: null, // Sin dirección
        estadoId: 1,
      );

      // Enviar pedido al servidor
      final success = await pedidoService.crearPedido(pedido);

      // Cerrar diálogo de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        // Vaciar el carrito
        cartService.clearCart();

        // Mostrar mensaje de éxito
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '¡Pedido realizado con éxito!',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navegar a la pantalla de inicio o de pedidos
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      } else {
        // Mostrar mensaje de error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Error al realizar el pedido. Inténtalo de nuevo.',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar diálogo de carga
      if (context.mounted) {
        Navigator.of(context).pop();

        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({Key? key, required this.cartItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  cartItem.platillo.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 30),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 15),
            // Información del platillo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cartItem.platillo.nombre,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'L.${cartItem.precioUnitario.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 25, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Cantidad: ',
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.grey[600],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove, size: 25),
                          onPressed: () {
                            cartService.updateItemQuantity(
                              cartItem.platillo.id!,
                              cartItem.cantidad - 1,
                            );
                          },
                        ),
                        Text(
                          '${cartItem.cantidad}',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 25),
                          onPressed: () {
                            cartService.updateItemQuantity(
                              cartItem.platillo.id!,
                              cartItem.cantidad + 1,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Subtotal y botón de eliminar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'L.${cartItem.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 35),
                  onPressed: () {
                    // Confirmar eliminación
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text(
                              'Eliminar producto',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              '¿Deseas eliminar ${cartItem.platillo.nombre} del carrito?',
                              style: const TextStyle(fontSize: 25),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  cartService.removeItem(cartItem.platillo.id!);
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text(
                                  'Eliminar',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
