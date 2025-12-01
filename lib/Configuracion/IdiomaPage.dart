import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IdiomaPage extends StatefulWidget {
  final bool darkMode;
  const IdiomaPage({super.key, required this.darkMode});

  @override
  State<IdiomaPage> createState() => _IdiomaPageState();
}

class _IdiomaPageState extends State<IdiomaPage> {
  String idioma = 'es';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadIdioma();
  }

  Future<void> _loadIdioma() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        idioma = doc.data()?['settings']?['language'] ?? prefs.getString('app_language') ?? 'es';
      } else {
        idioma = prefs.getString('app_language') ?? 'es';
      }
    } else {
      idioma = prefs.getString('app_language') ?? 'es';
    }

    setState(() => loading = false);
  }

  Future<void> _applyIdioma(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', value);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'settings': {'language': value}
      }, SetOptions(merge: true));
    }
    setState(() => idioma = value);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Idioma guardado')));
    // Nota: la aplicación real necesitaría re-build con localizations
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.darkMode;
    final bg = dark ? const Color(0xFF121212) : const Color(0xFFFFF4E6);
    final textColor = dark ? Colors.white : const Color(0xFF5A3E1B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Idioma'),
        backgroundColor: dark ? Colors.grey.shade900 : Colors.deepOrange,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                RadioListTile<String>(
                  title: Text('Español', style: TextStyle(color: textColor)),
                  value: 'es',
                  groupValue: idioma,
                  onChanged: (v) => _applyIdioma(v ?? 'es'),
                ),
                RadioListTile<String>(
                  title: Text('Inglés', style: TextStyle(color: textColor)),
                  value: 'en',
                  groupValue: idioma,
                  onChanged: (v) => _applyIdioma(v ?? 'en'),
                ),
                RadioListTile<String>(
                  title: Text('Francés', style: TextStyle(color: textColor)),
                  value: 'fr',
                  groupValue: idioma,
                  onChanged: (v) => _applyIdioma(v ?? 'fr'),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () => _applyIdioma(idioma),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    child: const Text('Aplicar idioma'),
                  ),
                )
              ],
            ),
    );
  }
}
