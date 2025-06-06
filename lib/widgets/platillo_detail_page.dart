import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/platillo.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class PlatilloDetailPage extends StatefulWidget {
  final Platillo platillo;

  const PlatilloDetailPage({Key? key, required this.platillo})
    : super(key: key);

  @override
  _PlatilloDetailPageState createState() => _PlatilloDetailPageState();
}

class _PlatilloDetailPageState extends State<PlatilloDetailPage> {
  int _cantidad = 1;
  List<ProductoExtra> _extrasSeleccionados = [];

  void _incrementCantidad() {
    setState(() {
      _cantidad++;
    });
  }

  void _decrementCantidad() {
    if (_cantidad > 1) {
      setState(() {
        _cantidad--;
      });
    }
  }

  void _agregarAlCarrito() {
    // Usar esto para evitar problemas si el widget se desmonta
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Obtener el servicio del carrito
    final cartService = Provider.of<CartService>(context, listen: false);

    // Agregar al carrito
    cartService.addItem(widget.platillo, cantidad: _cantidad);

    // Mostrar confirmación solo si el widget sigue montado
    if (mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${widget.platillo.nombre} agregado al carrito'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Ver Carrito',
            onPressed: () {
              if (mounted) {
                navigator.pushNamed('/cart');
              }
            },
          ),
        ),
      );

      // Volver a la página anterior
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.platillo.nombre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del platillo
            Container(
              height: 250,
              width: double.infinity,
              child: Image.network(
                widget.platillo.imageUrl,
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
                    child: const Center(child: Icon(Icons.error, size: 50)),
                  );
                },
              ),
            ),

            // Información del platillo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.platillo.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.platillo.tipoPlatillo,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.platillo.descripcion,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'L.${widget.platillo.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Cantidad',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Control de cantidad
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _decrementCantidad,
                        color: Colors.blue,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$_cantidad',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _incrementCantidad,
                        color: Colors.blue,
                      ),
                    ],
                  ),

                  // Puedes agregar aquí una sección para los extras si son necesarios
                  const SizedBox(height: 32),

                  // Botón para agregar al carrito
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agregarAlCarrito,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Agregar al Carrito',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
