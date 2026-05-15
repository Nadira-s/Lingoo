import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/branch.dart';
import '../../catalog_providers.dart';
import '../widgets/components/form_text_field.dart';
import '../widgets/components/primary_button.dart';

class BranchFormScreen extends ConsumerStatefulWidget {
  const BranchFormScreen({super.key, this.branchId});

  final int? branchId;

  @override
  ConsumerState<BranchFormScreen> createState() => _BranchFormScreenState();
}

class _BranchFormScreenState extends ConsumerState<BranchFormScreen> {
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
    final branchId = widget.branchId;
    if (branchId == null) {
      return _FormScaffold(
        title: 'Новый филиал',
        formKey: _formKey,
        onSave: () => _onSave(context),
        child: _BranchFormBody(formKey: _formKey, initial: null),
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
      data: (b) => _FormScaffold(
        title: 'Редактирование',
        formKey: _formKey,
        onSave: () => _onSave(context),
        child: _BranchFormBody(formKey: _formKey, initial: b),
      ),
    );
  }
}

class _FormScaffold extends StatelessWidget {
  const _FormScaffold({
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
        centerTitle: true,
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

class _BranchFormBody extends ConsumerStatefulWidget {
  const _BranchFormBody({required this.formKey, required this.initial});

  final GlobalKey<FormState> formKey;
  final Branch? initial;

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

  void _onDelete() {
    if (widget.initial == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Удаление будет доступно после сохранения филиала.'),
        ),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить филиал?'),
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
                  FormTextField(
                    controller: _phone,
                    labelText: 'Телефон',
                    hintText: 'Введите телефон...',
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
