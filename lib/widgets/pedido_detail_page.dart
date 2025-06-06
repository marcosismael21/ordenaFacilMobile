import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../models/estado_pedido.dart';
import 'package:intl/intl.dart';

class PedidoDetailPage extends StatelessWidget {
  final PedidoResumen pedido;

  const PedidoDetailPage({Key? key, required this.pedido}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${pedido.numeroOrden}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del pedido
            _buildPedidoInfo(),

            const SizedBox(height: 24),

            // Estado del pedido
            _buildEstadoPedido(),

            const SizedBox(height: 24),

            // Título de detalles
            const Text(
              'Detalles del Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Lista de productos
            _buildProductosList(),

            const SizedBox(height: 24),

            // Resumen de costos
            _buildResumenCostos(),
          ],
        ),
      ),
    );
  }

  Widget _buildPedidoInfo() {
    // Formatear la fecha
    DateTime fechaPedido;
    try {
      fechaPedido = DateTime.parse(pedido.fecha);
    } catch (e) {
      fechaPedido = DateTime.now();
    }
    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(fechaPedido);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${pedido.numeroOrden}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'L.${pedido.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha: $fechaFormateada',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoPedido() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado del Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Barra de progreso personalizada
            Row(
              children: EstadoPedido.getEstadosPredefinidos().map((estado) {
                bool isActive = estado.id <= pedido.estadoId;
                bool isCurrent = estado.id == pedido.estadoId;
                
                return Expanded(
                  child: Column(
                    children: [
                      // Círculo de estado
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive 
                              ? Color(int.parse(estado.color.substring(1), radix: 16) + 0xFF000000)
                              : Colors.grey[300],
                          border: isCurrent
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                        child: isActive
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      // Etiqueta de estado
                      Text(
                        estado.descripcion,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? Colors.black : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductosList() {
    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: pedido.detalles.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final detalle = pedido.detalles[index];
          return ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: detalle.imageUrl != null
                ? Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(detalle.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.grey),
                  ),
            title: Text(
              detalle.platilloNombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Cantidad: ${detalle.cantidad}'),
            trailing: Text(
              'L.${detalle.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResumenCostos() {
    // Calcular subtotal
    final subtotal = pedido.detalles.fold(
        0.0, (sum, detalle) => sum + detalle.subtotal);
    
    // Descuento es la diferencia entre el subtotal y el total
    final descuento = subtotal - pedido.total;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text('L.${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            if (descuento > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Descuento:'),
                  Text(
                    '-L.${descuento.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'L.${pedido.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}