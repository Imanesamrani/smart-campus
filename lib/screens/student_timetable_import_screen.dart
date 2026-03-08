import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/timetable_controller.dart';
import '../models/timetable_model.dart';

class StudentTimetableImportScreen extends StatelessWidget {
  const StudentTimetableImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TimetableController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Importer EDT Étudiants'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: controller.selectedFiliere,
                        decoration: const InputDecoration(
                          labelText: 'Filière',
                          border: OutlineInputBorder(),
                        ),
                        items: controller.filieres
                            .map((f) =>
                                DropdownMenuItem(value: f, child: Text(f)))
                            .toList(),
                        onChanged: controller.setFiliere,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: controller.selectedNiveau,
                        decoration: const InputDecoration(
                          labelText: 'Niveau',
                          border: OutlineInputBorder(),
                        ),
                        items: controller.niveaux
                            .map((n) =>
                                DropdownMenuItem(value: n, child: Text(n)))
                            .toList(),
                        onChanged: controller.setNiveau,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller.adminMessageController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Message admin (optionnel)',
                          hintText:
                              'Ex: Merci de consulter les modifications du mardi.',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: controller.pickFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Choisir un fichier'),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          controller.selectedFileName ??
                              'Aucun fichier sélectionné',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  final adminUid =
                                      FirebaseAuth.instance.currentUser?.uid ??
                                          '';

                                  final result = await controller
                                      .uploadStudentTimetable(adminUid);

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result == null
                                            ? '✅ Emploi du temps importé'
                                            : result,
                                      ),
                                      backgroundColor: result == null
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  );
                                },
                          icon: controller.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.cloud_upload),
                          label: const Text('Importer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TimetableModel>>(
              stream: controller.studentTimetablesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final timetables = snapshot.data!;
                if (timetables.isEmpty) {
                  return const Center(
                    child: Text('Aucun emploi du temps étudiant importé'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: timetables.length,
                  itemBuilder: (context, index) {
                    final timetable = timetables[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE3F2FD),
                          child: Icon(Icons.picture_as_pdf, color: Colors.blue),
                        ),
                        title: Text(
                          '${timetable.filiere} - ${timetable.niveau}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${timetable.fileName}\n${timetable.adminMessage.isEmpty ? 'Aucun message admin' : timetable.adminMessage}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await controller.deleteTimetable(timetable);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}