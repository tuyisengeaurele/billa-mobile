import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_status.freezed.dart';
part 'subscription_status.g.dart';

@freezed
class SubscriptionStatus with _$SubscriptionStatus {
  const SubscriptionStatus._();

  const factory SubscriptionStatus({
    String? plan,
    String? trialEndsAt,
    String? currentPeriodEnd,
    String? activeUntil,
  }) = _SubscriptionStatus;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) => _$SubscriptionStatusFromJson(json);

  /// A paid period exists; otherwise the account is on its free trial.
  bool get isPaid => currentPeriodEnd != null;
}
