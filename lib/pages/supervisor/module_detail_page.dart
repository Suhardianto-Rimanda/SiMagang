// lib/pages/supervisor/module_detail_page.dart

import 'package:app_simagang/api/supervisor_service.dart';
import 'package:app_simagang/models/learning_module_model.dart';
import 'package:app_simagang/models/learning_progress_model.dart';
import 'package:flutter/material.dart';

class ModuleDetailPage extends StatefulWidget {
  final LearningModuleModel module;

  const ModuleDetailPage({super.key, required this.module});

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  // PERBAIKAN: Deklarasi variabel yang benar
  late Future<List<LearningProgressModel>> _progressFuture;
  final SupervisorService _supervisorService = SupervisorService();

  @override
  void initState() {
    super.initState();
    _progressFuture = _supervisorService.getModuleProgress(widget.module.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.module.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.module.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.module.description),
            const Divider(height: 32),
            const Text(
              'Progress Peserta Magang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<LearningProgressModel>>(
                future: _progressFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Gagal memuat progress: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada progress untuk modul ini.'));
                  }

                  final progresses = snapshot.data!;
                  return ListView.builder(
                    itemCount: progresses.length,
                    itemBuilder: (context, index) {
                      final progress = progresses[index];
                      return Card(
                        child: ListTile(
                          title: Text(progress.internName ?? 'Nama Intern Tidak Ada'),
                          subtitle: Text(progress.moduleTitle ?? 'Tanpa Judul Progress'),
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
            ),
          ],
        ),
      ),
    );
  }
}
