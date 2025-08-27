// lib/pages/admin/all_learning_progress_page.dart

import 'package:app_simagang/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllLearningProgressPage extends StatefulWidget {
  const AllLearningProgressPage({super.key});

  @override
  State<AllLearningProgressPage> createState() => _AllLearningProgressPageState();
}

class _AllLearningProgressPageState extends State<AllLearningProgressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchAllLearningProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Progress Magang'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.progressesState == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.progressesState == ViewState.error) {
            return Center(child: Text('Gagal memuat data: ${provider.errorMessage}'));
          }
          if (provider.progresses.isEmpty) {
            return const Center(child: Text('Tidak ada data progress.'));
          }

          final progresses = provider.progresses;
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
