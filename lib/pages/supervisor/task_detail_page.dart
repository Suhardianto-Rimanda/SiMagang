// lib/pages/supervisor/task_detail_page.dart

import 'package:app_simagang/api/supervisor_service.dart';
import 'package:app_simagang/models/submission_model.dart';
import 'package:app_simagang/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Future<List<SubmissionModel>> _submissionsFuture;
  final SupervisorService _supervisorService = SupervisorService();

  @override
  void initState() {
    super.initState();
    _submissionsFuture = _supervisorService.getTaskSubmissions(widget.task.id);
  }

  Future<void> _launchUrl(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Path file tidak valid.')),
      );
      return;
    }

    try {
      final String? baseUrlString = dotenv.env['BASE_URL'];
      if (baseUrlString == null || baseUrlString.isEmpty) {
        throw Exception('BASE_URL tidak dikonfigurasi di .env');
      }

      // Membangun URL yang benar dengan mengambil origin dari BASE_URL
      final apiUri = Uri.parse(baseUrlString);
      final storageUrl = '${apiUri.scheme}://${apiUri.host}:${apiUri.port}/storage/$relativePath';

      final urlToLaunch = Uri.parse(storageUrl);

      if (await canLaunchUrl(urlToLaunch)) {
        await launchUrl(urlToLaunch, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Tidak dapat membuka $storageUrl');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Tenggat: ${DateFormat('dd MMMM yyyy').format(widget.task.dueDate)}'),
            const SizedBox(height: 8),
            Text(widget.task.description),
            const Divider(height: 32),
            const Text(
              'Pengumpulan Tugas (Submission)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<SubmissionModel>>(
                future: _submissionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada tugas yang dikumpulkan.'));
                  }

                  final submissions = snapshot.data!;
                  return ListView.builder(
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final submission = submissions[index];
                      final attempt = submission.attempts.isNotEmpty ? submission.attempts.first : null;

                      // PERBAIKAN: Mengakses nama dengan aman dari model yang sudah diperbarui
                      final internName = submission.intern?.fullName ?? 'Nama Intern Tidak Ada';

                      return Card(
                        child: ListTile(
                          title: Text(internName),
                          subtitle: Text('Dikumpulkan pada: ${DateFormat('dd MMM yyyy, HH:mm').format(submission.submissionDate)}'),
                          trailing: attempt?.filePath != null
                              ? ElevatedButton(
                            onPressed: () => _launchUrl(attempt!.filePath),
                            child: const Text('Lihat File'),
                          )
                              : const Text('Tidak ada file'),
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
