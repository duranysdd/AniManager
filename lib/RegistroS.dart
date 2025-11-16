import 'package:animanager/HomePage.dart';
import 'package:animanager/InicioS.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'InicioS.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final correoController = TextEditingController();
  final passController = TextEditingController();
  final pass2Controller = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;

  Future<void> registrar() async {
    if (passController.text != pass2Controller.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correoController.text.trim(),
        password: passController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = "Error desconocido";

      if (e.code == 'weak-password') mensaje = "La contraseña es muy débil";
      if (e.code == 'email-already-in-use')
        mensaje = "Este correo ya está registrado";
      if (e.code == 'invalid-email') mensaje = "Correo inválido";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var decoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFFEB3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Column(
                children: [
                  const Text(
                    "Crear cuenta",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: correoController,
                    decoration: decoration.copyWith(
                      hintText: "Correo",
                      prefixIcon: const Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passController,
                    obscureText: _obscure1,
                    decoration: decoration.copyWith(
                      hintText: "Contraseña",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure1 ? Icons.visibility_off : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscure1 = !_obscure1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: pass2Controller,
                    obscureText: _obscure2,
                    decoration: decoration.copyWith(
                      hintText: "Repetir contraseña",
                      prefixIcon: const Icon(Icons.lock_reset),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure2 ? Icons.visibility_off : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscure2 = !_obscure2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7043), Color(0xFFFFD54F)],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: registrar,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        "Registrarse",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
