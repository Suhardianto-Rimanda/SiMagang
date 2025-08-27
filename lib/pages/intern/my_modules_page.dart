import 'package:app_simagang/pages/intern/module_feedback_page.dart';
import 'package:app_simagang/providers/intern_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyModulesPage extends StatefulWidget {
  const MyModulesPage({super.key});

  @override
  State<MyModulesPage> createState() => _MyModulesPageState();
}

class _MyModulesPageState extends State<MyModulesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InternProvider>(context, listen: false).fetchMyLearningModules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul Pembelajaran Saya'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<InternProvider>(
        builder: (context, provider, child) {
          if (provider.modulesState == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.modulesState == ViewState.error) {
            return Center(child: Text('Gagal memuat data: ${provider.errorMessage}'));
          }
          if (provider.modules.isEmpty) {
            return const Center(child: Text('Belum ada modul yang ditugaskan.'));
          }

          final modules = provider.modules;
          return ListView.builder(
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.library_books),
                  title: Text(module.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(module.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModuleFeedbackPage(module: module),
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
