import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../auth/domain/auth_user.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../../core/media/image_picker_provider.dart';
import '../providers/current_user_provider.dart';
import '../providers/profile_repository_provider.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      // The form seeds its text fields once, so it is only built after the
      // signed-in user is known rather than starting empty and never filling.
      body: user == null ? const SizedBox.shrink() : _ProfileForm(initial: user),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.initial});

  final AuthUser initial;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial.name ?? '');
    _phone = TextEditingController(text: widget.initial.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
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
    final phone = _phone.text.trim();
    final profile = await ref
        .read(profileRepositoryProvider)
        .updateProfile(name: _name.text.trim(), phone: phone.isEmpty ? null : phone);
    ref
        .read(authControllerProvider.notifier)
        .updateUser((user) => user.copyWith(name: profile.name, phone: profile.phone));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
    }
  });

  Future<void> _changeAvatar() async {
    final picked = await ref.read(imagePickerProvider)();
    if (picked == null) return;
    await _runAction(() async {
      final url = await ref.read(profileRepositoryProvider).uploadAvatar(picked.bytes, picked.name);
      ref.read(authControllerProvider.notifier).updateUser((user) => user.copyWith(avatarUrl: url));
    });
  }

  Future<void> _removeAvatar() => _runAction(() async {
    await ref.read(profileRepositoryProvider).removeAvatar();
    ref.read(authControllerProvider.notifier).updateUser((user) => user.copyWith(avatarUrl: null));
  });

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (user != null) Center(child: UserAvatar(user: user, radius: 40)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              key: const Key('profile-avatar-change'),
              onPressed: _actionInProgress ? null : _changeAvatar,
              child: const Text('Change photo'),
            ),
            if (user?.avatarUrl != null)
              TextButton(
                key: const Key('profile-avatar-remove'),
                onPressed: _actionInProgress ? null : _removeAvatar,
                child: const Text('Remove'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('profile-name'),
          controller: _name,
          decoration: const InputDecoration(labelText: 'Name'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('profile-phone'),
          controller: _phone,
          decoration: const InputDecoration(labelText: 'Phone (optional)'),
          keyboardType: TextInputType.phone,
        ),
        if (_actionError != null) ...[
          const SizedBox(height: 16),
          ActionErrorBanner(
            message: _actionError!,
            onRetry: _lastAction == null || _actionInProgress ? null : () => _runAction(_lastAction!),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('profile-save'),
          onPressed: (_actionInProgress || _name.text.trim().isEmpty) ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
