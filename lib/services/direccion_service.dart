import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/direccion.dart';
import 'auth_service.dart';

class DireccionService {
  final String _baseUrl = 'http://10.0.2.2:3004/api-mobile/direccion';
  final AuthService _authService = AuthService();

  // Obtener todas las direcciones de un cliente
  Future<List<Direccion>> getDireccionesByCliente() async {
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
              .map((item) => Direccion.fromJson(item))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      debugPrint('Error al obtener direcciones: $e');
      return [];
    }
  }

  // Crear una nueva dirección
  Future<bool> crearDireccion(Direccion direccion) async {
    try {
      final token = await _authService.getToken();

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
          
        },
        body: json.encode(direccion.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error al crear dirección: $e');
      return false;
    }
  }

  // Actualizar una dirección existente
  Future<bool> actualizarDireccion(Direccion direccion) async {
    try {
      final token = await _authService.getToken();
      
      if (direccion.id == null) {
        return false;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/${direccion.id}'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
          
        },
        body: json.encode(direccion.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error al actualizar dirección: $e');
      return false;
    }
  }

  // Eliminar una dirección
  Future<bool> eliminarDireccion(int direccionId) async {
    try {
      final token = await _authService.getToken();

      final response = await http.delete(
        Uri.parse('$_baseUrl/$direccionId'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
          
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error al eliminar dirección: $e');
      return false;
    }
  }
}