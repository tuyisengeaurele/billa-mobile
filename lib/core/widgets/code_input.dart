import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';

/// One box per digit over a single invisible text field. The field keeps the
/// platform behaviour that matters for codes (numeric keyboard, one-time-code
/// autofill, backspace) while the boxes carry the look.
class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    required this.controller,
    this.fieldKey,
    this.length = 6,
    this.hasError = false,
    this.autofocus = false,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final Key? fieldKey;
  final int length;
  final bool hasError;
  final bool autofocus;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> with SingleTickerProviderStateMixin {
  final _focus = FocusNode();
  late final _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    _focus.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant CodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
    if (!oldWidget.hasError && widget.hasError) {
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _focus.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final text = widget.controller.text;
    final activeIndex = math.min(text.length, widget.length - 1);

    return Semantics(
      label: 'Verification code, ${text.length} of ${widget.length} digits entered',
      child: AnimatedBuilder(
        animation: _shake,
        builder: (context, child) {
          final t = _shake.value;
          return Transform.translate(offset: Offset(math.sin(t * math.pi * 4) * (1 - t) * 10, 0), child: child);
        },
        child: SizedBox(
          height: 60,
          child: Stack(
            children: [
              IgnorePointer(
                child: Row(
                  children: [
                    for (var i = 0; i < widget.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _Box(
                          digit: i < text.length ? text[i] : '',
                          focused: _focus.hasFocus && i == activeIndex,
                          hasError: widget.hasError,
                          colors: colors,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned.fill(
                child: TextField(
                  key: widget.fieldKey,
                  controller: widget.controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(widget.length)],
                  showCursor: false,
                  enableInteractiveSelection: false,
                  style: const TextStyle(color: Colors.transparent),
                  cursorColor: Colors.transparent,
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                  ),
                  onChanged: widget.onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.digit, required this.focused, required this.hasError, required this.colors});

  final String digit;
  final bool focused;
  final bool hasError;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError ? colors.error : (focused ? colors.accent : Colors.transparent);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: hasError ? colors.errorBg : colors.neutral100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(digit, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}
