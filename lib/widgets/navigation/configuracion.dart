import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  final AuthService _authService = AuthService();

  // Variables para almacenar los valores
  String _numeroMesa = '';
  String _colaboradorAsignado = '';
  String _mesasAsociadas = '';

  @override
  void initState() {
    super.initState();
    _loadConfiguracion();
  }

  Future<void> _loadConfiguracion() async {
    // Aquí puedes cargar los valores desde SharedPreferences o tu servicio
    // Por ahora los dejamos vacíos como placeholder
    setState(() {
      _numeroMesa = 'No asignada';
      _colaboradorAsignado = 'No asignado';
      _mesasAsociadas = 'Ninguna';
    });
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      await _authService.logout();

      if (mounted) {
        // Navegar a la página de login y eliminar todas las rutas anteriores
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarModalNumeroMesa() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Configurar Número de Mesa"),
          content: const Text(
            "Modal para configurar número de mesa\n(Lógica pendiente)",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí iría la lógica para configurar el número de mesa
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarModalColaborador() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Asignar Colaborador"),
          content: const Text(
            "Modal para asignar colaborador\n(Lógica pendiente)",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí iría la lógica para asignar colaborador
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarModalMesasAsociadas() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Configurar Mesas Asociadas"),
          content: const Text(
            "Modal para configurar mesas asociadas\n(Lógica pendiente)",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí iría la lógica para configurar mesas asociadas
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cerrar Sesión"),
          content: const Text("¿Estás seguro que deseas cerrar sesión?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cerrarSesion(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Cerrar Sesión",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración General',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Número de Mesa
            _buildConfigurationTile(
              icon: Icons.table_restaurant,
              title: 'Número de Mesa',
              value: _numeroMesa,
              onTap: _mostrarModalNumeroMesa,
            ),

            const SizedBox(height: 12),

            // Colaborador Asignado
            _buildConfigurationTile(
              icon: Icons.person_outline,
              title: 'Colaborador Asignado',
              value: _colaboradorAsignado,
              onTap: _mostrarModalColaborador,
            ),

            const SizedBox(height: 12),

            // Mesas Asociadas
            _buildConfigurationTile(
              icon: Icons.view_list,
              title: 'Mesas Asociadas',
              value: _mesasAsociadas,
              onTap: _mostrarModalMesasAsociadas,
            ),

            const Divider(height: 40, thickness: 1),

            // Cerrar sesión
            _buildOptionTile(
              icon: Icons.exit_to_app,
              title: 'Cerrar sesión',
              subtitle: 'Salir de la aplicación',
              iconColor: Colors.red,
              onTap: () => _mostrarDialogoCerrarSesion(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Configurar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.blue, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
