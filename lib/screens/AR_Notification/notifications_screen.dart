import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../models/AR_Notification/notification_model.dart';
import '../../services/AR_Notification/notification_service.dart';

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
              return Dismissible(
                key: ValueKey(notif.id),
                direction: DismissDirection.startToEnd,
                background: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Row(
                    children: [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Supprimer',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                onDismissed: (_) async {
                  await notificationService.deleteForUser(notif.id, user.uid);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification supprimée')),
                  );
                },
                child: ListTile(
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
                    await notificationService.markAsRead(notif.id, user.uid);

                    if (!context.mounted) return;
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
