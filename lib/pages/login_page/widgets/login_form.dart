import 'package:supabase/supabase.dart' as sf;
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/helpers/supabase/queries.dart';
import 'package:nethive_neo/providers/providers.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
      builder: (context, userState, child) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Email Field
              TextFormField(
                controller: userState.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu correo';
                  }
                  if (!EmailValidator.validate(value)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: userState.passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleLogin(userState),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Iniciar Sesión'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogin(UserState userState) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Check if user exists
      final userId = await userState.getUserId(userState.emailController.text);

      if (userId == null) {
        _showError('Este Correo no está registrado');
        setState(() => _isLoading = false);
        return;
      }

      await supabaseLU.auth.signInWithPassword(
        email: userState.emailController.text,
        password: userState.passwordController.text,
      );

      // Update current user
      currentUser = await SupabaseQueries.getCurrentUserData();

      if (currentUser == null) {
        _showError('Error al obtener datos del usuario');
        setState(() => _isLoading = false);
        return;
      }

      print('Usuario autenticado: ${currentUser!.email}');

      if (mounted) {
        // Navigate to home - for now just show success
        _showSuccess('Inicio de sesión exitoso');
        // TODO: Navigate to home page when implemented
        // Navigator.pushReplacementNamed(context, '/home');
      }
    } on sf.AuthException catch (error) {
      print('AuthException: ${error.message}');
      _showError('Credenciales Inválidas');
    } catch (error) {
      print('Error inesperado: $error');
      _showError('Error inesperado');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
