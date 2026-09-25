import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/media/image_picker_provider.dart';
import '../../../../core/network/asset_url.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../onboarding/domain/logo_pipeline_step.dart';
import '../../../onboarding/presentation/providers/logo_pipeline_provider.dart';
import '../../domain/business_settings.dart';
import '../providers/business_settings_provider.dart';
import '../widgets/settings_section_scaffold.dart';

class LogoScreen extends StatelessWidget {
  const LogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionScaffold(
      title: 'Logo and brand',
      builder: (settings) => _LogoBody(settings: settings),
    );
  }
}

Color _color(String hex) {
  final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  return value == null ? Colors.grey : Color(0xFF000000 | value);
}

String _stageLabel(LogoPipelineStage stage) => switch (stage) {
      LogoPipelineStage.uploading => 'Uploading logo…',
      LogoPipelineStage.checkingBackground => 'Checking background…',
      LogoPipelineStage.extractingColors => 'Extracting brand colors…',
      LogoPipelineStage.done => 'Done',
    };

class _LogoBody extends ConsumerStatefulWidget {
  const _LogoBody({required this.settings});

  final BusinessSettings settings;

  @override
  ConsumerState<_LogoBody> createState() => _LogoBodyState();
}

class _LogoBodyState extends ConsumerState<_LogoBody> {
  LogoPipelineStage? _stage;
  LogoPipelineResult? _result;
  bool _busy = false;
  String? _error;
  Future<void> Function()? _lastAction;

  // One wrapper for both the pipeline and the confirm step so each failure
  // becomes a message with Retry rather than a spinner that never stops.
  Future<void> _runAction(Future<void> Function() action) async {
    _lastAction = action;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = describeActionError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _choose() async {
    final picked = await ref.read(imagePickerProvider)();
    if (picked == null) return;
    await _runAction(() => _runPipeline(picked));
  }

  Future<void> _runPipeline(PickedImage picked) async {
    setState(() {
      _stage = null;
      _result = null;
    });
    final service = ref.read(logoPipelineServiceProvider);
    await for (final stage in service.run(picked.bytes, picked.name)) {
      if (!mounted) return;
      setState(() => _stage = stage);
    }
    if (mounted) setState(() => _result = service.result);
  }

  Future<void> _confirm() => _runAction(() async {
        await ref.read(logoPipelineServiceProvider).confirm();
        ref.invalidate(businessSettingsProvider);
        if (mounted) {
          setState(() {
            _stage = null;
            _result = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo saved')));
        }
      });

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final logoUrl = settings.logoUrl;
    final result = _result;
    final running = _busy && _stage != null && _stage != LogoPipelineStage.done;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Current logo', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (logoUrl != null)
          Image.network(
            resolveAssetUrl(logoUrl),
            height: 96,
            alignment: Alignment.centerLeft,
            errorBuilder: (context, error, stackTrace) => const Text('Logo added'),
          )
        else
          const Text('No logo yet'),
        const SizedBox(height: 16),
        if (settings.primaryColor != null)
          Row(
            children: [
              Container(width: 28, height: 28, color: _color(settings.primaryColor!)),
              const SizedBox(width: 8),
              Text('Primary color ${settings.primaryColor}'),
              const SizedBox(width: 12),
              for (final accent in settings.accentColors)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(width: 20, height: 20, color: _color(accent)),
                ),
            ],
          ),
        const Divider(height: 32),
        if (running)
          Row(
            children: [
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 12),
              Text(_stageLabel(_stage!)),
            ],
          ),
        if (result != null) ...[
          Row(
            children: [
              Container(width: 28, height: 28, color: _color(result.primaryColor)),
              const SizedBox(width: 8),
              Text('New primary color ${result.primaryColor}'),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('logo-confirm'),
            onPressed: _busy ? null : _confirm,
            child: const Text('Use this logo'),
          ),
          const SizedBox(height: 8),
        ],
        if (_error != null) ...[
          ActionErrorBanner(
            message: _error!,
            onRetry: _lastAction == null || _busy ? null : () => _runAction(_lastAction!),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton(
          key: const Key('logo-choose'),
          onPressed: _busy ? null : _choose,
          child: Text(logoUrl == null && result == null ? 'Choose a logo' : 'Choose a different logo'),
        ),
      ],
    );
  }
}
