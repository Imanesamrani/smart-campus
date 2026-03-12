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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Importer EDT Étudiants',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Column(
        children: [
          // Formulaire d'import
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Filière
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: controller.selectedFiliere,
                    decoration: const InputDecoration(
                      hintText: 'Filière',
                      prefixIcon: Icon(Icons.school, color: Color(0xFF1E293B)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: controller.filieres
                        .map((f) => DropdownMenuItem(
                              value: f, 
                              child: Text(f),
                            ))
                        .toList(),
                    onChanged: controller.setFiliere,
                  ),
                ),
                const SizedBox(height: 16),

                // Niveau
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: controller.selectedNiveau,
                    decoration: const InputDecoration(
                      hintText: 'Niveau',
                      prefixIcon: Icon(Icons.trending_up, color: Color(0xFF1E293B)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: controller.niveaux
                        .map((n) => DropdownMenuItem(
                              value: n, 
                              child: Text(n),
                            ))
                        .toList(),
                    onChanged: controller.setNiveau,
                  ),
                ),
                const SizedBox(height: 16),

                // Message admin
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: controller.adminMessageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Message admin (optionnel)',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 50),
                        child: Icon(Icons.message, color: Color(0xFF1E293B)),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bouton choix fichier
                OutlinedButton.icon(
                  onPressed: controller.pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Choisir un fichier'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E88E5),
                    side: const BorderSide(color: Color(0xFF1E88E5)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Nom du fichier sélectionné
                Text(
                  controller.selectedFileName ?? 'Aucun fichier sélectionné',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),

                // Bouton importer
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading || 
                              controller.selectedFiliere == null ||
                              controller.selectedNiveau == null ||
                              controller.selectedFileName == null
                        ? null
                        : () async {
                            final adminUid =
                                FirebaseAuth.instance.currentUser?.uid ?? '';

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
                                    ? const Color(0xFF43A047)
                                    : const Color(0xFFE53935),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Importer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des emplois du temps importés
          Expanded(
            child: StreamBuilder<List<TimetableModel>>(
              stream: controller.studentTimetablesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.picture_as_pdf,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun emploi du temps étudiant importé',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final timetables = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: timetables.length,
                  itemBuilder: (context, index) {
                    final timetable = timetables[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E88E5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        title: Text(
                          '${timetable.filiere} - ${timetable.niveau}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timetable.fileName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (timetable.adminMessage.isNotEmpty)
                              Text(
                                timetable.adminMessage,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFE53935)),
                            onPressed: () async {
                              await controller.deleteTimetable(timetable);
                            },
                          ),
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