import 'dart:ui';

class EstadoPedido {
  final int id;
  final String descripcion;
  final String color;

  EstadoPedido({
    required this.id,
    required this.descripcion,
    required this.color,
  });

  factory EstadoPedido.fromJson(Map<String, dynamic> json) {
    return EstadoPedido(
      id: json['id'],
      descripcion: json['descripcion'],
      color: json['color'] ?? '#2196F3', // Color azul por defecto
    );
  }

  // Lista de estados predefinidos
  static List<EstadoPedido> getEstadosPredefinidos() {
    return [
      EstadoPedido(id: 1, descripcion: 'Recibida', color: '#FFC107'),
      EstadoPedido(id: 2, descripcion: 'En Cocina', color: '#2196F0'),
      EstadoPedido(id: 3, descripcion: 'Orden Lista', color: '#4CAF50'),
      EstadoPedido(id: 4, descripcion: 'En Camino', color: '#2196F3'),
      EstadoPedido(id: 5, descripcion: 'Buen Provecho', color: '#9C27B0'),
      EstadoPedido(id: 6, descripcion: 'Finalizado', color: '#4CAF50'),
    ];
  }

  // Obtener color en formato hexadecimal para un estado específico
  static Color getColorForEstado(int estadoId) {
    final estados = getEstadosPredefinidos();
    final estado = estados.firstWhere(
      (e) => e.id == estadoId,
      orElse: () => estados[0], // Estado por defecto si no se encuentra
    );
    
    // Convertir hexadecimal a Color
    return Color(int.parse(estado.color.substring(1), radix: 16) + 0xFF000000);
  }

  // Obtener descripción para un ID de estado
  static String getDescripcionForEstado(int estadoId) {
    final estados = getEstadosPredefinidos();
    final estado = estados.firstWhere(
      (e) => e.id == estadoId,
      orElse: () => estados[0], // Estado por defecto si no se encuentra
    );
    
    return estado.descripcion;
  }
}