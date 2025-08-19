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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF2563EB),
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${userProvider.errorMessage}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        title: Text(
          _isEditMode ? 'Ubah Pengguna' : 'Tambah Pengguna',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: 'Informasi Dasar',
                icon: Icons.person_outline,
                child: _buildBasicInfoFields(),
              ),
              const SizedBox(height: 20),
              if (_selectedRole != 'admin') ...[
                _buildSectionCard(
                  title: _selectedRole == 'intern' ? 'Informasi Magang' : 'Informasi Supervisor',
                  icon: _selectedRole == 'intern' ? Icons.school_outlined : Icons.supervisor_account_outlined,
                  child: _buildRoleSpecificFields(),
                ),
                const SizedBox(height: 32),
              ] else
                const SizedBox(height: 32),
              Consumer<UserProvider>(
                builder: (context, provider, child) {
                  return Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: provider.operationStatus == UserOperationStatus.loading
                          ? null
                          : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: provider.operationStatus == UserOperationStatus.loading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Text(
                        _isEditMode ? 'Simpan Perubahan' : 'Tambah Pengguna',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 16,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1F2937),
          ),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildBasicInfoFields() {
    return Column(
      children: [
        _buildCustomTextField(
          controller: _nameController,
          label: 'Nama Lengkap',
          validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
        ),
        const SizedBox(height: 20),
        _buildCustomTextField(
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v!.isEmpty ? 'Email tidak boleh kosong' : null,
        ),
        const SizedBox(height: 20),
        _buildCustomTextField(
          controller: _passwordController,
          label: 'Password',
          hint: _isEditMode ? 'Kosongkan jika tidak ingin mengubah' : null,
          obscureText: true,
          validator: (v) {
            if (!_isEditMode && v!.isEmpty) return 'Password tidak boleh kosong';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildCustomDropdown<String>(
          label: 'Role',
          value: _selectedRole,
          items: ['intern', 'supervisor', 'admin']
              .map((role) => DropdownMenuItem(
            value: role,
            child: Text(
              role.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ))
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
      return _buildCustomTextField(
        controller: _divisionController,
        label: 'Divisi',
        validator: (v) => v!.isEmpty ? 'Divisi tidak boleh kosong' : null,
      );
    } else if (_selectedRole == 'intern') {
      return Column(
        children: [
          _buildCustomTextField(
            controller: _divisionController,
            label: 'Divisi',
            validator: (v) => v!.isEmpty ? 'Divisi tidak boleh kosong' : null,
          ),
          const SizedBox(height: 20),
          _buildCustomTextField(
            controller: _schoolOriginController,
            label: 'Asal Sekolah/Universitas',
            validator: (v) => v!.isEmpty ? 'Asal sekolah tidak boleh kosong' : null,
          ),
          const SizedBox(height: 20),
          _buildCustomTextField(
            controller: _majorController,
            label: 'Jurusan',
            validator: (v) => v!.isEmpty ? 'Jurusan tidak boleh kosong' : null,
          ),
          const SizedBox(height: 20),
          _buildCustomDropdown<String>(
            label: 'Jenis Kelamin',
            value: _selectedGender,
            items: ['Laki-laki', 'Perempuan']
                .map((gender) => DropdownMenuItem(
              value: gender,
              child: Text(gender),
            ))
                .toList(),
            onChanged: (value) => setState(() => _selectedGender = value),
            validator: (v) => v == null ? 'Pilih jenis kelamin' : null,
          ),
          const SizedBox(height: 20),
          _buildCustomTextField(
            controller: _phoneNumberController,
            label: 'Nomor Telepon',
            keyboardType: TextInputType.phone,
            validator: (v) => v!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
          ),
          const SizedBox(height: 20),
          _buildCustomTextField(
            controller: _birthDateController,
            label: 'Tanggal Lahir',
            hint: 'YYYY-MM-DD',
            readOnly: true,
            onTap: () => _selectDate(context, _birthDateController),
            validator: (v) => v!.isEmpty ? 'Tanggal lahir tidak boleh kosong' : null,
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
          const SizedBox(height: 20),
          _buildCustomTextField(
            controller: _startDateController,
            label: 'Tanggal Mulai',
            hint: 'YYYY-MM-DD',
            readOnly: true,
            onTap: () => _selectDate(context, _startDateController),
            validator: (v) => v!.isEmpty ? 'Tanggal mulai tidak boleh kosong' : null,
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
          const SizedBox(height: 20),
          _buildCustomTextField(
            controller: _endDateController,
            label: 'Tanggal Selesai',
            hint: 'YYYY-MM-DD',
            readOnly: true,
            onTap: () => _selectDate(context, _endDateController),
            validator: (v) => v!.isEmpty ? 'Tanggal selesai tidak boleh kosong' : null,
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
          const SizedBox(height: 20),
          Consumer<UserProvider>(
            builder: (context, provider, child) {
              final supervisorItems = provider.supervisors;
              final uniqueSupervisorMap = {for (var s in supervisorItems) s.id: s};
              final uniqueSupervisorList = uniqueSupervisorMap.values.toList();

              String? currentValue = _selectedSupervisorId;
              if (currentValue != null && !uniqueSupervisorMap.containsKey(currentValue)) {
                currentValue = null;
              }

              return _buildCustomDropdown<String>(
                label: 'Supervisor',
                value: currentValue,
                items: uniqueSupervisorList
                    .map((s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(s.fullName),
                ))
                    .toList(),
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