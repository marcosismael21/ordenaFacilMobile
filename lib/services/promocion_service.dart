import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/promocion.dart';
import 'auth_service.dart';

class PromocionService {
  final String _baseUrl = 'http://10.0.2.2:3004/api-mobile/promocion';
  final AuthService _authService = AuthService();

  Future<List<Promocion>> getAllPromociones() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
          
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          return (responseData['data'] as List)
              .map((item) => Promocion.fromJson(item))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error al obtener promociones: $e');
      return [];
    }
  }
}
