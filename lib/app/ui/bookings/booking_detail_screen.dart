import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/model/booking.dart';
import '../../auth_notifier.dart';
import '../../catalog_providers.dart';
import '../../di/app_providers.dart';
import '../../utils/api_exception.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/components/booking_status_badge.dart';
import '../widgets/components/manager_status_action_button.dart';
import '../widgets/components/status_outline_button.dart';

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final int bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppUiTokens.primaryText,
        title: const Text(
          'Детали записи',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppUiTokens.primaryText,
          ),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final isForbidden = e is ApiException && e.statusCode == 403;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                isForbidden ? 'У вас нет доступа к этой записи.' : 'Запись не найдена.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
        data: (b) => _BookingDetailContent(key: ValueKey(b.id), booking: b),
      ),
    );
  }
}

class _BookingDetailContent extends ConsumerStatefulWidget {
  const _BookingDetailContent({super.key, required this.booking});

  final Booking booking;

  @override
  ConsumerState<_BookingDetailContent> createState() =>
      _BookingDetailContentState();
}

class _BookingDetailContentState extends ConsumerState<_BookingDetailContent> {
  late String? _status;
  late final TextEditingController _noteCtrl;
  late final FocusNode _noteFocus;
  late final GlobalKey _noteKey;
  bool _saving = false;
  bool _noteEditable = false;

  static const _statuses = <String, String>{
    'NEW': 'Новая',
    'PENDING': 'Ожидает',
    'CONFIRMED': 'Подтверждена',
    'COMPLETED': 'Завершена',
    'CANCELLED': 'Отменена',
    'NO_SHOW': 'Неявка',
    'pending': 'Ожидает',
    'confirmed': 'Подтверждена',
    'completed': 'Завершена',
    'cancelled': 'Отменена',
    'no_show': 'Неявка',
    'new': 'Новая',
  };

  static const _ruMonths = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  @override
  void initState() {
    super.initState();
    final b = widget.booking;
    _status = b.status.isEmpty ? null : b.status.toUpperCase();
    if (_status != null && !_statuses.containsKey(_status)) {
      _status = b.status.isEmpty ? null : b.status;
      if (_status != null && !_statuses.containsKey(_status)) {
        _status = null;
      }
    }
    _noteCtrl = TextEditingController(text: b.note);
    _noteFocus = FocusNode();
    _noteKey = GlobalKey();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime? t) {
    if (t == null) return '—';
    final d = t.toLocal();
    return '${d.day} ${_ruMonths[d.month - 1]}, ${DateFormat('HH:mm').format(d)}';
  }

  String _phoneLine(Booking b) {
    final p = b.clientPhone?.trim();
    if (p == null || p.isEmpty) return 'Телефон не указан';
    return p;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(lingooRepositoryProvider);
      final newStatus = _status?.trim();
      final oldStatus = widget.booking.status.toUpperCase();
      if (newStatus != null &&
          newStatus.isNotEmpty &&
          newStatus.toUpperCase() != oldStatus) {
        await repo.updateBookingStatus(widget.booking.id, newStatus);
      }
      final note = _noteCtrl.text.trim();
      if (note != widget.booking.note.trim()) {
        await repo.updateBookingComment(widget.booking.id, note);
      }
      ref.invalidate(bookingDetailProvider(widget.booking.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сохранено')),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException
          ? e.userMessage
          : 'Не удалось сохранить изменения.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _applyStatus(String status) async {
    setState(() {
      _saving = true;
      _status = status;
    });
    try {
      await ref
          .read(lingooRepositoryProvider)
          .updateBookingStatus(widget.booking.id, status);
      ref.invalidate(bookingDetailProvider(widget.booking.id));
      ref.invalidate(bookingsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Статус обновлён')),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.userMessage : 'Ошибка';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openChangeStatus() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppUiTokens.radiusLg),
        ),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                'Статус записи',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppUiTokens.primaryText,
                ),
              ),
            ),
            ..._statuses.entries.map((e) {
              final selected = _status == e.key;
              return ListTile(
                title: Text(
                  e.value,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: AppUiTokens.primaryText,
                  ),
                ),
                trailing: selected
                    ? const Icon(Icons.check_rounded, color: Color(0xFFFFCC00))
                    : null,
                onTap: () {
                  setState(() => _status = e.key);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  void _onEditPressed() {
    setState(() => _noteEditable = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _noteFocus.requestFocus();
      final ctx = _noteKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  static const _labelStyle = TextStyle(
    color: AppUiTokens.secondaryText,
    fontWeight: FontWeight.w500,
    fontSize: 15,
    height: 1.25,
  );

  static const _valueStyle = TextStyle(
    color: AppUiTokens.primaryText,
    fontWeight: FontWeight.w700,
    fontSize: 15,
    height: 1.25,
  );

  Widget _infoRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 12, child: Text(label, style: _labelStyle)),
          const SizedBox(width: 12),
          Expanded(
            flex: 13,
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  trailing ??
                  Text(value, textAlign: TextAlign.right, style: _valueStyle),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isManager =
        ref.watch(authNotifierProvider).valueOrNull?.isManagerUser ?? false;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
              child: b.clientAvatarUrl != null && b.clientAvatarUrl!.isNotEmpty
                  ? Image.network(
                      b.clientAvatarUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _avatarPlaceholder(),
                    )
                  : _avatarPlaceholder(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.clientName.isEmpty ? 'Клиент' : b.clientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: AppUiTokens.primaryText,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _phoneLine(b),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color:
                          b.clientPhone == null || b.clientPhone!.trim().isEmpty
                          ? AppUiTokens.tertiaryText
                          : AppUiTokens.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
            border: Border.all(color: AppUiTokens.borderSubtle),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _infoRow('Услуга', b.serviceName.isEmpty ? '—' : b.serviceName),
                const Divider(height: 1, color: AppUiTokens.borderSubtle),
                _infoRow('Сотрудник', b.staffName.isEmpty ? '—' : b.staffName),
                const Divider(height: 1, color: AppUiTokens.borderSubtle),
                _infoRow('Дата и время', _formatDateTime(b.startsAt)),
                const Divider(height: 1, color: AppUiTokens.borderSubtle),
                _infoRow('Филиал', b.branchName.isEmpty ? '—' : b.branchName),
                const Divider(height: 1, color: AppUiTokens.borderSubtle),
                _infoRow(
                  'Статус',
                  '',
                  trailing: BookingStatusBadge(status: _status ?? b.status),
                ),
                const Divider(height: 1, color: AppUiTokens.borderSubtle),
                if (!isManager)
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Комментарий', style: _labelStyle),
                        const SizedBox(height: 10),
                        Material(
                          key: _noteKey,
                          color: AppUiTokens.surfaceMuted,
                          borderRadius: BorderRadius.circular(
                            AppUiTokens.radiusMd,
                          ),
                          child: TextField(
                            controller: _noteCtrl,
                            focusNode: _noteFocus,
                            readOnly: !_noteEditable,
                            maxLines: 6,
                            minLines: 3,
                            style: const TextStyle(
                              color: AppUiTokens.primaryText,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              height: 1.45,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.all(14),
                              border: InputBorder.none,
                              hintText: 'Нет комментария',
                              hintStyle: TextStyle(
                                color: AppUiTokens.tertiaryText,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Изменить статус',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        if (isManager) ...[
          ManagerStatusActionButton(
            label: 'Подтвердить',
            color: const Color(0xFF1B7A3D),
            loading: _saving,
            onPressed: () => _applyStatus('CONFIRMED'),
          ),
          const SizedBox(height: 10),
          ManagerStatusActionButton(
            label: 'Отменить',
            color: const Color(0xFFC62828),
            loading: _saving,
            onPressed: () => _applyStatus('CANCELLED'),
          ),
          const SizedBox(height: 10),
          ManagerStatusActionButton(
            label: 'Завершить',
            color: const Color(0xFF0B57D0),
            loading: _saving,
            onPressed: () => _applyStatus('COMPLETED'),
          ),
        ] else ...[
          StatusOutlineButton(
            label: 'Подтвердить',
            color: const Color(0xFF1B7A3D),
            loading: _saving,
            onPressed: () => _applyStatus('CONFIRMED'),
          ),
          const SizedBox(height: 10),
          StatusOutlineButton(
            label: 'Отменить',
            color: const Color(0xFFC62828),
            loading: _saving,
            onPressed: () => _applyStatus('CANCELLED'),
          ),
          const SizedBox(height: 10),
          StatusOutlineButton(
            label: 'Завершить',
            color: const Color(0xFF0B57D0),
            loading: _saving,
            onPressed: () => _applyStatus('COMPLETED'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _saving ? null : _openChangeStatus,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC00),
                foregroundColor: AppUiTokens.primaryText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              child: const Text('Изменить статус'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: _saving ? null : _onEditPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppUiTokens.primaryText,
                side: const BorderSide(color: AppUiTokens.borderSubtle, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              child: const Text('Редактировать'),
            ),
          ),
          if (_noteEditable) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Сохранить комментарий'),
              ),
            ),
          ],
        ],
        SizedBox(height: bottomInset + 8),
      ],
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: AppUiTokens.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: 40,
        color: AppUiTokens.secondaryText.withValues(alpha: 0.65),
      ),
    );
  }
}
