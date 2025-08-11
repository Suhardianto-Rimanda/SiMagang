import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_simagang/providers/auth_provider.dart';
import 'package:app_simagang/models/user_model.dart';
import 'package:app_simagang/pages/auth/login_page.dart';
import 'package:app_simagang/pages/admin/home_page.dart';
import 'package:app_simagang/pages/supervisor/home_page.dart';
import 'package:app_simagang/pages/intern/home_page.dart';
import 'package:app_simagang/pages/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case AuthStatus.Uninitialized:
      case AuthStatus.Authenticating:
        return const SplashScreen(); // Tampilkan loading screen
      case AuthStatus.Authenticated:
      // Cek role dan arahkan ke halaman yang sesuai
        switch (authProvider.user?.role) {
          case UserRole.admin:
            return const AdminHomePage();
          case UserRole.supervisor:
            return const SupervisorHomePage();
          case UserRole.intern:
            return const InternHomePage();
          default:
          // Jika role tidak dikenali, fallback ke login
            return const LoginPage();
        }
      case AuthStatus.Unauthenticated:
      default:
        return const LoginPage();
    }
  }
}
