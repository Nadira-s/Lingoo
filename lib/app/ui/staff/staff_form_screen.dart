import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/branch.dart';
import '../../domain/model/staff_member.dart';
import '../../domain/model/user_role.dart';
import '../../access_providers.dart';
import '../../catalog_providers.dart';
import '../../di/app_providers.dart';
import '../../utils/api_exception.dart';
import '../../utils/phone_format.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/components/form_text_field.dart';
import '../widgets/components/password_text_field.dart';
import '../widgets/components/phone_text_field.dart';
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
    
    Widget buildBody(StaffMember? initial) {
      return _StaffFormBody(
        key: _bodyKey,
        formKey: _formKey,
        initial: initial,
        saving: _saving,
        onSave: () => _onSave(context),
      );
    }

    if (staffId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title: const Text('Новый сотрудник'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1C1E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: buildBody(null),
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
      data: (s) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title: const Text('Редактирование'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1C1E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            TextButton(
              onPressed: _saving ? null : () => _bodyKey.currentState?.onDelete(),
              child: const Text(
                'Удалить',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        body: buildBody(s),
      ),
    );
  }
}

class _StaffFormBody extends ConsumerStatefulWidget {
  const _StaffFormBody({
    super.key,
    required this.formKey,
    required this.initial,
    required this.saving,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final StaffMember? initial;
  final bool saving;
  final VoidCallback onSave;

  @override
  ConsumerState<_StaffFormBody> createState() => _StaffFormBodyState();
}

class _StaffFormBodyState extends ConsumerState<_StaffFormBody> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _password;
  int? _branchId;
  final Set<int> _serviceIds = {};
  late bool _active;

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
    final rawBranch = i?.branchId;
    _branchId = rawBranch != null && rawBranch > 0 ? rawBranch : null;
    _serviceIds.addAll(i?.serviceIds ?? const []);
    _active = i?.isActive ?? true;
  }

  @override
  void didUpdateWidget(covariant _StaffFormBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final raw = widget.initial?.branchId;
    if (raw != null && raw > 0 && _branchId == null) {
      _branchId = raw;
    }
  }

  /// ID филиала, который реально есть в списке с API.
  int? _resolvedBranchId(List<Branch> branches) {
    if (_branchId != null &&
        _branchId! > 0 &&
        branches.any((b) => b.id == _branchId)) {
      return _branchId;
    }
    final fromInitial = widget.initial?.branchId;
    if (fromInitial != null &&
        fromInitial > 0 &&
        branches.any((b) => b.id == fromInitial)) {
      return fromInitial;
    }
    if (branches.length == 1) {
      final only = branches.first.id;
      if (only > 0) return only;
    }
    return null;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  StaffMember _buildDraft({int? branchId}) {
    return StaffMember(
      id: widget.initial?.id ?? 0,
      name: _name.text.trim(),
      phone: PhoneFormat.forApi(_phone.text),
      email: _email.text.trim(),
      role: UserRole.manager,
      apiRole: 'MANAGER',
      branchId: branchId ?? _branchId,
      branchName: '',
      isActive: _active,
      serviceIds: _serviceIds.toList(),
      bufferMinutes: widget.initial?.bufferMinutes ?? 0,
    );
  }

  Future<void> onDelete() => _onDelete();

  void _showError(Object e) {
    var msg = e is ApiException
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
    List<Branch> branches;
    try {
      branches = await ref.read(branchesListProvider.future);
    } catch (e) {
      _showError(e);
      return false;
    }
    if (!mounted) return false;
    final branchId = _resolvedBranchId(
      branches.where((b) => b.id > 0).toList(),
    );
    if (branchId == null || branchId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Выберите филиал из списка. Если список пуст или не загрузился — '
            'создайте филиал в разделе «Филиалы».',
          ),
        ),
      );
      return false;
    }
    if (_branchId != branchId) {
      setState(() => _branchId = branchId);
    }
    final repo = ref.read(lingooRepositoryProvider);
    final draft = _buildDraft(branchId: branchId);
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
      ref.invalidate(accessUsersProvider);
      if (widget.initial != null) {
        ref.invalidate(staffDetailProvider(widget.initial!.id));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сотрудник сохранён')),
        );
      }
      return true;
    } on ApiException catch (e) {
      if (e.code == 'staff_partial_create' || e.code == 'staff_partial_update') {
        ref.invalidate(staffListProvider);
        ref.invalidate(accessUsersProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.userMessage),
              duration: const Duration(seconds: 6),
            ),
          );
        }
        return true;
      }
      _showError(e);
      return false;
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
                  // Profile image
                  Center(
                    child: Container(
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
                    controller: _name,
                    labelText: 'Имя Фамилия',
                    hintText: 'Введите имя и фамилию...',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Обязательное поле'
                        : null,
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
                    hintText: 'Введите email...',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Обязательное поле'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  PasswordTextField(
                    controller: _password,
                    labelText: widget.initial == null
                        ? 'Пароль'
                        : 'Новый пароль (необязательно)',
                    hintText: 'Введите пароль...',
                    validator: widget.initial == null
                        ? (v) => (v == null || v.trim().length < 4)
                            ? 'Минимум 4 символа'
                            : null
                        : null,
                  ),
                  const SizedBox(height: 16),

                  ref.watch(servicesListProvider).when(
                    data: (services) {
                      if (services.isEmpty) {
                        return const Text(
                          'Сначала создайте услуги в разделе «Услуги»',
                          style: TextStyle(color: AppUiTokens.secondaryText),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Услуги',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppUiTokens.primaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: services.map((s) {
                              final selected = _serviceIds.contains(s.id);
                              return FilterChip(
                                label: Text(s.name),
                                selected: selected,
                                selectedColor: const Color(0xFFFFF3B0),
                                checkmarkColor: Colors.black,
                                onSelected: (v) {
                                  setState(() {
                                    if (v) {
                                      _serviceIds.add(s.id);
                                    } else {
                                      _serviceIds.remove(s.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Услуги: $e'),
                  ),
                  const SizedBox(height: 16),
                  branches.when(
                    data: (list) {
                      final valid = list.where((b) => b.id > 0).toList();
                      final selectedId = _resolvedBranchId(valid);
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
                          if (valid.isEmpty)
                            const Text(
                              'Сначала создайте филиал в разделе «Филиалы»',
                              style: TextStyle(color: AppUiTokens.secondaryText),
                            )
                          else
                            DropdownButtonFormField<int>(
                              initialValue: selectedId,
                              dropdownColor: Colors.white,
                              decoration: _dropdownDecoration(),
                              hint: const Text('Выберите филиал'),
                              items: valid
                                  .map(
                                    (b) => DropdownMenuItem<int>(
                                      value: b.id,
                                      child: Text(
                                        b.name.isEmpty ? 'Филиал #${b.id}' : b.name,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null && v > 0) {
                                  setState(() => _branchId = v);
                                }
                              },
                              validator: (_) =>
                                  selectedId == null || selectedId <= 0
                                  ? 'Выберите филиал'
                                  : null,
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
              label: 'Сохранить',
              onPressed: widget.onSave,
              isLoading: widget.saving,
            ),
          ),
        ),
      ],
    );
  }
}
