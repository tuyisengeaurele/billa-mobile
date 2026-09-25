import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/search_result.dart';
import '../providers/search_repository_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const _minLength = 2;
  static const _debounce = Duration(milliseconds: 300);

  final _controller = TextEditingController();
  Timer? _timer;
  String _query = '';
  Future<List<SearchResult>>? _future;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    final query = value.trim();
    if (query.length < _minLength) {
      setState(() {
        _query = '';
        _future = null;
      });
      return;
    }
    // Debounced so a fast typist fires one request, not one per keystroke.
    _timer = Timer(_debounce, () => _run(query));
  }

  void _run(String query) {
    setState(() {
      _query = query;
      _future = ref.read(searchRepositoryProvider).search(query);
    });
  }

  static const _sections = [
    (SearchResultType.customer, 'Customers', Icons.people_outline),
    (SearchResultType.item, 'Items', Icons.inventory_2_outlined),
    (SearchResultType.document, 'Documents', Icons.description_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const Key('search-field'),
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(hintText: 'Search customers, items, documents', border: InputBorder.none),
          onChanged: _onChanged,
        ),
      ),
      body: _future == null
          ? const EmptyState(
              icon: Icons.search,
              message: 'Type at least 2 characters to search customers, items, and documents.',
            )
          : FutureBuilder<List<SearchResult>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorState(
                    message: describeActionError(snapshot.error!),
                    onRetry: () => _run(_query),
                  );
                }
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(children: [
                      LoadingSkeleton(height: 56),
                      SizedBox(height: 12),
                      LoadingSkeleton(height: 56),
                    ]),
                  );
                }
                final results = snapshot.data!;
                if (results.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    message: 'No matches for "$_query". Try a customer name, an item, or a document number.',
                  );
                }
                return ListView(
                  children: [
                    for (final (type, title, icon) in _sections)
                      if (results.any((r) => r.type == type)) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
                        ),
                        for (final result in results.where((r) => r.type == type))
                          ListTile(
                            key: Key('search-result-${result.id}'),
                            leading: Icon(icon),
                            title: Text(result.label),
                            subtitle: result.sublabel.isEmpty ? null : Text(result.sublabel),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push(result.route),
                          ),
                      ],
                  ],
                );
              },
            ),
    );
  }
}
