// lib/pages/admin/all_learning_progress_page.dart
import 'package:app_simagang/api/admin_service.dart';
import 'package:app_simagang/models/learning_progress_model.dart';
import 'package:flutter/material.dart';

class AllLearningProgressPage extends StatefulWidget {
  const AllLearningProgressPage({super.key});

  @override
  State<AllLearningProgressPage> createState() => _AllLearningProgressPageState();
}

class _AllLearningProgressPageState extends State<AllLearningProgressPage> {
  late Future<List<LearningProgressModel>> _progressFuture;
  final AdminService _adminService = AdminService();

  @override
  void initState() {
    super.initState();
    _progressFuture = _adminService.getAllLearningProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Progress Magang'),
      ),
      body: FutureBuilder<List<LearningProgressModel>>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data progress.'));
          }

          final progresses = snapshot.data!;
          return ListView.builder(
            itemCount: progresses.length,
            itemBuilder: (context, index) {
              final progress = progresses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(progress.moduleTitle ?? 'Tanpa Judul Modul'),
                  subtitle: Text(progress.internName ?? 'Nama Intern'),
                  trailing: Text(
                    progress.progressStatus,
                    style: TextStyle(
                      color: progress.progressStatus.toLowerCase() == 'done' ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
