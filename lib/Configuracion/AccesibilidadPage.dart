import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccesibilidadPage extends StatefulWidget {
  final bool darkMode;
  const AccesibilidadPage({super.key, required this.darkMode});

  @override
  State<AccesibilidadPage> createState() => _AccesibilidadPageState();
}

class _AccesibilidadPageState extends State<AccesibilidadPage> {
  double textScale = 1.0;
  bool altoContraste = false;
  bool reducirAnimaciones = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAccesibilidad();
  }

  Future<void> _loadAccesibilidad() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final s = doc.data()?['settings'] ?? {};
        textScale = (s['textScale'] ?? prefs.getDouble('textScale') ?? 1.0).toDouble();
        altoContraste = s['altoContraste'] ?? prefs.getBool('altoContraste') ?? false;
        reducirAnimaciones = s['reducirAnimaciones'] ?? prefs.getBool('reducirAnimaciones') ?? false;
      } else {
        textScale = prefs.getDouble('textScale') ?? 1.0;
        altoContraste = prefs.getBool('altoContraste') ?? false;
        reducirAnimaciones = prefs.getBool('reducirAnimaciones') ?? false;
      }
    } else {
      textScale = prefs.getDouble('textScale') ?? 1.0;
      altoContraste = prefs.getBool('altoContraste') ?? false;
      reducirAnimaciones = prefs.getBool('reducirAnimaciones') ?? false;
    }

    setState(() => loading = false);
  }

  Future<void> _saveAccesibilidad() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScale', textScale);
    await prefs.setBool('altoContraste', altoContraste);
    await prefs.setBool('reducirAnimaciones', reducirAnimaciones);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'settings': {
          'textScale': textScale,
          'altoContraste': altoContraste,
          'reducirAnimaciones': reducirAnimaciones,
        }
      }, SetOptions(merge: true));
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accesibilidad guardada')));
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.darkMode;
    final bg = dark ? const Color(0xFF121212) : const Color(0xFFFFF4E6);
    final textColor = dark ? Colors.white : const Color(0xFF5A3E1B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Accesibilidad'),
        backgroundColor: dark ? Colors.grey.shade900 : Colors.deepOrange,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Tamaño de texto', style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.bold)),
                Slider(
                  value: textScale,
                  min: 0.8,
                  max: 1.6,
                  divisions: 8,
                  label: '${(textScale * 100).round()}%',
                  onChanged: (v) => setState(() => textScale = v),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Alto contraste'),
                  value: altoContraste,
                  onChanged: (v) => setState(() => altoContraste = v),
                  activeColor: Colors.deepOrange,
                ),
                SwitchListTile(
                  title: const Text('Reducir animaciones'),
                  value: reducirAnimaciones,
                  onChanged: (v) => setState(() => reducirAnimaciones = v),
                  activeColor: Colors.deepOrange,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveAccesibilidad,
                  child: const Text('Guardar accesibilidad'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
              ],
            ),
    );
  }
}
