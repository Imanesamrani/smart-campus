import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createStudentNotification({
    required String filiere,
    required String niveau,
    required String timetableId,
    required String adminMessage,
  }) async {
    await _firestore.collection('notifications').add({
      'targetType': 'student',
      'filiere': filiere,
      'niveau': niveau,
      'teacherId': '',
      'title': 'Nouvel emploi du temps disponible',
      'message': 'Votre emploi du temps a été mis à jour par l’administration.',
      'adminMessage': adminMessage,
      'timetableId': timetableId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<void> createTeacherNotification({
    required String teacherId,
    required String timetableId,
    required String adminMessage,
  }) async {
    await _firestore.collection('notifications').add({
      'targetType': 'teacher',
      'filiere': '',
      'niveau': '',
      'teacherId': teacherId,
      'title': 'Nouvel emploi du temps disponible',
      'message': 'Votre emploi du temps a été publié par l’administration.',
      'adminMessage': adminMessage,
      'timetableId': timetableId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Stream<List<AppNotificationModel>> getNotificationsForUser(UserModel user) {
    if (user.role == 'étudiant') {
      return _firestore
          .collection('notifications')
          .where('targetType', isEqualTo: 'student')
          .where('filiere', isEqualTo: user.filiere)
          .where('niveau', isEqualTo: user.niveau)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) =>
                  AppNotificationModel.fromFirestore(doc.data(), doc.id))
              .toList());
    } else if (user.role == 'enseignant') {
      return _firestore
          .collection('notifications')
          .where('targetType', isEqualTo: 'teacher')
          .where('teacherId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) =>
                  AppNotificationModel.fromFirestore(doc.data(), doc.id))
              .toList());
    } else {
      return const Stream.empty();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Stream<int> unreadCount(UserModel user) {
    if (user.role == 'étudiant') {
      return _firestore
          .collection('notifications')
          .where('targetType', isEqualTo: 'student')
          .where('filiere', isEqualTo: user.filiere)
          .where('niveau', isEqualTo: user.niveau)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } else if (user.role == 'enseignant') {
      return _firestore
          .collection('notifications')
          .where('targetType', isEqualTo: 'teacher')
          .where('teacherId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } else {
      return Stream.value(0);
    }
  }
}