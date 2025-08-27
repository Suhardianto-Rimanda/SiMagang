// lib/pages/supervisor/learning_progress_page.dart

import 'package:app_simagang/providers/supervisor_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_simagang/models/learning_progress_model.dart';

class LearningProgressPage extends StatefulWidget {
  const LearningProgressPage({super.key});

  @override
  State<LearningProgressPage> createState() => _LearningProgressPageState();
}

class _LearningProgressPageState extends State<LearningProgressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupervisorProvider>(context, listen: false).fetchLearningProgress();
    });
  }

  Map<String, List<LearningProgressModel>> _groupProgressByIntern(List<LearningProgressModel> progresses) {
    Map<String, List<LearningProgressModel>> grouped = {};
    for (var progress in progresses) {
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
      body: Consumer<SupervisorProvider>(
        builder: (context, provider, child) {
          if (provider.progressesState == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.progressesState == ViewState.error) {
            return Center(child: Text('Gagal memuat data: ${provider.errorMessage}'));
          }
          if (provider.progresses.isEmpty) {
            return const Center(child: Text('Belum ada progres pembelajaran.'));
          }

          final groupedProgress = _groupProgressByIntern(provider.progresses);
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
                    child: Text(internName.isNotEmpty ? internName[0] : '?'),
                  ),
                  title: Text(internName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${progresses.length} modul ditugaskan'),
                  children: progresses.map((progress) {
                    return ListTile(
                      title: Text(progress.moduleTitle ?? 'Judul Modul Tidak Ada'),
                      trailing: Text(
                        progress.progressStatus,
                        style: TextStyle(
                          color: progress.progressStatus.toLowerCase() == 'done' ? Colors.green : Colors.orange,
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
