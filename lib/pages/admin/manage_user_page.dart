import 'add_user_page.dart';
import 'edit_user_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_simagang/models/user_model.dart';
import 'package:app_simagang/providers/user_provider.dart';
import 'package:app_simagang/api/admin_service.dart';
import 'package:app_simagang/utils/report_generator.dart';
import 'package:app_simagang/models/activity_report_model.dart';
import 'package:app_simagang/models/learning_progress_model.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Anda yakin ingin menghapus ${user.name}?'),
          actions: <Widget>[
            TextButton(child: const Text('Batal'), onPressed: () => Navigator.of(ctx).pop()),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).deleteUser(user.id);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPrintDialog(BuildContext context, UserModel user) async {
    if (user.intern == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data intern tidak lengkap untuk dicetak.')),
      );
      return;
    }

    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih Rentang Tanggal Laporan',
    );

    if (picked != null && mounted) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
          const Center(child: CircularProgressIndicator()));

      try {
        final adminService = AdminService();
        final startDate = DateFormat('yyyy-MM-dd').format(picked.start);
        final endDate = DateFormat('yyyy-MM-dd').format(picked.end);

        final summaryData = await adminService.getReportSummary(user.intern!.id, startDate, endDate);

        Navigator.pop(context); // Tutup loading

        // Panggil generator PDF
        await ReportGenerator.generateAndPrintReport(
          internUser: user,
          activityReports: summaryData['activity_reports'] as List<ActivityReportModel>,
          learningProgress: summaryData['learning_progress'] as List<LearningProgressModel>,
          startDate: picked.start,
          endDate: picked.end,
        );
      } catch (e) {
        Navigator.pop(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data laporan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Pengguna')),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userProvider.errorMessage != null && userProvider.users.isEmpty) {
            return Center(child: Text('Error: ${userProvider.errorMessage}'));
          }
          if (userProvider.users.isEmpty) {
            return const Center(child: Text('Tidak ada data pengguna.'));
          }

          return RefreshIndicator(
            onRefresh: () => userProvider.fetchUsers(),
            child: ListView.builder(
              itemCount: userProvider.users.length,
              itemBuilder: (context, index) {
                final user = userProvider.users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditUserPage(user: user)),
                          );
                        } else if (value == 'delete') {
                          _showDeleteConfirmationDialog(context, user);
                        } else if (value == 'print' && user.role == UserRole.intern) {
                          _showPrintDialog(context, user);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(leading: Icon(Icons.edit), title: Text('Ubah')),
                        ),
                        if (user.role == UserRole.intern)
                          const PopupMenuItem<String>(
                            value: 'print',
                            child: ListTile(leading: Icon(Icons.print_outlined), title: Text('Cetak Laporan')),
                          ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Hapus', style: TextStyle(color: Colors.red))),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddUserPage()),
          );
        },
        tooltip: 'Tambah Pengguna',
        child: const Icon(Icons.add),
      ),
    );
  }
}
