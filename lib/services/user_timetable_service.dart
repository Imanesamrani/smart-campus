import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // ← IMPORTANT : pour debugPrint
import '../models/timetable_model.dart';
import '../models/user_model.dart';

class UserTimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TimetableModel>> getTimetablesForUser(UserModel user) {
    Query query = _firestore.collection('timetables');

    if (user.role == 'étudiant') {
      query = query
          .where('type', isEqualTo: 'student')
          .where('filiere', isEqualTo: user.filiere)
          .where('niveau', isEqualTo: user.niveau)
          .orderBy('uploadedAt', descending: true);
    } else if (user.role == 'enseignant') {
      query = query
          .where('type', isEqualTo: 'teacher')
          .where('teacherId', isEqualTo: user.uid)
          .orderBy('uploadedAt', descending: true);
    } else {
      // Admin : voir tous les emplois du temps
      query = query.orderBy('uploadedAt', descending: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Correction : s'assurer que doc.data() est bien un Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>;
        return TimetableModel.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  // Récupérer un emploi du temps spécifique par son ID
  Future<TimetableModel?> getTimetableById(String id) async {
    try {
      final doc = await _firestore.collection('timetables').doc(id).get();
      if (doc.exists) {
        // Correction : s'assurer que doc.data()! est bien un Map<String, dynamic>
        final data = doc.data()! as Map<String, dynamic>;
        return TimetableModel.fromFirestore(data, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getTimetableById: $e');
      return null;
    }
  }
}