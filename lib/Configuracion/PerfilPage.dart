import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String uid = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }
    uid = user.uid;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      _nameCtrl.text = data['profile']?['name'] ?? user.displayName ?? '';
      _emailCtrl.text = data['profile']?['email'] ?? user.email ?? '';
    } else {
      _emailCtrl.text = user.email ?? '';
      _nameCtrl.text = user.displayName ?? '';
    }

    setState(() => loading = false);
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay usuario autenticado')));
      return;
    }

    final uid = user.uid;
    final profile = {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'role': 'Personal', // aquí guardamos el rol fijo
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'profile': profile}, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil guardado')));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.darkMode;
    final bg = dark ? const Color(0xFF121212) : const Color(0xFFFFF4E6);
    final textColor = dark ? Colors.white : const Color(0xFF5A3E1B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: dark ? Colors.grey.shade900 : Colors.deepOrange,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.orange.shade300,
                    child: Text(
                      (_nameCtrl.text.isNotEmpty
                              ? _nameCtrl.text[0]
                              : 'U')
                          .toUpperCase(),
                      style:
                          const TextStyle(fontSize: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo nombre
                  TextField(
                    controller: _nameCtrl,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 12),

                  // Campo email
                  TextField(
                    controller: _emailCtrl,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(labelText: 'Correo'),
                  ),
                  const SizedBox(height: 20),

                  // 🔥 NUEVO: Texto fijo del rol
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Rol: Personal",
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Guardar perfil'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
    );
  }
}
