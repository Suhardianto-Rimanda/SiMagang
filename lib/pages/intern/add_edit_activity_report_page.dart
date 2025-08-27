import 'package:app_simagang/api/intern_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEditActivityReportPage extends StatefulWidget {
  const AddEditActivityReportPage({super.key});

  @override
  State<AddEditActivityReportPage> createState() => _AddEditActivityReportPageState();
}

class _AddEditActivityReportPageState extends State<AddEditActivityReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final InternService _internService = InternService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      bool success = await _internService.createActivityReport(
        title: _titleController.text,
        description: _descriptionController.text,
        reportDate: _dateController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.pop(context, true); // Kirim 'true' untuk menandakan sukses
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan laporan. Coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Aktivitas'),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi Aktivitas'),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Tanggal Laporan'),
                readOnly: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Laporan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
