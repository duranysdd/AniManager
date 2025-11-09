import 'package:flutter/material.dart';
import 'SplashScreen.dart';
import 'InicioS.dart';
import 'Notificaciones.dart';

  void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AniManager',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      // Pantalla inicial
      home: const SplashScreen(),
      // Rutas definidas
      routes: {
        '/login': (context) => const LoginScreen(),
        '/notificaciones': (context) => const NotificacionesScreen(),
      },
    );
  }
}
