import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  List<Map<String, dynamic>> notificaciones = [
    {
      'titulo': 'Nueva tarea asignada',
      'descripcion': 'Revisa el establo 3 y verifica el nivel de agua.',
      'hora': DateTime.now().subtract(const Duration(minutes: 5)),
      'tipo': 'tarea',
      'leida': false,
    },
    {
      'titulo': 'Reporte aceptado',
      'descripcion': 'Tu reporte sobre el corral 2 ha sido revisado.',
      'hora': DateTime.now().subtract(const Duration(hours: 1)),
      'tipo': 'info',
      'leida': false,
    },
    {
      'titulo': 'Pendiente por realizar',
      'descripcion': 'Limpieza del área de alimentación pendiente.',
      'hora': DateTime.now().subtract(const Duration(hours: 3)),
      'tipo': 'alerta',
      'leida': true,
    },
  ];

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

  void marcarTodasComoLeidas() {
    setState(() {
      for (var n in notificaciones) {
        n['leida'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Todas las notificaciones marcadas como leídas")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Notificaciones",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            tooltip: 'Marcar todas como leídas',
            onPressed: marcarTodasComoLeidas,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFFEB3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notificaciones.length,
            itemBuilder: (context, index) {
              final noti = notificaciones[index];
              final hora = DateFormat('hh:mm a').format(noti['hora']);
              final color = _getColor(noti['tipo']);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: noti['leida']
                      ? Colors.white.withOpacity(0.6)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(_getIcon(noti['tipo']), color: color),
                  ),
                  title: Text(
                    noti['titulo'],
                    style: TextStyle(
                      fontWeight:
                          noti['leida'] ? FontWeight.normal : FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        noti['descripcion'],
                        style: TextStyle(
                          color: Colors.black54,
                          fontStyle: noti['leida']
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hora,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      noti['leida']
                          ? Icons.check_circle
                          : Icons.mark_email_unread,
                      color: noti['leida'] ? Colors.green : Colors.orangeAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        noti['leida'] = true;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
