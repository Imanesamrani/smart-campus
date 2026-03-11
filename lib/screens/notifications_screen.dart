import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'timetable_viewer_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthController>().currentUser!;
    final notificationService = NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<List<AppNotificationModel>>(
        stream: notificationService.getNotificationsForUser(user),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return const Center(
              child: Text('Aucune notification'),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      notif.isRead ? Colors.grey.shade300 : Colors.blue.shade100,
                  child: Icon(
                    Icons.notifications,
                    color: notif.isRead ? Colors.grey : Colors.blue,
                  ),
                ),
                title: Text(notif.title),
                subtitle: Text(
                  '${notif.message}\n${notif.adminMessage}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  notif.createdAt != null
                      ? DateFormat('dd/MM/yyyy').format(notif.createdAt!)
                      : '',
                  style: const TextStyle(fontSize: 12),
                ),
                isThreeLine: true,
                onTap: () async {
                  await notificationService.markAsRead(notif.id);

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TimetableViewerScreen(
                        timetableId: notif.timetableId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}