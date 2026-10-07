// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SubscriptionStatus _$SubscriptionStatusFromJson(Map<String, dynamic> json) {
  return _SubscriptionStatus.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionStatus {
  String? get plan => throw _privateConstructorUsedError;
  String? get trialEndsAt => throw _privateConstructorUsedError;
  String? get currentPeriodEnd => throw _privateConstructorUsedError;
  String? get activeUntil => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SubscriptionStatusCopyWith<SubscriptionStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionStatusCopyWith<$Res> {
  factory $SubscriptionStatusCopyWith(
          SubscriptionStatus value, $Res Function(SubscriptionStatus) then) =
      _$SubscriptionStatusCopyWithImpl<$Res, SubscriptionStatus>;
  @useResult
  $Res call(
      {String? plan,
      String? trialEndsAt,
      String? currentPeriodEnd,
      String? activeUntil});
}

/// @nodoc
class _$SubscriptionStatusCopyWithImpl<$Res, $Val extends SubscriptionStatus>
    implements $SubscriptionStatusCopyWith<$Res> {
  _$SubscriptionStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plan = freezed,
    Object? trialEndsAt = freezed,
    Object? currentPeriodEnd = freezed,
    Object? activeUntil = freezed,
  }) {
    return _then(_value.copyWith(
      plan: freezed == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as String?,
      trialEndsAt: freezed == trialEndsAt
          ? _value.trialEndsAt
          : trialEndsAt // ignore: cast_nullable_to_non_nullable
              as String?,
      currentPeriodEnd: freezed == currentPeriodEnd
          ? _value.currentPeriodEnd
          : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
              as String?,
      activeUntil: freezed == activeUntil
          ? _value.activeUntil
          : activeUntil // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionStatusImplCopyWith<$Res>
    implements $SubscriptionStatusCopyWith<$Res> {
  factory _$$SubscriptionStatusImplCopyWith(_$SubscriptionStatusImpl value,
          $Res Function(_$SubscriptionStatusImpl) then) =
      __$$SubscriptionStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? plan,
      String? trialEndsAt,
      String? currentPeriodEnd,
      String? activeUntil});
}

/// @nodoc
class __$$SubscriptionStatusImplCopyWithImpl<$Res>
    extends _$SubscriptionStatusCopyWithImpl<$Res, _$SubscriptionStatusImpl>
    implements _$$SubscriptionStatusImplCopyWith<$Res> {
  __$$SubscriptionStatusImplCopyWithImpl(_$SubscriptionStatusImpl _value,
      $Res Function(_$SubscriptionStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plan = freezed,
    Object? trialEndsAt = freezed,
    Object? currentPeriodEnd = freezed,
    Object? activeUntil = freezed,
  }) {
    return _then(_$SubscriptionStatusImpl(
      plan: freezed == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as String?,
      trialEndsAt: freezed == trialEndsAt
          ? _value.trialEndsAt
          : trialEndsAt // ignore: cast_nullable_to_non_nullable
              as String?,
      currentPeriodEnd: freezed == currentPeriodEnd
          ? _value.currentPeriodEnd
          : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
              as String?,
      activeUntil: freezed == activeUntil
          ? _value.activeUntil
          : activeUntil // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionStatusImpl extends _SubscriptionStatus {
  const _$SubscriptionStatusImpl(
      {this.plan, this.trialEndsAt, this.currentPeriodEnd, this.activeUntil})
      : super._();

  factory _$SubscriptionStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionStatusImplFromJson(json);

  @override
  final String? plan;
  @override
  final String? trialEndsAt;
  @override
  final String? currentPeriodEnd;
  @override
  final String? activeUntil;

  @override
  String toString() {
    return 'SubscriptionStatus(plan: $plan, trialEndsAt: $trialEndsAt, currentPeriodEnd: $currentPeriodEnd, activeUntil: $activeUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionStatusImpl &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.trialEndsAt, trialEndsAt) ||
                other.trialEndsAt == trialEndsAt) &&
            (identical(other.currentPeriodEnd, currentPeriodEnd) ||
                other.currentPeriodEnd == currentPeriodEnd) &&
            (identical(other.activeUntil, activeUntil) ||
                other.activeUntil == activeUntil));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, plan, trialEndsAt, currentPeriodEnd, activeUntil);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionStatusImplCopyWith<_$SubscriptionStatusImpl> get copyWith =>
      __$$SubscriptionStatusImplCopyWithImpl<_$SubscriptionStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionStatusImplToJson(
      this,
    );
  }
}

abstract class _SubscriptionStatus extends SubscriptionStatus {
  const factory _SubscriptionStatus(
      {final String? plan,
      final String? trialEndsAt,
      final String? currentPeriodEnd,
      final String? activeUntil}) = _$SubscriptionStatusImpl;
  const _SubscriptionStatus._() : super._();

  factory _SubscriptionStatus.fromJson(Map<String, dynamic> json) =
      _$SubscriptionStatusImpl.fromJson;

  @override
  String? get plan;
  @override
  String? get trialEndsAt;
  @override
  String? get currentPeriodEnd;
  @override
  String? get activeUntil;
  @override
  @JsonKey(ignore: true)
  _$$SubscriptionStatusImplCopyWith<_$SubscriptionStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
