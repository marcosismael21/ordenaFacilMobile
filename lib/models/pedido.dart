import 'package:flutter/material.dart';
import 'estado_pedido.dart';

class PedidoResumen {
  final int id;
  final String numeroOrden;
  final int clienteId;
  final String nombreCliente;
  final String dni;
  final int colaboradorId;
  final int tipoPedidoId;
  final int? direccionId;
  final double subtotal;
  final double impuesto;
  final double descuento;
  final double total;
  final int estadoId;
  final String fecha;
  final List<PedidoDetalle> detalles;

  PedidoResumen({
    required this.id,
    required this.numeroOrden,
    required this.clienteId,
    required this.nombreCliente,
    required this.dni,
    required this.colaboradorId,
    required this.tipoPedidoId,
    this.direccionId,
    required this.subtotal,
    required this.impuesto,
    required this.descuento,
    required this.total,
    required this.estadoId,
    required this.fecha,
    this.detalles = const [],
  });

  factory PedidoResumen.fromJson(Map<String, dynamic> json) {
    List<PedidoDetalle> detalles = [];
    if (json['detalles'] != null) {
      detalles =
          (json['detalles'] as List)
              .map((detalle) => PedidoDetalle.fromJson(detalle))
              .toList();
    }

    return PedidoResumen(
      id: json['id'],
      numeroOrden: json['numeroOrden'] ?? '',
      clienteId: json['clienteId'],
      nombreCliente: json['nombreCliente'] ?? '',
      dni: json['dni'] ?? '',
      colaboradorId: json['colaboradorId'],
      tipoPedidoId: json['tipoPedidoId'],
      direccionId: json['direccionId'],
      subtotal: double.parse(json['subtotal'].toString()),
      impuesto: double.parse(json['impuesto'].toString()),
      descuento: double.parse(json['descuento'].toString()),
      total: double.parse(json['total'].toString()),
      estadoId: json['estadoId'],
      fecha: json['fecha'] ?? DateTime.now().toIso8601String(),
      detalles: detalles,
    );
  }

  // Obtener color de estado
  Color get estadoColor => EstadoPedido.getColorForEstado(estadoId);

  // Obtener descripción de estado
  String get estadoDescripcion =>
      EstadoPedido.getDescripcionForEstado(estadoId);
}

class PedidoDetalle {
  final int id;
  final String platilloNombre;
  final int cantidad;
  final double precioUnitario;
  final String? imageUrl;

  PedidoDetalle({
    required this.id,
    required this.platilloNombre,
    required this.cantidad,
    required this.precioUnitario,
    this.imageUrl,
  });

  factory PedidoDetalle.fromJson(Map<String, dynamic> json) {
    return PedidoDetalle(
      id: json['id'],
      platilloNombre: json['platilloNombre'] ?? json['nombre'] ?? '',
      cantidad: json['cantidad'] ?? 1,
      precioUnitario: double.parse(
        (json['precioUnitario'] ?? json['precio'] ?? 0).toString(),
      ),
      imageUrl: json['imageUrl'],
    );
  }

  double get subtotal => cantidad * precioUnitario;
}

// Clase para el pedido completo al enviar al servidor
class Pedido {
  int? id;
  int clienteId;
  int colaboradorId;
  int tipoPedidoId;
  int? direccionId;
  int? mesaId;
  double descuentoPedido;
  List<int> platilloIds;
  List<int> cantidadPedidoDetalles;
  List<double> precioUnitarioPedidoDetalles;
  List<int> contExtras;
  List<int> productoIds;
  List<int> cantidadExtras;
  List<double> precioUnitarioExtras;
  int? estadoId;

  Pedido({
    this.id,
    required this.clienteId,
    required this.colaboradorId,
    required this.tipoPedidoId,
    this.direccionId,
    this.mesaId,
    required this.descuentoPedido,
    required this.platilloIds,
    required this.cantidadPedidoDetalles,
    required this.precioUnitarioPedidoDetalles,
    required this.contExtras,
    required this.productoIds,
    required this.cantidadExtras,
    required this.precioUnitarioExtras,
    this.estadoId,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      clienteId: json['clienteId'],
      colaboradorId: json['colaboradorId'],
      tipoPedidoId: json['tipoPedidoId'],
      direccionId: json['direccionId'],
      mesaId: json['mesaId'],
      descuentoPedido: double.parse(json['descuentoPedido'].toString()),
      platilloIds: List<int>.from(json['platilloIds']),
      cantidadPedidoDetalles: List<int>.from(json['cantidadPedidoDetalles']),
      precioUnitarioPedidoDetalles: List<double>.from(
        json['precioUnitarioPedidoDetalles'].map(
          (p) => double.parse(p.toString()),
        ),
      ),
      contExtras: List<int>.from(json['contExtras']),
      productoIds: List<int>.from(json['productoIds'] ?? []),
      cantidadExtras: List<int>.from(json['cantidadExtras'] ?? []),
      precioUnitarioExtras: List<double>.from(
        (json['precioUnitarioExtras'] ?? []).map(
          (p) => double.parse(p.toString()),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clienteId': clienteId,
      'colaboradorId': colaboradorId,
      'tipoPedidoId': tipoPedidoId,
      'direccionId': direccionId,
      'mesaId': mesaId,
      'descuentoPedido': descuentoPedido,
      'platilloIds': platilloIds,
      'cantidadPedidoDetalles': cantidadPedidoDetalles,
      'precioUnitarioPedidoDetalles': precioUnitarioPedidoDetalles,
      'contExtras': contExtras,
      'productoIds': productoIds,
      'cantidadExtras': cantidadExtras,
      'precioUnitarioExtras': precioUnitarioExtras,
      'estadoId': estadoId,
    };
  }
}
