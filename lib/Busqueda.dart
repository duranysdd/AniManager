import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const List<String> _kAvailableCategories = [
  'Todas las Categorías',
  'Alimentacion', 
  'Limpieza',
  'Mantenimiento',
  'Administracion',
];

class SearchTasksPage extends StatefulWidget {
  final bool darkMode;

  const SearchTasksPage({super.key, required this.darkMode});

  @override
  State<SearchTasksPage> createState() => _SearchTasksPageState();
}

class _SearchTasksPageState extends State<SearchTasksPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late String currentUserEmail;

  String _searchText = '';
  String _selectedCategory = _kAvailableCategories.first;

  @override
  void initState() {
    super.initState();
    currentUserEmail = currentUser?.email ?? "sinemail@example.com";
  }
  Stream<QuerySnapshot> _streamAllTasks() {
    return FirebaseFirestore.instance
        .collection("tareas")
        .where("paraNombre", isEqualTo: currentUserEmail)
        .orderBy("fecha", descending: true)
        .snapshots();
  }

  List<DocumentSnapshot> _filterTasks(List<DocumentSnapshot> allTasks) {
    if (allTasks.isEmpty) return [];
    Iterable<DocumentSnapshot> filteredByText = allTasks.where((task) {
      final title = (task.get('titulo') as String? ?? '').toLowerCase();
      final description = (task.get('descripcion') as String? ?? '').toLowerCase();
      final searchText = _searchText.toLowerCase();

      if (searchText.isEmpty) return true;

      return title.contains(searchText) || description.contains(searchText);
    });

    if (_selectedCategory == _kAvailableCategories.first) {
      return filteredByText.toList();
    } else {
      return filteredByText.where((task) {
        final category = (task.get('categoria') as String? ?? '');
        return category == _selectedCategory;
      }).toList();
    }
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
        title: Text("Buscador de Tareas", style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Buscar por título o descripción...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(width: 10),

                DropdownButton<String>(
                  value: _selectedCategory,
                  icon: Icon(Icons.filter_list, color: textColor),
                  underline: Container(height: 1, color: textColor.withOpacity(0.5)),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  items: _kAvailableCategories
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _streamAllTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error al cargar tareas: ${snapshot.error}", style: TextStyle(color: textColor)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No hay tareas asignadas.", style: TextStyle(color: textColor)));
                }

                final allTasks = snapshot.data!.docs;
                final filteredTasks = _filterTasks(allTasks);

                if (filteredTasks.isEmpty) {
                  return Center(child: Text("No se encontraron resultados para los filtros seleccionados.", style: TextStyle(color: textColor)));
                }

                return ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final tareaDoc = filteredTasks[index];
                    final data = tareaDoc.data() as Map<String, dynamic>;
                    
                    final title = data['titulo'] as String? ?? 'Sin título';
                    final category = data['categoria'] as String? ?? 'N/A';
                    final date = data['fecha'] as String? ?? 'Fecha desconocida';
                    final completed = data['completada'] as bool? ?? false;
                    
                    return Card(
                      color: darkMode ? Colors.grey.shade800 : Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          completed ? Icons.check_circle : Icons.pending,
                          color: completed ? Colors.green : Colors.deepOrange,
                        ),
                        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                        subtitle: Text("Categoría: $category | Fecha: $date", style: TextStyle(color: textColor.withOpacity(0.7))),
                        onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Abriendo detalles de la tarea: $title')),
                            );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}