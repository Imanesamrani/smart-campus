import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/timetable_model.dart';
import '../models/user_model.dart';

class UserTimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TimetableModel>> getTimetablesForUser(UserModel user) {
    debugPrint('===== DEBUG TIMETABLE USER =====');
    debugPrint('role: ${user.role}');
    debugPrint('uid: ${user.uid}');
    debugPrint('filiere: ${user.filiere}');
    debugPrint('niveau: ${user.niveau}');
    debugPrint('displayName: ${user.displayName}');

    Query<Map<String, dynamic>> query = _firestore.collection('timetables');

    if (user.role == 'étudiant') {
      query = query
          .where('type', isEqualTo: 'student')
          .where('filiere', isEqualTo: user.filiere)
          .where('niveau', isEqualTo: user.niveau);
    } else if (user.role == 'enseignant') {
      query = query
          .where('type', isEqualTo: 'teacher')
          .where('teacherId', isEqualTo: user.uid);
    } else {
      return const Stream.empty();
    }

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => TimetableModel.fromFirestore(doc.data(), doc.id))
          .toList();

      items.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

      debugPrint('Nombre de timetables trouvés: ${items.length}');
      for (final item in items) {
        debugPrint(
          'Timetable => type=${item.type}, filiere=${item.filiere}, niveau=${item.niveau}, teacherId=${item.teacherId}, fileName=${item.fileName}',
        );
      }

      return items;
    });
  }

  Future<TimetableModel?> getTimetableById(String id) async {
    try {
      final doc = await _firestore.collection('timetables').doc(id).get();
      if (!doc.exists) return null;
      return TimetableModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('Erreur getTimetableById: $e');
      return null;
    }
  }
}