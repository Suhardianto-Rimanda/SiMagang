import 'package:app_simagang/models/user_model.dart';
import 'package:app_simagang/providers/supervisor_provider.dart';
import 'package:app_simagang/pages/supervisor/add_assignment_page.dart';
import 'package:app_simagang/pages/supervisor/intern_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageInternsPage extends StatefulWidget {
  const ManageInternsPage({super.key});

  @override
  State<ManageInternsPage> createState() => _ManageInternsPageState();
}

class _ManageInternsPageState extends State<ManageInternsPage> {
  late Future<List<UserModel>> _internsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupervisorProvider>(context, listen: false).fetchSupervisorInterns();
    });
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.library_books_outlined),
                title: const Text('Tambah Modul Baru'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddAssignmentPage(type: AssignmentType.module),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_outlined),
                title: const Text('Tambah Tugas Baru'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddAssignmentPage(type: AssignmentType.task),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleMenuSelection(String value, UserModel internUser) {
    if (value == 'detail') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InternDetailPage(internUser: internUser),
        ),
      );
    } else if (value == 'progress') {
      _showComingSoonSnackBar(context, 'Navigasi ke halaman progress ${internUser.intern?.fullName}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Peserta Magang'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _internsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada peserta magang yang dibimbing.'));
          }

          final internUsers = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: internUsers.length,
            itemBuilder: (context, index) {
              final internUser = internUsers[index];
              final internData = internUser.intern;

              if (internData == null) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person_off)),
                    title: Text(internUser.name),
                    subtitle: const Text('Data magang tidak lengkap.'),
                  ),
                );
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Text(
                          internData.fullName.isNotEmpty ? internData.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              internData.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              internData.division ?? 'Tanpa Divisi',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            Text(
                              internData.schoolOrigin ?? 'Asal Sekolah Tidak Diketahui',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleMenuSelection(value, internUser),
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'detail',
                            child: Text('Lihat Detail'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'progress',
                            child: Text('Lihat Progress'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        tooltip: 'Tambah Modul atau Tugas',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
