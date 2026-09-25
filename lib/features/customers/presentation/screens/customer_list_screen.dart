import '../../../../core/widgets/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/fade_switcher.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../providers/customer_list_controller.dart';
import '../widgets/customer_list_tile.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _scrollController = ScrollController();
  bool _includeInactive = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // The list controller outlives this screen, so search or a toggle from an
    // earlier visit would otherwise stay applied behind an empty search box.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(customerListControllerProvider.notifier);
      if (controller.resetViewState()) controller.refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(customerListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/customers/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('customer-search'),
                    decoration: const InputDecoration(hintText: 'Search customers', prefixIcon: Icon(Icons.search)),
                    onChanged: (value) => ref.read(customerListControllerProvider.notifier).setSearch(value),
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  key: const Key('customer-show-inactive'),
                  label: const Text('Show inactive'),
                  selected: _includeInactive,
                  onSelected: (value) {
                    setState(() => _includeInactive = value);
                    ref.read(customerListControllerProvider.notifier).setIncludeInactive(value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: PullToRefresh(
            onRefresh: () => ref.read(customerListControllerProvider.notifier).pullToRefresh(),
            child: FadeSwitcher(
              child: KeyedSubtree(
                key: ValueKey(asyncViewKind(state, isEmpty: (data) => data.items.isEmpty)),
                child: switch (state) {
              AsyncData(value: final data) when data.items.isEmpty => ScrollableFill(child: EmptyState(
                  icon: Icons.people_outline,
                  message: 'No customers yet',
                  actionLabel: 'Add customer',
                  onAction: () => context.push('/customers/new'),
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
                    final customer = data.items[index];
                    return CustomerListTile(
                      customer: customer,
                      onTap: () => context.push('/customers/${customer.id}'),
                    );
                  },
                ),
              AsyncError() => ScrollableFill(child: ErrorState(
                  message: "Couldn't load your customers",
                  onRetry: () => ref.read(customerListControllerProvider.notifier).refresh(),
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
