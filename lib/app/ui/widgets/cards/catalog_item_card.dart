import 'package:flutter/material.dart';

import '../components/app_ui_tokens.dart';

/// Стиль нижней кнопки карточки каталога.
enum CatalogItemCardButtonStyle {
  /// Белый фон, серая обводка (как поле ввода).
  outlined,

  /// Жёлтая заливка (акцент).
  filledAccent,
}

/// Действие в нижней части [CatalogItemCard].
class CatalogItemCardAction {
  const CatalogItemCardAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = CatalogItemCardButtonStyle.outlined,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final CatalogItemCardButtonStyle style;
}

/// Универсальная карточка для списков (сотрудники, услуги и т.д.):
/// сверху слева бейдж, справа превью; заголовок и подзаголовок; две кнопки снизу.
class CatalogItemCard extends StatelessWidget {
  const CatalogItemCard({
    super.key,
    required this.statusBadge,
    required this.title,
    required this.subtitle,
    required this.trailingVisual,
    required this.primaryAction,
    required this.secondaryAction,
    this.onCardTap,
    this.visualSize = 88,
  });

  /// Обычно [ActiveStatusChip] или свой бейдж.
  final Widget statusBadge;
  final String title;
  final String subtitle;
  final Widget trailingVisual;
  final CatalogItemCardAction primaryAction;
  final CatalogItemCardAction secondaryAction;
  final VoidCallback? onCardTap;
  final double visualSize;

  static const _border = Color(0xFFB2AFAF);
  static const _buttonHeight = 48.0;
  static const _buttonRadius = 12.0;

  static const _labelTextStyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 1.1,
  );

  ButtonStyle _outlinedStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppUiTokens.primaryText,
      backgroundColor: Colors.white,
      side: const BorderSide(color: _border, width: 1),
      elevation: 0,
      shadowColor: Colors.transparent,
      minimumSize: const Size(0, _buttonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
      ),
      textStyle: _labelTextStyle,
    );
  }

  ButtonStyle _filledAccentStyle() {
    return FilledButton.styleFrom(
      backgroundColor: const Color(0xFFFFCC00),
      foregroundColor: AppUiTokens.primaryText,
      elevation: 0,
      shadowColor: Colors.transparent,
      minimumSize: const Size(0, _buttonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
      ),
      textStyle: _labelTextStyle,
    );
  }

  Widget _actionButton(CatalogItemCardAction a) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (a.icon != null) ...[
          Icon(a.icon, size: 18),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            a.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _labelTextStyle.copyWith(color: AppUiTokens.primaryText),
          ),
        ),
      ],
    );

    switch (a.style) {
      case CatalogItemCardButtonStyle.outlined:
        return SizedBox(
          width: double.infinity,
          height: _buttonHeight,
          child: OutlinedButton(
            onPressed: a.onPressed,
            style: _outlinedStyle(),
            child: child,
          ),
        );
      case CatalogItemCardButtonStyle.filledAccent:
        return SizedBox(
          width: double.infinity,
          height: _buttonHeight,
          child: FilledButton(
            onPressed: a.onPressed,
            style: _filledAccentStyle(),
            child: child,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppUiTokens.borderSubtle),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      statusBadge,
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: AppUiTokens.primaryText,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppUiTokens.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: visualSize,
                  height: visualSize,
                  child: trailingVisual,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _actionButton(primaryAction)),
                const SizedBox(width: 10),
                Expanded(child: _actionButton(secondaryAction)),
              ],
            ),
          ],
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: onCardTap != null
          ? InkWell(
              onTap: onCardTap,
              borderRadius: BorderRadius.circular(16),
              child: content,
            )
          : content,
    );
  }
}
