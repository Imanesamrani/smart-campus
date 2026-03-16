import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../models/AR_Notification/notification_model.dart';
import '../../models/user_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _localNotifications.initialize(initializationSettings);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'High Importance Notifications',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      });
    }
  }

  Future<void> createNotification({
    required String targetType,
    String? filiere,
    String? niveau,
    String? teacherId,
    required String title,
    required String message,
    required String adminMessage,
    String timetableId = 'none',
  }) async {
    await _firestore.collection('notifications').add({
      'targetType': targetType,
      'filiere': filiere ?? 'tous',
      'niveau': niveau ?? 'tous',
      'teacherId': teacherId ?? '',
      'title': title,
      'message': message,
      'adminMessage': adminMessage,
      'timetableId': timetableId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Stream<List<AppNotificationModel>> getNotificationsForUser(UserModel user) {
    // On simplifie la requête Firestore pour éviter les problèmes d'index complexes
    // On filtre davantage côté client pour supporter les notifications "tous"
    return _firestore.collection('notifications')
        .snapshots()
        .map((snapshot) {
          final allNotifs = snapshot.docs
            .map((doc) => AppNotificationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
          
          final filtered = allNotifs.where((notif) {
            if (user.role == 'admin') return true;
            
            if (user.role == 'étudiant') {
              if (notif.targetType != 'student') return false;
              bool filiereMatch = notif.filiere == 'tous' || notif.filiere == user.filiere;
              bool niveauMatch = notif.niveau == 'tous' || notif.niveau == user.niveau;
              return filiereMatch && niveauMatch;
            }
            
            if (user.role == 'enseignant') {
              if (notif.targetType != 'teacher') return false;
              return notif.teacherId == '' || notif.teacherId == user.uid;
            }
            
            return false;
          }).toList();

          // Tri local
          filtered.sort((a, b) {
            final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return dateB.compareTo(dateA);
          });
          
          return filtered;
        });
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Stream<int> unreadCount(UserModel user) {
    return getNotificationsForUser(user).map((list) => list.where((n) => !n.isRead).length);
  }
}