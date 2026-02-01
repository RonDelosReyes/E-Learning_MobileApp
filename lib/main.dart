import 'package:e_learning_app/admin/a_dashboard_page.dart';
import 'package:e_learning_app/faculty/f_dashboard_page.dart';
import 'package:e_learning_app/login_pages/login_form.dart';
import 'package:e_learning_app/db_connect.dart';
import 'package:e_learning_app/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  //Supabase Initialization
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
      home: const LogInForm(),
    );
  }
}