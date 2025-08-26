// lib/pages/supervisor/add_assignment_page.dart

import 'package:app_simagang/api/module_service.dart';
import 'package:app_simagang/api/supervisor_service.dart';
import 'package:app_simagang/api/task_service.dart';
import 'package:app_simagang/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AssignmentType { module, task }

class AddAssignmentPage extends StatefulWidget {
  final AssignmentType type;

  const AddAssignmentPage({super.key, required this.type});

  @override
  State<AddAssignmentPage> createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();

  // Instance Services
  final SupervisorService _supervisorService = SupervisorService();
  final ModuleService _moduleService = ModuleService();
  final TaskService _taskService = TaskService();

  late Future<List<UserModel>> _internsFuture;
  final List<String> _selectedInternIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _internsFuture = _supervisorService.getSupervisorInterns();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedInternIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih minimal satu peserta magang.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      bool success = false;
      if (widget.type == AssignmentType.module) {
        success = await _moduleService.createAndAssignModule(
          title: _titleController.text,
          description: _descriptionController.text,
          internIds: _selectedInternIds,
        );
      } else {
        success = await _taskService.createAndAssignTask(
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _dueDateController.text,
          internIds: _selectedInternIds,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.type == AssignmentType.module ? 'Modul' : 'Tugas'} berhasil dibuat dan dikirim!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat ${widget.type == AssignmentType.module ? 'Modul' : 'Tugas'}. Coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = widget.type == AssignmentType.module ? 'Tambah Modul Baru' : 'Tambah Tugas Baru';

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              if (widget.type == AssignmentType.task) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dueDateController,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Tenggat',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: _selectDate,
                  validator: (value) => value!.isEmpty ? 'Tanggal tenggat tidak boleh kosong' : null,
                ),
              ],
              const SizedBox(height: 24),
              const Text('Bagikan Ke:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildInternList(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan dan Bagikan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInternList() {
    return FutureBuilder<List<UserModel>>(
      future: _internsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Tidak dapat memuat daftar peserta magang.');
        }

        final interns = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: interns.length,
          itemBuilder: (context, index) {
            final internUser = interns[index];
            final internData = internUser.intern;
            if (internData == null) return const SizedBox.shrink();

            return CheckboxListTile(
              title: Text(internData.fullName),
              subtitle: Text(internData.division ?? 'Tanpa Divisi'),
              value: _selectedInternIds.contains(internData.id),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedInternIds.add(internData.id);
                  } else {
                    _selectedInternIds.remove(internData.id);
                  }
                });
              },
            );
          },
        );
      },
    );
  }
}
