import 'package:app_simagang/models/user_model.dart';
import 'package:flutter/material.dart';

class InternDetailPage extends StatelessWidget {
  final UserModel internUser;

  const InternDetailPage({super.key, required this.internUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final internData = internUser.intern;

    if (internData == null) {
      return Scaffold(
        appBar: AppBar(title: Text(internUser.name)),
        body: const Center(
          child: Text('Data detail magang tidak ditemukan.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(internData.fullName),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Text(internData.fullName.isNotEmpty ? internData.fullName[0].toUpperCase() : '?', style: theme.textTheme.headlineLarge),
                  ),
                  const SizedBox(height: 16),
                  Text(internData.fullName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text(internData.division ?? 'Tanpa Divisi', style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bagian Informasi Pribadi
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Informasi Pribadi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildDetailRow(Icons.school_outlined, "Asal Sekolah", internData.schoolOrigin),
                    _buildDetailRow(Icons.book_outlined, "Jurusan", internData.major),
                    _buildDetailRow(Icons.person_outline, "Jenis Kelamin", internData.gender),
                    _buildDetailRow(Icons.phone_outlined, "No. Telepon", internData.phoneNumber),
                    _buildDetailRow(Icons.cake_outlined, "Tanggal Lahir", internData.birthDate),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bagian Informasi Magang
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Informasi Magang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildDetailRow(Icons.date_range_outlined, "Tanggal Mulai", internData.startDate),
                    _buildDetailRow(Icons.date_range_outlined, "Tanggal Selesai", internData.endDate),
                    _buildDetailRow(Icons.work_outline, "Tipe Magang", internData.internType),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Text("$title:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value ?? 'Tidak ada data')),
        ],
      ),
    );
  }
}
