import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'my_tasks_page.dart';
import 'my_modules_page.dart';
import 'activity_report_page.dart';

class InternHomePage extends StatelessWidget {
  const InternHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intern Dashboard'),
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
              user?.name ?? 'Intern',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColorDark,
              ),
            ),
            const SizedBox(height: 24),
            _buildFeatureCard(
              context,
              icon: Icons.assignment,
              title: 'Tugas Saya',
              subtitle: 'Lihat dan kerjakan tugas yang diberikan.',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyTasksPage()));
              },
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.library_books,
              title: 'Modul Pembelajaran',
              subtitle: 'Akses materi pembelajaran Anda.',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyModulesPage()));
              },
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.edit_calendar,
              title: 'Laporan Aktivitas',
              subtitle: 'Isi dan lihat laporan aktivitas harian.',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ActivityReportPage()));
              },
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
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
