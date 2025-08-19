// lib/pages/admin/add_edit_user_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class AddEditUserPage extends StatefulWidget {
  final UserModel? user;

  const AddEditUserPage({super.key, this.user});

  @override
  State<AddEditUserPage> createState() => _AddEditUserPageState();
}

class _AddEditUserPageState extends State<AddEditUserPage> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditMode => widget.user != null;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _divisionController;
  late TextEditingController _schoolOriginController;
  late TextEditingController _majorController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _birthDateController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  String _selectedRole = 'intern';
  String? _selectedGender;
  String? _selectedSupervisorId;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final internData = widget.user?.intern;
    final supervisorData = widget.user?.supervisor;

    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController(); 

    _selectedRole = widget.user?.role.name ?? 'intern';

    _divisionController = TextEditingController(text: internData?.division ?? supervisorData?.division ?? '');
    _schoolOriginController = TextEditingController(text: internData?.schoolOrigin ?? '');
    _majorController = TextEditingController(text: internData?.major ?? '');
    _selectedGender = internData?.gender;
    _phoneNumberController = TextEditingController(text: internData?.phoneNumber ?? '');
    _birthDateController = TextEditingController(text: internData?.birthDate ?? '');
    _startDateController = TextEditingController(text: internData?.startDate ?? '');
    _endDateController = TextEditingController(text: internData?.endDate ?? '');
    _selectedSupervisorId = internData?.supervisor?.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _divisionController.dispose();
    _schoolOriginController.dispose();
    _majorController.dispose();
    _phoneNumberController.dispose();
    _birthDateController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    Map<String, dynamic> userData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'role': _selectedRole,
    };

    if (_passwordController.text.isNotEmpty) {
      userData['password'] = _passwordController.text;
    }

    if (_selectedRole == 'supervisor') {
      userData['full_name'] = _nameController.text;
      userData['division'] = _divisionController.text;
    } else if (_selectedRole == 'intern') {
      userData['full_name'] = _nameController.text;
      userData.addAll({
        'division': _divisionController.text,
        'school_origin': _schoolOriginController.text,
        'major': _majorController.text,
        'gender': _selectedGender,
        'phone_number': _phoneNumberController.text,
        'birth_date': _birthDateController.text,
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
        'supervisor_id': _selectedSupervisorId,
      });
    }

    if (_isEditMode) {
      await userProvider.updateUser(widget.user!.id, userData);
    } else {
      await userProvider.addUser(userData);
    }

    if (mounted) {
      if (userProvider.operationStatus == UserOperationStatus.success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengguna berhasil ${_isEditMode ? 'diperbarui' : 'ditambahkan'}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${userProvider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Ubah Pengguna' : 'Tambah Pengguna'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoFields(),
              const SizedBox(height: 16),
              _buildRoleSpecificFields(),
              const SizedBox(height: 32),
              Consumer<UserProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.operationStatus == UserOperationStatus.loading
                        ? null
                        : _submitForm,
                    child: provider.operationStatus == UserOperationStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isEditMode ? 'Simpan Perubahan' : 'Tambah Pengguna'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nama Lengkap'),
          validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v!.isEmpty ? 'Email tidak boleh kosong' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: _isEditMode ? 'Kosongkan jika tidak ingin mengubah' : null,
          ),
          obscureText: true,
          validator: (v) {
            if (!_isEditMode && v!.isEmpty) return 'Password tidak boleh kosong';
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: const InputDecoration(labelText: 'Role'),
          items: ['intern', 'supervisor', 'admin']
              .map((role) => DropdownMenuItem(value: role, child: Text(role)))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedRole = value);
          },
        ),
      ],
    );
  }

  Widget _buildRoleSpecificFields() {
    if (_selectedRole == 'supervisor') {
      return TextFormField(
        controller: _divisionController,
        decoration: const InputDecoration(labelText: 'Divisi'),
        validator: (v) => v!.isEmpty ? 'Divisi tidak boleh kosong' : null,
      );
    } else if (_selectedRole == 'intern') {
      return Column(
        children: [
          TextFormField(
            controller: _divisionController,
            decoration: const InputDecoration(labelText: 'Divisi'),
            validator: (v) => v!.isEmpty ? 'Divisi tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _schoolOriginController,
            decoration: const InputDecoration(labelText: 'Asal Sekolah/Universitas'),
            validator: (v) => v!.isEmpty ? 'Asal sekolah tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _majorController,
            decoration: const InputDecoration(labelText: 'Jurusan'),
            validator: (v) => v!.isEmpty ? 'Jurusan tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
            items: ['Laki-laki', 'Perempuan']
                .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                .toList(),
            onChanged: (value) => setState(() => _selectedGender = value),
            validator: (v) => v == null ? 'Pilih jenis kelamin' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(labelText: 'Nomor Telepon'),
            keyboardType: TextInputType.phone,
            validator: (v) => v!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _birthDateController,
            decoration: const InputDecoration(labelText: 'Tanggal Lahir', hintText: 'YYYY-MM-DD'),
            readOnly: true,
            onTap: () => _selectDate(context, _birthDateController),
            validator: (v) => v!.isEmpty ? 'Tanggal lahir tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _startDateController,
            decoration: const InputDecoration(labelText: 'Tanggal Mulai', hintText: 'YYYY-MM-DD'),
            readOnly: true,
            onTap: () => _selectDate(context, _startDateController),
            validator: (v) => v!.isEmpty ? 'Tanggal mulai tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _endDateController,
            decoration: const InputDecoration(labelText: 'Tanggal Selesai', hintText: 'YYYY-MM-DD'),
            readOnly: true,
            onTap: () => _selectDate(context, _endDateController),
            validator: (v) => v!.isEmpty ? 'Tanggal selesai tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          Consumer<UserProvider>(
            builder: (context, provider, child) {
              final supervisorItems = provider.supervisors;

              // FIX: Logika yang paling sederhana dan aman
              final uniqueSupervisorMap = {for (var s in supervisorItems) s.id: s};
              final uniqueSupervisorList = uniqueSupervisorMap.values.toList();

              String? currentValue = _selectedSupervisorId;
              if (currentValue != null && !uniqueSupervisorMap.containsKey(currentValue)) {
                currentValue = null;
              }

              return DropdownButtonFormField<String>( // FIX: Ubah ke String
                value: currentValue,
                decoration: const InputDecoration(labelText: 'Supervisor'),
                items: uniqueSupervisorList.map((s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(s.fullName),
                )).toList(),
                onChanged: (value) => setState(() => _selectedSupervisorId = value),
                validator: (v) => v == null ? 'Wajib dipilih' : null,
              );
            },
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
