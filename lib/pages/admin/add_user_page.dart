import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _divisionController = TextEditingController();
  final _schoolOriginController = TextEditingController();
  final _majorController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // State
  String _selectedRole = 'intern';
  String? _selectedGender;
  String? _selectedSupervisorId;

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
    FocusScope.of(context).unfocus();

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    Map<String, dynamic> userData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'role': _selectedRole,
      'password': _passwordController.text,
      'full_name': _nameController.text,
    };

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
        'supervisor_id': _selectedSupervisorId,
      });
    }

    await userProvider.addUser(userData);

    if (mounted) {
      final status = userProvider.operationStatus;
      final message = status == UserOperationStatus.success
          ? 'Pengguna berhasil ditambahkan'
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
      appBar: AppBar(title: const Text('Tambah Pengguna')),
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
                child: const Text('Tambah Pengguna'),
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
        TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true, validator: (v) => v!.isEmpty ? 'Password wajib diisi' : null),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: const InputDecoration(labelText: 'Role'),
          items: ['intern', 'supervisor', 'admin'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (v) => setState(() => _selectedRole = v!),
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
          DropdownButtonFormField<String>(value: _selectedGender, decoration: const InputDecoration(labelText: 'Jenis Kelamin'), items: ['Laki-laki', 'Perempuan'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), onChanged: (v) => setState(() => _selectedGender = v), validator: (v) => v == null ? 'Wajib dipilih' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _phoneNumberController, decoration: const InputDecoration(labelText: 'Nomor Telepon'), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _birthDateController, decoration: const InputDecoration(labelText: 'Tanggal Lahir'), readOnly: true, onTap: () => _selectDate(context, _birthDateController), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _startDateController, decoration: const InputDecoration(labelText: 'Tanggal Mulai'), readOnly: true, onTap: () => _selectDate(context, _startDateController), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _endDateController, decoration: const InputDecoration(labelText: 'Tanggal Selesai'), readOnly: true, onTap: () => _selectDate(context, _endDateController), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
          const SizedBox(height: 16),
          Consumer<UserProvider>(
            builder: (context, provider, child) {
              final uniqueSupervisors = {for (var s in provider.supervisors) s.id: s}.values.toList();
              return DropdownButtonFormField<String>(
                value: _selectedSupervisorId,
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
