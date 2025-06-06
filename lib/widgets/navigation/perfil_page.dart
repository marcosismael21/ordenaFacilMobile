import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cliente.dart';
import '../../services/cliente_service.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';
import '../perfil/edit_info_page.dart';
import '../perfil/change_password_page.dart';
import '../perfil/direcciones_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final ClienteService _clienteService = ClienteService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  Cliente? _cliente;

  @override
  void initState() {
    super.initState();
    _loadClienteInfo();
  }

  Future<void> _loadClienteInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cliente = await _clienteService.getClienteInfo();
      setState(() {
        _cliente = cliente;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar información: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClienteInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cliente == null
              ? const Center(
                  child: Text('No se pudo cargar la información del perfil'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección de perfil
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      
                      // Sección de opciones
                      const Text(
                        'Opciones de Cuenta',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Editar información personal
                      _buildOptionTile(
                        icon: Icons.person,
                        title: 'Editar información personal',
                        subtitle: 'Modifica tus datos personales',
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditInfoPage(cliente: _cliente!),
                            ),
                          );
                          
                          if (result == true) {
                            _loadClienteInfo();
                          }
                        },
                      ),
                      
                      // Cambiar contraseña
                      _buildOptionTile(
                        icon: Icons.key,
                        title: 'Cambiar contraseña',
                        subtitle: 'Actualiza tu contraseña',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChangePasswordPage(
                                clienteId: _cliente!.id!,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Gestionar direcciones
                      _buildOptionTile(
                        icon: Icons.location_on,
                        title: 'Mis direcciones',
                        subtitle: 'Administra tus direcciones de entrega',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DireccionesPage(),
                            ),
                          );
                        },
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

  Widget _buildProfileHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar con iniciales
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Text(
                _getInitials(_cliente?.nombres ?? ''),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Nombre completo
            Text(
              _cliente?.nombres ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Información adicional
            _buildInfoRow(Icons.email, _cliente?.correo ?? ''),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, _cliente?.telefono ?? ''),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.badge, _cliente?.dni ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
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
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  String _getInitials(String fullName) {
    List<String> nameParts = fullName.split(' ');
    String initials = '';
    if (nameParts.isNotEmpty) {
      initials += nameParts[0][0];
      if (nameParts.length > 1) {
        initials += nameParts[1][0];
      }
    }
    return initials.toUpperCase();
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
}