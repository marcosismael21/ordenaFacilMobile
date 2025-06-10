import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/cliente.dart';
import 'auth_service.dart';

class ClienteService {
  final String _baseUrl = 'http://10.0.2.2:3004/api-mobile/cliente';
  final AuthService _authService = AuthService();

  // Obtener información del cliente actual
  Future<Cliente?> getClienteInfo() async {
    try {
      final token = await _authService.getToken();
      final clienteId = await _authService.getUserId();

      if (clienteId == null) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/$clienteId'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          // Asumiendo que la API devuelve un objeto cliente en 'data'
          return Cliente.fromJson(responseData['data']);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error al obtener información del cliente: $e');
      return null;
    }
  }

  Future<Cliente?> getClienteByDni(String dni) async {
    try {
      if (dni == null) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/dni/$dni'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          return Cliente.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener información del cliente: $e');
      return null;
    }
  }

  Future<bool> createCliente(Cliente cliente) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/caja'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
        },
        body: json.encode(cliente.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('Error al actualizar información del cliente: $e');
      return false;
    }
  }

  // Actualizar información del cliente
  Future<bool> updateClienteInfo(Cliente cliente) async {
    try {
      final token = await _authService.getToken();

      if (cliente.id == null) {
        return false;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/infocliente/${cliente.id}'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
        },
        body: json.encode(cliente.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('Error al actualizar información del cliente: $e');
      return false;
    }
  }

  // Cambiar contraseña
  Future<bool> changePassword(
    int clienteId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final token = await _authService.getToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
        },
        body: json.encode({
          'clienteId': clienteId,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('Error al cambiar contraseña: $e');
      return false;
    }
  }
}
