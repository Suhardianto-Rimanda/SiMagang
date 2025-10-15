import 'package:app_simagang/models/learning_progress_model.dart';
import 'package:flutter/material.dart';

class ProgressDetailPage extends StatelessWidget {
  final LearningProgressModel progress;

  const ProgressDetailPage({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(progress.moduleTitle ?? 'Detail Progress'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Progress',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildDetailRow('Peserta Magang', progress.internName ?? 'N/A'),
            _buildDetailRow('Modul', progress.moduleTitle ?? 'N/A'),
            _buildDetailRow('Judul Progress', progress.moduleTitle ?? 'N/A'),
            _buildDetailRow('Status', progress.progressStatus),
            const SizedBox(height: 16),
            const Text(
              'Deskripsi:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(progress.description ?? 'Tidak ada deskripsi.'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
