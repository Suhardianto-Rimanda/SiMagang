import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_simagang/providers/auth_provider.dart';
import 'manage_user_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.user?.name ?? 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Bagian Header Sambutan
          _buildWelcomeHeader(context, userName),
          const SizedBox(height: 24),
          // Grid untuk menu-menu admin
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDashboardCard(
                context,
                icon: Icons.people_alt_outlined,
                label: 'Manajemen Pengguna',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageUsersPage()),
                  );
                },
              ),
              _buildDashboardCard(
                context,
                icon: Icons.assignment_outlined,
                label: 'Laporan Aktivitas',
                onTap: () {
                  // TODO: Navigasi ke halaman laporan
                },
              ),
              _buildDashboardCard(
                context,
                icon: Icons.task_alt,
                label: 'Progres Magang',
                onTap: () {
                  // TODO: Navigasi ke halaman progres
                },
              ),
              _buildDashboardCard(
                context,
                icon: Icons.settings_outlined,
                label: 'Pengaturan',
                onTap: () {
                  // TODO: Navigasi ke halaman pengaturan
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk header sambutan
  Widget _buildWelcomeHeader(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang Kembali,',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk kartu menu di dashboard
  Widget _buildDashboardCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
