import 'package:flutter/material.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../domain/document_enums.dart';

/// Asks which language the document's own labels should be written in before
/// it leaves the app. The choice is per action, so the sheet opens on the
/// document's current language and dismissing it cancels the share or send.
Future<DocumentLanguage?> showLanguagePicker(BuildContext context, {required DocumentLanguage initial}) {
  return showAppSheet<DocumentLanguage>(
    context,
    builder: (context) => AppSheetContent(
      title: 'Document language',
      children: [
        for (final language in DocumentLanguage.values)
          ListTile(
            key: Key('language-${language.name}'),
            contentPadding: EdgeInsets.zero,
            title: Text(documentLanguageLabel(language)),
            trailing: language == initial ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(language),
          ),
      ],
    ),
  );
}
