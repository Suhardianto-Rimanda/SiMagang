import 'package:app_simagang/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
