import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Est extends StatefulWidget {
  final bool darkMode;

  const Est({super.key, required this.darkMode});

  @override
  State<Est> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<Est> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late String currentUserEmail;

  @override
  void initState() {
    super.initState();
    currentUserEmail = currentUser?.email ?? "sinemail@example.com";
  }
  Stream<QuerySnapshot> _streamTotalTareas() {
    return FirebaseFirestore.instance
        .collection("tareas")
        .where("paraNombre", isEqualTo: currentUserEmail)
        .snapshots();
  }

  Stream<QuerySnapshot> _streamTareasCompletadas() {
    return FirebaseFirestore.instance
        .collection("tareas")
        .where("paraNombre", isEqualTo: currentUserEmail)
        .where("completada", isEqualTo: true)
        .snapshots();
  }
  Stream<QuerySnapshot> _streamTareasPendientes() {
    return FirebaseFirestore.instance
        .collection("tareas")
        .where("paraNombre", isEqualTo: currentUserEmail)
        .where("completada", isEqualTo: false)
        .snapshots();
  }
  Widget _buildMetricCard({
    required String title,
    required Stream<QuerySnapshot> stream,
    required Color color,
    required IconData icon,
  }) {
    final bool darkMode = widget.darkMode;
    final cardColor = darkMode ? color.withOpacity(0.2) : color.withOpacity(0.85);
    final titleColor = darkMode ? color.shade200 : Colors.white;
    final valueColor = darkMode ? Colors.white : Colors.white;

    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          int count = 0;
          if (snapshot.hasData) {
            count = snapshot.data!.docs.length;
          }

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: titleColor),
                      ),
                      Icon(icon, color: titleColor, size: 24),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = widget.darkMode;
    final bgColor =
        darkMode ? const Color(0xFF121212) : const Color(0xFFFFF4E6);
    final textColor =
        darkMode ? Colors.white : const Color(0xFF5A3E1B);

    if (currentUser == null) {
      return Scaffold(
        appBar:
            AppBar(title: const Text("Dashboard"), backgroundColor: Colors.red),
        body: const Center(child: Text("Error: Usuario no autenticado")),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Resumen de Actividad", style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
              child: Text(
                "Métricas Clave",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Row(
              children: [
                _buildMetricCard(
                  title: "Tareas Asignadas",
                  stream: _streamTotalTareas(),
                  color: Colors.blue,
                  icon: Icons.assignment,
                ),
                const SizedBox(width: 16),
                _buildMetricCard(
                  title: "Tareas Completadas",
                  stream: _streamTareasCompletadas(),
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
            Row(
              children: [
                _buildMetricCard(
                  title: "Tareas Pendientes",
                  stream: _streamTareasPendientes(),
                  color: Colors.deepOrange,
                  icon: Icons.schedule,
                ),
                const SizedBox(width: 16), 
                Expanded(child: Container()), 
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension on Color {
  get shade200 => null;
}