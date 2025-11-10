import 'package:flutter/material.dart';
import 'TareasPage.dart';
import 'Notificaciones.dart';
import 'dart:math';

class AniManagerInicio extends StatefulWidget {
  const AniManagerInicio({super.key});

  @override
  State<AniManagerInicio> createState() => _AniManagerInicioState();
}

class _AniManagerInicioState extends State<AniManagerInicio>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _darkMode = false;
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 18))
          ..repeat(); // la velocidad de las particulas 
    _particles = List.generate(25, (_) => _Particle());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

void _openPage(String name) {
  if (name == "Tareas") {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TareasPage(darkMode: _darkMode),
      ),
    );
  } else if (name == "Notificaciones") {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificacionesScreen(darkMode: _darkMode),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Abrir página: $name"),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final bgColor = _darkMode ? const Color(0xFF121212) : const Color(0xFFFFF4E6);
    final textColor = _darkMode ? Colors.white : const Color(0xFF5A3E1B);

    final pages = [
      _HomeContent(
        particles: _particles,
        controller: _controller,
        onTapCard: _openPage,
        darkMode: _darkMode,
        textColor: textColor,
      ),
      _SettingsPage(
        darkMode: _darkMode,
        onToggleDarkMode: (value) {
          setState(() => _darkMode = value);
        },
      ),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: _darkMode ? Colors.grey.shade500 : Colors.grey,
        backgroundColor: _darkMode ? Colors.grey.shade900 : Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: "Configuración",
          ),
        ],
      ),
    );
  }
}

// Acá inicia el espacio de los botones
class _HomeContent extends StatelessWidget {
  final List<_Particle> particles;
  final AnimationController controller;
  final Function(String) onTapCard;
  final bool darkMode;
  final Color textColor;

  const _HomeContent({
    required this.particles,
    required this.controller,
    required this.onTapCard,
    required this.darkMode,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            return CustomPaint(
              painter: _ParticlePainter(particles, controller.value,
                  darkMode ? Colors.orange.shade200 : Colors.orange),
              child: Container(),
            );
          },
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              _HeaderSection(darkMode: darkMode),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  children: [
                    _AnimatedCard(
                      color: Colors.orange.shade600,
                      icon: Icons.notifications_active_rounded,
                      title: "Notificaciones",
                      subtitle: "Revisa alertas y recordatorios del ganado",
                      onTap: () => onTapCard("Notificaciones"),
                      darkMode: darkMode,
                    ),
                    const SizedBox(height: 25),
                    _AnimatedCard(
                      color: Colors.deepOrange.shade400,
                      icon: Icons.task_alt_rounded,
                      title: "Tareas",
                      subtitle: "Gestiona vacunaciones, alimentaciones y más",
                      onTap: () => onTapCard("Tareas"),
                      darkMode: darkMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Esta madre es el header
class _HeaderSection extends StatelessWidget {
  final bool darkMode;

  const _HeaderSection({required this.darkMode});

  @override
  Widget build(BuildContext context) {
    final textGradient = darkMode
        ? const LinearGradient(
            colors: [Colors.white, Color(0xFFFFE0B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Colors.white, Color(0xFFFFE082)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: darkMode
              ? [const Color(0xFF2E2E2E), const Color(0xFF1B1B1B)]
              : [const Color(0xFFFF9F43), const Color(0xFFFF6F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 25, right: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => textGradient.createShader(bounds),
              child: Text(
                "Panel principal",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white, // modo negrito
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              transform: Matrix4.translationValues(
                darkMode ? 10 : -10,
                0,
                0,
              ),
              child: const Icon(
                Icons.agriculture_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Esto es lo de la configuración
class _SettingsPage extends StatelessWidget {
  final bool darkMode;
  final Function(bool) onToggleDarkMode;

  const _SettingsPage({
    required this.darkMode,
    required this.onToggleDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          darkMode ? const Color(0xFF121212) : const Color(0xFFFFF4E6),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Text(
              "Configuración",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: darkMode ? Colors.white : const Color(0xFF5A3E1B),
              ),
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: const Text("Modo oscuro"),
              value: darkMode,
              onChanged: onToggleDarkMode,
              activeColor: Colors.deepOrange,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.deepOrange),
              title: Text(
                "Cerrar sesión",
                style: TextStyle(
                  color: darkMode ? Colors.white70 : Colors.black,
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Sesión cerrada")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Animaciones
class _AnimatedCard extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool darkMode;

  const _AnimatedCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.darkMode,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.darkMode ? Colors.grey.shade900 : Colors.white;
    final textColor =
        widget.darkMode ? Colors.white.withOpacity(0.9) : const Color(0xFF5A3E1B);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border(
              left: BorderSide(color: widget.color, width: 8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(widget.icon, size: 36, color: widget.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textColor)),
                    const SizedBox(height: 4),
                    Text(widget.subtitle,
                        style: TextStyle(
                            fontSize: 14,
                            color: widget.darkMode
                                ? Colors.grey.shade400
                                : Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Estas son las particulas, no le muevan nada porque alch poco entendi del tuto
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
