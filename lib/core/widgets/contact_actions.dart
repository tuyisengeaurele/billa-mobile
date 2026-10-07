import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../formatting/phone_number.dart';
import '../platform/link_launcher.dart';
import 'app_sheet.dart';

/// Reach a customer from the phone's own apps. The message is shown first so
/// nobody sends words they have not seen.
Future<void> showContactActions(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String? phone,
  required String message,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final launcher = ref.read(linkLauncherProvider);

  final action = await showAppSheet<Future<bool> Function()>(
    context,
    builder: (context) => _ContactSheet(
      title: title,
      phone: phone,
      message: message,
      call: () => launcher.call(phone!),
      sms: () => launcher.sms(phone!, body: message),
      whatsapp: () => launcher.whatsapp(phone!, message),
    ),
  );
  if (action == null) return;

  if (!await action()) {
    messenger?.showSnackBar(const SnackBar(content: Text("Couldn't open that app. Is it installed?")));
  }
}

class _ContactSheet extends StatelessWidget {
  const _ContactSheet({
    required this.title,
    required this.phone,
    required this.message,
    required this.call,
    required this.sms,
    required this.whatsapp,
  });

  final String title;
  final String? phone;
  final String message;
  final Future<bool> Function() call;
  final Future<bool> Function() sms;
  final Future<bool> Function() whatsapp;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final number = phone;
    final String? problem = number == null || number.trim().isEmpty
        ? 'No phone number saved'
        : normaliseRwandaNumber(number) == null
            ? "That number can't be dialled"
            : null;

    Widget option(Key key, IconData icon, String label, Future<bool> Function() action) {
      return ListTile(
        key: key,
        contentPadding: EdgeInsets.zero,
        enabled: problem == null,
        leading: Icon(icon),
        title: Text(label),
        subtitle: problem == null ? (number == null ? null : Text(number)) : Text(problem),
        onTap: problem == null ? () => Navigator.of(context).pop(action) : null,
      );
    }

    return AppSheetContent(
      title: title,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: colors.neutral100, borderRadius: BorderRadius.circular(12)),
          child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(height: 8),
        option(const Key('contact-whatsapp'), Icons.chat_outlined, 'WhatsApp', whatsapp),
        option(const Key('contact-sms'), Icons.sms_outlined, 'SMS', sms),
        option(const Key('contact-call'), Icons.call_outlined, 'Call', call),
      ],
    );
  }
}
