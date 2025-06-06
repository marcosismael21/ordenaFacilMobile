class TipoPlatillo {
  final int id;
  final String descripcion;
  final bool estado;

  TipoPlatillo({
    required this.id,
    required this.descripcion,
    required this.estado,
  });

  factory TipoPlatillo.fromJson(Map<String, dynamic> json) => TipoPlatillo(
        id: json["id"],
        descripcion: json["descripcion"],
        estado: json["estado"],
      );
}
