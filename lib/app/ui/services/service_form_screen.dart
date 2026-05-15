import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/salon_service.dart';
import '../../catalog_providers.dart';
import '../widgets/components/form_text_field.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  const ServiceFormScreen({super.key, this.serviceId});

  final int? serviceId;

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
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
    final serviceId = widget.serviceId;
    if (serviceId == null) {
      return _ServiceFormScaffold(
        title: 'Новая услуга',
        formKey: _formKey,
        onSave: () => _onSave(context),
        child: _ServiceFormBody(formKey: _formKey, initial: null),
      );
    }

    final async = ref.watch(serviceDetailProvider(serviceId));
    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Услуга')),
        body: Center(child: Text('$e')),
      ),
      data: (s) => _ServiceFormScaffold(
        title: 'Редактирование',
        formKey: _formKey,
        onSave: () => _onSave(context),
        child: _ServiceFormBody(formKey: _formKey, initial: s),
      ),
    );
  }
}

class _ServiceFormScaffold extends StatelessWidget {
  const _ServiceFormScaffold({
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

class _ServiceFormBody extends ConsumerStatefulWidget {
  const _ServiceFormBody({required this.formKey, required this.initial});

  final GlobalKey<FormState> formKey;
  final SalonService? initial;

  @override
  ConsumerState<_ServiceFormBody> createState() => _ServiceFormBodyState();
}

class _ServiceFormBodyState extends ConsumerState<_ServiceFormBody> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _duration;
  late bool _active;

  static const _border = Color(0xFFB2AFAF);

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _name = TextEditingController(text: i?.name ?? '');
    _description = TextEditingController(text: i?.description ?? '');
    _price = TextEditingController(text: i != null ? i.price.toString() : '');
    _duration = TextEditingController(
      text: i != null ? '${i.durationMinutes}' : '',
    );
    _active = i?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _duration.dispose();
    super.dispose();
  }

  void _onDelete() {
    if (widget.initial == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Удаление будет доступно после сохранения услуги.'),
        ),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить услугу?'),
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
                    controller: _description,
                    labelText: 'Описание',
                    hintText: 'Введите описание...',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),
                  FormTextField(
                    controller: _price,
                    labelText: 'Цена',
                    hintText: 'Введите цену...',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Укажите цену';
                      }
                      if (double.tryParse(v.replaceAll(',', '.')) == null) {
                        return 'Некорректное число';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  FormTextField(
                    controller: _duration,
                    labelText: 'Длительность (мин)',
                    hintText: 'Введите длительность...',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Укажите длительность';
                      }
                      if (int.tryParse(v.trim()) == null) {
                        return 'Целое число';
                      }
                      return null;
                    },
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
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _onDelete,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1A1C1E),
                  side: const BorderSide(color: _border, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Удалить',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
