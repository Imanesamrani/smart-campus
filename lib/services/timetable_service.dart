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

    print('1. Début upload étudiant');

    final ref = _storage.ref().child(storagePath);

    if (fileBytes != null) {
      print('2. Upload avec bytes');

      await ref.putData(
        fileBytes,
        SettableMetadata(contentType: 'application/pdf'),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception(
            'Upload web bloqué. Sur web, Firebase Storage est bloqué par CORS. Teste sur Android ou configure CORS.',
          );
        },
      );

      print('3. Upload Storage terminé');
    } else if (file != null) {
      print('2. Upload avec file');

      await ref.putFile(
        file,
        SettableMetadata(contentType: 'application/pdf'),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Upload fichier trop long ou bloqué.');
        },
      );

      print('3. Upload Storage terminé');
    } else {
      throw Exception('Aucun fichier valide trouvé');
    }

    final downloadUrl = await ref.getDownloadURL();
    print('4. URL récupérée: $downloadUrl');

    final docRef = await _firestore.collection('timetables').add({
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
      'isActive': true,
    });

    print('5. Document timetable créé: ${docRef.id}');
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

    print('1. Début upload enseignant');

    final ref = _storage.ref().child(storagePath);

    if (fileBytes != null) {
      print('2. Upload enseignant avec bytes');

      await ref.putData(
        fileBytes,
        SettableMetadata(contentType: 'application/pdf'),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception(
            'Upload web bloqué. Sur web, Firebase Storage est bloqué par CORS. Teste sur Android ou configure CORS.',
          );
        },
      );

      print('3. Upload Storage enseignant terminé');
    } else if (file != null) {
      print('2. Upload enseignant avec file');

      await ref.putFile(
        file,
        SettableMetadata(contentType: 'application/pdf'),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Upload fichier trop long ou bloqué.');
        },
      );

      print('3. Upload Storage enseignant terminé');
    } else {
      throw Exception('Aucun fichier valide trouvé');
    }

    final downloadUrl = await ref.getDownloadURL();
    print('4. URL enseignant récupérée: $downloadUrl');

    final docRef = await _firestore.collection('timetables').add({
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
      'isActive': true,
    });

    print('5. Document timetable enseignant créé: ${docRef.id}');
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