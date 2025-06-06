class TipoPedido {
  final int id;
  final String descripcion;
  final bool estado;

  TipoPedido({
    required this.id,
    required this.descripcion,
    required this.estado,
  });

  factory TipoPedido.fromJson(Map<String, dynamic> json) {
    return TipoPedido(
      id: json['id'],
      descripcion: json['descripcion'],
      estado: json['estado'] == true || json['estado'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'estado': estado,
    };
  }
}