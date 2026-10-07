import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/media/image_picker_provider.dart';
import '../../../../core/network/asset_url.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../domain/business_settings.dart';
import '../providers/business_settings_provider.dart';
import '../providers/business_settings_repository_provider.dart';
import '../widgets/settings_section_scaffold.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionScaffold(
      title: 'Payments and signatory',
      builder: (settings) => _PaymentsForm(settings: settings),
    );
  }
}

class _PaymentsForm extends ConsumerStatefulWidget {
  const _PaymentsForm({required this.settings});

  final BusinessSettings settings;

  @override
  ConsumerState<_PaymentsForm> createState() => _PaymentsFormState();
}

class _PaymentsFormState extends ConsumerState<_PaymentsForm> {
  late final _bank = TextEditingController(text: widget.settings.bankName ?? '');
  late final _account = TextEditingController(text: widget.settings.bankAccountNumber ?? '');
  late final _signatoryName = TextEditingController(text: widget.settings.signatoryName ?? '');
  late final _signatoryTitle = TextEditingController(text: widget.settings.signatoryTitle ?? '');
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  @override
  void dispose() {
    for (final controller in [_bank, _account, _signatoryName, _signatoryTitle]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _runAction(Future<void> Function() action) async {
    _lastAction = action;
    setState(() {
      _actionInProgress = true;
      _actionError = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _actionError = describeActionError(e));
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _save() => _runAction(() async {
        await ref.read(businessSettingsRepositoryProvider).updatePayments(
              bankName: nullIfBlank(_bank.text),
              bankAccountNumber: nullIfBlank(_account.text),
              signatoryName: nullIfBlank(_signatoryName.text),
              signatoryTitle: nullIfBlank(_signatoryTitle.text),
            );
        ref.invalidate(businessSettingsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment details saved')));
        }
      });

  Future<void> _changeSignature() async {
    final picked = await ref.read(imagePickerProvider)();
    if (picked == null) return;
    await _runAction(() async {
      final repository = ref.read(businessSettingsRepositoryProvider);
      final url = await repository.uploadSignature(picked.bytes, picked.name);
      await repository.setSignature(url);
      ref.invalidate(businessSettingsProvider);
    });
  }

  Future<void> _removeSignature() => _runAction(() async {
        await ref.read(businessSettingsRepositoryProvider).setSignature(null);
        ref.invalidate(businessSettingsProvider);
      });

  Widget _field(String key, TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        key: Key(key),
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signatureUrl = widget.settings.signatureUrl;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _field('pay-bank', _bank, 'Bank name (optional)'),
        _field('pay-account', _account, 'Account number (optional)', keyboardType: TextInputType.number),
        _field('pay-signatory-name', _signatoryName, 'Signatory name (optional)'),
        _field('pay-signatory-title', _signatoryTitle, 'Signatory title (optional)'),
        Text('Signature', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (signatureUrl != null)
          Image.network(
            resolveAssetUrl(signatureUrl),
            height: 64,
            alignment: Alignment.centerLeft,
            errorBuilder: (context, error, stackTrace) => const Text('Signature added'),
          )
        else
          const Text('No signature added'),
        Row(
          children: [
            TextButton(
              key: const Key('pay-signature-change'),
              onPressed: _actionInProgress ? null : _changeSignature,
              child: Text(signatureUrl == null ? 'Add signature' : 'Change signature'),
            ),
            if (signatureUrl != null)
              TextButton(
                key: const Key('pay-signature-remove'),
                onPressed: _actionInProgress ? null : _removeSignature,
                child: const Text('Remove'),
              ),
          ],
        ),
        if (_actionError != null) ...[
          const SizedBox(height: 8),
          ActionErrorBanner(
            message: _actionError!,
            onRetry: _lastAction == null || _actionInProgress ? null : () => _runAction(_lastAction!),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('pay-save'),
          onPressed: _actionInProgress ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
