enum LogoPipelineStage { uploading, checkingBackground, extractingColors, done }

class LogoPipelineResult {
  const LogoPipelineResult({required this.url, required this.primaryColor, required this.accentColors});

  final String url;
  final String primaryColor;
  final List<String> accentColors;
}
