/// Configuración de Supabase.
///
/// La clave "publishable" está pensada para ir dentro de la app (es pública);
/// la seguridad de los datos la dan las políticas RLS de `supabase/schema.sql`.
/// NUNCA pongas aquí la clave "secret" / service_role.
class SupabaseConfig {
  SupabaseConfig._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hjaysdrwcttaebvacclm.supabase.co',
  );

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: 'sb_publishable_MBHt4hOnbCFk9DJe6pK_Vg_5vGKBY8g',
  );

  /// Deep link al que vuelve la app Android después de iniciar sesión con Google.
  /// Debe coincidir con el intent-filter de AndroidManifest.xml y estar en
  /// Supabase > Authentication > URL Configuration > Redirect URLs.
  static const mobileRedirect = 'io.supabase.finix://login-callback/';
}
