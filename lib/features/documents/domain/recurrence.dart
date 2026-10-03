/// The ways an invoice can repeat, as the server names them and as the phone words them.
const recurrenceOptions = <({String interval, String label})>[
  (interval: 'WEEKLY', label: 'Every week'),
  (interval: 'MONTHLY', label: 'Every month'),
  (interval: 'QUARTERLY', label: 'Every quarter'),
  (interval: 'ANNUALLY', label: 'Every year'),
];

/// "every month", for use inside a sentence.
String recurrenceWords(String interval) {
  for (final option in recurrenceOptions) {
    if (option.interval == interval) return option.label.toLowerCase();
  }
  return 'on a schedule';
}
