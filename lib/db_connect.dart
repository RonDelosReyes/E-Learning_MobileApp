import 'package:supabase_flutter/supabase_flutter.dart';

/// Initialize Supabase before runApp
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://djnbwuaqjociuehoziqf.supabase.co',
    anonKey: 'sb_publishable_O8yCH_3pOmzdxZoCyFs1tg_Qf0Sm6zc',
  );
}

/// Access the Supabase client **after initialization**
SupabaseClient get supabase => Supabase.instance.client;
