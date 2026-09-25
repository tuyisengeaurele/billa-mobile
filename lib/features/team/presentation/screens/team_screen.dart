import '../../../../core/widgets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/pending_invite.dart';
import '../../domain/team_member.dart';
import '../../domain/team_role.dart';
import '../providers/team_repository_provider.dart';

String teamRoleLabel(TeamRole role) => switch (role) {
      TeamRole.owner => 'Owner',
      TeamRole.member => 'Member',
      TeamRole.accountant => 'Accountant',
    };

const _assignableRoles = [TeamRole.member, TeamRole.accountant];

class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  late Future<List<TeamMember>> _membersFuture;
  late Future<List<PendingInvite>> _invitesFuture;
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  @override
  void initState() {
    super.initState();
    _membersFuture = ref.read(teamRepositoryProvider).members();
    _invitesFuture = ref.read(teamRepositoryProvider).invites();
  }

  // Members and invites load independently so one failing doesn't blank the
  // other; every mutation can change both (a role edit, an accepted invite),
  // so mutations reload both.
  void _reloadAll() {
    setState(() {
      _membersFuture = ref.read(teamRepositoryProvider).members();
      _invitesFuture = ref.read(teamRepositoryProvider).invites();
    });
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

  Future<void> _changeRole(TeamMember member, TeamRole role) => _runAction(() async {
        await ref.read(teamRepositoryProvider).updateRole(member.id, role);
        _reloadAll();
      });

  Future<void> _remove(TeamMember member) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove ${member.email}?',
      content: 'They lose access to this business immediately.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed) return;
    await _runAction(() async {
      await ref.read(teamRepositoryProvider).removeMember(member.id);
      _reloadAll();
    });
  }

  Future<(String, TeamRole)?> _promptInvite() {
    return showAppSheet<(String, TeamRole)>(context, builder: (context) => const _InviteSheet());
  }

  Future<void> _invite() async {
    final result = await _promptInvite();
    if (result == null) return;
    final (email, role) = result;
    await _runAction(() async {
      await ref.read(teamRepositoryProvider).invite(email, role);
      _reloadAll();
    });
  }

  Future<void> _resend(PendingInvite invite) => _runAction(() async {
        await ref.read(teamRepositoryProvider).resendInvite(invite.id);
        _reloadAll();
      });

  Future<void> _revoke(PendingInvite invite) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Revoke the invite to ${invite.email}?',
      confirmLabel: 'Revoke',
      destructive: true,
    );
    if (!confirmed) return;
    await _runAction(() async {
      await ref.read(teamRepositoryProvider).revokeInvite(invite.id);
      _reloadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Members', style: Theme.of(context).textTheme.titleMedium),
          FutureBuilder<List<TeamMember>>(
            future: _membersFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorState(message: "Couldn't load the team", onRetry: _reloadAll);
              }
              if (!snapshot.hasData) {
                return const Padding(padding: EdgeInsets.all(8), child: LoadingSkeleton(height: 56));
              }
              return Column(
                children: [
                  for (final member in snapshot.data!)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(member.email),
                      subtitle: member.role == TeamRole.owner ? const Text('Owner') : null,
                      trailing: member.role == TeamRole.owner
                          ? null
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<TeamRole>(
                                  value: member.role,
                                  items: [
                                    for (final r in _assignableRoles)
                                      DropdownMenuItem(value: r, child: Text(teamRoleLabel(r))),
                                  ],
                                  onChanged: _actionInProgress
                                      ? null
                                      : (role) {
                                          if (role != null && role != member.role) _changeRole(member, role);
                                        },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.person_remove),
                                  tooltip: 'Remove',
                                  onPressed: _actionInProgress ? null : () => _remove(member),
                                ),
                              ],
                            ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Pending invites', style: Theme.of(context).textTheme.titleMedium),
          FutureBuilder<List<PendingInvite>>(
            future: _invitesFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorState(message: "Couldn't load invites", onRetry: _reloadAll);
              }
              if (!snapshot.hasData) {
                return const Padding(padding: EdgeInsets.all(8), child: LoadingSkeleton(height: 56));
              }
              if (snapshot.data!.isEmpty) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('No pending invites'));
              }
              return Column(
                children: [
                  for (final invite in snapshot.data!)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(invite.email),
                      subtitle: Text('${teamRoleLabel(invite.role)} · expires ${invite.expiresAt.split('T').first}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: _actionInProgress ? null : () => _resend(invite),
                            child: const Text('Resend'),
                          ),
                          TextButton(
                            onPressed: _actionInProgress ? null : () => _revoke(invite),
                            child: const Text('Revoke'),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          if (_actionError != null) ...[
            const SizedBox(height: 16),
            ActionErrorBanner(
              message: _actionError!,
              onRetry: _lastAction == null ? null : () => _runAction(_lastAction!),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('team-invite-button'),
            onPressed: _actionInProgress ? null : _invite,
            child: const Text('Invite someone'),
          ),
        ],
      ),
    );
  }
}

class _InviteSheet extends StatefulWidget {
  const _InviteSheet();

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final _email = TextEditingController();
  var _role = TeamRole.member;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = _email.text.trim();
    return AppSheetContent(
      title: 'Invite someone',
      message: 'They get an email with a link to join this business.',
      actions: SheetActions(
        confirmLabel: 'Send invite',
        onCancel: () => Navigator.pop(context),
        onConfirm: email.contains('@') ? () => Navigator.pop(context, (email, _role)) : null,
      ),
      children: [
        TextField(
          key: const Key('invite-email'),
          controller: _email,
          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        SegmentedButton<TeamRole>(
          segments: [for (final role in _assignableRoles) ButtonSegment(value: role, label: Text(teamRoleLabel(role)))],
          selected: {_role},
          onSelectionChanged: (selection) => setState(() => _role = selection.first),
        ),
      ],
    );
  }
}
