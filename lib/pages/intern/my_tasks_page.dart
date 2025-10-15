import 'package:app_simagang/pages/intern/task_submission_page.dart';
import 'package:app_simagang/providers/intern_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage> {
  @override
  void initState() {
    super.initState();
    // Memanggil business logic dari provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InternProvider>(context, listen: false).fetchMyTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Saya'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      // Menggunakan Consumer untuk 'mendengarkan' perubahan state dari provider
      body: Consumer<InternProvider>(
        builder: (context, provider, child) {
          if (provider.tasksState == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.tasksState == ViewState.error) {
            return Center(child: Text('Gagal memuat data: ${provider.errorMessage}'));
          }
          if (provider.tasks.isEmpty) {
            return const Center(child: Text('Belum ada tugas yang diberikan.'));
          }

          final tasks = provider.tasks;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final bool isSubmitted = task.submission != null; // Cek apakah sudah ada submission

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.assignment),
                  title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Tenggat: ${DateFormat('dd MMMM yyyy').format(task.dueDate)}'),
                  // --- MODIFIKASI TAMPILAN TRAILING ---
                  trailing: isSubmitted
                      ? const Chip(
                    label: Text('Terkumpul', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  )
                      : const Icon(Icons.chevron_right),
                  // --- AKHIR MODIFIKASI ---
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskSubmissionPage(task: task),
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
