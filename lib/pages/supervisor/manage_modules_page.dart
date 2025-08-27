import 'package:app_simagang/api/module_service.dart';
import 'package:app_simagang/models/learning_module_model.dart';
import 'module_detail_page.dart';
import 'package:flutter/material.dart';

class ManageModulesPage extends StatefulWidget {
  const ManageModulesPage({super.key});

  @override
  State<ManageModulesPage> createState() => _ManageModulesPageState();
}

class _ManageModulesPageState extends State<ManageModulesPage> {
  late Future<List<LearningModuleModel>> _modulesFuture;
  final ModuleService _moduleService = ModuleService();

  @override
  void initState() {
    super.initState();
    _modulesFuture = _moduleService.getLearningModules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Modul Belajar'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<LearningModuleModel>>(
        future: _modulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada modul yang dibuat.'));
          }

          final modules = snapshot.data!;
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
                        builder: (context) => ModuleDetailPage(module: module),
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
