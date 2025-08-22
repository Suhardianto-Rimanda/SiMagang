import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class EditUserPage extends StatefulWidget {
  final UserModel user;

  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _newPasswordController = TextEditingController();
  late TextEditingController _divisionController;
  late TextEditingController _schoolOriginController;
  late TextEditingController _majorController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _birthDateController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  late String _selectedRole;
  String? _selectedGender;
  String? _selectedInternType;
  String? _selectedSupervisorId;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = widget.user;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _selectedRole = user.role.name;

    final internData = user.intern;
    final supervisorData = user.supervisor;
    _divisionController = TextEditingController(text: internData?.division ?? supervisorData?.division ?? '');
    _schoolOriginController = TextEditingController(text: internData?.schoolOrigin ?? '');
    _majorController = TextEditingController(text: internData?.major ?? '');
    _selectedGender = internData?.gender;
    _phoneNumberController = TextEditingController(text: internData?.phoneNumber ?? '');
    _birthDateController = TextEditingController(text: internData?.birthDate ?? '');
    _startDateController = TextEditingController(text: internData?.startDate ?? '');
    _endDateController = TextEditingController(text: internData?.endDate ?? '');
    _selectedInternType = internData?.internType;
    _selectedSupervisorId = internData?.supervisor?.id;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime(2100));
    if (picked != null) {
      setState(() => controller.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    Map<String, dynamic> userData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'full_name': _nameController.text,
    };

    if (_newPasswordController.text.isNotEmpty) {
      userData['password'] = _newPasswordController.text;
    }

    if (_selectedRole == 'supervisor') {
      userData['division'] = _divisionController.text;
    } else if (_selectedRole == 'intern') {
      userData.addAll({
        'division': _divisionController.text,
        'school_origin': _schoolOriginController.text,
        'major': _majorController.text,
        'gender': _selectedGender,
        'phone_number': _phoneNumberController.text,
        'birth_date': _birthDateController.text,
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
        'intern_type': _selectedInternType,
        'supervisor_id': _selectedSupervisorId,
      });
    }

    await userProvider.updateUser(widget.user.id, userData);

    if (mounted) {
      final status = userProvider.operationStatus;
      final message = status == UserOperationStatus.success
          ? 'Pengguna berhasil diperbarui'
          : 'Error: ${userProvider.errorMessage}';
      final color = status == UserOperationStatus.success ? Colors.green : Colors.red;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: color,
      ));
      if (status == UserOperationStatus.success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Pengguna')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoFields(),
              const SizedBox(height: 20),
              _buildRoleSpecificFields(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Simpan Perubahan'),
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
        TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Lengkap'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
        const SizedBox(height: 16),
        TextFormField(
          controller: _newPasswordController,
          decoration: const InputDecoration(labelText: 'Password Baru', hintText: 'Kosongkan jika tidak diubah'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: TextEditingController(text: _selectedRole),
          decoration: const InputDecoration(labelText: 'Role'),
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildRoleSpecificFields() {
    if (_selectedRole == 'supervisor') {
      return TextFormField(controller: _divisionController, decoration: const InputDecoration(labelText: 'Divisi'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null);
    } else if (_selectedRole == 'intern') {
      return Column(
        children: [
          TextFormField(controller: _divisionController, decoration: const InputDecoration(labelText: 'Divisi'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _schoolOriginController, decoration: const InputDecoration(labelText: 'Asal Sekolah/Universitas'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _majorController, decoration: const InputDecoration(labelText: 'Jurusan'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(initialValue: _selectedGender, decoration: const InputDecoration(labelText: 'Jenis Kelamin'), items: ['Pria', 'Wanita'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), onChanged: (v) => setState(() => _selectedGender = v), validator: (v) => v == null ? 'Wajib dipilih' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _phoneNumberController, decoration: const InputDecoration(labelText: 'Nomor Telepon'), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _birthDateController, decoration: const InputDecoration(labelText: 'Tanggal Lahir'), readOnly: true, onTap: () => _selectDate(context, _birthDateController), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _startDateController, decoration: const InputDecoration(labelText: 'Tanggal Mulai'), readOnly: true, onTap: () => _selectDate(context, _startDateController), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _endDateController, decoration: const InputDecoration(labelText: 'Tanggal Selesai'), readOnly: true, onTap: () => _selectDate(context, _endDateController), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(initialValue: _selectedInternType, decoration: const InputDecoration(labelText: 'Jenis Magang'), items: ['school', 'college'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setState(() => _selectedInternType = v), validator: (v) => v == null ? 'Wajib dipilih' : null),
          const SizedBox(height: 16),
          Consumer<UserProvider>(
            builder: (context, provider, child) {
              final uniqueSupervisors = {for (var s in provider.supervisors) s.id: s}.values.toList();
              return DropdownButtonFormField<String>(
                initialValue: _selectedSupervisorId,
                decoration: const InputDecoration(labelText: 'Supervisor'),
                items: uniqueSupervisors.map((s) => DropdownMenuItem(value: s.id, child: Text(s.fullName))).toList(),
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
