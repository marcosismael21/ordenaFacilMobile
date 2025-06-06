class Promocion {
  final int id;
  final String urlImage;
  final String descripcion;
  final int platilloId;
  final DateTime fechaInicio;
  final DateTime fechaFinal;
  final bool estado;

  Promocion({
    required this.id,
    required this.urlImage,
    required this.descripcion,
    required this.platilloId,
    required this.fechaInicio,
    required this.fechaFinal,
    required this.estado,
  });

  factory Promocion.fromJson(Map<String, dynamic> json) => Promocion(
        id: json["id"],
        urlImage: json["urlImage"],
        descripcion: json["descripcion"],
        platilloId: json["platilloId"],
        fechaInicio: DateTime.parse(json["fechaInicio"]),
        fechaFinal: DateTime.parse(json["fechaFinal"]),
        estado: json["estado"],
      );
}
