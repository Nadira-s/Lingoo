import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth_notifier.dart';
import '../../catalog_providers.dart';
import '../../domain/model/branch.dart';
import '../../domain/model/salon_service.dart';
import '../../domain/model/staff_member.dart';
import '../widgets/components/form_text_field.dart';
import '../widgets/components/phone_text_field.dart';
import '../widgets/components/primary_button.dart';

class BookingFormScreen extends ConsumerStatefulWidget {
  const BookingFormScreen({super.key});

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientName = TextEditingController();
  final _clientPhone = TextEditingController();
  final _note = TextEditingController();

  late final TextEditingController _dateController;
  late final TextEditingController _timeController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Branch? _selectedBranch;
  SalonService? _selectedService;
  StaffMember? _selectedStaff;

  bool _saving = false;
  bool _defaultsApplied = false;
  static const _border = Color(0xFFB2AFAF);

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _timeController = TextEditingController();
  }

  @override
  void dispose() {
    _clientName.dispose();
    _clientPhone.dispose();
    _note.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('ru'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFCC00),
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('d MMMM yyyy', 'ru').format(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFCC00),
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_saving) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Демо: новая запись не сохраняется. Откройте запись из списка.',
        ),
      ),
    );
    context.pop();
    if (mounted) setState(() => _saving = false);
  }

  Branch? _branchValue(List<Branch> branches) {
    if (_selectedBranch == null) return null;
    for (final b in branches) {
      if (b.id == _selectedBranch!.id) return b;
    }
    return null;
  }

  SalonService? _serviceValue(List<SalonService> services) {
    if (_selectedService == null) return null;
    for (final s in services) {
      if (s.id == _selectedService!.id) return s;
    }
    return null;
  }

  StaffMember? _staffValue(List<StaffMember> staff) {
    if (_selectedStaff == null) return null;
    for (final s in staff) {
      if (s.id == _selectedStaff!.id) return s;
    }
    return null;
  }

  void _applyDefaults(BookingFormCatalog catalog) {
    if (_defaultsApplied) return;
    _defaultsApplied = true;

    final user = ref.read(authNotifierProvider).valueOrNull;
    final isManager = user?.isManagerUser ?? false;
    final profile = user?.staffProfile;
    final branches = catalog.branches;
    final services = catalog.services;
    final staff = catalog.staff;

    if (isManager && profile != null) {
      final staffMatch = staff.where((s) => s.id == profile.id && s.id > 0);
      _selectedStaff = staffMatch.isNotEmpty
          ? staffMatch.first
          : (staff.isNotEmpty ? staff.first : profile);

      final branchId = profile.branchId;
      if (branchId != null && branchId > 0) {
        final branchMatch = branches.where((b) => b.id == branchId);
        _selectedBranch =
            branchMatch.isNotEmpty ? branchMatch.first : branches.firstOrNull;
      } else if (branches.length == 1) {
        _selectedBranch = branches.first;
      }

      if (services.length == 1) {
        _selectedService = services.first;
      }
    } else if (branches.length == 1) {
      _selectedBranch ??= branches.first;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Widget _buildForm({
    required List<Branch> branches,
    required List<SalonService> services,
    required List<StaffMember> staffList,
    required bool isManager,
  }) {
    final branchValue = _branchValue(branches);
    final serviceValue = _serviceValue(services);
    final staffValue = _staffValue(staffList);
    final lockStaff = isManager;

    if (branches.isEmpty || services.isEmpty || staffList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                branches.isEmpty
                    ? 'Нет доступных филиалов для создания записи.'
                    : services.isEmpty
                        ? 'Нет доступных услуг.'
                        : 'Нет данных о специалисте.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(bookingFormCatalogProvider),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormTextField(
                    controller: _clientName,
                    labelText: 'Имя клиента',
                    hintText: 'Введите имя...',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Обязательное поле'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  PhoneTextField(
                    controller: _clientPhone,
                    labelText: 'Телефон клиента',
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: FormTextField(
                              controller: _dateController,
                              labelText: 'Дата',
                              hintText: 'Выберите...',
                              validator: (v) =>
                                  _selectedDate == null ? 'Укажите дату' : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickTime,
                          child: AbsorbPointer(
                            child: FormTextField(
                              controller: _timeController,
                              labelText: 'Время',
                              hintText: 'Выберите...',
                              validator: (v) =>
                                  _selectedTime == null ? 'Укажите время' : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Филиал',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Branch>(
                    // ignore: deprecated_member_use
                    value: branchValue,
                    hint: const Text('Выберите филиал'),
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    decoration: _dropdownDecoration(),
                    items: branches
                        .map(
                          (b) => DropdownMenuItem(
                            value: b,
                            child: Text(b.name),
                          ),
                        )
                        .toList(),
                    onChanged: isManager
                        ? null
                        : (v) => setState(() => _selectedBranch = v),
                    validator: (v) => v == null ? 'Укажите филиал' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Услуга',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<SalonService>(
                    // ignore: deprecated_member_use
                    value: serviceValue,
                    hint: const Text('Выберите услугу'),
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    decoration: _dropdownDecoration(),
                    items: services
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedService = v),
                    validator: (v) => v == null ? 'Укажите услугу' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Специалист',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<StaffMember>(
                    // ignore: deprecated_member_use
                    value: staffValue,
                    hint: const Text('Выберите специалиста'),
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    decoration: _dropdownDecoration(),
                    items: staffList
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    onChanged: lockStaff
                        ? null
                        : (v) => setState(() => _selectedStaff = v),
                    validator: (v) => v == null ? 'Укажите специалиста' : null,
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    controller: _note,
                    labelText: 'Заметка к записи',
                    hintText: 'Добавьте комментарий...',
                    maxLines: 3,
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
              onPressed: _submit,
              isLoading: _saving,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(bookingFormCatalogProvider);
    final isManager =
        ref.watch(authNotifierProvider).valueOrNull?.isManagerUser ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Новая запись',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1C1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Не удалось загрузить данные: $e',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(bookingFormCatalogProvider),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
        data: (catalog) {
          _applyDefaults(catalog);
          return _buildForm(
            branches: catalog.branches,
            services: catalog.services,
            staffList: catalog.staff,
            isManager: isManager,
          );
        },
      ),
    );
  }
}
