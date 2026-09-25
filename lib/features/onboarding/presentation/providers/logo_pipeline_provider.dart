import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../data/logo_pipeline_service.dart';

/// Auto-disposed because the service holds the last run's result: a fresh
/// screen must never confirm an upload from a previous visit.
final logoPipelineServiceProvider = Provider.autoDispose<LogoPipelineService>((ref) {
  return LogoPipelineService(ref.watch(apiClientProvider).dio);
});
