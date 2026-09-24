import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/item_repository_impl.dart';
import '../../domain/item_repository.dart';
import '../../../../core/network/api_client_provider.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepositoryImpl(ref.watch(apiClientProvider).dio);
});
