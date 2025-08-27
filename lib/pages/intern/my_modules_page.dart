import 'package:app_simagang/api/intern_service.dart';
import 'package:app_simagang/models/learning_module_model.dart';
import 'package:app_simagang/pages/intern/module_feedback_page.dart';
import 'package:flutter/material.dart';

class MyModulesPage extends StatefulWidget {
  const MyModulesPage({super.key});

  @override
  State<MyModulesPage> createState() => _MyModulesPageState();
}

class _MyModulesPageState extends State<MyModulesPage> {
  late Future<List<LearningModuleModel>> _modulesFuture;
  final InternService _internService = InternService();

  @override
  void initState() {
    super.initState();
    _modulesFuture = _internService.getMyLearningModules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul Pembelajaran Saya'),
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
            return const Center(child: Text('Belum ada modul yang ditugaskan.'));
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
