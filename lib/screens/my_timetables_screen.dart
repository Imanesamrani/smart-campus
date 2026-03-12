import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../models/timetable_model.dart';
import '../services/user_timetable_service.dart';
import 'timetable_viewer_screen.dart';
import 'package:intl/intl.dart';

class MyTimetablesScreen extends StatelessWidget {
  const MyTimetablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthController>().currentUser!;
    final service = UserTimetableService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes emplois du temps'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<TimetableModel>>(
        stream: service.getTimetablesForUser(user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erreur Firestore:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final timetables = snapshot.data ?? [];

          if (timetables.isEmpty) {
            return const Center(
              child: Text('Aucun emploi du temps disponible'),
            );
          }

          final latest = timetables.first;
          final oldTimetables =
              timetables.length > 1 ? timetables.sublist(1) : <TimetableModel>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Dernier emploi du temps',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildPinnedCard(context, latest),
              const SizedBox(height: 24),
              if (oldTimetables.isNotEmpty) ...[
                const Text(
                  'Historique',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...oldTimetables.map((t) => _buildHistoryCard(context, t)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPinnedCard(BuildContext context, TimetableModel timetable) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ÉPINGLÉ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              timetable.type == 'student'
                  ? '${timetable.filiere ?? ''} - ${timetable.niveau ?? ''}'
                  : (timetable.teacherName ?? 'Emploi du temps enseignant'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              timetable.fileName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
           Container(
  width: double.infinity,
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.16),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Message de l’administration',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        timetable.adminMessage.isEmpty
            ? 'Aucun message de l’administration'
            : timetable.adminMessage,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
),
            const SizedBox(height: 12),
            Text(
              _formatDate(timetable.uploadedAt),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimetableViewerScreen(
                      timetableId: timetable.id,
                      fileUrl: timetable.fileUrl,
                      fileName: timetable.fileName,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Ouvrir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5E35B1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, TimetableModel timetable) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEDE7F6),
          child: Icon(
            timetable.type == 'student' ? Icons.class_ : Icons.person,
            color: const Color(0xFF5E35B1),
          ),
        ),
        title: Text(
          timetable.fileName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_formatDate(timetable.uploadedAt)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TimetableViewerScreen(
                timetableId: timetable.id,
                fileUrl: timetable.fileUrl,
                fileName: timetable.fileName,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(int timestamp) {
    if (timestamp <= 0) return 'Date non disponible';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }
}