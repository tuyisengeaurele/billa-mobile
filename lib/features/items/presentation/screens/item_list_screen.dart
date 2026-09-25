import '../../../../core/widgets/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/fade_switcher.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../providers/item_list_controller.dart';
import '../widgets/item_list_tile.dart';

class ItemListScreen extends ConsumerStatefulWidget {
  const ItemListScreen({super.key});

  @override
  ConsumerState<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends ConsumerState<ItemListScreen> {
  final _scrollController = ScrollController();
  final _categoryController = TextEditingController();
  bool _includeInactive = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // The list controller outlives this screen, so search or a toggle from an
    // earlier visit would otherwise stay applied behind an empty search box.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(itemListControllerProvider.notifier);
      if (controller.resetViewState()) controller.refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(itemListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/items/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('item-search'),
                        decoration: const InputDecoration(hintText: 'Search items', prefixIcon: Icon(Icons.search)),
                        onChanged: (value) => ref.read(itemListControllerProvider.notifier).setSearch(value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      key: const Key('item-show-inactive'),
                      label: const Text('Show inactive'),
                      selected: _includeInactive,
                      onSelected: (value) {
                        setState(() => _includeInactive = value);
                        ref.read(itemListControllerProvider.notifier).setIncludeInactive(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('item-category-filter'),
                  controller: _categoryController,
                  decoration: const InputDecoration(hintText: 'Filter by category (optional)'),
                  onSubmitted: (value) => ref
                      .read(itemListControllerProvider.notifier)
                      .setCategory(value.trim().isEmpty ? null : value.trim()),
                ),
              ],
            ),
          ),
          Expanded(
            child: PullToRefresh(
            onRefresh: () => ref.read(itemListControllerProvider.notifier).pullToRefresh(),
            child: FadeSwitcher(
              child: KeyedSubtree(
                key: ValueKey(asyncViewKind(state, isEmpty: (data) => data.items.isEmpty)),
                child: switch (state) {
              AsyncData(value: final data) when data.items.isEmpty => ScrollableFill(child: EmptyState(
                  icon: Icons.inventory_2_outlined,
                  message: 'No items yet',
                  actionLabel: 'Add item',
                  onAction: () => context.push('/items/new'),
                )),
              AsyncData(value: final data) => ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: data.items.length + (data.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= data.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    final item = data.items[index];
                    return ItemListTile(
                      item: item,
                      onTap: () => context.push('/items/${item.id}/edit', extra: item),
                    );
                  },
                ),
              AsyncError() => ScrollableFill(child: ErrorState(
                  message: "Couldn't load your items",
                  onRetry: () => ref.read(itemListControllerProvider.notifier).refresh(),
                )),
              _ => ScrollableFill(child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(children: [LoadingSkeleton(height: 64), SizedBox(height: 12), LoadingSkeleton(height: 64)]),
                )),
            },
              ),
            )
          ),
          ),
        ],
      ),
    );
  }
}
