import 'package:flutter/material.dart';
import 'package:baru_mobil/services/notification_service.dart';

class NotificationTestWidget extends StatelessWidget {
  const NotificationTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            NotificationService.sendTestNotification(
              title: 'Test Kulüp Bildirimi',
              body: 'Bu bir test kulüp bildirimidir',
              channelId: 'clubs_channel',
            );
          },
          child: const Text('Kulüp Bildirimi Test Et'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            NotificationService.sendTestNotification(
              title: 'Test Duyuru Bildirimi',
              body: 'Bu bir test duyuru bildirimidir',
              channelId: 'announcements_channel',
            );
          },
          child: const Text('Duyuru Bildirimi Test Et'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            NotificationService.sendTestNotification(
              title: 'Test Yemekhane Bildirimi',
              body: 'Bu bir test yemekhane bildirimidir',
              channelId: 'cafeteria_channel',
            );
          },
          child: const Text('Yemekhane Bildirimi Test Et'),
        ),
      ],
    );
  }
}
