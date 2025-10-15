// lib/pages/supervisor/intern_progress_detail_page.dart

import 'package:app_simagang/api/supervisor_service.dart';
import 'package:app_simagang/models/learning_progress_model.dart';
import 'package:app_simagang/models/user_model.dart';
import 'package:flutter/material.dart';

class InternProgressDetailPage extends StatefulWidget {
  final UserModel internUser;

  const InternProgressDetailPage({super.key, required this.internUser});

  @override
  State<InternProgressDetailPage> createState() => _InternProgressDetailPageState();
}

class _InternProgressDetailPageState extends State<InternProgressDetailPage> {
  late Future<List<LearningProgressModel>> _progressFuture;
  final SupervisorService _supervisorService = SupervisorService();

  @override
  void initState() {
    super.initState();
    // Memastikan intern data tidak null sebelum mengambil ID
    if (widget.internUser.intern != null) {
      _progressFuture = _supervisorService.getInternProgress(widget.internUser.intern!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menangani kasus jika data intern tidak ada
    if (widget.internUser.intern == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Data intern tidak lengkap.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Progress: ${widget.internUser.intern!.fullName}'),
      ),
      body: FutureBuilder<List<LearningProgressModel>>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat progress: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Peserta ini belum memiliki progress.'));
          }

          final progresses = snapshot.data!;
          return ListView.builder(
            itemCount: progresses.length,
            itemBuilder: (context, index) {
              final progress = progresses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(progress.moduleTitle ?? 'Tanpa Judul Modul', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(progress.moduleTitle ?? 'Tanpa judul progress'),
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
