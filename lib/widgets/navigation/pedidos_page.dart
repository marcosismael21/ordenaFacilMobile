import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/pedido.dart';
import '../../models/estado_pedido.dart';
import '../../services/pedido_service.dart';
import '../../services/socket_service.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

import '../home_page.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({Key? key}) : super(key: key);

  @override
  _PedidosPageState createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  final PedidoService _pedidoService = PedidoService();
  final SocketService _socketService = SocketService();
  PedidoResumen? _pedido;
  bool _isLoading = true;
  String? _errorMessage;

  // Estados permitidos para restaurante (sin domicilio)
  final List<int> _estadosRestaurante = [1, 2, 3, 5];

  @override
  void initState() {
    super.initState();
    _cargarUltimoPedido();
    _initializeSocket();
  }

  void _initializeSocket() {
    _socketService.connect();

    // Escuchar cuando se crea un nuevo pedido (desde cualquier origen)
    _socketService.on('nuevoPedido', (data) {
      print('Nuevo pedido recibido: $data');
      _handleNuevoPedido(data);
    });

    // Escuchar actualizaciones de orden
    _socketService.on('actualizacionOrden', (data) {
      print('Actualización de orden recibida: $data');
      _handleActualizacionOrden(data);
    });
  }

  void _handleNuevoPedido(dynamic data) async {
    // Si el nuevo pedido es del cliente actual
    final prefs = await SharedPreferences.getInstance();
    final clienteId = prefs.getInt('cliente_id');

    if (data['data'] != null) {
      final pedidoData = data['data'];

      // Verificar si es un pedido del cliente actual
      if (pedidoData['clienteId'] == clienteId) {
        // Guardar como último pedido
        await prefs.setInt('ultimo_pedido_id', pedidoData['id']);
        await prefs.setString('ultimo_pedido_fecha', DateTime.now().toIso8601String());

        // Recargar el pedido
        _cargarUltimoPedido();
      }
    }
  }

  void _handleActualizacionOrden(dynamic data) {
    print('Manejando actualización de orden: $data');

    if (_pedido != null && data['id'] == _pedido!.id) {
      final nuevoEstado = data['estado'];

      print('Actualizando estado del pedido ${_pedido!.id} a $nuevoEstado');

      if (nuevoEstado == 6) {
        // Pedido finalizado
        setState(() {
          _pedido = null;
        });
        _clearLastPedido();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Tu pedido ha sido finalizado. ¡Gracias por tu preferencia!',
              style: TextStyle(fontSize: 20),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        // Actualizar estado
        setState(() {
          _pedido = PedidoResumen(
            id: _pedido!.id,
            numeroOrden: _pedido!.numeroOrden,
            clienteId: _pedido!.clienteId,
            nombreCliente: _pedido!.nombreCliente,
            dni: _pedido!.dni,
            colaboradorId: _pedido!.colaboradorId,
            tipoPedidoId: _pedido!.tipoPedidoId,
            direccionId: _pedido!.direccionId,
            subtotal: _pedido!.subtotal,
            impuesto: _pedido!.impuesto,
            descuento: _pedido!.descuento,
            total: _pedido!.total,
            estadoId: nuevoEstado,
            fecha: _pedido!.fecha,
            detalles: _pedido!.detalles,
          );
        });

        // Mostrar notificación del cambio de estado
        String mensaje = '';
        switch (nuevoEstado) {
          case 2:
            mensaje = 'Tu pedido está en cocina';
            break;
          case 3:
            mensaje = '¡Tu pedido está listo!';
            break;
          case 5:
            mensaje = '¡Buen provecho!';
            break;
          default:
            mensaje = 'Estado actualizado: ${EstadoPedido.getDescripcionForEstado(nuevoEstado)}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              mensaje,
              style: const TextStyle(fontSize: 20),
            ),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      // Si hay datos completos, opcionalmente recargar
      if (data['pedido'] != null && nuevoEstado != 6) {
        // Opcional: recargar para obtener cualquier cambio adicional
        // _cargarUltimoPedido();
      }
    }
  }

  Future<void> _clearLastPedido() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ultimo_pedido_id');
    await prefs.remove('ultimo_pedido_fecha');
  }

  Future<void> _cargarUltimoPedido() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final ultimoPedidoId = prefs.getInt('ultimo_pedido_id');

      if (ultimoPedidoId != null) {
        final pedido = await _pedidoService.getPedidoDetalle(ultimoPedidoId);

        // Si el pedido existe y NO está finalizado
        if (pedido != null && pedido.estadoId != 6) {
          setState(() {
            _pedido = pedido;
            _isLoading = false;
          });
        } else {
          // Si el pedido está finalizado o no existe, limpiar
          await _clearLastPedido();
          setState(() {
            _pedido = null;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _pedido = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el pedido';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _socketService.off('actualizacionPedido');
    _socketService.off('actualizacionOrden');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Pedido',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: _cargarUltimoPedido,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            const SizedBox(height: 20),
            Text(
              'Cargando pedido...',
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _cargarUltimoPedido,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    if (_pedido == null) {
      return _buildNoPedidoView();
    }

    return RefreshIndicator(
      onRefresh: _cargarUltimoPedido,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del pedido
            _buildPedidoInfo(),
            const SizedBox(height: 20),

            // Estado del pedido
            _buildEstadoPedido(),
            const SizedBox(height: 20),

            // Lista de productos
            _buildSeccionProductos(),
            const SizedBox(height: 20),

            // Resumen de costos
            _buildResumenCostos(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPedidoView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '¡Tu pedido te está esperando!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no has realizado ningún pedido.\nExplora nuestro delicioso menú y ordena tus platillos favoritos.',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.grey600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.restaurant, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Ver Menú',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPedidoInfo() {
    DateTime fechaPedido;
    try {
      fechaPedido = DateTime.parse(_pedido!.fecha);
    } catch (e) {
      fechaPedido = DateTime.now();
    }
    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(fechaPedido);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido #${_pedido!.numeroOrden}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppColors.grey600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            fechaFormateada,
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'L.${_pedido!.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoPedido() {
    final estadoActual = _pedido!.estadoId;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.timeline, color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  const Text(
                    'Estado del Pedido',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Barra de progreso
              _buildProgresoEstados(estadoActual),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgresoEstados(int estadoActual) {
    final estados =
        EstadoPedido.getEstadosPredefinidos()
            .where((estado) => _estadosRestaurante.contains(estado.id))
            .toList();

    return Column(
      children:
          estados.map((estado) {
            bool isActive = estado.id <= estadoActual;
            bool isCurrent = estado.id == estadoActual;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  // Círculo de estado
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isActive
                              ? Color(
                                int.parse(
                                      estado.color.substring(1),
                                      radix: 16,
                                    ) +
                                    0xFF000000,
                              )
                              : AppColors.grey300,
                      border:
                          isCurrent
                              ? Border.all(color: AppColors.primary, width: 3)
                              : null,
                      boxShadow:
                          isCurrent
                              ? [
                                BoxShadow(
                                  color: Color(
                                    int.parse(
                                          estado.color.substring(1),
                                          radix: 16,
                                        ) +
                                        0xFF000000,
                                  ).withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                              : null,
                    ),
                    child:
                        isActive
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                            : Text(
                              '${estado.id}',
                              style: TextStyle(
                                color: AppColors.grey600,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                  ),
                  const SizedBox(width: 20),
                  // Descripción del estado
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isCurrent
                                ? Color(
                                  int.parse(
                                        estado.color.substring(1),
                                        radix: 16,
                                      ) +
                                      0xFF000000,
                                ).withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        estado.descripcion,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.w500,
                          color:
                              isCurrent
                                  ? Color(
                                    int.parse(
                                          estado.color.substring(1),
                                          radix: 16,
                                        ) +
                                        0xFF000000,
                                  )
                                  : isActive
                                  ? AppColors.onBackground
                                  : AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSeccionProductos() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Detalles del Pedido',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ..._pedido!.detalles
                  .map((detalle) => _buildProductoItem(detalle))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductoItem(PedidoDetalle detalle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        children: [
          // Imagen del platillo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  detalle.imageUrl != null
                      ? Image.network(
                        detalle.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.grey300,
                            child: Icon(
                              Icons.restaurant,
                              color: AppColors.grey600,
                              size: 40,
                            ),
                          );
                        },
                      )
                      : Container(
                        color: AppColors.grey300,
                        child: Icon(
                          Icons.restaurant,
                          color: AppColors.grey600,
                          size: 40,
                        ),
                      ),
            ),
          ),
          const SizedBox(width: 16),
          // Información del platillo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detalle.platilloNombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Cantidad: ${detalle.cantidad}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Precio
          Text(
            'L.${detalle.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCostos() {
    final subtotal = _pedido!.detalles.fold(
      0.0,
      (sum, detalle) => sum + detalle.subtotal,
    );
    final descuento = subtotal - _pedido!.total;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.primary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long, color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  const Text(
                    'Resumen',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildCostoRow('Subtotal:', 'L.${subtotal.toStringAsFixed(2)}'),
              if (descuento > 0) ...[
                const SizedBox(height: 12),
                _buildCostoRow(
                  'Descuento:',
                  '-L.${descuento.toStringAsFixed(2)}',
                  isDiscount: true,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(thickness: 2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'L.${_pedido!.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostoRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 20, color: AppColors.grey700)),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDiscount ? AppColors.success : AppColors.onBackground,
          ),
        ),
      ],
    );
  }
}
