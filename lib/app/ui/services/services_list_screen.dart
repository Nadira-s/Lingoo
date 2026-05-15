import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../catalog_providers.dart';
import '../widgets/components/app_bar_add_button.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/lists/search_field.dart';
import '../widgets/cards/service_list_card.dart';

class ServicesListScreen extends ConsumerStatefulWidget {
  const ServicesListScreen({super.key});

  @override
  ConsumerState<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends ConsumerState<ServicesListScreen> {
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
    final list = ref.watch(servicesListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'Услуги',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: AppUiTokens.primaryText,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppBarAddButton(
              onPressed: () => context.push('/services/new'),
            ),
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
                          s.description.toLowerCase().contains(q),
                    )
                    .toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(servicesListProvider);
              await ref.read(servicesListProvider.future);
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: SearchField(
                      controller: _searchController,
                      hintText: 'Поиск услуги...',
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
                        return ServiceListCard(
                          service: s,
                          onEdit: () => context.push('/services/${s.id}/edit'),
                          onSchedule: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Расписание: ${s.name}')),
                            );
                          },
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
