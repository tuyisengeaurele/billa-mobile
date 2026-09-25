import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../items/domain/item.dart';

sealed class _Suggestion {
  const _Suggestion();
}

class _ItemSuggestion extends _Suggestion {
  const _ItemSuggestion(this.item);
  final Item item;
}

/// Keeps what was typed as a custom line instead of picking from the catalogue.
class _FreeTextSuggestion extends _Suggestion {
  const _FreeTextSuggestion(this.text);
  final String text;
}

enum _StatusKind { noItems, failed }

class _StatusSuggestion extends _Suggestion {
  const _StatusSuggestion(this.kind);
  final _StatusKind kind;
}

/// The description field of an invoice line, with the item catalogue searched
/// as the user types: a match fills the line, and free text stays a custom
/// line. Mirrors the web editor's item picker, so both apps behave alike.
class ItemSearchField extends StatefulWidget {
  const ItemSearchField({
    super.key,
    required this.controller,
    required this.searchItems,
    required this.onItemSelected,
    required this.onTextChanged,
    this.fieldKey,
    this.errorText,
  });

  final TextEditingController controller;
  final Future<List<Item>> Function(String query) searchItems;
  final ValueChanged<Item> onItemSelected;
  final ValueChanged<String> onTextChanged;
  final Key? fieldKey;
  final String? errorText;

  @override
  State<ItemSearchField> createState() => _ItemSearchFieldState();
}

class _ItemSearchFieldState extends State<ItemSearchField> {
  static const _debounce = Duration(milliseconds: 300);
  static const _maxResults = 8;

  final _focusNode = FocusNode();
  int _generation = 0;
  bool _loading = false;
  // Choosing an item rewrites the field, which would otherwise trigger a
  // pointless search for the name that was just picked.
  String? _selectedText;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<Iterable<_Suggestion>> _suggestions(TextEditingValue value) async {
    final query = value.text.trim();
    final generation = ++_generation;
    // Only the latest keystroke gets to search: a fast typist would otherwise
    // fire one request per letter and see results arrive out of order.
    await Future<void>.delayed(_debounce);
    if (generation != _generation) return const [];
    // Checked after the delay because the selection callback runs just after
    // the text is rewritten, so it is only known by now.
    if (query == _selectedText) return const [];
    _selectedText = null;

    if (mounted) setState(() => _loading = true);
    try {
      final items = await widget.searchItems(query);
      if (generation != _generation) return const [];
      final matches = items.take(_maxResults).map(_ItemSuggestion.new).toList();
      return [
        ...matches,
        if (query.isNotEmpty) _FreeTextSuggestion(query),
        if (matches.isEmpty && query.isEmpty) const _StatusSuggestion(_StatusKind.noItems),
      ];
    } catch (_) {
      if (generation != _generation) return const [];
      // The typed text stays usable as a custom line, and the next keystroke
      // searches again, so a failed lookup never blocks the invoice.
      final query = value.text.trim();
      return [
        const _StatusSuggestion(_StatusKind.failed),
        if (query.isNotEmpty) _FreeTextSuggestion(query),
      ];
    } finally {
      if (mounted && generation == _generation) setState(() => _loading = false);
    }
  }

  void _select(_Suggestion suggestion) {
    switch (suggestion) {
      case _ItemSuggestion(:final item):
        _selectedText = item.description;
        widget.onItemSelected(item);
      case _FreeTextSuggestion() || _StatusSuggestion():
        _focusNode.unfocus();
    }
  }

  String _display(_Suggestion suggestion) => switch (suggestion) {
        _ItemSuggestion(:final item) => item.description,
        _ => widget.controller.text,
      };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => RawAutocomplete<_Suggestion>(
        textEditingController: widget.controller,
        focusNode: _focusNode,
        optionsBuilder: _suggestions,
        displayStringForOption: _display,
        onSelected: _select,
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) => TextFormField(
          key: widget.fieldKey,
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Item or description',
            hintText: 'Search items or type a description',
            errorText: widget.errorText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : null,
          ),
          onChanged: widget.onTextChanged,
        ),
        optionsViewBuilder: (context, onSelected, options) => _SuggestionList(
          width: constraints.maxWidth,
          options: options.toList(),
          onSelected: onSelected,
        ),
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.width, required this.options, required this.onSelected});

  final double width;
  final List<_Suggestion> options;
  final ValueChanged<_Suggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        color: colors.surface,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(AppRadii.large),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width, maxHeight: 280),
          child: SizedBox(
            width: width,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return switch (option) {
                  _ItemSuggestion(:final item) => ListTile(
                      key: Key('item-option-${item.id}'),
                      title: Text(item.description),
                      subtitle: Text(item.unit),
                      trailing: MoneyText(item.unitPrice, style: textTheme.bodyMedium),
                      onTap: () => onSelected(option),
                    ),
                  _FreeTextSuggestion(:final text) => ListTile(
                      key: const Key('item-option-free-text'),
                      leading: const Icon(Icons.edit_outlined),
                      title: Text('Use "$text" as the description'),
                      onTap: () => onSelected(option),
                    ),
                  _StatusSuggestion(kind: _StatusKind.failed) => ListTile(
                      key: const Key('item-option-failed'),
                      leading: Icon(Icons.wifi_off, color: colors.error),
                      title: const Text("Couldn't load your items"),
                      subtitle: const Text('Keep typing to try again'),
                      onTap: () => onSelected(option),
                    ),
                  _StatusSuggestion() => ListTile(
                      key: const Key('item-option-empty'),
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: const Text('No items yet'),
                      subtitle: const Text('Type a description to add a custom line'),
                      onTap: () => onSelected(option),
                    ),
                };
              },
            ),
          ),
        ),
      ),
    );
  }
}
