class Platillo {
  int? id;
  String nombre;
  String imageUrl;
  String descripcion;
  double precio;
  int tipoPlatilloId;
  String tipoPlatillo;
  bool estado;

  Platillo({
    this.id,
    required this.nombre,
    required this.imageUrl,
    required this.descripcion,
    required this.precio,
    required this.tipoPlatilloId,
    required this.tipoPlatillo,
    required this.estado,
  });

  factory Platillo.fromJson(Map<String, dynamic> json) => Platillo(
    id: json["id"],
    nombre: json["nombre"],
    imageUrl: json["imageUrl"],
    descripcion: json["descripcion"],
    precio: double.parse(json["precio"]),
    tipoPlatilloId: json["tipoPlatilloId"],
    tipoPlatillo: json["tipoPlatillo"],
    // El estado viene como int en el JSON, necesitamos convertirlo a bool
    estado: json["estado"] == 1,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "imageUrl": imageUrl,
    "descripcion": descripcion,
    "precio": precio,
    "tipoPlatilloId": tipoPlatilloId,
    "tipoPlatillo": tipoPlatillo,
    "estado": estado,
  };
}
