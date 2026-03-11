import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String message;
  final String author;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String type;
  final bool isPinned;
  final List<String> targetRoles;
  final List<String> targetFilieres;
  final List<String> targetNiveaux;
  final bool isActive;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.author,
    required this.createdAt,
    this.updatedAt,
    required this.type,
    required this.isPinned,
    required this.targetRoles,
    required this.targetFilieres,
    required this.targetNiveaux,
    required this.isActive,
  });

  factory Announcement.fromJson(Map<String, dynamic>? json, String docId) {
    final data = json ?? {};

    final createdAtRaw = data['createdAt'];
    final updatedAtRaw = data['updatedAt'];
    final targetRolesRaw = data['targetRoles'];
    final targetFilieresRaw = data['targetFilieres'];
    final targetNiveauxRaw = data['targetNiveaux'];

    return Announcement(
      id: docId,
      title: (data['title'] ?? '').toString(),
      message: (data['message'] ?? '').toString(),
      author: (data['author'] ?? 'Administration').toString(),
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.now(),
      updatedAt: updatedAtRaw is Timestamp ? updatedAtRaw.toDate() : null,
      type: (data['type'] ?? 'général').toString(),
      isPinned: data['isPinned'] == true,
      targetRoles: targetRolesRaw is List
          ? targetRolesRaw.whereType<String>().toList().isNotEmpty
              ? targetRolesRaw.whereType<String>().toList()
              : ['tous']
          : ['tous'],
      targetFilieres: targetFilieresRaw is List
          ? targetFilieresRaw.whereType<String>().toList().isNotEmpty
              ? targetFilieresRaw.whereType<String>().toList()
              : ['tous']
          : ['tous'],
      targetNiveaux: targetNiveauxRaw is List
          ? targetNiveauxRaw.whereType<String>().toList().isNotEmpty
              ? targetNiveauxRaw.whereType<String>().toList()
              : ['tous']
          : ['tous'],
      isActive: data['isActive'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'title': title,
      'message': message,
      'author': author,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type,
      'isPinned': isPinned,
      'targetRoles': targetRoles,
      'targetFilieres': targetFilieres,
      'targetNiveaux': targetNiveaux,
      'isActive': isActive,
    };

    if (updatedAt != null) {
      data['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }

    return data;
  }

  Announcement copyWith({
    String? id,
    String? title,
    String? message,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    bool? isPinned,
    List<String>? targetRoles,
    List<String>? targetFilieres,
    List<String>? targetNiveaux,
    bool? isActive,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      isPinned: isPinned ?? this.isPinned,
      targetRoles: targetRoles ?? this.targetRoles,
      targetFilieres: targetFilieres ?? this.targetFilieres,
      targetNiveaux: targetNiveaux ?? this.targetNiveaux,
      isActive: isActive ?? this.isActive,
    );
  }
}