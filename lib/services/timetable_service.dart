import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/timetable_model.dart';
import 'upload_service.dart';

class TimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UploadService _uploadService = UploadService();

  // Récupérer tous les emplois du temps étudiants (pour admin)
  Stream<List<TimetableModel>> getStudentTimetablesAdmin() {
  return _firestore
      .collection('timetables')
      .where('type', isEqualTo: 'student')
      .snapshots()
      .map((snapshot) {
    final items = snapshot.docs
        .map((doc) => TimetableModel.fromFirestore(doc.data(), doc.id))
        .toList();

    items.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return items;
  });
}

Stream<List<TimetableModel>> getTeacherTimetablesAdmin() {
  return _firestore
      .collection('timetables')
      .where('type', isEqualTo: 'teacher')
      .snapshots()
      .map((snapshot) {
    final items = snapshot.docs
        .map((doc) => TimetableModel.fromFirestore(doc.data(), doc.id))
        .toList();

    items.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return items;
  });
}
         

  
  // Récupérer les enseignants
  Future<List<UserModel>> getTeachers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'enseignant')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Erreur getTeachers: $e');
      return [];
    }
  }

  // Upload emploi du temps étudiant
  Future<void> uploadStudentTimetable({
    File? file,
    Uint8List? fileBytes,
    required String fileName,
    required String filiere,
    required String niveau,
    required String adminMessage,
    required String uploadedBy,
  }) async {
    // 1. Uploader le fichier vers le service gratuit
    final fileUrl = await _uploadService.uploadFile(
      file: file,
      fileBytes: fileBytes,
      fileName: fileName,
    );

    if (fileUrl == null) {
      throw Exception("Échec de l'upload du fichier");
    }

    // 2. Créer l'entrée dans Firestore
    await _firestore.collection('timetables').add({
      'type': 'student',
      'filiere': filiere,
      'niveau': niveau,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'adminMessage': adminMessage,
      'uploadedBy': uploadedBy,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  // Upload emploi du temps enseignant
  Future<void> uploadTeacherTimetable({
    File? file,
    Uint8List? fileBytes,
    required String fileName,
    required UserModel teacher,
    required String adminMessage,
    required String uploadedBy,
  }) async {
    // 1. Uploader le fichier vers le service gratuit
    final fileUrl = await _uploadService.uploadFile(
      file: file,
      fileBytes: fileBytes,
      fileName: fileName,
    );

    if (fileUrl == null) {
      throw Exception("Échec de l'upload du fichier");
    }

    // 2. Créer l'entrée dans Firestore
    await _firestore.collection('timetables').add({
      'type': 'teacher',
      'teacherId': teacher.uid,
      'teacherName': teacher.displayName,
      'teacherEmail': teacher.email,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'adminMessage': adminMessage,
      'uploadedBy': uploadedBy,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  // Supprimer un emploi du temps
  Future<void> deleteTimetable(TimetableModel timetable) async {
    await _firestore.collection('timetables').doc(timetable.id).delete();
  }
}