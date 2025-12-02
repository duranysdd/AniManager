import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // REGISTRO DE USUARIO
  Future<String?> registrarUsuario(String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = cred.user!.uid;

      // Guardar datos en Firestore
      await _db.collection("users").doc(uid).set({
        "uid": uid,
        "email": email.trim(),
        "createdAt": DateTime.now(),
        "role": "pending",      // 👈 CLAVE para que la web detecte y envíe correo
      });

      return null; // null = todo bien
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "weak-password":
          return "La contraseña es demasiado débil.";
        case "email-already-in-use":
          return "Este correo ya está registrado.";
        case "invalid-email":
          return "Correo inválido.";
        default:
          return "Error desconocido: ${e.message}";
      }
    }
  }

  // LOGIN
  Future<String?> iniciarSesion(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Todo bien
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // CERRAR SESIÓN
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}
