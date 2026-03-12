import 'package:cloud_firestore/cloud_firestore.dart';

class TimetableModel {
  final String id;
  final String type; // 'student' ou 'teacher'
  final String? filiere;
  final String? niveau;
  final String? teacherId;
  final String? teacherName;
  final String fileName;
  final String fileUrl;
  final String adminMessage;
  final String uploadedBy;
  final int uploadedAt; // Timestamp en millisecondes

  TimetableModel({
    required this.id,
    required this.type,
    this.filiere,
    this.niveau,
    this.teacherId,
    this.teacherName,
    required this.fileName,
    required this.fileUrl,
    required this.adminMessage,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  // Pour Realtime Database
  factory TimetableModel.fromMap(Map<String, dynamic> map, String id) {
    return TimetableModel(
      id: id,
      type: map['type'] ?? '',
      filiere: map['filiere'],
      niveau: map['niveau'],
      teacherId: map['teacherId'],
      teacherName: map['teacherName'],
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      adminMessage: map['adminMessage'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedAt: map['uploadedAt'] ?? 0,
    );
  }

  // Pour Firestore
  factory TimetableModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TimetableModel(
      id: id,
      type: data['type'] ?? '',
      filiere: data['filiere'],
      niveau: data['niveau'],
      teacherId: data['teacherId'],
      teacherName: data['teacherName'],
      fileName: data['fileName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      adminMessage: data['adminMessage'] ?? '',
      uploadedBy: data['uploadedBy'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'filiere': filiere,
      'niveau': niveau,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'adminMessage': adminMessage,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt,
    };
  }
}