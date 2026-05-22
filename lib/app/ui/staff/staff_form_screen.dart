import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/model/staff_member.dart';
import '../../domain/model/user_role.dart';
import '../../catalog_providers.dart';
import '../../di/app_providers.dart';
import '../../utils/api_exception.dart';
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
  final _bodyKey = GlobalKey<_StaffFormBodyState>();
  bool _saving = false;

  Future<void> _onSave(BuildContext context) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final ok = await _bodyKey.currentState?.submit() ?? false;
      if (ok && context.mounted) Navigator.of(context).maybePop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffId = widget.staffId;
    if (staffId == null) {
      return _StaffFormScaffold(
        title: 'Новый сотрудник',
        saving: _saving,
        onSave: () => _onSave(context),
        child: _StaffFormBody(
          key: _bodyKey,
          formKey: _formKey,
          initial: null,
        ),
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
        saving: _saving,
        onSave: () => _onSave(context),
        child: _StaffFormBody(
          key: _bodyKey,
          formKey: _formKey,
          initial: s,
        ),
      ),
    );
  }
}

class _StaffFormScaffold extends StatelessWidget {
  const _StaffFormScaffold({
    required this.title,
    required this.onSave,
    required this.child,
    this.saving = false,
  });

  final String title;
  final VoidCallback onSave;
  final Widget child;
  final bool saving;

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
            onPressed: saving ? null : onSave,
            child: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
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
  const _StaffFormBody({
    super.key,
    required this.formKey,
    required this.initial,
  });

  final GlobalKey<FormState> formKey;
  final StaffMember? initial;

  @override
  ConsumerState<_StaffFormBody> createState() => _StaffFormBodyState();
}

class _StaffFormBodyState extends ConsumerState<_StaffFormBody> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _password;
  int? _branchId;
  late bool _active;
  File? _imageFile;
  final ImagePicker _imagePicker = ImagePicker();

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
    _phone = TextEditingController(text: i?.phone ?? '');
    _email = TextEditingController(text: i?.email ?? '');
    _password = TextEditingController();
    _branchId = i?.branchId;
    _active = i?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  StaffMember _buildDraft() {
    return StaffMember(
      id: widget.initial?.id ?? 0,
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      role: UserRole.manager,
      apiRole: 'MANAGER',
      branchId: _branchId,
      branchName: '',
      isActive: _active,
    );
  }

  void _showError(Object e) {
    final msg = e is ApiException
        ? e.userMessage
        : 'Не удалось выполнить операцию.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> submit() async {
    if (!(widget.formKey.currentState?.validate() ?? false)) return false;
    final email = _email.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите email сотрудника')),
      );
      return false;
    }
    final repo = ref.read(lingooRepositoryProvider);
    final draft = _buildDraft();
    final password = _password.text.trim();
    try {
      if (widget.initial == null) {
        if (password.length < 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Укажите пароль для нового сотрудника')),
          );
          return false;
        }
        await repo.createStaff(draft, password: password);
      } else {
        await repo.updateStaff(
          draft,
          password: password.isNotEmpty ? password : null,
        );
      }
      ref.invalidate(staffListProvider);
      if (widget.initial != null) {
        ref.invalidate(staffDetailProvider(widget.initial!.id));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сотрудник сохранён')),
        );
      }
      return true;
    } catch (e) {
      _showError(e);
      return false;
    }
  }

  Future<void> _onDelete() async {
    if (widget.initial == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Удаление будет доступно после сохранения сотрудника.'),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить сотрудника?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(lingooRepositoryProvider).deleteStaff(widget.initial!.id);
      ref.invalidate(staffListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сотрудник удалён')),
        );
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      _showError(e);
    }
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
                    controller: _phone,
                    labelText: 'Телефон',
                    hintText: 'Введите телефон...',
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    controller: _email,
                    labelText: 'Email',
                    hintText: 'Введите email...',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Обязательное поле'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    controller: _password,
                    labelText: widget.initial == null
                        ? 'Пароль'
                        : 'Новый пароль (необязательно)',
                    hintText: 'Введите пароль...',
                    obscureText: true,
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
                            value: _branchId,
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
                        value: _active ? 'active' : 'inactive',
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
