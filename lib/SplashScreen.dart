import 'package:animanager/InicioS.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String loadingText = "Rumiando datos";
  int dotCount = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      setState(() {
        dotCount = (dotCount + 1) % 4;
      });
    });

    Future.delayed(const Duration(seconds: 3), () {
      timer.cancel(); 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * dotCount;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFFEB3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/vaca.json',
              width: 200,
              height: 200,
              repeat: true,
            ),
            const SizedBox(height: 30),
            
            const Text(
              "¡Bienvenido!",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              "$loadingText$dots",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
