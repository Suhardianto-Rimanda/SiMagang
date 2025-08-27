// lib/pages/supervisor/learning_progress_page.dart

import 'package:app_simagang/api/supervisor_service.dart';
import 'package:app_simagang/models/learning_progress_model.dart';
import 'package:flutter/material.dart';

class LearningProgressPage extends StatefulWidget {
  const LearningProgressPage({super.key});

  @override
  State<LearningProgressPage> createState() => _LearningProgressPageState();
}

class _LearningProgressPageState extends State<LearningProgressPage> {
  late Future<List<LearningProgressModel>> _progressFuture;
  final SupervisorService _supervisorService = SupervisorService();

  @override
  void initState() {
    super.initState();
    _progressFuture = _supervisorService.getLearningProgress();
  }

  // Fungsi untuk mengelompokkan progres berdasarkan nama intern
  Map<String, List<LearningProgressModel>> _groupProgressByIntern(List<LearningProgressModel> progresses) {
    Map<String, List<LearningProgressModel>> grouped = {};
    for (var progress in progresses) {
      // PERBAIKAN: Mengambil nama dari properti 'internName' yang baru
      final internName = progress.internName ?? 'Nama Tidak Diketahui';
      if (grouped[internName] == null) {
        grouped[internName] = [];
      }
      grouped[internName]!.add(progress);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Pembelajaran'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<LearningProgressModel>>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada progres pembelajaran.'));
          }

          final groupedProgress = _groupProgressByIntern(snapshot.data!);
          final internNames = groupedProgress.keys.toList();

          return ListView.builder(
            itemCount: internNames.length,
            itemBuilder: (context, index) {
              final internName = internNames[index];
              final progresses = groupedProgress[internName]!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    child: Text(internName[0]),
                  ),
                  title: Text(internName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${progresses.length} modul ditugaskan'),
                  children: progresses.map((progress) {
                    return ListTile(
                      title: Text(progress.moduleTitle ?? 'Judul Modul Tidak Ada'),
                      trailing: Text(
                        progress.progressStatus,
                        style: TextStyle(
                          color: progress.progressStatus.toLowerCase() == 'completed' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
