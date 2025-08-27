// lib/pages/intern/module_feedback_page.dart

import 'package:app_simagang/api/intern_service.dart';
import 'package:app_simagang/models/learning_module_model.dart';
import 'package:flutter/material.dart';

class ModuleFeedbackPage extends StatefulWidget {
  final LearningModuleModel module;

  const ModuleFeedbackPage({super.key, required this.module});

  @override
  State<ModuleFeedbackPage> createState() => _ModuleFeedbackPageState();
}

class _ModuleFeedbackPageState extends State<ModuleFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(); // Ditambahkan
  final _feedbackController = TextEditingController();
  final InternService _internService = InternService();

  // PERBAIKAN: Nilai disesuaikan dengan backend
  String _selectedStatus = 'in_progress';
  bool _isLoading = false;

  // Opsi untuk dropdown agar UI tetap ramah pengguna
  final Map<String, String> _statusOptions = {
    'in_progress': 'In Progress',
    'done': 'Completed',
  };

  Future<void> _submitProgress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      bool success = await _internService.submitLearningProgress(
        moduleId: widget.module.id,
        title: _titleController.text, // Ditambahkan
        description: _feedbackController.text,
        status: _selectedStatus,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress berhasil dikirim!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim progress. Coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.module.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                'Update Progress Hari Ini',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Field untuk Title ditambahkan
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Progress',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsikan progress Anda...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                // Deskripsi sekarang boleh kosong (nullable)
                validator: null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status Pengerjaan',
                  border: OutlineInputBorder(),
                ),
                // PERBAIKAN: Menggunakan map untuk memisahkan nilai dan tampilan
                items: _statusOptions.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key, // Nilai yang dikirim: 'in_progress' atau 'done'
                    child: Text(entry.value), // Teks yang ditampilkan: 'In Progress' atau 'Completed'
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProgress,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Kirim Progress'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
