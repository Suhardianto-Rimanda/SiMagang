// lib/pages/admin/all_activity_reports_page.dart

import 'package:app_simagang/api/admin_service.dart';
import 'package:app_simagang/models/activity_report_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllActivityReportsPage extends StatefulWidget {
  const AllActivityReportsPage({super.key});

  @override
  State<AllActivityReportsPage> createState() => _AllActivityReportsPageState();
}

class _AllActivityReportsPageState extends State<AllActivityReportsPage> {
  late Future<List<ActivityReportModel>> _reportsFuture;
  final AdminService _adminService = AdminService();

  @override
  void initState() {
    super.initState();
    _reportsFuture = _adminService.getAllActivityReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Laporan Aktivitas'),
      ),
      body: FutureBuilder<List<ActivityReportModel>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada laporan aktivitas.'));
          }

          final reports = snapshot.data!;
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(report.title),
                  subtitle: Text(
                    '${report.intern?.fullName ?? 'Nama Intern'} - ${DateFormat('dd MMM yyyy').format(report.reportDate)}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
