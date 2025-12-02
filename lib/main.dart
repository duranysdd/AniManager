import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

// Pantallas existentes
import './InicioS.dart'; // LoginScreen
import 'providers/AppProvider.dart';

// NUEVE = Import de RegistroScreen si no estaba importado
import 'RegistroS.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mi App',

          // 🌙 Tema dinámico
          themeMode: provider.darkMode ? ThemeMode.dark : ThemeMode.light,

          // Tema claro
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.orange,
            textTheme: Theme.of(context)
                .textTheme
                .apply(fontSizeFactor: provider.textScale),
          ),

          // Tema oscuro
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            textTheme: Theme.of(context)
                .textTheme
                .apply(fontSizeFactor: provider.textScale),
          ),

          // 🌐 Idioma dinámico
          locale: Locale(provider.language),

          // Pantalla inicial
          home: const LoginScreen(),

          // 🚀 Rutas opcionales (para navegar más limpio)
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegistroScreen(),
          },
        );
      },
    );
  }
}
