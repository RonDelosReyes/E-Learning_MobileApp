import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String supabaseUrl = dotenv.get('SUPABASE_URL', fallback: 'https://qvztoirnfzsgihohdzjr.supabase.co');
final String supabaseAnonKey = dotenv.get('SUPABASE_ANON_KEY', fallback: '');

/// Initialize Supabase before runApp
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
}

/// Access the Supabase client **after initialization**
SupabaseClient get supabase => Supabase.instance.client;
