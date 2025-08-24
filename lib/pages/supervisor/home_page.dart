import 'package:app_simagang/pages/supervisor/manage_interns_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SupervisorHomePage extends StatelessWidget {
  const SupervisorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Dashboard'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang,',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              user?.name ?? 'Supervisor',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColorDark,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Menu Utama',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.people_outline,
                  title: 'Kelola Peserta Magang',
                  onTap: () {
                    // Navigasi ke halaman Manage Interns
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ManageInternsPage()));
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.library_books_outlined,
                  title: 'Kelola Modul Belajar',
                  onTap: () {
                    // TODO: Navigasi ke halaman Manage Modules
                    _showComingSoonSnackBar(context);
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.assignment_outlined,
                  title: 'Kelola Tugas',
                  onTap: () {
                    // TODO: Navigasi ke halaman Manage Tasks
                    _showComingSoonSnackBar(context);
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.trending_up,
                  title: 'Lihat Progress Magang',
                  onTap: () {
                    // TODO: Navigasi ke halaman Intern Progress
                    _showComingSoonSnackBar(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ini sedang dalam pengembangan.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
