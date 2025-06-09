import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = 'http://10.0.2.2:3004/api-mobile/colaborador';

  // Método para iniciar sesión
  Future<Map<String, dynamic>> login(String usuario, String clave) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'tu_api_key_para_mobile',
        },
        body: json.encode({'usuario': usuario, 'clave': clave}),
      );

      print('Respuesta del servidor: ${response.body}');
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        // Guardar el token
        await prefs.setString('token', data['token']);

        // Guardar los datos del usuario
        if (data['userData'] != null) {
          await prefs.setString('userData', json.encode(data['userData']));
        }

        return {'success': true, 'token': data['token']};
      }

      return {
        'success': false,
        'message': data['mensage'] ?? 'Error en el inicio de sesión',
      };
    } catch (e) {
      print('Error en login: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userData');
  }

  // Método para obtener el token almacenado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token;
  }

  // Método para verificar si el usuario está autenticado
  Future<bool> isAuth() async {
    final token = await getToken();
    return token != null;
  }

  // Método para obtener los datos del usuario actual
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

  // Método para obtener el ID del usuario actual
  Future<int?> getUserId() async {
    final userData = await getUserData();
    if (userData != null && userData.containsKey('id')) {
      return userData['id'];
    }
    return null;
  }

  // Método para obtener el nombre del usuario actual
  Future<String?> getUserName() async {
    final userData = await getUserData();
    if (userData != null && userData.containsKey('nombres')) {
      return userData['nombres'];
    }
    return null;
  }
}
