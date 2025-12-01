import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificacionesPage extends StatefulWidget {
  final bool darkMode;
  const NotificacionesPage({super.key, required this.darkMode});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  bool ganado = true;
  bool vacunas = true;
  bool alimentacion = true;
  bool emergencias = true;
  String uid = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    if (user != null) {
      uid = user.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final s = doc.data()?['settings'] ?? {};
        ganado = s['notify_ganado'] ?? prefs.getBool('notify_ganado') ?? ganado;
        vacunas = s['notify_vacunas'] ?? prefs.getBool('notify_vacunas') ?? vacunas;
        alimentacion = s['notify_alimentacion'] ?? prefs.getBool('notify_alimentacion') ?? alimentacion;
        emergencias = s['notify_emergencias'] ?? prefs.getBool('notify_emergencias') ?? emergencias;
      } else {
        ganado = prefs.getBool('notify_ganado') ?? ganado;
        vacunas = prefs.getBool('notify_vacunas') ?? vacunas;
        alimentacion = prefs.getBool('notify_alimentacion') ?? alimentacion;
        emergencias = prefs.getBool('notify_emergencias') ?? emergencias;
      }
    } else {
      ganado = prefs.getBool('notify_ganado') ?? ganado;
      vacunas = prefs.getBool('notify_vacunas') ?? vacunas;
      alimentacion = prefs.getBool('notify_alimentacion') ?? alimentacion;
      emergencias = prefs.getBool('notify_emergencias') ?? emergencias;
    }

    setState(() => loading = false);
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notify_ganado', ganado);
    await prefs.setBool('notify_vacunas', vacunas);
    await prefs.setBool('notify_alimentacion', alimentacion);
    await prefs.setBool('notify_emergencias', emergencias);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'settings': {
          'notify_ganado': ganado,
          'notify_vacunas': vacunas,
          'notify_alimentacion': alimentacion,
          'notify_emergencias': emergencias,
        }
      }, SetOptions(merge: true));
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferencias guardadas')));
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.darkMode;
    final bg = dark ? const Color(0xFF121212) : const Color(0xFFFFF4E6);
    final textColor = dark ? Colors.white : const Color(0xFF5A3E1B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: dark ? Colors.grey.shade900 : Colors.deepOrange,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Ajustes de notificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Alertas de ganado'),
                  subtitle: const Text('Notificaciones sobre estado general del ganado'),
                  value: ganado,
                  onChanged: (v) => setState(() => ganado = v),
                  activeColor: Colors.deepOrange,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Recordatorios de vacunas'),
                  subtitle: const Text('Recibe recordatorios para campañas de vacunación'),
                  value: vacunas,
                  onChanged: (v) => setState(() => vacunas = v),
                  activeColor: Colors.deepOrange,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Alertas de alimentación'),
                  subtitle: const Text('Recordatorios de ración y horarios'),
                  value: alimentacion,
                  onChanged: (v) => setState(() => alimentacion = v),
                  activeColor: Colors.deepOrange,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Notificaciones de emergencia'),
                  subtitle: const Text('Alertas urgentes'),
                  value: emergencias,
                  onChanged: (v) => setState(() => emergencias = v),
                  activeColor: Colors.redAccent,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveAll,
                  child: const Text('Guardar ajustes'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
              ],
            ),
    );
  }
}
