import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/api_exception.dart';
import 'components/app_ui_tokens.dart';

/// Unified loading / empty / error / data states for list screens.
class AsyncScreenBody<T> extends StatelessWidget {
  const AsyncScreenBody({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.emptyMessage = 'Нет данных',
    this.loading,
    this.padding,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final String emptyMessage;
  final Widget? loading;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () =>
          loading ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
      error: (e, _) => _ErrorState(
        message: e is ApiException ? e.userMessage : 'Не удалось загрузить данные',
        onRetry: onRetry,
      ),
      data: (d) {
        if (d is List && d.isEmpty) {
          return _EmptyState(message: emptyMessage);
        }
        final child = data(d);
        if (padding != null) {
          return Padding(padding: padding!, child: child);
        }
        return child;
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppUiTokens.secondaryText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppUiTokens.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: Color(0xFFE53935)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Повторить'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
