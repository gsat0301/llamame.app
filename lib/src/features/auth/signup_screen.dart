import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase_client.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _passwordError;
  bool _obscurePassword = true;

  // 'cliente' or 'proveedor'
  String _selectedRole = 'cliente';

  static const int _minPasswordLength = 8;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Returns a validation error string if the password is invalid, or null if OK.
  String? _validatePassword(String password) {
    if (password.length < _minPasswordLength) {
      return 'La contraseña debe tener al menos $_minPasswordLength caracteres.';
    }
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'));

    final missing = <String>[];
    if (!hasUppercase) missing.add('una letra mayúscula');
    if (!hasDigit) missing.add('un número');
    if (!hasSpecial) missing.add('un caracter especial (!@#\$%...)');

    if (missing.isNotEmpty) {
      return 'La contraseña debe contener: ${missing.join(', ')}.';
    }
    return null;
  }

  Future<void> _signup() async {
    // Validate password first
    final passwordError = _validatePassword(_passwordController.text);
    if (passwordError != null) {
      setState(() => _passwordError = passwordError);
      return;
    }
    setState(() => _passwordError = null);

    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Supabase no está configurado. Revisa tu archivo .env.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'full_name': _fullNameController.text.trim(),
          'role': _selectedRole,
        },
      );

      if (!mounted) return;

      // Show email verification dialog
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.mark_email_unread_outlined,
              size: 48, color: Colors.blue),
          title: const Text(
            'Verifica tu correo',
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Hemos enviado un enlace de verificación a:\n\n'
            '${_emailController.text.trim()}\n\n'
            'Por favor revisa tu bandeja de entrada (y la carpeta de spam) '
            'y haz clic en el enlace para activar tu cuenta.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/login');
              },
              child: const Text('Ir al inicio de sesión'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la cuenta: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // ── Proveedor / Cliente toggle ──────────────────────────────
              Center(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'cliente',
                      label: Text('Cliente'),
                      icon: Icon(Icons.person_outline),
                    ),
                    ButtonSegment(
                      value: 'proveedor',
                      label: Text('Proveedor'),
                      icon: Icon(Icons.store_outlined),
                    ),
                  ],
                  selected: {_selectedRole},
                  onSelectionChanged: (newSelection) {
                    setState(() => _selectedRole = newSelection.first);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── Fields ──────────────────────────────────────────────────
              TextField(
                controller: _fullNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) {
                  // Clear error while user is typing
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    tooltip: _obscurePassword
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
                  ),
                  errorText: _passwordError,
                  helperText:
                      'Mín. $_minPasswordLength caracteres, mayúscula, número y caracter especial.',
                  helperMaxLines: 2,
                ),
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: _loading ? null : _signup,
                child: Text(_loading ? 'Creando cuenta…' : 'Crear cuenta'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Volver al inicio de sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
