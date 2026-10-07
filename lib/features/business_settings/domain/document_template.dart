enum DocumentTemplate { minimal, premium, classic }

DocumentTemplate documentTemplateFromJson(String value) => switch (value) {
      'MINIMAL' => DocumentTemplate.minimal,
      'PREMIUM' => DocumentTemplate.premium,
      'CLASSIC' => DocumentTemplate.classic,
      _ => throw ArgumentError('Unknown document template: $value'),
    };

String documentTemplateToJson(DocumentTemplate value) => switch (value) {
      DocumentTemplate.minimal => 'MINIMAL',
      DocumentTemplate.premium => 'PREMIUM',
      DocumentTemplate.classic => 'CLASSIC',
    };

String documentTemplateLabel(DocumentTemplate value) => switch (value) {
      DocumentTemplate.minimal => 'Minimal',
      DocumentTemplate.premium => 'Premium',
      DocumentTemplate.classic => 'Classic',
    };
