import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings.dart';
import 'package:billa_mobile/features/business_settings/domain/document_sequence.dart';
import 'package:billa_mobile/features/business_settings/domain/document_template.dart';
import 'package:billa_mobile/features/business_settings/domain/subscription_status.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';

void main() {
  test('BusinessSettings.fromJson applies defaults for a minimal payload', () {
    final settings = BusinessSettings.fromJson({'id': 'b1', 'name': 'Acme'});

    expect(settings.remindersEnabled, isTrue);
    expect(settings.reminderCadenceDays, 7);
    expect(settings.requireApprovalToFinalize, isFalse);
    expect(settings.defaultTemplate, DocumentTemplate.minimal);
    expect(settings.accentColors, isEmpty);
    expect(settings.bankName, isNull);
  });

  test('BusinessSettings.fromJson maps a full payload', () {
    final settings = BusinessSettings.fromJson({
      'id': 'b1',
      'name': 'Acme',
      'tin': '123',
      'bankName': 'BK',
      'signatoryName': 'Ada',
      'signatureUrl': '/uploads/sig.png',
      'primaryColor': '#112233',
      'accentColors': ['#445566'],
      'remindersEnabled': false,
      'reminderCadenceDays': 14,
      'requireApprovalToFinalize': true,
      'defaultTemplate': 'PREMIUM',
    });

    expect(settings.defaultTemplate, DocumentTemplate.premium);
    expect(settings.requireApprovalToFinalize, isTrue);
    expect(settings.reminderCadenceDays, 14);
    expect(settings.accentColors, ['#445566']);
  });

  test('an unknown template is rejected', () {
    expect(() => documentTemplateFromJson('FANCY'), throwsArgumentError);
  });

  test('template wire names are uppercase and round-trip', () {
    for (final template in DocumentTemplate.values) {
      expect(documentTemplateFromJson(documentTemplateToJson(template)), template);
    }
    expect(documentTemplateToJson(DocumentTemplate.classic), 'CLASSIC');
  });

  test('DocumentSequence round-trips a multi-word type', () {
    final sequence = DocumentSequence.fromJson({
      'type': 'DELIVERY_NOTE',
      'prefix': 'DN-',
      'nextNumber': 5,
      'resetYearly': true,
    });

    expect(sequence.type, DocumentType.deliveryNote);
    expect(sequence.toJson()['type'], 'DELIVERY_NOTE');
  });

  test('SubscriptionStatus is paid only when a period end exists', () {
    final trial = SubscriptionStatus.fromJson({
      'plan': null,
      'trialEndsAt': '2026-03-01T00:00:00.000Z',
      'currentPeriodEnd': null,
      'activeUntil': '2026-03-01T00:00:00.000Z',
    });
    final paid = SubscriptionStatus.fromJson({
      'plan': 'MONTHLY',
      'trialEndsAt': null,
      'currentPeriodEnd': '2026-04-01T00:00:00.000Z',
      'activeUntil': '2026-04-01T00:00:00.000Z',
    });

    expect(trial.isPaid, isFalse);
    expect(paid.isPaid, isTrue);
  });
}
