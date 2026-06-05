import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth_notifier.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/components/form_text_field.dart';
import '../widgets/components/primary_button.dart';

class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _emailController;
  late String _selectedBranch;
  late String _selectedStatus;


  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).valueOrNull;
    _nameController = TextEditingController(text: user?.username ?? '');
    _positionController = TextEditingController(
      text: user?.staffProfile?.apiRole ?? user?.role.displayRu ?? '',
    );
    _emailController = TextEditingController(
      text: user?.staffProfile?.email ?? '',
    );
    _selectedBranch = user?.tenant?.name ?? 'Main Branch';
    _selectedStatus = 'Активен';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    super.dispose();
  }



  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль сохранён (демо-режим)')),
      );
    }
  }

  void _onLogout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).logout();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Изменить профиль',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: AppUiTokens.primaryText,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppUiTokens.primaryText,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          TextButton(
            onPressed: _onLogout,
            child: const Text(
              'Выйти',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Image
                    Center(
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppUiTokens.radiusLg,
                          ),
                          color: AppUiTokens.surfaceMuted,
                          border: Border.all(
                            color: AppUiTokens.borderSubtle,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: AppUiTokens.secondaryText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FormTextField(
                      controller: _nameController,
                      labelText: 'Имя Фамилия',
                      hintText: 'Введите имя и фамилию...',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Обязательное поле'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    FormTextField(
                      controller: _positionController,
                      labelText: 'Должность',
                      hintText: 'Введите должность...',
                    ),
                    const SizedBox(height: 16),
                    FormTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Введите email...',
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Филиал',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppUiTokens.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedBranch,
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFB2AFAF),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFB2AFAF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFFC107),
                                width: 1.5,
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Main Branch',
                              child: Text('Main Branch'),
                            ),
                            DropdownMenuItem(
                              value: 'Secondary Branch',
                              child: Text('Secondary Branch'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedBranch = v ?? ''),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Статус',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppUiTokens.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedStatus,
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFB2AFAF),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFB2AFAF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFFC107),
                                width: 1.5,
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Активен',
                              child: Text('Активен'),
                            ),
                            DropdownMenuItem(
                              value: 'Неактивен',
                              child: Text('Неактивен'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedStatus = v ?? ''),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: PrimaryButton(
                label: 'Сохранить',
                onPressed: _onSave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
