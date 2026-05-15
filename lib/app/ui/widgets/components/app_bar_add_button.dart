import 'package:flutter/material.dart';

import 'app_ui_tokens.dart';

class AppBarAddButton extends StatelessWidget {
  const AppBarAddButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFCC00),
          borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
        ),
        padding: const EdgeInsets.all(6),
        child: const Icon(Icons.add, color: AppUiTokens.primaryText),
      ),
    );
  }
}
