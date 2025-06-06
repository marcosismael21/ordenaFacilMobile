import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedido.dart';
import 'auth_service.dart';

class PedidoService {
  final String _baseUrl = 'http://10.0.2.2:3004/api-mobile/pedido';
  final AuthService _authService = AuthService();

  Future<bool> crearPedido(Pedido pedido) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
          
        },
        body: json.encode(pedido.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error al crear pedido: $e');
      return false;
    }
  }

  Future<List<PedidoResumen>> getPedidosByCliente() async {
    try {
      final token = await _authService.getToken();
      final clienteId = await _authService.getUserId();

      if (clienteId == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/cliente/$clienteId'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
          
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          return (responseData['data'] as List)
              .map((item) => PedidoResumen.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error al obtener pedidos: $e');
      return [];
    }
  }

  // Obtener detalles de un pedido específico
  Future<PedidoResumen?> getPedidoDetalle(int pedidoId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/$pedidoId'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
          
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          return PedidoResumen.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener detalle del pedido: $e');
      return null;
    }
  }
}
