import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uni_club/firebase_options.dart';
import 'package:uni_club/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(2, 99, 81, 239))
      ),
      home: const LoginScreen(), // Set the initial screen to the LoginScreen
    );
  }
}
