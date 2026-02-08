import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spor Takip',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ExerciseTrackerPage(),
    );
  }
}

class ExerciseTrackerPage extends StatefulWidget {
  const ExerciseTrackerPage({super.key});

  @override
  State<ExerciseTrackerPage> createState() => _ExerciseTrackerPageState();
}

class _ExerciseTrackerPageState extends State<ExerciseTrackerPage> {
  final List<Map<String, dynamic>> _exercises = [
    {'name': '10 şınav', 'done': false},
    {'name': '20 mekik', 'done': false},
    {'name': '15 squat', 'done': false},
    {'name': '50 şınav', 'done': false},
  ];

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _saveExercises() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saveList = _exercises.map((e) {
      return '${e['name']}||${e['done']}';
    }).toList();
    await prefs.setStringList('exercises', saveList);
  }

  Future<void> _loadExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList('exercises');
    if (savedData != null) {
      setState(() {
        _exercises.clear();
        for (var item in savedData) {
          final parts = item.split('||');
          if (parts.length == 2) {
            _exercises.add({
              'name': parts[0],
              'done': parts[1] == 'true',
            });
          }
        }
      });
    }
  }

  void _toggleDone(int index) {
    setState(() {
      _exercises[index]['done'] = !_exercises[index]['done'];
    });
    _saveExercises();
  }

  void _addExercise(String name) {
    if (name.trim().isEmpty) return;
    setState(() {
      _exercises.add({'name': name.trim(), 'done': false});
    });
    _saveExercises();
    _textController.clear();
    Navigator.of(context).pop();
  }

  void _resetExercises() {
    setState(() {
      for (var exercise in _exercises) {
        exercise['done'] = false;
      }
    });
    _saveExercises();
  }

  void _deleteExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
    _saveExercises();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Egzersiz Ekle'),
        content: TextField(
          controller: _textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Egzersiz adı'),
          onSubmitted: _addExercise,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _textController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => _addExercise(_textController.text),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bugünkü Egzersizler'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tümünü sıfırla',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Egzersizleri Sıfırla"),
                  content: const Text("Tüm işaretlemeleri sıfırlamak istiyor musunuz?"),
                  actions: [
                    TextButton(
                      child: const Text("İptal"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      child: const Text("Sıfırla"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetExercises();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _exercises.length,
        itemBuilder: (context, index) {
          final exercise = _exercises[index];
          return ListTile(
            leading: Checkbox(
              value: exercise['done'],
              onChanged: (_) => _toggleDone(index),
            ),
            title: Text(
              exercise['name'],
              style: TextStyle(
                color: exercise['done'] ? Colors.red : null,
                decoration: exercise['done'] ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Egzersizi Sil"),
                    content: Text("“${exercise['name']}” silinsin mi?"),
                    actions: [
                      TextButton(
                        child: const Text("İptal"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      ElevatedButton(
                        child: const Text("Sil"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deleteExercise(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: 'Yeni egzersiz ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}
