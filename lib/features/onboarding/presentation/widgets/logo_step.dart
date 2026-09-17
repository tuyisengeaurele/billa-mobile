import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/logo_pipeline_service.dart';
import '../../domain/logo_pipeline_step.dart';

class LogoStep extends StatefulWidget {
  const LogoStep({super.key, required this.service, required this.onDone, required this.onSkip});

  final LogoPipelineService service;
  final Future<void> Function() onDone;
  final VoidCallback onSkip;

  @override
  State<LogoStep> createState() => _LogoStepState();
}

class _LogoStepState extends State<LogoStep> {
  LogoPipelineStage? _stage;
  bool _isConfirming = false;

  Future<void> _pickAndRun() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await File(picked.path).readAsBytes();
    setState(() => _stage = null);
    widget.service.run(bytes, picked.name).listen((stage) {
      setState(() => _stage = stage);
    });
  }

  Future<void> _confirm() async {
    setState(() => _isConfirming = true);
    await widget.service.confirm();
    await widget.onDone();
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
        const SizedBox(height: 16),
        TextButton(key: const Key('onboarding-logo-skip'), onPressed: widget.onSkip, child: const Text('Skip this step')),
      ],
    );
  }
}
