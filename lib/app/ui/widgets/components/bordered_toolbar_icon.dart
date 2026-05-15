import 'package:flutter/material.dart';

import 'app_ui_tokens.dart';

class BorderedToolbarIcon extends StatelessWidget {
  const BorderedToolbarIcon({
    super.key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.all(8),
  });

  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: AppUiTokens.borderSubtle),
            borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
