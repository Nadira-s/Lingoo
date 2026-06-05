import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth_notifier.dart';
import '../../data_providers.dart';
import '../../domain/model/business_settings.dart';
import '../../di/app_providers.dart';
import '../../utils/api_exception.dart';
import '../../utils/phone_format.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/components/form_text_field.dart';
import '../widgets/components/phone_text_field.dart';
import '../widgets/components/primary_button.dart';

/// Настройки бизнеса — Screen Map §10.
class BusinessSettingsScreen extends ConsumerStatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  ConsumerState<BusinessSettingsScreen> createState() =>
      _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends ConsumerState<BusinessSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _currency = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _phone.dispose();
    _email.dispose();
    _currency.dispose();
    super.dispose();
  }

  void _bind(BusinessSettings s) {
    if (_loaded) return;
    _name.text = s.name;
    _description.text = s.description;
    PhoneFormat.applyToController(_phone, s.phone);
    _email.text = s.email;
    _currency.text = s.currency;
    _loaded = true;
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы будете перенаправлены на экран входа.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go('/login');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final draft = BusinessSettings(
        name: _name.text.trim(),
        description: _description.text.trim(),
        phone: PhoneFormat.forApi(_phone.text),
        email: _email.text.trim(),
        currency: _currency.text.trim(),
      );
      await ref.read(lingooRepositoryProvider).updateBusinessSettings(draft);
      ref.invalidate(businessSettingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Настройки бизнеса сохранены')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.userMessage : 'Ошибка сохранения';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(businessSettingsProvider);
    final publicUrl = ref.watch(publicBookingUrlProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки бизнеса'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) {
          _bind(s);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormTextField(
                    controller: _name,
                    labelText: 'Название',
                    hintText: 'Название компании',
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    controller: _description,
                    labelText: 'Описание',
                    hintText: 'Описание',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  PhoneTextField(
                    controller: _phone,
                    labelText: 'Телефон',
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    controller: _email,
                    labelText: 'Email',
                    hintText: 'email@company.com',
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    controller: _currency,
                    labelText: 'Валюта',
                    hintText: 'KZT',
                  ),
                  const SizedBox(height: 24),
                  publicUrl.when(
                    data: (url) => url.isEmpty
                        ? const SizedBox.shrink()
                        : Text(
                            'Ссылка для записи:\n$url',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _saving ? 'Сохранение...' : 'Сохранить',
                    onPressed: _saving ? () {} : _save,
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Аккаунт',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppUiTokens.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Выйти из аккаунта',
                    isOutlined: true,
                    onPressed: _logout,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
