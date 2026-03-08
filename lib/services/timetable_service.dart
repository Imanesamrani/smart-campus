import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/timetable_model.dart';
import '../models/user_model.dart';

class TimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> uploadStudentTimetable({
    required File? file,
    required Uint8List? fileBytes,
    required String fileName,
    required String filiere,
    required String niveau,
    required String adminMessage,
    required String uploadedBy,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeFiliere = filiere.replaceAll(' ', '_');
    final safeNiveau = niveau.replaceAll(' ', '_');
    final storagePath =
        'timetables/students/${safeFiliere}_${safeNiveau}_${timestamp}_$fileName';

    final ref = _storage.ref().child(storagePath);

    if (fileBytes != null) {
      await ref.putData(fileBytes);
    } else if (file != null) {
      await ref.putFile(file);
    } else {
      throw Exception('Aucun fichier valide trouvé');
    }

    final downloadUrl = await ref.getDownloadURL();

    await _firestore.collection('timetables').add({
      'type': 'student',
      'filiere': filiere,
      'niveau': niveau,
      'teacherId': '',
      'teacherName': '',
      'fileName': fileName,
      'fileUrl': downloadUrl,
      'filePath': storagePath,
      'adminMessage': adminMessage,
      'uploadedBy': uploadedBy,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> uploadTeacherTimetable({
    required File? file,
    required Uint8List? fileBytes,
    required String fileName,
    required UserModel teacher,
    required String adminMessage,
    required String uploadedBy,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = teacher.displayName.replaceAll(' ', '_');
    final storagePath =
        'timetables/teachers/${teacher.uid}_${safeName}_${timestamp}_$fileName';

    final ref = _storage.ref().child(storagePath);

    if (fileBytes != null) {
      await ref.putData(fileBytes);
    } else if (file != null) {
      await ref.putFile(file);
    } else {
      throw Exception('Aucun fichier valide trouvé');
    }

    final downloadUrl = await ref.getDownloadURL();

    await _firestore.collection('timetables').add({
      'type': 'teacher',
      'filiere': '',
      'niveau': '',
      'teacherId': teacher.uid,
      'teacherName': teacher.displayName,
      'fileName': fileName,
      'fileUrl': downloadUrl,
      'filePath': storagePath,
      'adminMessage': adminMessage,
      'uploadedBy': uploadedBy,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<UserModel>> getTeachers() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'enseignant')
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Stream<List<TimetableModel>> getStudentTimetablesAdmin() {
    return _firestore
        .collection('timetables')
        .where('type', isEqualTo: 'student')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TimetableModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<TimetableModel>> getTeacherTimetablesAdmin() {
    return _firestore
        .collection('timetables')
        .where('type', isEqualTo: 'teacher')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TimetableModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteTimetable(TimetableModel timetable) async {
    if (timetable.filePath.isNotEmpty) {
      await _storage.ref().child(timetable.filePath).delete();
    }
    await _firestore.collection('timetables').doc(timetable.id).delete();
  }
}