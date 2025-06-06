import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tipo_platillo.dart';
import 'auth_service.dart';

class TipoPlatilloService {
  final String _baseUrl = 'http://10.0.2.2:3004/api-mobile/tipoPlatillo';
  final AuthService _authService = AuthService();

  Future<List<TipoPlatillo>> getAllTipoPlatillo() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/activate"),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          return (responseData['data'] as List)
              .map((item) => TipoPlatillo.fromJson(item))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Error al obtener los datos: $e');
      throw Exception('Error al obtener los datos del servidor.');
    }
  }
}
