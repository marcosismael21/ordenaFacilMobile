import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tipo_pedido.dart';
import 'auth_service.dart';

class TipoPedidoService {
  final String _baseUrl = 'http://10.0.2.2:3004/api-mobile/tipoPedido';
  final AuthService _authService = AuthService();

  Future<List<TipoPedido>> getAllTiposPedido() async {
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
              .map((item) => TipoPedido.fromJson(item))
              .where((tipoPedido) => tipoPedido.estado) // Solo tipos activos
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error al obtener tipos de pedido: $e');
      return [];
    }
  }

  Future<TipoPedido?> getTipoPedidoById(int id) async {
    try {
      final token = await _authService.getToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
          
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          return TipoPedido.fromJson(responseData['data']);
        }
      }
      
      return null;
    } catch (e) {
      print('Error al obtener tipo de pedido por ID: $e');
      return null;
    }
  }
}