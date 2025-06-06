class Cliente {
  final int? id;
  String nombres;
  String correo;
  String telefono;
  String dni;
  String usuario;
  String? clave;
  String? fechaVerificacionC;
  bool estado;

  Cliente({
    this.id,
    required this.nombres,
    required this.correo,
    required this.telefono,
    required this.dni,
    required this.usuario,
    this.clave,
    this.fechaVerificacionC,
    this.estado = true,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombres: json['nombres'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      dni: json['dni'] ?? '',
      usuario: json['usuario'] ?? '',
      fechaVerificacionC: json['fechaVerificacionC'],
      estado: json['estado'] == true || json['estado'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nombres': nombres,
      'correo': correo,
      'telefono': telefono,
      'dni': dni,
      'usuario': usuario,
      'estado': estado,
    };

    if (id != null) {
      data['id'] = id;
    }

    if (clave != null && clave!.isNotEmpty) {
      data['clave'] = clave;
    }

    return data;
  }
}
