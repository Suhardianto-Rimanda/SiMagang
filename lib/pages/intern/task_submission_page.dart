import 'dart:io';
import 'package:app_simagang/api/intern_service.dart';
import 'package:app_simagang/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

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

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitTask() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih file untuk diunggah.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await _internService.submitTask(widget.task.id, file: _selectedFile);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil dikumpulkan!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengumpulkan tugas. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
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
            const Text(
              'Kumpulkan Tugas Anda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Pilih File'),
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
                    : const Text('Kumpulkan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
