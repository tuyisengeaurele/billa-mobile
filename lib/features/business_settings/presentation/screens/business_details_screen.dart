import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../domain/business_settings.dart';
import '../providers/business_settings_provider.dart';
import '../providers/business_settings_repository_provider.dart';
import '../widgets/settings_section_scaffold.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class BusinessDetailsScreen extends StatelessWidget {
  const BusinessDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionScaffold(
      title: 'Business details',
      builder: (settings) => _DetailsForm(initial: settings),
    );
  }
}

class _DetailsForm extends ConsumerStatefulWidget {
  const _DetailsForm({required this.initial});

  final BusinessSettings initial;

  @override
  ConsumerState<_DetailsForm> createState() => _DetailsFormState();
}

class _DetailsFormState extends ConsumerState<_DetailsForm> {
  late final _name = TextEditingController(text: widget.initial.name);
  late final _tin = TextEditingController(text: widget.initial.tin ?? '');
  late final _industry = TextEditingController(text: widget.initial.industry ?? '');
  late final _phone = TextEditingController(text: widget.initial.phone ?? '');
  late final _email = TextEditingController(text: widget.initial.email ?? '');
  late final _address = TextEditingController(text: widget.initial.address ?? '');
  late final _rra = TextEditingController(text: widget.initial.rraEbmNumber ?? '');
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  @override
  void dispose() {
    for (final controller in [_name, _tin, _industry, _phone, _email, _address, _rra]) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _emailValid => _email.text.trim().isEmpty || _emailPattern.hasMatch(_email.text.trim());

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
        final saved = await ref.read(businessSettingsRepositoryProvider).updateDetails(
              name: _name.text.trim(),
              tin: nullIfBlank(_tin.text),
              industry: nullIfBlank(_industry.text),
              phone: nullIfBlank(_phone.text),
              email: nullIfBlank(_email.text),
              address: nullIfBlank(_address.text),
              rraEbmNumber: nullIfBlank(_rra.text),
            );
        // The home header reads the name from the auth state, so a rename has
        // to be written back there as well as reloaded here.
        final current = ref.read(currentBusinessProvider);
        if (current != null && current.name != saved.name) {
          ref.read(authControllerProvider.notifier).setBusiness(current.copyWith(name: saved.name));
        }
        ref.invalidate(businessSettingsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Business details saved')));
        }
      });

  Widget _field(String key, TextEditingController controller, String label,
      {TextInputType? keyboardType, String? errorText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        key: Key(key),
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, errorText: errorText),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _field('bd-name', _name, 'Business name'),
        _field('bd-tin', _tin, 'TIN (optional)', keyboardType: TextInputType.number),
        _field('bd-industry', _industry, 'Industry (optional)'),
        _field('bd-phone', _phone, 'Phone (optional)', keyboardType: TextInputType.phone),
        _field('bd-email', _email, 'Email (optional)',
            keyboardType: TextInputType.emailAddress, errorText: _emailValid ? null : 'Enter a valid email address'),
        _field('bd-address', _address, 'Address (optional)'),
        _field('bd-rra', _rra, 'RRA EBM number (optional)'),
        if (_actionError != null) ...[
          ActionErrorBanner(
            message: _actionError!,
            onRetry: _lastAction == null || _actionInProgress ? null : () => _runAction(_lastAction!),
          ),
          const SizedBox(height: 16),
        ],
        FilledButton(
          key: const Key('bd-save'),
          onPressed: (_actionInProgress || _name.text.trim().isEmpty || !_emailValid) ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
