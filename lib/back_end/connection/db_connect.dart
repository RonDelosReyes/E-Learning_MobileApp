import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://qvztoirnfzsgihohdzjr.supabase.co';
const String supabaseAnonKey = 'sb_publishable_4DKXVG8dmcoixGHpMviW9Q_u_jo9x2C';

/// Initialize Supabase before runApp
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
}

/// Access the Supabase client **after initialization**
SupabaseClient get supabase => Supabase.instance.client;
