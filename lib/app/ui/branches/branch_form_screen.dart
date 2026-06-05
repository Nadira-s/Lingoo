import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/branch.dart';
import '../../catalog_providers.dart';
import '../../dashboard_provider.dart';
import '../../di/app_providers.dart';
import '../../utils/api_exception.dart';
import '../../utils/phone_format.dart';
import '../widgets/components/form_text_field.dart';
import '../widgets/components/phone_text_field.dart';
import '../widgets/components/primary_button.dart';

class BranchFormScreen extends ConsumerStatefulWidget {
  const BranchFormScreen({super.key, this.branchId});

  final int? branchId;

  @override
  ConsumerState<BranchFormScreen> createState() => _BranchFormScreenState();
}

class _BranchFormScreenState extends ConsumerState<BranchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bodyKey = GlobalKey<_BranchFormBodyState>();
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
    final branchId = widget.branchId;

    Widget buildBody(Branch? initial) {
      return _BranchFormBody(
        key: _bodyKey,
        formKey: _formKey,
        initial: initial,
        saving: _saving,
        onSave: () => _onSave(context),
      );
    }

    if (branchId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Новый филиал'),
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

    final async = ref.watch(branchDetailProvider(branchId));
    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Филиал')),
        body: Center(child: Text('$e')),
      ),
      data: (b) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
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
        body: buildBody(b),
      ),
    );
  }
}

class _BranchFormBody extends ConsumerStatefulWidget {
  const _BranchFormBody({
    super.key,
    required this.formKey,
    required this.initial,
    required this.saving,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final Branch? initial;
  final bool saving;
  final VoidCallback onSave;

  @override
  ConsumerState<_BranchFormBody> createState() => _BranchFormBodyState();
}

class _BranchFormBodyState extends ConsumerState<_BranchFormBody> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late bool _active;

  static const _border = Color(0xFFB2AFAF);

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _name = TextEditingController(text: i?.name ?? '');
    _address = TextEditingController(text: i?.address ?? '');
    _phone = TextEditingController(text: i?.phone ?? '');
    _active = i?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Branch _buildDraft() {
    return Branch(
      id: widget.initial?.id ?? 0,
      name: _name.text.trim(),
      address: _address.text.trim(),
      phone: PhoneFormat.forApi(_phone.text),
      isActive: _active,
    );
  }

  void _showError(Object e) {
    final msg = e is ApiException
        ? e.userMessage
        : 'Не удалось выполнить операцию.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> onDelete() => _onDelete();

  Future<bool> submit() async {
    if (!(widget.formKey.currentState?.validate() ?? false)) return false;
    final repo = ref.read(lingooRepositoryProvider);
    try {
      if (widget.initial == null) {
        await repo.createBranch(_buildDraft());
      } else {
        await repo.updateBranch(_buildDraft());
      }
      ref.invalidate(branchesListProvider);
      ref.invalidate(dashboardDataProvider);
      if (widget.initial != null) {
        ref.invalidate(branchDetailProvider(widget.initial!.id));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Филиал сохранён')),
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
          content: Text('Удаление будет доступно после сохранения филиала.'),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить филиал?'),
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
      await ref.read(lingooRepositoryProvider).deleteBranch(widget.initial!.id);
      ref.invalidate(branchesListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Филиал удалён')),
        );
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  FormTextField(
                    controller: _name,
                    labelText: 'Название',
                    hintText: 'Введите название...',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Обязательное поле'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    controller: _address,
                    labelText: 'Адрес',
                    hintText: 'Введите адрес...',
                  ),
                  const SizedBox(height: 16),
                  PhoneTextField(
                    controller: _phone,
                    labelText: 'Телефон',
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
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _active ? 'active' : 'inactive',
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
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFFFCC00),
                              width: 1.5,
                            ),
                          ),
                        ),
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
