import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilPage extends StatefulWidget {
  final bool darkMode;
  const PerfilPage({super.key, required this.darkMode});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool loading = true;
  String userRole = 'Cargando...';

  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _loadUserData();
    } else {
      setState(() {
        loading = false;
        _nameCtrl.text = "Usuario no autenticado";
        _emailCtrl.text = "N/A";
        userRole = "Invitado";
      });
    }
  }

  Future<void> _loadUserData() async {
    if (currentUser == null) return;

    try {
      final uid = currentUser!.uid;
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        
        String name = data?['name'] ?? 'Nombre no disponible';
        String email = data?['email'] ?? currentUser!.email ?? 'Correo no disponible';
        String role = 'Rol no disponible';

        if (data?['role'] is String) {
          role = data!['role'];
        } else if (data?['profile'] is Map && data!['profile']['role'] is String) {
          role = data!['profile']['role'];
        }

        setState(() {
          _nameCtrl.text = name;
          _emailCtrl.text = email;
          userRole = role;
          loading = false;
        });
      } else {
        setState(() {
          _nameCtrl.text = currentUser!.displayName ?? 'Usuario de Firebase';
          _emailCtrl.text = currentUser!.email ?? 'Correo no disponible';
          userRole = "Default";
          loading = false;
        });
      }
    } catch (e) {
      print("Error al cargar datos del usuario: $e");
      setState(() {
        _nameCtrl.text = 'Error de carga';
        _emailCtrl.text = currentUser?.email ?? 'Error de carga';
        userRole = 'Error';
        loading = false;
      });
    }
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Funcionalidad de edición deshabilitada temporalmente."),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.darkMode ? const Color(0xFF121212) : const Color(0xFFFFF4E6);
    final cardColor = widget.darkMode ? Colors.grey.shade900 : Colors.white;
    final textColor = widget.darkMode ? Colors.white : const Color(0xFF5A3E1B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Mi Perfil", style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.deepOrange.shade400,
                    child: Icon(Icons.person_rounded, size: 70, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userRole.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildProfileField(
                    icon: Icons.badge_rounded,
                    label: "Nombre",
                    controller: _nameCtrl,
                    readOnly: true,
                    darkMode: widget.darkMode,
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 20),
                  _buildProfileField(
                    icon: Icons.email_rounded,
                    label: "Correo Electrónico",
                    controller: _emailCtrl,
                    readOnly: true, 
                    darkMode: widget.darkMode,
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, 
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Guardar Cambios (Deshabilitado)", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool readOnly,
    required bool darkMode,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(darkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: TextStyle(color: textColor, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Colors.deepOrange),
          border: InputBorder.none,
          suffixIcon: readOnly ? null : Icon(Icons.edit, color: textColor.withOpacity(0.5)),
        ),
      ),
    );
  }
}