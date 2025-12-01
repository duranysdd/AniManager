import 'package:flutter/material.dart';

class AyudaPage extends StatelessWidget {
  final bool darkMode;
  const AyudaPage({super.key, required this.darkMode});

  @override
  Widget build(BuildContext context) {
    final dark = darkMode;
    final bg = dark ? const Color(0xFF121212) : const Color(0xFFFFF4E6);
    final textColor = dark ? Colors.white : const Color(0xFF5A3E1B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Centro de ayuda'),
        backgroundColor: dark ? Colors.grey.shade900 : Colors.deepOrange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ---------------- TÍTULO ----------------
          Text(
            'Preguntas frecuentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          // ------------ FAQ 4 ------------
          ExpansionTile(
            title: Text(
              '¿Cómo veo mis tareas pendientes?',
              style: TextStyle(color: textColor),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Ingresa a la sección “Tareas”.\n'
                  'Ahí verás una lista de actividades por realizar con sus fechas y prioridades.',
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),

          // ------------ FAQ 6 ------------
          ExpansionTile(
            title: Text('¿Cómo cambiar a modo oscuro?', style: TextStyle(color: textColor)),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Ve a Configuración y activa la opción “Modo oscuro”.\n'
                  'El cambio se aplica inmediatamente.',
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),

          // ------------ FAQ 7 ------------
          ExpansionTile(
            title: Text(
              '¿Cómo cambio mi información personal?',
              style: TextStyle(color: textColor),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Ve a Configuración → Mi perfil.\n'
                  'Puedes cambiar tu nombre y correo, y luego presionar “Guardar”.\n'
                  'Tu rol siempre será “Personal” y no puede modificarse.',
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),

          // ------------ FAQ 8 ------------
          ExpansionTile(
            title: Text(
              'No recibo notificaciones, ¿qué hago?',
              style: TextStyle(color: textColor),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '- Asegura que las notificaciones están activadas desde Configuración.\n'
                  '- Revisa si tu celular permite notificaciones para AniManager.\n'
                  '- Comprueba que tienes conexión a internet.\n'
                  '- Reinicia la app si el problema continúa.',
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // ---------------- SECCIÓN DE CONTACTO ----------------
          Text(
            'Soporte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),

          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text('Contacto del equipo', style: TextStyle(color: textColor)),
            subtitle: const Text('soporte@animanager.app'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
