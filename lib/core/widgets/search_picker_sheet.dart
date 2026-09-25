import 'app_sheet.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../errors/action_errors.dart';
import 'error_state.dart';
import 'loading_skeleton.dart';

Future<T?> showSearchPickerSheet<T>({
  required BuildContext context,
  required String title,
  required Future<List<T>> Function(String search) fetch,
  required Widget Function(T item) itemBuilder,
}) {
  return showAppSheet<T>(
    context,
    scrollable: false,
    builder: (context) => _SearchPickerSheet<T>(title: title, fetch: fetch, itemBuilder: itemBuilder),
  );
}

class _SearchPickerSheet<T> extends StatefulWidget {
  const _SearchPickerSheet({required this.title, required this.fetch, required this.itemBuilder});

  final String title;
  final Future<List<T>> Function(String search) fetch;
  final Widget Function(T item) itemBuilder;

  @override
  State<_SearchPickerSheet<T>> createState() => _SearchPickerSheetState<T>();
}

class _SearchPickerSheetState<T> extends State<_SearchPickerSheet<T>> {
  static const _debounce = Duration(milliseconds: 300);
  Timer? _debounceTimer;
  String _search = '';
  late Future<List<T>> _results = widget.fetch('');

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () {
      if (mounted) {
        setState(() {
          _search = value;
          _results = widget.fetch(value);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  key: const Key('search-picker-field'),
                  decoration: const InputDecoration(hintText: 'Search', prefixIcon: Icon(Icons.search)),
                  onChanged: _onSearchChanged,
                ),
              ),
              Expanded(
                child: FutureBuilder<List<T>>(
                  future: _results,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return ErrorState(
                        message: describeActionError(snapshot.error!),
                        onRetry: () => setState(() {
                          _results = widget.fetch(_search);
                        }),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(children: [
                          LoadingSkeleton(height: 48),
                          SizedBox(height: 8),
                          LoadingSkeleton(height: 48),
                        ]),
                      );
                    }
                    final items = snapshot.data!;
                    if (items.isEmpty) return const Center(child: Text('No results'));
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return InkWell(
                          onTap: () => Navigator.of(context).pop(item),
                          child: widget.itemBuilder(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
        ),
      ),
    );
  }
}
