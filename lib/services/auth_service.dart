import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../data/finance_data.dart';
import 'database_service.dart';

/// Inicio de sesión con Google y con correo/contraseña usando Supabase Auth.
class AuthService {
  AuthService._();

  static GoTrueClient get _auth => Supabase.instance.client.auth;

  static User? get currentUser =>
      AppState.backendReady ? _auth.currentUser : null;

  /// Se emite cada vez que alguien inicia sesión (incluye la vuelta desde Google).
  static Stream<AuthState> get changes =>
      AppState.backendReady ? _auth.onAuthStateChange : const Stream.empty();

  static void _ensureReady() {
    if (!AppState.backendReady) {
      throw const AuthException(
        'No se pudo conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  /// Abre la ventana de Google. El resultado llega por [changes]
  /// (en web la página se recarga y vuelve con la sesión iniciada).
  static Future<void> signInWithGoogle() async {
    _ensureReady();
    await _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? _webRedirect() : SupabaseConfig.mobileRedirect,
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
      queryParams: const {'prompt': 'select_account'},
    );
  }

  /// En web vuelve a la misma dirección (localhost o GitHub Pages /finix/).
  static String _webRedirect() {
    final u = Uri.base;
    return '${u.origin}${u.path}';
  }

  static Future<User> signInWithEmail(String email, String password) async {
    _ensureReady();
    final res = await _auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return res.user!;
  }

  /// Devuelve el usuario si quedó con sesión iniciada, o null si Supabase
  /// exige confirmar el correo primero.
  static Future<User?> register(
    String name,
    String email,
    String password,
  ) async {
    _ensureReady();
    final res = await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': name.trim()},
      emailRedirectTo: kIsWeb ? _webRedirect() : SupabaseConfig.mobileRedirect,
    );
    return res.session == null ? null : res.user;
  }

  static Future<void> signOut() async {
    DatabaseService.unbind();
    if (AppState.backendReady) await _auth.signOut();
  }

  static String errorMessage(Object e) {
    if (e is AuthException) {
      final m = e.message.toLowerCase();
      const known = {
        'invalid login credentials': 'Correo o contraseña incorrectos',
        'email not confirmed': 'Confirma tu correo antes de iniciar sesión',
        'already registered': 'Ese correo ya tiene una cuenta',
        'password should be': 'La contraseña debe tener al menos 6 caracteres',
        'provider is not enabled': 'El inicio con Google aún no está activado en Supabase',
        'valid email': 'Escribe un correo válido',
        'invalid format': 'Escribe un correo válido',
      };
      for (final entry in known.entries) {
        if (m.contains(entry.key)) return entry.value;
      }
      return e.message;
    }
    if (e is PostgrestException) return 'Error de base de datos: ${e.message}';
    return 'Ocurrió un error. Intenta de nuevo.';
  }
}
