import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../catalog_providers.dart';
import '../widgets/components/active_status_chip.dart';
import '../widgets/components/app_bar_add_button.dart';
import '../widgets/lists/search_field.dart';

class BranchesListScreen extends ConsumerStatefulWidget {
  const BranchesListScreen({super.key});

  @override
  ConsumerState<BranchesListScreen> createState() => _BranchesListScreenState();
}

class _BranchesListScreenState extends ConsumerState<BranchesListScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Филиалы',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Color(0xFF1A1C1E),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1C1E),
        actions: [
          AppBarAddButton(onPressed: () => context.push('/branches/new')),
        ],
      ),
      body: list.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Список пуст.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(branchesListProvider);
              await ref.read(branchesListProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: items.length + 1,
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
                final b = items[i - 1];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0F0F0)),
                  ),
                  child: GestureDetector(
                    onTap: () => context.push('/branches/${b.id}/edit'),
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
                                  color: Color(0xFF1A1C1E),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                b.address.isEmpty ? '—' : b.address,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xFF8B8B8B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ActiveStatusChip(active: b.isActive),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
