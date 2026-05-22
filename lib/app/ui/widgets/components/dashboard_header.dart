import 'package:flutter/material.dart';

import 'app_ui_tokens.dart';
import 'bordered_toolbar_icon.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.subtitle,
    this.onNotifications,
  });

  final String greeting;
  final String subtitle;
  final VoidCallback? onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppUiTokens.primaryText,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppUiTokens.secondaryText,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        if (onNotifications != null) ...[
          const SizedBox(width: 16),
          BorderedToolbarIcon(
            onPressed: onNotifications!,
            child: Image.asset(
              'assets/icons/Vector.png',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ],
    );
  }
}
