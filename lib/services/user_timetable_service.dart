import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/timetable_model.dart';
import '../models/user_model.dart';

class UserTimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TimetableModel>> getTimetablesForUser(UserModel user) {
    if (user.role == 'étudiant') {
      return _firestore
          .collection('timetables')
          .where('type', isEqualTo: 'student')
          .where('filiere', isEqualTo: user.filiere)
          .where('niveau', isEqualTo: user.niveau)
          .orderBy('uploadedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => TimetableModel.fromFirestore(doc.data(), doc.id))
                .toList(),
          );
    }

    if (user.role == 'enseignant') {
      return _firestore
          .collection('timetables')
          .where('type', isEqualTo: 'teacher')
          .where('teacherId', isEqualTo: user.uid)
          .orderBy('uploadedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => TimetableModel.fromFirestore(doc.data(), doc.id))
                .toList(),
          );
    }

    return const Stream.empty();
  }
}