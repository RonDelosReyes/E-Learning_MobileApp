import 'package:e_learning_app/db_connect.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'user_provider.dart';
import 'app_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait ONLY on mobile
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Supabase Initialization
  try {
    await initSupabase();
    debugPrint("Connected.");
  } catch (e) {
    debugPrint("Supabase Initialization Failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Learning App',
      theme: ThemeData(primarySwatch: Colors.lightBlue),
      home: const AppEntry(),
    );
  }
}
