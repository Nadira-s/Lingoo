import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../catalog_providers.dart';
import '../../domain/model/branch.dart';
import '../widgets/async_screen_body.dart';
import '../widgets/components/active_status_chip.dart';
import '../widgets/components/app_bar_add_button.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/lists/search_field.dart';

class BranchesListScreen extends ConsumerStatefulWidget {
  const BranchesListScreen({super.key});

  @override
  ConsumerState<BranchesListScreen> createState() => _BranchesListScreenState();
}

class _BranchesListScreenState extends ConsumerState<BranchesListScreen> {
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
    final list = ref.watch(branchesListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Филиалы',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: AppUiTokens.primaryText,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppUiTokens.primaryText,
        actions: [
          AppBarAddButton(onPressed: () => context.push('/branches/new')),
        ],
      ),
      body: AsyncScreenBody<List<Branch>>(
        value: list,
        emptyMessage: 'Филиалов пока нет',
        onRetry: () => ref.invalidate(branchesListProvider),
        data: (items) {
          final q = _searchController.text.trim().toLowerCase();
          final filtered = q.isEmpty
              ? items
              : items
                  .where(
                    (b) =>
                        b.name.toLowerCase().contains(q) ||
                        b.address.toLowerCase().contains(q),
                  )
                  .toList();
          if (filtered.isEmpty) {
            return const Center(child: Text('Ничего не найдено'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(branchesListProvider);
              await ref.read(branchesListProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: filtered.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SearchField(
                      controller: _searchController,
                      hintText: 'Поиск филиала...',
                    ),
                  );
                }
                final b = filtered[i - 1];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppUiTokens.borderSubtle),
                  ),
                  child: InkWell(
                    onTap: () => context.push('/branches/${b.id}/edit'),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.name.isEmpty ? 'Без названия' : b.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                b.address.isEmpty ? '—' : b.address,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: AppUiTokens.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ActiveStatusChip(active: b.isActive),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
