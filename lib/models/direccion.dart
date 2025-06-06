class Direccion {
  final int? id;
  final int clienteId;
  String alias;
  String descripcion;
  bool estado;

  Direccion({
    this.id,
    required this.clienteId,
    required this.alias,
    required this.descripcion,
    this.estado = true,
  });

  factory Direccion.fromJson(Map<String, dynamic> json) {
    return Direccion(
      id: json['id'],
      clienteId: json['clienteId'],
      alias: json['alias'] ?? '',
      descripcion: json['descripcion'] ?? '',
      estado: json['estado'] == true || json['estado'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'clienteId': clienteId,
      'alias': alias,
      'descripcion': descripcion,
      'estado': estado,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }
}
