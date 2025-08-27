import 'package:app_simagang/api/task_service.dart';
import 'package:app_simagang/models/task_model.dart';
import 'package:flutter/material.dart';
import 'task_detail_page.dart';
import 'package:intl/intl.dart';

class ManageTasksPage extends StatefulWidget {
  const ManageTasksPage({super.key});

  @override
  State<ManageTasksPage> createState() => _ManageTasksPageState();
}

class _ManageTasksPageState extends State<ManageTasksPage> {
  late Future<List<Task>> _tasksFuture;
  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _tasksFuture = _taskService.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Tugas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada tugas yang dibuat.'));
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.assignment),
                  title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Tenggat: ${DateFormat('dd MMMM yyyy').format(task.dueDate)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailPage(task: task),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
