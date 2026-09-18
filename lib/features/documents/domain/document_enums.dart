enum DocumentType { invoice, proforma, deliveryNote, quote, receipt, creditNote }

DocumentType documentTypeFromJson(String value) => switch (value) {
      'INVOICE' => DocumentType.invoice,
      'PROFORMA' => DocumentType.proforma,
      'DELIVERY_NOTE' => DocumentType.deliveryNote,
      'QUOTE' => DocumentType.quote,
      'RECEIPT' => DocumentType.receipt,
      'CREDIT_NOTE' => DocumentType.creditNote,
      _ => throw ArgumentError('Unknown document type: $value'),
    };

String documentTypeToJson(DocumentType value) => switch (value) {
      DocumentType.invoice => 'INVOICE',
      DocumentType.proforma => 'PROFORMA',
      DocumentType.deliveryNote => 'DELIVERY_NOTE',
      DocumentType.quote => 'QUOTE',
      DocumentType.receipt => 'RECEIPT',
      DocumentType.creditNote => 'CREDIT_NOTE',
    };

enum DocumentStatus { draft, finalized }

DocumentStatus documentStatusFromJson(String value) => switch (value) {
      'DRAFT' => DocumentStatus.draft,
      'FINALIZED' => DocumentStatus.finalized,
      _ => throw ArgumentError('Unknown document status: $value'),
    };

String documentStatusToJson(DocumentStatus value) => switch (value) {
      DocumentStatus.draft => 'DRAFT',
      DocumentStatus.finalized => 'FINALIZED',
    };

enum PaymentStatus { unpaid, partiallyPaid, paid, writtenOff }

PaymentStatus? paymentStatusFromJson(String? value) => switch (value) {
      null => null,
      'UNPAID' => PaymentStatus.unpaid,
      'PARTIALLY_PAID' => PaymentStatus.partiallyPaid,
      'PAID' => PaymentStatus.paid,
      'WRITTEN_OFF' => PaymentStatus.writtenOff,
      _ => throw ArgumentError('Unknown payment status: $value'),
    };

String? paymentStatusToJson(PaymentStatus? value) => switch (value) {
      null => null,
      PaymentStatus.unpaid => 'UNPAID',
      PaymentStatus.partiallyPaid => 'PARTIALLY_PAID',
      PaymentStatus.paid => 'PAID',
      PaymentStatus.writtenOff => 'WRITTEN_OFF',
    };

enum DiscountType { percent, flat }

DiscountType? discountTypeFromJson(String? value) => switch (value) {
      null => null,
      'PERCENT' => DiscountType.percent,
      'FLAT' => DiscountType.flat,
      _ => throw ArgumentError('Unknown discount type: $value'),
    };

String? discountTypeToJson(DiscountType? value) => switch (value) {
      null => null,
      DiscountType.percent => 'PERCENT',
      DiscountType.flat => 'FLAT',
    };

enum DocumentLanguage { en, fr }

DocumentLanguage documentLanguageFromJson(String value) => switch (value) {
      'EN' => DocumentLanguage.en,
      'FR' => DocumentLanguage.fr,
      _ => throw ArgumentError('Unknown document language: $value'),
    };

String documentLanguageToJson(DocumentLanguage value) => switch (value) {
      DocumentLanguage.en => 'EN',
      DocumentLanguage.fr => 'FR',
    };

enum PaymentMethod { cash, bankTransfer, mobileMoney, cheque, other }

PaymentMethod paymentMethodFromJson(String value) => switch (value) {
      'CASH' => PaymentMethod.cash,
      'BANK_TRANSFER' => PaymentMethod.bankTransfer,
      'MOBILE_MONEY' => PaymentMethod.mobileMoney,
      'CHEQUE' => PaymentMethod.cheque,
      'OTHER' => PaymentMethod.other,
      _ => throw ArgumentError('Unknown payment method: $value'),
    };

String paymentMethodToJson(PaymentMethod value) => switch (value) {
      PaymentMethod.cash => 'CASH',
      PaymentMethod.bankTransfer => 'BANK_TRANSFER',
      PaymentMethod.mobileMoney => 'MOBILE_MONEY',
      PaymentMethod.cheque => 'CHEQUE',
      PaymentMethod.other => 'OTHER',
    };
