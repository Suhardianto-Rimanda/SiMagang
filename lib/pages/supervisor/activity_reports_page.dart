import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:app_simagang/providers/supervisor_provider.dart';
import 'activity_report_detail_page.dart'; // Halaman detail yang akan kita buat

class SupervisorActivityReportsPage extends StatefulWidget {
  const SupervisorActivityReportsPage({super.key});

  @override
  State<SupervisorActivityReportsPage> createState() =>
      _SupervisorActivityReportsPageState();
}

class _SupervisorActivityReportsPageState
    extends State<SupervisorActivityReportsPage> {
  @override
  void initState() {
    super.initState();
    // Panggil provider untuk mengambil data saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupervisorProvider>(context, listen: false)
          .fetchActivityReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Aktivitas Intern'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SupervisorProvider>(
        builder: (context, provider, child) {
          if (provider.activityReportsState == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.activityReportsState == ViewState.error) {
            return Center(
                child: Text('Gagal memuat data: ${provider.errorMessage}'));
          }
          if (provider.activityReports.isEmpty) {
            return const Center(child: Text('Belum ada laporan aktivitas.'));
          }

          final reports = provider.activityReports;
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.summarize_outlined),
                  title: Text(report.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Oleh: ${report.intern?.fullName ?? "N/A"}\n${DateFormat('EEEE, dd MMM yyyy').format(report.reportDate)}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ActivityReportDetailPage(report: report),
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