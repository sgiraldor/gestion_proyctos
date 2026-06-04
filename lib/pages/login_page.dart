import 'package:flutter/material.dart';

<<<<<<< HEAD
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../validators/login_validator.dart';

class LoginPage extends StatefulWidget {
  final AuthService authService;

  const LoginPage({
    super.key,
    required this.authService,
  });
=======
import '../pages/blocked_page.dart';
import '../pages/home_page.dart';
import '../pages/pending_page.dart';
import '../services/auth_service.dart';
import '../services/permission_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
>>>>>>> 70233f51266470e69ae422e749a14accd5b9113f

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
<<<<<<< HEAD
  bool _loading = false;
=======

  final AuthService _authService = AuthService();
  final PermissionService _permissionService = PermissionService();

  bool _isLoading = false;
>>>>>>> 70233f51266470e69ae422e749a14accd5b9113f
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);
    try {
      await widget.authService.login(
        _emailController.text,
        _passwordController.text,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.authService.mensajeError(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
=======
  Future<void> _iniciarSesion() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final usuario = _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales inválidas.')),
        );
        return;
      }

      if (_permissionService.estaBloqueado(usuario)) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BlockedPage()),
        );
        return;
      }

      if (_permissionService.estaPendienteAprobacion(usuario)) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PendingPage()),
        );
        return;
      }

      if (!_permissionService.puedeIngresarSistema(usuario)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tu cuenta no está habilitada para ingresar.'),
          ),
        );
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(usuario: usuario),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
>>>>>>> 70233f51266470e69ae422e749a14accd5b9113f
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.science,
                              color: AppTheme.primary,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Gestion de Investigacion',
                          style: TextStyle(
                            color: AppTheme.ink,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Accede a proyectos, entregables, avances y revisiones.',
                          style: TextStyle(
                            color: AppTheme.secondaryInk,
                            fontSize: 15,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: LoginValidator.validarEmail,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contrasena',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Mostrar contrasena'
                                  : 'Ocultar contrasena',
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: LoginValidator.validarPassword,
                          onFieldSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 22),
                        ElevatedButton.icon(
                          onPressed: _loading ? null : _login,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward),
                          label: const Text('Ingresar'),
                        ),
                      ],
=======
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF101B3A), Color(0xFF1E3A8A), Color(0xFFF4F6FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 18,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.account_circle,
                            size: 72,
                            color: Color(0xFF1E3A8A),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Gestión de Investigación',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ingresa con las credenciales de prueba para acceder al sistema.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Ingresa tu correo.';
                              }
                              if (!text.contains('@')) {
                                return 'Ingresa un correo válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if ((value ?? '').isEmpty) {
                                return 'Ingresa tu contraseña.';
                              }
                              if ((value ?? '').length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres.';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _iniciarSesion(),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Ingresar'),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Usuarios de prueba:\ninvestigador@test.com\nevaluador@test.com\ncoordinador@test.com\nbloqueado@test.com\npendiente@test.com\nContraseña: 123456',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
>>>>>>> 70233f51266470e69ae422e749a14accd5b9113f
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
