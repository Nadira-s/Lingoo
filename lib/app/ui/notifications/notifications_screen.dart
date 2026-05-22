import 'package:flutter/material.dart';

import '../widgets/components/app_ui_tokens.dart';

/// Экран уведомлений (заглушка до подключения push / API).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppUiTokens.primaryText,
        title: const Text(
          'Уведомления',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppUiTokens.primaryText,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 72,
                color: AppUiTokens.secondaryText.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              const Text(
                'Здесь появятся уведомления',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppUiTokens.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Новые записи, изменения статуса и важные сообщения '
                'от платформы будут отображаться в этом разделе.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppUiTokens.secondaryText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
