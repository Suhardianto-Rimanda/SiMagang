import 'package:app_simagang/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'activity_report_detail_page.dart';

class AllActivityReportsPage extends StatefulWidget {
  const AllActivityReportsPage({super.key});

  @override
  State<AllActivityReportsPage> createState() => _AllActivityReportsPageState();
}

class _AllActivityReportsPageState extends State<AllActivityReportsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchAllActivityReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Laporan Aktivitas'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.reportsState == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.reportsState == ViewState.error) {
            return Center(child: Text('Gagal memuat data: ${provider.errorMessage}'));
          }
          if (provider.reports.isEmpty) {
            return const Center(child: Text('Tidak ada laporan aktivitas.'));
          }

          final reports = provider.reports;
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Oleh: ${report.intern?.fullName ?? 'N/A'}\n${DateFormat('dd MMM yyyy').format(report.reportDate)}',
                  ),
                  isThreeLine: true, // Tambahkan ini agar subtitle tidak terpotong
                  trailing: const Icon(Icons.chevron_right), // Tambahkan ikon panah
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminActivityReportDetailPage(report: report),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
