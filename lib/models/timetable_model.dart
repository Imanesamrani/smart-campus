import 'package:cloud_firestore/cloud_firestore.dart';

class TimetableModel {
  final String id;
  final String type; // student or teacher
  final String? filiere;
  final String? niveau;
  final String? teacherId;
  final String? teacherName;
  final String fileName;
  final String fileUrl;
  final String filePath;
  final String adminMessage;
  final String uploadedBy;
  final DateTime? uploadedAt;

  TimetableModel({
    required this.id,
    required this.type,
    this.filiere,
    this.niveau,
    this.teacherId,
    this.teacherName,
    required this.fileName,
    required this.fileUrl,
    required this.filePath,
    required this.adminMessage,
    required this.uploadedBy,
    this.uploadedAt,
  });

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
      filePath: data['filePath'] ?? '',
      adminMessage: data['adminMessage'] ?? '',
      uploadedBy: data['uploadedBy'] ?? '',
      uploadedAt: data['uploadedAt'] != null
          ? (data['uploadedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'filiere': filiere,
      'niveau': niveau,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'filePath': filePath,
      'adminMessage': adminMessage,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt != null
          ? Timestamp.fromDate(uploadedAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}