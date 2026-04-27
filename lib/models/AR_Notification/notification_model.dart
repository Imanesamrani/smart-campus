import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationModel {
  final String id;
  final String targetType;
  final String? filiere;
  final String? niveau;
  final String? teacherId;
  final String title;
  final String message;
  final String adminMessage;
  final String timetableId;
  final DateTime? createdAt;
  final List<String> readBy;
  final List<String> deletedBy;
  final bool isRead;

  AppNotificationModel({
    required this.id,
    required this.targetType,
    this.filiere,
    this.niveau,
    this.teacherId,
    required this.title,
    required this.message,
    required this.adminMessage,
    required this.timetableId,
    this.createdAt,
    required this.readBy,
    required this.deletedBy,
    required this.isRead,
  });

  factory AppNotificationModel.fromFirestore(
    Map<String, dynamic> data,
    String id, {
    String? currentUserId,
  }) {
    final readBy = List<String>.from(data['readBy'] ?? const []);
    final deletedBy = List<String>.from(data['deletedBy'] ?? const []);

    return AppNotificationModel(
      id: id,
      targetType: data['targetType'] ?? '',
      filiere: data['filiere'],
      niveau: data['niveau'],
      teacherId: data['teacherId'],
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      adminMessage: data['adminMessage'] ?? '',
      timetableId: data['timetableId'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      readBy: readBy,
      deletedBy: deletedBy,
      isRead: currentUserId != null
          ? readBy.contains(currentUserId)
          : (data['isRead'] ?? false),
    );
  }
}
