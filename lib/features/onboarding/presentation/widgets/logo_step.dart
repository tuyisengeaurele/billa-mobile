import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/media/image_picker_provider.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/logo_pipeline_service.dart';
import '../../domain/logo_pipeline_step.dart';

class LogoStep extends ConsumerStatefulWidget {
  const LogoStep({super.key, required this.service, required this.onDone, required this.onSkip});

  final LogoPipelineService service;
  final Future<void> Function() onDone;
  final VoidCallback onSkip;

  @override
  ConsumerState<LogoStep> createState() => _LogoStepState();
}

class _LogoStepState extends ConsumerState<LogoStep> {
  LogoPipelineStage? _stage;
  bool _isConfirming = false;
  String? _error;
  // Kept so Retry repeats the exact action that failed on the same image,
  // instead of sending the user back to the picker.
  Future<void> Function()? _lastAction;

  Future<void> _pickAndRun() async {
    final picked = await ref.read(imagePickerProvider)();
    if (picked == null) return;
    await _runAction(() => _runPipeline(picked));
  }

  Future<void> _runPipeline(PickedImage picked) async {
    setState(() => _stage = null);
    await for (final stage in widget.service.run(picked.bytes, picked.name)) {
      if (!mounted) return;
      setState(() => _stage = stage);
    }
  }

  Future<void> _confirm() => _runAction(() async {
        setState(() => _isConfirming = true);
        try {
          await widget.service.confirm();
          await widget.onDone();
        } finally {
          if (mounted) setState(() => _isConfirming = false);
        }
      });

  // Any failure clears the stage: a stalled progress row would offer no way
  // forward, while the banner carries the reason and a working Retry.
  Future<void> _runAction(Future<void> Function() action) async {
    _lastAction = action;
    setState(() => _error = null);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = describeActionError(e);
          if (_stage != LogoPipelineStage.done) _stage = null;
        });
      }
    }
  }

  String _stageLabel(LogoPipelineStage stage) => switch (stage) {
        LogoPipelineStage.uploading => 'Uploading logo…',
        LogoPipelineStage.checkingBackground => 'Checking background…',
        LogoPipelineStage.extractingColors => 'Extracting brand colors…',
        LogoPipelineStage.done => 'Done',
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final result = widget.service.result;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Add your logo', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (_stage == null)
          AppButton(label: 'Choose a photo', onPressed: _pickAndRun)
        else if (_stage != LogoPipelineStage.done)
          Row(
            children: [
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 12),
              Text(_stageLabel(_stage!)),
            ],
          )
        else if (result != null) ...[
          Row(
            children: [
              Container(width: 32, height: 32, color: Color(int.parse(result.primaryColor.substring(1), radix: 16) + 0xFF000000)),
              const SizedBox(width: 8),
              Text('Primary color ${result.primaryColor}', style: TextStyle(color: colors.neutral600)),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(label: 'Confirm', onPressed: _confirm, isLoading: _isConfirming),
        ],
        if (_error != null) ...[
          const SizedBox(height: 16),
          ActionErrorBanner(
            message: _error!,
            onRetry: _lastAction == null || _isConfirming ? null : () => _runAction(_lastAction!),
          ),
        ],
        const SizedBox(height: 16),
        TextButton(key: const Key('onboarding-logo-skip'), onPressed: widget.onSkip, child: const Text('Skip this step')),
      ],
    );
  }
}
