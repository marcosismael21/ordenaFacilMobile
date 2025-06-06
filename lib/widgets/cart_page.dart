import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../models/cart_item.dart';
import '../models/tipo_pedido.dart';
import '../models/direccion.dart';
import '../services/cart_service.dart';
import '../services/pedido_service.dart';
import '../services/auth_service.dart';
import '../services/tipo_pedido_service.dart';
import '../services/direccion_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TipoPedidoService _tipoPedidoService = TipoPedidoService();
  final DireccionService _direccionService = DireccionService();
  List<TipoPedido> _tiposPedido = [];
  List<Direccion> _direcciones = [];
  TipoPedido? _selectedTipoPedido;
  Direccion? _selectedDireccion;
  bool _isLoading = true;
  bool _loadingDirecciones = false;

  @override
  void initState() {
    super.initState();
    _loadTiposPedido();
  }

  Future<void> _loadTiposPedido() async {
    try {
      final tiposPedido = await _tipoPedidoService.getAllTiposPedido();
      setState(() {
        _tiposPedido = tiposPedido;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar tipos de pedido: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDirecciones() async {
    if (_selectedTipoPedido?.descripcion == 'A Domicilio') {
      setState(() {
        _loadingDirecciones = true;
      });

      try {
        final direcciones = await _direccionService.getDireccionesByCliente();
        setState(() {
          _direcciones = direcciones;
          _selectedDireccion = direcciones.isNotEmpty ? direcciones[0] : null;
          _loadingDirecciones = false;
        });
      } catch (e) {
        print('Error al cargar direcciones: $e');
        setState(() {
          _loadingDirecciones = false;
        });
      }
    } else {
      setState(() {
        _selectedDireccion = null;
      });
    }
  }

  // Función para obtener el icono según el tipo de pedido
  IconData _getIconForTipoPedido(String descripcion) {
    switch (descripcion) {
      case 'Restaurante':
        return Icons.restaurant;
      case 'Para Llevar':
        return Icons.takeout_dining;
      case 'A Domicilio':
        return Icons.delivery_dining;
      case 'AutoServicio':
        return Icons.drive_eta;
      default:
        return Icons.room_service;
    }
  }

  // Función para obtener el color según el tipo de pedido
  Color _getColorForTipoPedido(String descripcion) {
    switch (descripcion) {
      case 'Restaurante':
        return Colors.blue;
      case 'Para Llevar':
        return Colors.orange;
      case 'A Domicilio':
        return Colors.green;
      case 'AutoServicio':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final items = cartService.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Vaciar carrito'),
                        content: const Text(
                          '¿Estás seguro de vaciar el carrito?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              cartService.clearCart();
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                );
              },
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
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

                  // Selector de tipo de pedido con tarjetas
                  if (_tiposPedido.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selecciona el tipo de pedido:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _tiposPedido.length,
                              itemBuilder: (context, index) {
                                final tipoPedido = _tiposPedido[index];
                                final isSelected =
                                    _selectedTipoPedido == tipoPedido;
                                final color = _getColorForTipoPedido(
                                  tipoPedido.descripcion,
                                );

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTipoPedido = tipoPedido;
                                    });
                                    _loadDirecciones();
                                  },
                                  child: Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? color.withOpacity(0.2)
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? color
                                                : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow:
                                          isSelected
                                              ? [
                                                BoxShadow(
                                                  color: color.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                              : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _getIconForTipoPedido(
                                            tipoPedido.descripcion,
                                          ),
                                          color: color,
                                          size: 36,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          tipoPedido.descripcion,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? color
                                                    : Colors.black87,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Selector de dirección (solo para pedidos a domicilio)
                  if (_selectedTipoPedido?.descripcion == 'A Domicilio')
                    _loadingDirecciones
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                        : _direcciones.isEmpty
                        ? _buildNoDireccionesAviso()
                        : _buildDireccionSelector(),

                  // Total y botón de pedir
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: L.${cartService.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              _canPlaceOrder()
                                  ? () =>
                                      _mostrarDialogoConfirmarPedido(context)
                                  : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            backgroundColor:
                                _canPlaceOrder()
                                    ? _getColorForTipoPedido(
                                      _selectedTipoPedido?.descripcion ?? '',
                                    )
                                    : Colors.grey,
                          ),
                          child: const Text(
                            'Realizar Pedido',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  bool _canPlaceOrder() {
    if (_selectedTipoPedido == null) return false;
    if (_selectedTipoPedido?.descripcion == 'A Domicilio' &&
        _selectedDireccion == null)
      return false;
    return true;
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos para comenzar tu pedido',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
            child: const Text('Ver Menú', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDireccionesAviso() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.amber.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber.shade800,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'No tienes direcciones guardadas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Para pedidos a domicilio, necesitas agregar al menos una dirección de entrega.',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // Navegar a la página de direcciones
                  Navigator.pushNamed(context, '/perfil/direcciones').then((_) {
                    // Recargar direcciones cuando regrese
                    _loadDirecciones();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade800,
                ),
                child: const Text('Agregar Dirección'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDireccionSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona una dirección de entrega:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Direccion>(
                isExpanded: true,
                value: _selectedDireccion,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                onChanged: (Direccion? newValue) {
                  setState(() {
                    _selectedDireccion = newValue;
                  });
                },
                items:
                    _direcciones.map<DropdownMenuItem<Direccion>>((
                      Direccion direccion,
                    ) {
                      return DropdownMenuItem<Direccion>(
                        value: direccion,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    direccion.alias,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    direccion.descripcion,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/perfil/direcciones').then((_) {
                _loadDirecciones();
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar otra dirección'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: Colors.blue,
              textStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoConfirmarPedido(BuildContext context) {
    String mensaje =
        '¿Deseas realizar el pedido como ${_selectedTipoPedido?.descripcion}?';

    if (_selectedTipoPedido?.descripcion == 'A Domicilio' &&
        _selectedDireccion != null) {
      mensaje +=
          '\n\nSe entregará en: ${_selectedDireccion!.alias}\n${_selectedDireccion!.descripcion}';
    }

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirmar Pedido'),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _procesarPedido(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getColorForTipoPedido(
                    _selectedTipoPedido?.descripcion ?? '',
                  ),
                ),
                child: const Text('Confirmar'),
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
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: _getColorForTipoPedido(
                    _selectedTipoPedido?.descripcion ?? '',
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Procesando pedido..."),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Obtener el ID del cliente actual
      final clienteId = await authService.getUserId();

      // Crear objeto Pedido a partir del carrito
      final pedido = cartService.toPedido(
        clienteId: clienteId ?? 1,
        colaboradorId: 8,
        tipoPedidoId: _selectedTipoPedido?.id ?? 1,
        direccionId:
            _selectedTipoPedido?.descripcion == 'A Domicilio'
                ? _selectedDireccion?.id
                : null,
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
              content: Text('¡Pedido realizado con éxito!'),
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
              content: Text('Error al realizar el pedido. Inténtalo de nuevo.'),
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
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Imagen del platillo
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 10),
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
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
            ),

            // Información del platillo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.platillo.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'L.${cartItem.precioUnitario.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Cantidad: ',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
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

            // Subtotal y botón de eliminar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'L.${cartItem.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Confirmar eliminación
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text('Eliminar producto'),
                            content: Text(
                              '¿Deseas eliminar ${cartItem.platillo.nombre} del carrito?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  cartService.removeItem(cartItem.platillo.id!);
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text('Eliminar'),
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
