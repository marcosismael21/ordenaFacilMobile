import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final bool isModal;
  final Function(bool, {Map<String, dynamic>? userData})?
  onLoginComplete; // Callback mejorado

  const LoginPage({super.key, this.isModal = false, this.onLoginComplete});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _claveController = TextEditingController();
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    // Si es modal, solo retorna el formulario
    if (widget.isModal) {
      return _buildModalForm();
    }

    // Si no es modal, envuelve en Scaffold con fondo
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(child: _buildModalForm()),
      ),
    );
  }

  Widget _buildModalForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono de acceso
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Título
              Text(
                widget.isModal ? 'Acceso Requerido' : 'Bienvenido',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 8),

              // Subtítulo
              Text(
                widget.isModal
                    ? 'Ingresa tus credenciales para acceder a la configuración'
                    : 'Ingresa a tu cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, color: AppColors.grey600),
              ),
              const SizedBox(height: 32),

              // Campo de Usuario
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey300.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _usuarioController,
                  style: const TextStyle(fontSize: 23),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    hintText: 'Usuario',
                    hintStyle: TextStyle(
                      color: AppColors.grey500,
                      fontSize: 23,
                    ),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      size: 30,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    errorStyle: const TextStyle(fontSize: 20),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingrese su usuario';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Campo de Contraseña
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey300.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _claveController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 23),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    hintText: 'Contraseña',
                    hintStyle: TextStyle(
                      color: AppColors.grey500,
                      fontSize: 23,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      size: 30,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    errorStyle: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingrese su contraseña';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Botón de Inicio de Sesión
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),

              // Espaciado adicional si no es modal
              if (!widget.isModal) ...[
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    // Acción para crear cuenta si no es modal
                  },
                  child: Text(
                    'Crear cuenta',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final response = await _authService.login(
          _usuarioController.text,
          _claveController.text,
        );

        if (response['success']) {
          // Si es modal, usar callback
          if (widget.isModal && widget.onLoginComplete != null) {
            widget.onLoginComplete!(
              true, userData: response['userData'],
            ); // Retorna true si el login fue exitoso
          } else {
            // Navegación normal si no es modal
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          // Si es modal, también retornar false
          if (widget.isModal && widget.onLoginComplete != null) {
            widget.onLoginComplete!(false);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'],
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        // En caso de error, también retornar false si es modal
        if (widget.isModal && widget.onLoginComplete != null) {
          widget.onLoginComplete!(false);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _claveController.dispose();
    super.dispose();
  }
}
