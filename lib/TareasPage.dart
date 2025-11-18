import 'package:flutter/material.dart';
import 'dart:math';

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

  // Lista simulada de tareas (con comentario)
  final List<Map<String, dynamic>> tareas = [
    {
      "titulo": "Vacunar res #12",
      "fecha": "2025-11-10",
      "descripcion":
          "Aplicar la vacuna anual contra fiebre aftosa a la res #12. Revisar también temperatura corporal y apetito.",
      "completada": false,
      "comentario": ""
    },
    {
      "titulo": "Limpieza del corral",
      "fecha": "2025-11-12",
      "descripcion":
          "Retirar desechos del área de alimentación y colocar nueva paja en los corrales.",
      "completada": true,
      "comentario": ""
    },
    {
      "titulo": "Revisión veterinaria",
      "fecha": "2025-11-15",
      "descripcion":
          "El veterinario realizará un chequeo general de salud del ganado y revisará signos de parásitos.",
      "completada": false,
      "comentario": ""
    },
  ];

  final TextEditingController _comentarioCtrl = TextEditingController();

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
    super.dispose();
  }

  // Confirmación antes de marcar completada
  Future<void> _confirmarToggle(int index) async {
    final tarea = tareas[index];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            tarea["completada"]
                ? "¿Marcar como pendiente?"
                : "¿Marcar como completada?",
          ),
          content: Text(
            tarea["completada"]
                ? "La tarea volverá a estado pendiente."
                : "La tarea se marcará como completada.",
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        tareas[index]["completada"] = !tareas[index]["completada"];
      });
    }
  }

  void _mostrarDetalles(Map<String, dynamic> tarea) {
    final darkMode = widget.darkMode;
    _comentarioCtrl.text = tarea["comentario"];

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
                  tarea["titulo"],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color:
                        darkMode ? Colors.orange.shade200 : Colors.deepOrange,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 20,
                      color:
                          darkMode ? Colors.orange.shade200 : Colors.deepOrange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Fecha: ${tarea["fecha"]}",
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
                  tarea["descripcion"],
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: darkMode ? Colors.white70 : Colors.black87,
                  ),
                ),

                const SizedBox(height: 25),

                // COMENTARIOS X TAREA :)
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
                  decoration: InputDecoration(
                    hintText: "Añadir un comentario...",
                    filled: true,
                    fillColor:
                        darkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    tarea["comentario"] = value;
                  },
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tarea["completada"] ? "✅ Completada" : "🕓 Pendiente",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: tarea["completada"]
                            ? Colors.green
                            : Colors.deepOrange,
                      ),
                    ),

                    // BOTÓN DE  CONFIRMACIÓN DE TARA <3
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmarToggle(tareas.indexOf(tarea));
                      },
                      icon: Icon(
                        tarea["completada"]
                            ? Icons.undo_rounded
                            : Icons.check_circle_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        tarea["completada"]
                            ? "Marcar como pendiente"
                            : "Marcar como completada",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tarea["completada"]
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
    final textColor = darkMode ? Colors.white : const Color(0xFF5A3E1B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Tareas"),
        backgroundColor: darkMode ? Colors.grey.shade900 : Colors.orange,
        foregroundColor: Colors.white,
        elevation: 4,
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
                  darkMode ? Colors.orange.shade200 : Colors.orange,
                ),
                child: Container(),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: tareas.length,
              itemBuilder: (context, index) {
                final tarea = tareas[index];
                final completada = tarea["completada"] as bool;

                return GestureDetector(
                  onTap: () => _mostrarDetalles(tarea),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 150),
                    scale: completada ? 0.97 : 1.0,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: darkMode ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border(
                          left: BorderSide(
                            color: completada
                                ? Colors.green
                                : Colors.deepOrange.shade400,
                            width: 6,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          completada
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked,
                          color: completada
                              ? Colors.green
                              : Colors.deepOrange.shade400,
                        ),
                        title: Text(
                          tarea["titulo"],
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            decoration: completada
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          "Fecha: ${tarea["fecha"]}",
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
                                : Colors.deepOrange.shade400,
                          ),
                          onPressed: () => _confirmarToggle(index),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add_task_rounded),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Función de agregar tarea próximamente")),
          );
        },
      ),
    );
  }
}

// Partículas :3

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

  _ParticlePainter(this.particles, this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.15);
    for (final p in particles) {
      final dx = (p.x * size.width +
              sin(progress * 2 * pi + p.x * 2 * pi) * 10) %
          size.width;
      final dy = (p.y * size.height +
              cos(progress * 2 * pi + p.y * 2 * pi) * 10) %
          size.height;
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
