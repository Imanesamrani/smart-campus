import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String role; // student, teacher, admin
  final String department;
  final List<String> favoriteRooms;
  final List<String> favoriteBuildings;
  final DateTime createdAt;
  final DateTime lastLogin;
  final String? notificationToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.role,
    required this.department,
    required this.favoriteRooms,
    required this.favoriteBuildings,
    required this.createdAt,
    required this.lastLogin,
    this.notificationToken,
  });

  // Convertir un document Firestore en UserModel
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      role: data['role'] ?? 'student',
      department: data['department'] ?? '',
      favoriteRooms: List<String>.from(data['favoriteRooms'] ?? []),
      favoriteBuildings: List<String>.from(data['favoriteBuildings'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: (data['lastLogin'] as Timestamp).toDate(),
      notificationToken: data['notificationToken'],
    );
  }

  // Convertir UserModel en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role,
      'department': department,
      'favoriteRooms': favoriteRooms,
      'favoriteBuildings': favoriteBuildings,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'notificationToken': notificationToken,
    };
  }
}