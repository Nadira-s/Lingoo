import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/model/staff_member.dart';
import '../../catalog_providers.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/components/form_text_field.dart';
import '../widgets/components/primary_button.dart';

class StaffFormScreen extends ConsumerStatefulWidget {
  const StaffFormScreen({super.key, this.staffId});

  final int? staffId;

  @override
  ConsumerState<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends ConsumerState<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();

  void _onSave(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Сохранено (демо-режим)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffId = widget.staffId;
    if (staffId == null) {
      return _StaffFormScaffold(
        title: 'Новый сотрудник',

        formKey: _formKey,
        onSave: () => _onSave(context),
        child: _StaffFormBody(formKey: _formKey, initial: null),
      );
    }

    final async = ref.watch(staffDetailProvider(staffId));
    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Сотрудник')),
        body: Center(child: Text('$e')),
      ),
      data: (s) => _StaffFormScaffold(
        title: 'Редактирование',
        formKey: _formKey,
        onSave: () => _onSave(context),
        child: _StaffFormBody(formKey: _formKey, initial: s),
      ),
    );
  }
}

class _StaffFormScaffold extends StatelessWidget {
  const _StaffFormScaffold({
    required this.title,
    required this.formKey,
    required this.onSave,
    required this.child,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: Text(title),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1C1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          TextButton(
            onPressed: onSave,
            child: const Text(
              'Сохранить',
              style: TextStyle(
                color: Color(0xFFFFCC00),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: child,
    );
  }
}

class _StaffFormBody extends ConsumerStatefulWidget {
  const _StaffFormBody({required this.formKey, required this.initial});

  final GlobalKey<FormState> formKey;
  final StaffMember? initial;

  @override
  ConsumerState<_StaffFormBody> createState() => _StaffFormBodyState();
}

class _StaffFormBodyState extends ConsumerState<_StaffFormBody> {
  late final TextEditingController _name;
  late final TextEditingController _position;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late String _apiRole;
  int? _branchId;
  late bool _active;
  File? _imageFile;
  final ImagePicker _imagePicker = ImagePicker();

  static const _roles = <String, String>{
    'MANAGER': 'Менеджер',
    'STAFF': 'Сотрудник',
  };

  static const _border = Color(0xFFB2AFAF);

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFCC00), width: 1.5),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _name = TextEditingController(text: i?.name ?? '');
    _position = TextEditingController(text: i?.apiRole ?? '');
    _phone = TextEditingController(text: i?.phone ?? '');
    _email = TextEditingController(text: i?.email ?? '');
    _apiRole = i?.apiRole.isNotEmpty == true ? i!.apiRole : 'MANAGER';
    if (!_roles.containsKey(_apiRole)) _apiRole = 'MANAGER';
    _branchId = i?.branchId;
    _active = i?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _position.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  void _onDelete() {
    if (widget.initial == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Удаление будет доступно после сохранения сотрудника.'),
        ),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить сотрудника?'),
        content: const Text('Демо: запись не будет удалена.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Демо: удаление не выполнено.')),
              );
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при выборе изображения: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final branches = ref.watch(branchesListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Form(
              key: widget.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile image with camera icon
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
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
                          child: _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppUiTokens.radiusLg,
                                  ),
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppUiTokens.secondaryText,
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color(0xFFFFCC00),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  FormTextField(
                    controller: _name,
                    labelText: 'Имя Фамилия',
                    hintText: 'Введите имя и фамилию...',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Обязательное поле'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    controller: _position,
                    labelText: 'Должность',
                    hintText: 'Введите должность...',
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    controller: _phone,
                    labelText: 'Телефон',
                    hintText: 'Введите телефон...',
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    controller: _email,
                    labelText: 'Email',
                    hintText: 'Введите email...',
                  ),
                  const SizedBox(height: 16),
                  branches.when(
                    data: (list) {
                      return Column(
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
                          DropdownButtonFormField<int?>(
                            initialValue: _branchId,
                            dropdownColor: Colors.white,
                            decoration: _dropdownDecoration(),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Не выбран'),
                              ),
                              ...list.map(
                                (b) => DropdownMenuItem<int?>(
                                  value: b.id,
                                  child: Text(b.name),
                                ),
                              ),
                            ],
                            onChanged: (v) => setState(() => _branchId = v),
                          ),
                        ],
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Филиалы: $e'),
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
                        initialValue: _active ? 'active' : 'inactive',
                        dropdownColor: Colors.white,
                        decoration: _dropdownDecoration(),
                        items: const [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Активен'),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text('Неактивен'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _active = v == 'active'),
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
              label: 'Удалить',
              onPressed: _onDelete,
              isOutlined: true,
            ),
          ),
        ),
      ],
    );
  }
}
