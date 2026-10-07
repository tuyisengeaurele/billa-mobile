import '../../../../core/widgets/pull_to_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/fade_switcher.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/list_skeleton.dart';
import '../../domain/document_enums.dart';
import '../providers/document_contact.dart';
import '../providers/document_duplicate.dart';
import '../providers/document_list_controller.dart';
import '../widgets/document_list_tile.dart';

class DocumentListScreen extends ConsumerStatefulWidget {
  const DocumentListScreen({super.key, this.initialTypes, this.initialStatus});

  final List<DocumentType>? initialTypes;
  final DocumentStatus? initialStatus;

  @override
  ConsumerState<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends ConsumerState<DocumentListScreen> {
  final _scrollController = ScrollController();
  late final Set<DocumentType> _selectedTypes = {...?widget.initialTypes};
  late DocumentStatus? _selectedStatus = widget.initialStatus;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // The list controller outlives this screen, so a filter or search from an
    // earlier visit would otherwise survive while the chips and the search
    // box start out cleared.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(documentListControllerProvider.notifier);
      final types = _selectedTypes.isEmpty ? null : _selectedTypes.toList();
      final searchWasStale = controller.resetViewState();
      if (!controller.hasFilters(types: types, status: _selectedStatus)) {
        controller.setFilters(types: types, status: _selectedStatus);
      } else if (searchWasStale) {
        controller.refresh();
      }
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
      ref.read(documentListControllerProvider.notifier).loadMore();
    }
  }

  void _toggleType(DocumentType type, bool selected) {
    setState(() {
      if (selected) {
        _selectedTypes.add(type);
      } else {
        _selectedTypes.remove(type);
      }
    });
    ref.read(documentListControllerProvider.notifier).setTypes(_selectedTypes.isEmpty ? null : _selectedTypes.toList());
  }

  void _selectStatus(DocumentStatus? status) {
    setState(() => _selectedStatus = status);
    ref.read(documentListControllerProvider.notifier).setStatusFilter(status);
  }

  @override
  void didUpdateWidget(covariant DocumentListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The tab stays alive between visits, so a link into it with new filters
    // arrives as an updated widget rather than a new screen.
    if (!listEquals(oldWidget.initialTypes, widget.initialTypes) || oldWidget.initialStatus != widget.initialStatus) {
      setState(() {
        _selectedTypes
          ..clear()
          ..addAll(widget.initialTypes ?? const []);
        _selectedStatus = widget.initialStatus;
      });
      // Providers cannot be changed while the tree is updating.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(documentListControllerProvider.notifier).setFilters(
              types: _selectedTypes.isEmpty ? null : _selectedTypes.toList(),
              status: _selectedStatus,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              key: const Key('document-search'),
              decoration: const InputDecoration(hintText: 'Search documents', prefixIcon: Icon(Icons.search)),
              onChanged: (value) => ref.read(documentListControllerProvider.notifier).setSearch(value),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  key: const Key('document-status-all'),
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  onSelected: (_) => _selectStatus(null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  key: const Key('document-status-draft'),
                  label: const Text('Draft'),
                  selected: _selectedStatus == DocumentStatus.draft,
                  onSelected: (_) => _selectStatus(DocumentStatus.draft),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  key: const Key('document-status-finalized'),
                  label: const Text('Finalized'),
                  selected: _selectedStatus == DocumentStatus.finalized,
                  onSelected: (_) => _selectStatus(DocumentStatus.finalized),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final type in DocumentType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(documentTypeLabel(type)),
                      selected: _selectedTypes.contains(type),
                      onSelected: (selected) => _toggleType(type, selected),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PullToRefresh(
            onRefresh: () => ref.read(documentListControllerProvider.notifier).pullToRefresh(),
            child: FadeSwitcher(
              child: KeyedSubtree(
                key: ValueKey(asyncViewKind(state, isEmpty: (data) => data.items.isEmpty)),
                child: switch (state) {
              AsyncData(value: final data) when data.items.isEmpty => ScrollableFill(child: const EmptyState(
                  icon: Icons.description_outlined,
                  message: 'No documents yet',
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
                    final document = data.items[index];
                    return DocumentListTile(
                      document: document,
                      onTap: () => context.push('/documents/${document.id}'),
                      onDuplicate: () => duplicateDocument(context, ref, documentId: document.id),
                      onContact: () => startDocumentContact(context, ref, documentId: document.id),
                    );
                  },
                ),
              AsyncError() => ScrollableFill(child: ErrorState(
                  message: "Couldn't load your documents",
                  onRetry: () => ref.read(documentListControllerProvider.notifier).refresh(),
                )),
              _ => const ListSkeleton(),
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
