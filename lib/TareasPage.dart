import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' show sin, cos, pi;

class TareasPage extends StatefulWidget {
  final bool darkMode;

  const TareasPage({super.key, required this.darkMode});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  final TextEditingController _comentarioCtrl = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 18))
          ..repeat();
    _particles = List.generate(20, (_) => _Particle());
  }

  @override
  void dispose() {
    _controller.dispose();
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleTarea(DocumentSnapshot tareaDoc) async {
    final data = tareaDoc.data() as Map<String, dynamic>;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            data["completada"]
                ? "¿Marcar como pendiente?"
                : "¿Marcar como completada?",
          ),
          content: Text(
            data["completada"]
                ? "La tarea volverá a estado pendiente."
                : "La tarea se marcará como completada.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await tareaDoc.reference.update({
        "completada": !data["completada"],
        "estado": !data["completada"] ? "pendiente" : "realizada",
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!data["completada"]
                ? "Tarea completada! 🎉"
                : "Tarea marcada como pendiente."),
            backgroundColor:
                !data["completada"] ? Colors.green : Colors.grey,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  void _mostrarDetalles(DocumentSnapshot tareaDoc) {
    final data = tareaDoc.data() as Map<String, dynamic>;
    final darkMode = widget.darkMode;

    // Usar 'reporte' si ese es el campo correcto de la web, si no usa 'comentario'
    _comentarioCtrl.text = data["reporte"] ?? data["comentario"] ?? ""; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: darkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),

                Text(
                  data["titulo"] ??
                      data["descripcion"] ??
                      "Tarea sin título",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkMode
                        ? Colors.orange.shade200
                        : Colors.deepOrange,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 20,
                      color: darkMode
                          ? Colors.orange.shade200
                          : Colors.deepOrange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Fecha: ${data["fecha"] ?? "N/A"}",
                      style: TextStyle(
                        color: darkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  data["descripcion"] ?? "Sin descripción detallada.",
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: darkMode ? Colors.white70 : Colors.black87,
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  "Comentarios:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkMode ? Colors.orange.shade100 : Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _comentarioCtrl,
                  maxLines: 3,
                  style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Añadir un comentario...",
                    hintStyle: TextStyle(
                        color: darkMode
                            ? Colors.grey.shade500
                            : Colors.grey.shade600),
                    filled: true,
                    fillColor: darkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data["completada"]
                          ? "✅ Completada"
                          : "🕓 Pendiente",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: data["completada"]
                            ? Colors.green
                            : Colors.deepOrange,
                      ),
                    ),

                    // ----------------------------------------------------------------
                    // 🔥 BOTÓN FINAL — COMPLETO: Guarda comentario + estado + notifica
                    // ----------------------------------------------------------------

                    ElevatedButton.icon(
                      onPressed: () async {
                        // 1. Variables de estado
                        final bool nuevaCompletada = !(data["completada"] ?? false);
                        final String nuevoEstado = nuevaCompletada ? "realizada" : "pendiente";
                        final String comentario = _comentarioCtrl.text.trim();
                        final String trabajadorEmail = currentUser!.email ?? "Sin Email";

                        try {
                            // 2. ACTUALIZAR ESTADO Y REPORTE
                            await tareaDoc.reference.update({
                                "reporte": comentario, 
                                "completada": nuevaCompletada,
                                "estado": nuevoEstado,
                            });

                            // 3. NOTIFICAR AL ADMINISTRADOR/SISTEMA (Ruta corregida en la iteración anterior)
                            await FirebaseFirestore.instance
                                .collection("admin_notificaciones") 
                                .add({
                                    "tipo": "reporte_tarea",
                                    "trabajador": trabajadorEmail,
                                    "mensaje": nuevaCompletada 
                                        ? "El trabajador $trabajadorEmail completó la tarea: ${data["titulo"] ?? "Sin título"}"
                                        : "El trabajador $trabajadorEmail desmarcó la tarea como pendiente: ${data["titulo"] ?? "Sin título"}",
                                    "comentario": comentario,
                                    "tareaId": tareaDoc.id,
                                    "creadoEn": FieldValue.serverTimestamp(),
                                    "leida": false,
                                });

                            // 4. Mensaje visual de éxito
                            if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            nuevaCompletada ? "Tarea completada 🎉" : "Tarea marcada como pendiente",
                                        ),
                                        backgroundColor: nuevaCompletada ? Colors.green : Colors.orange,
                                    ),
                                );
                            }
                        } catch (e) {
                            // 5. Manejo de errores
                            print("Error al actualizar tarea o enviar notificación: $e");
                            if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Error al procesar la tarea. Intenta de nuevo. ($e)'),
                                        backgroundColor: Colors.redAccent,
                                    ),
                                );
                            }
                        }
                        
                        // 6. CIERRA EL BOTTOM SHEET AQUÍ (Después de todo el await)
                        if (mounted) {
                            Navigator.pop(context);
                        }
                      },

                      icon: Icon(
                        data["completada"]
                            ? Icons.undo_rounded
                            : Icons.check_circle_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        data["completada"]
                            ? "Marcar como pendiente"
                            : "Marcar como completada",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: data["completada"]
                            ? Colors.grey
                            : Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
            AppBar(title: const Text("Tareas"), backgroundColor: Colors.red),
        body: const Center(child: Text("Error: Usuario no autenticado")),
      );
    }

    final String currentUserEmail =
        currentUser!.email ?? "Sin Email";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Mis Tareas", style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return CustomPaint(
                painter: _ParticlePainter(
                  _particles,
                  _controller.value,
                  darkMode
                      ? Colors.orange.shade200
                      : Colors.orange,
                ),
                child: Container(),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("tareas")
                  .where("paraNombre",
                      isEqualTo: currentUserEmail)
                  .orderBy("fecha", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Colors.deepOrange));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        "Error: ${snapshot.error}",
                        style: TextStyle(color: Colors.red)),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No se encontraron tareas para: $currentUserEmail",
                      style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final tareaDoc = docs[index];
                    final data = tareaDoc.data();

                    final completada =
                        data["completada"] ?? false;
                    final itemTitle =
                        data["titulo"] ??
                            data["descripcion"] ??
                            "Tarea sin título";

                    return GestureDetector(
                      onTap: () => _mostrarDetalles(tareaDoc),
                      child: AnimatedScale(
                        duration:
                            const Duration(milliseconds: 150),
                        scale: completada ? 0.97 : 1.0,
                        child: Container(
                          margin:
                              const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: darkMode
                                ? Colors.grey.shade900
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(darkMode
                                        ? 0.3
                                        : 0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border(
                              left: BorderSide(
                                color: completada
                                    ? Colors.green
                                    : Colors
                                        .deepOrange.shade400,
                                width: 6,
                              ),
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              completada
                                  ? Icons
                                      .check_circle_rounded
                                  : Icons
                                      .radio_button_unchecked,
                              color: completada
                                  ? Colors.green
                                  : Colors.deepOrange.shade400,
                            ),
                            title: Text(
                              itemTitle,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                decoration: completada
                                    ? TextDecoration
                                        .lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text(
                              "Fecha: ${data["fecha"] ?? "N/A"}",
                              style: TextStyle(
                                color: darkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                completada
                                    ? Icons.undo_rounded
                                    : Icons.check_rounded,
                                color: completada
                                    ? Colors.grey
                                    : Colors
                                        .deepOrange.shade400,
                              ),
                              onPressed: () =>
                                  _toggleTarea(tareaDoc),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_task_rounded),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Función de agregar tarea próximamente"),
              backgroundColor: Colors.deepOrange,
            ),
          );
        },
      ),
    );
  }
}

/// PARTICULAS
class _Particle {
  late double x;
  late double y;
  late double radius;
  late double speed;

  _Particle() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    radius = random.nextDouble() * 2 + 1;
    speed = random.nextDouble() * 0.2 + 0.05;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter(
      this.particles, this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()..color = color.withOpacity(0.15);
    for (final p in particles) {
      final dx = (p.x * size.width +
              sin(progress * 2 * pi + p.x * 2 * pi) * 10) %
          size.width;
      final dy = (p.y * size.height +
              cos(progress * 2 * pi + p.y * 2 * pi) * 10) %
          size.height;
      canvas.drawCircle(
          Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(
          covariant CustomPainter oldDelegate) =>
      true;
}