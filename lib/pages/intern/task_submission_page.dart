import 'dart:io';
import 'package:app_simagang/api/intern_service.dart';
import 'package:app_simagang/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TaskSubmissionPage extends StatefulWidget {
  final Task task;

  const TaskSubmissionPage({super.key, required this.task});

  @override
  State<TaskSubmissionPage> createState() => _TaskSubmissionPageState();
}

class _TaskSubmissionPageState extends State<TaskSubmissionPage> {
  final InternService _internService = InternService();
  File? _selectedFile;
  bool _isLoading = false;

  late bool isSubmitted;
  late bool isPastDeadline;

  @override
  void initState() {
    super.initState();
    isSubmitted = widget.task.submission != null;
    isPastDeadline = DateTime.now().isAfter(widget.task.dueDate);
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitTask() async {
    // Validasi hanya jika ini adalah pengumpulan baru dan file belum dipilih
    if (!isSubmitted && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih file untuk diunggah.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _internService.submitTask(widget.task.id, file: _selectedFile);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      if (result['success']) {
        Navigator.pop(context, true); // Kirim true untuk refresh halaman sebelumnya
      }
    }
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
        // Menggunakan mode eksternal agar dibuka di browser atau PDF viewer
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
    String appBarTitle = isSubmitted ? 'Edit Pengumpulan' : 'Kumpulkan Tugas';
    String buttonText = isSubmitted ? 'Update Pengumpulan' : 'Kumpulkan';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: SingleChildScrollView(
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

            // --- TAMPILAN KONDISIONAL BERDASARKAN STATUS ---
            if (isSubmitted && isPastDeadline)
              _buildDeadlinePassedView()
            else
              _buildSubmissionView(buttonText),
          ],
        ),
      ),
    );
  }

  // Widget untuk tampilan pengumpulan/edit
  Widget _buildSubmissionView(String buttonText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSubmitted && widget.task.submission!.attempts.isNotEmpty) ...[
          const Text(
            'File Terkumpul Saat Ini:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.task.submission!.attempts.map((attempt) => ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: Text(attempt.filePath.split('/').last, overflow: TextOverflow.ellipsis),
            onTap: () => _launchUrl(attempt.filePath),
          )),
          const SizedBox(height: 16),
          const Text(
            'Ganti File (Opsional):',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(isSubmitted ? 'Ganti File' : 'Pilih File'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedFile?.path.split('/').last ?? 'Belum ada file dipilih',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitTask,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(buttonText),
          ),
        ),
      ],
    );
  }

  // Widget untuk tampilan jika sudah lewat deadline
  Widget _buildDeadlinePassedView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Tugas telah dikumpulkan dan tenggat waktu telah berakhir. Anda tidak dapat mengubahnya lagi.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
