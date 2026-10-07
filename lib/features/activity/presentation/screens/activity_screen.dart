import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/formatting/relative_time.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/fade_switcher.dart';
import '../../../../core/widgets/list_skeleton.dart';
import '../../../../core/widgets/pull_to_refresh.dart';
import '../../domain/activity_labels.dart';
import '../providers/activity_list_controller.dart';

/// What has happened in the business and who did it, newest first, a page at a time.
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(activityListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityListControllerProvider);
    final controller = ref.read(activityListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: PullToRefresh(
        onRefresh: controller.pullToRefresh,
        child: FadeSwitcher(
          child: KeyedSubtree(
            key: ValueKey(asyncViewKind(state, isEmpty: (data) => data.items.isEmpty)),
            child: switch (state) {
              AsyncData(value: final data) when data.items.isEmpty => ScrollableFill(
                  child: EmptyState(
                    icon: Icons.history_outlined,
                    message: 'Nothing has happened yet. Creating, finalizing and sharing documents shows up here.',
                    actionLabel: 'Create a document',
                    onAction: () => context.push('/documents/new'),
                  ),
                ),
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
                    final entry = data.items[index];
                    return ListTile(
                      key: Key('activity-${entry.id}'),
                      title: Text('${activityActorName(entry)} ${describeActivity(entry)}'),
                      subtitle: Text(relativeTime(entry.createdAt)),
                    );
                  },
                ),
              AsyncError() => ScrollableFill(
                  child: ErrorState(message: "Couldn't load the activity", onRetry: controller.refresh),
                ),
              _ => const ListSkeleton(),
            },
          ),
        ),
      ),
    );
  }
}
