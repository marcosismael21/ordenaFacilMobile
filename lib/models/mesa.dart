class Mesa {
  final int id;
  final String descripcion;
  final int cupos;
  final bool estado;

  Mesa({
    required this.id,
    required this.descripcion,
    required this.cupos,
    required this.estado,
  });

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: json['id'],
      descripcion: json['descripcion'],
      cupos: json['cupos'],
      estado: json['estado'] == true || json['estado'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'cupos': cupos,
      'estado': estado,
    };
  }
}