import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificacionesScreen extends StatefulWidget {
  final bool darkMode;
  const NotificacionesScreen({super.key, this.darkMode = false});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String? uid;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // UID del usuario autenticado
    uid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  IconData _getIcon(String tipo) {
    switch (tipo) {
      case 'tarea':
        return Icons.assignment_outlined;
      case 'alerta':
        return Icons.warning_amber_rounded;
      case 'info':
        return Icons.notifications_active_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getColor(String tipo) {
    switch (tipo) {
      case 'tarea':
        return Colors.orangeAccent;
      case 'alerta':
        return Colors.redAccent;
      case 'info':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> marcarTodasComoLeidas() async {
    if (uid == null) return;

    final query = await FirebaseFirestore.instance
        .collection("workers")
        .doc(uid)
        .collection("notificaciones")
        .get();

    for (var doc in query.docs) {
      doc.reference.update({"leida": true});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Todas las notificaciones marcadas como leídas"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Usuario no autenticado")),
      );
    }

    final darkMode = widget.darkMode;
    final gradientColors = darkMode
        ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
        : [const Color(0xFFFFA726), const Color(0xFFFFEB3B)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Notificaciones",
          style: TextStyle(
            color: darkMode ? Colors.orangeAccent : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            IconThemeData(color: darkMode ? Colors.orangeAccent : Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done_all,
              color: darkMode ? Colors.orangeAccent : Colors.white,
            ),
            tooltip: 'Marcar todas como leídas',
            onPressed: marcarTodasComoLeidas,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("workers")
                .doc(uid)
                .collection("notificaciones")
                .orderBy("hora", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text(
                  "No hay notificaciones aún",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ));
              }

              final docs = snapshot.data!.docs;

              return AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final notiDoc = docs[index];
                      final noti = notiDoc.data() as Map<String, dynamic>;

                      final horaFormato = noti["hora"] is Timestamp
                          ? DateFormat('hh:mm a')
                              .format(noti["hora"].toDate())
                          : "—";

                      final color = _getColor(noti['tipo']);

                      final bgColor = darkMode
                          ? (noti['leida']
                              ? Colors.grey.shade800
                              : const Color(0xFF2C2C2C))
                          : (noti['leida']
                              ? Colors.white.withOpacity(0.7)
                              : Colors.white);

                      final anim = CurvedAnimation(
                        parent: _animController,
                        curve: Interval(
                          0.1 * index,
                          0.6 + (0.1 * index),
                          curve: Curves.easeOut,
                        ),
                      );

                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(anim),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: darkMode
                                      ? Colors.black.withOpacity(0.4)
                                      : Colors.black26.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              leading: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color.withOpacity(0.15),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  _getIcon(noti['tipo']),
                                  color: color,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                noti['titulo'] ?? "Sin título",
                                style: TextStyle(
                                  fontWeight: noti['leida']
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color:
                                      darkMode ? Colors.white : Colors.grey[900],
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      noti['descripcion'] ?? "",
                                      style: TextStyle(
                                        color: darkMode
                                            ? Colors.white70
                                            : Colors.grey[700],
                                        fontStyle: noti['leida']
                                            ? FontStyle.italic
                                            : FontStyle.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      horaFormato,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: darkMode
                                            ? Colors.grey.shade500
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  noti['leida']
                                      ? Icons.check_circle
                                      : Icons.mark_email_unread,
                                  color: noti['leida']
                                      ? Colors.greenAccent
                                      : Colors.orangeAccent,
                                ),
                                onPressed: () {
                                  notiDoc.reference.update({"leida": true});
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
