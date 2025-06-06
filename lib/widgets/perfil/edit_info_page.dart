import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../services/cliente_service.dart';

class EditInfoPage extends StatefulWidget {
  final Cliente cliente;

  const EditInfoPage({Key? key, required this.cliente}) : super(key: key);

  @override
  State<EditInfoPage> createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _clienteService = ClienteService();
  bool _isLoading = false;

  late TextEditingController _nombresController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _dniController;

  @override
  void initState() {
    super.initState();
    _nombresController = TextEditingController(text: widget.cliente.nombres);
    _correoController = TextEditingController(text: widget.cliente.correo);
    _telefonoController = TextEditingController(text: widget.cliente.telefono);
    _dniController = TextEditingController(text: widget.cliente.dni);
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final Cliente clienteActualizado = Cliente(
          id: widget.cliente.id,
          nombres: _nombresController.text,
          correo: _correoController.text,
          telefono: _telefonoController.text,
          dni: _dniController.text,
          usuario: widget.cliente.usuario,
          estado: widget.cliente.estado,
        );

        final success = await _clienteService.updateClienteInfo(
          clienteActualizado,
        );

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Información actualizada con éxito'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Devuelve true para indicar éxito
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al actualizar la información'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Información')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nombres
                      _buildInputField(
                        controller: _nombresController,
                        label: 'Nombres Completos',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese sus nombres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Correo
                      _buildInputField(
                        controller: _correoController,
                        label: 'Correo Electrónico',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su correo';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Ingrese un correo válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Teléfono
                      _buildInputField(
                        controller: _telefonoController,
                        label: 'Teléfono',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su teléfono';
                          }
                          if (!RegExp(r'^\d{8}$').hasMatch(value)) {
                            return 'El teléfono debe tener 8 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // DNI
                      _buildInputField(
                        controller: _dniController,
                        label: 'DNI',
                        icon: Icons.badge,
                        enabled: false, // No permitir cambiar el DNI
                      ),
                      const SizedBox(height: 32),

                      // Botón para guardar cambios
                      ElevatedButton(
                        onPressed: _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          'Guardar Cambios',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[200],
      ),
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
    );
  }
}
