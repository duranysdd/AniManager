import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import './InicioS.dart'; 
import 'providers/AppProvider.dart';
import 'RegistroS.dart';
import 'SplashScreen.dart';

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

          themeMode: provider.darkMode ? ThemeMode.dark : ThemeMode.light,

          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.orange,
            textTheme: Theme.of(context)
                .textTheme
                .apply(fontSizeFactor: provider.textScale),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            textTheme: Theme.of(context)
                .textTheme
                .apply(fontSizeFactor: provider.textScale),
          ),

          locale: Locale(provider.language),

          home: const SplashScreen(),

          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegistroScreen(),
          },
        );
      },
    );
  }
}
