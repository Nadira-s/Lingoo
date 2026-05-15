import 'package:flutter/material.dart';

import '../components/app_ui_tokens.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.subLabel,
    this.onTap,
  });

  final String label;
  final int value;
  final String subLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
          border: Border.all(color: AppUiTokens.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppUiTokens.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w500,
                color: AppUiTokens.primaryText,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subLabel,
              style: const TextStyle(
                color: AppUiTokens.tertiaryText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
