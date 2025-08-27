import 'package:app_simagang/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Tenggat: ${DateFormat('dd MMMM yyyy').format(task.dueDate)}'),
            const SizedBox(height: 8),
            Text(task.description),
            const Divider(height: 32),
            const Text(
              'Pengumpulan Tugas (Submission)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // TODO: Implement API call to get submissions for this task
            // and display them in a list. Each item should have a button
            // to view the submitted file.
            const Expanded(
              child: Center(
                child: Text('Fitur untuk menampilkan submission intern akan ditambahkan di sini.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
