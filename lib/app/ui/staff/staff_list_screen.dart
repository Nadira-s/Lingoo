import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth_notifier.dart';
import '../../catalog_providers.dart';
import '../widgets/components/app_bar_add_button.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/lists/search_field.dart';
import '../widgets/cards/staff_list_card.dart';

class StaffListScreen extends ConsumerStatefulWidget {
  const StaffListScreen({super.key});

  @override
  ConsumerState<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends ConsumerState<StaffListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(staffListProvider);
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final isManager = user?.isManagerUser ?? false;
    final ownStaffId = user?.staffProfile?.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'Сотрудники',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: AppUiTokens.primaryText,
          ),
        ),
        actions: [
          if (!isManager)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppBarAddButton(onPressed: () => context.push('/staff/new')),
            ),
        ],
      ),
      body: list.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Список пуст.'));
          }

          final q = _searchController.text.trim().toLowerCase();
          final filtered = q.isEmpty
              ? items
              : items
                    .where(
                      (s) =>
                          s.name.toLowerCase().contains(q) ||
                          s.email.toLowerCase().contains(q) ||
                          s.phone.contains(q) ||
                          s.branchName.toLowerCase().contains(q),
                    )
                    .toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(staffListProvider);
              await ref.read(staffListProvider.future);
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: SearchField(
                      controller: _searchController,
                      hintText: 'Поиск сотрудника...',
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'Ничего не найдено',
                        style: TextStyle(
                          color: AppUiTokens.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final s = filtered[index];
                        final isOwn = ownStaffId != null && s.id == ownStaffId;
                        return StaffListCard(
                          member: s,
                          readOnly: isManager,
                          showSchedule: isManager ? isOwn : true,
                          onEdit: () => context.push('/staff/${s.id}/edit'),
                          onSchedule: () =>
                              context.push('/staff/${s.id}/schedule'),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
