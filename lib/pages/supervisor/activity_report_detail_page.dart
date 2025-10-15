import 'package:app_simagang/models/activity_report_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityReportDetailPage extends StatelessWidget {
  final ActivityReportModel report;

  const ActivityReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
                Icons.person_outline, 'Nama Intern', report.intern?.fullName),
            _buildDetailRow(
                Icons.calendar_today_outlined,
                'Tanggal Laporan',
                DateFormat('EEEE, dd MMMM yyyy').format(report.reportDate)),
            const Divider(height: 32),
            const Text(
              'Deskripsi Aktivitas:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              report.description ?? 'Tidak ada deskripsi.',
              style: const TextStyle(fontSize: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text(value ?? 'N/A', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}