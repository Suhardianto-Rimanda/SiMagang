import 'package:app_simagang/providers/intern_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'add_edit_activity_report_page.dart';

class ActivityReportPage extends StatefulWidget {
  const ActivityReportPage({super.key});

  @override
  State<ActivityReportPage> createState() => _ActivityReportPageState();
}

class _ActivityReportPageState extends State<ActivityReportPage> {
  @override
  void initState() {
    super.initState();
    _refreshReports();
  }

  void _refreshReports() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InternProvider>(context, listen: false).fetchActivityReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Aktivitas Harian'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<InternProvider>(
        builder: (context, provider, child) {
          if (provider.reportsState == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.reportsState == ViewState.error) {
            return Center(child: Text('Gagal memuat data: ${provider.errorMessage}'));
          }
          if (provider.reports.isEmpty) {
            return const Center(child: Text('Belum ada laporan yang dibuat.'));
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
                  subtitle: Text(DateFormat('EEEE, dd MMMM yyyy').format(report.reportDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigasi ke halaman detail/edit laporan
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditActivityReportPage()),
          );
          if (result == true) {
            _refreshReports();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
