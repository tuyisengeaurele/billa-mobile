// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_payment_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CustomerPaymentStats _$CustomerPaymentStatsFromJson(Map<String, dynamic> json) {
  return _CustomerPaymentStats.fromJson(json);
}

/// @nodoc
mixin _$CustomerPaymentStats {
  int get paidInvoiceCount => throw _privateConstructorUsedError;
  int? get averageDaysToPay => throw _privateConstructorUsedError;
  int? get onTimeRate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CustomerPaymentStatsCopyWith<CustomerPaymentStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerPaymentStatsCopyWith<$Res> {
  factory $CustomerPaymentStatsCopyWith(CustomerPaymentStats value,
          $Res Function(CustomerPaymentStats) then) =
      _$CustomerPaymentStatsCopyWithImpl<$Res, CustomerPaymentStats>;
  @useResult
  $Res call({int paidInvoiceCount, int? averageDaysToPay, int? onTimeRate});
}

/// @nodoc
class _$CustomerPaymentStatsCopyWithImpl<$Res,
        $Val extends CustomerPaymentStats>
    implements $CustomerPaymentStatsCopyWith<$Res> {
  _$CustomerPaymentStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paidInvoiceCount = null,
    Object? averageDaysToPay = freezed,
    Object? onTimeRate = freezed,
  }) {
    return _then(_value.copyWith(
      paidInvoiceCount: null == paidInvoiceCount
          ? _value.paidInvoiceCount
          : paidInvoiceCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageDaysToPay: freezed == averageDaysToPay
          ? _value.averageDaysToPay
          : averageDaysToPay // ignore: cast_nullable_to_non_nullable
              as int?,
      onTimeRate: freezed == onTimeRate
          ? _value.onTimeRate
          : onTimeRate // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomerPaymentStatsImplCopyWith<$Res>
    implements $CustomerPaymentStatsCopyWith<$Res> {
  factory _$$CustomerPaymentStatsImplCopyWith(_$CustomerPaymentStatsImpl value,
          $Res Function(_$CustomerPaymentStatsImpl) then) =
      __$$CustomerPaymentStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int paidInvoiceCount, int? averageDaysToPay, int? onTimeRate});
}

/// @nodoc
class __$$CustomerPaymentStatsImplCopyWithImpl<$Res>
    extends _$CustomerPaymentStatsCopyWithImpl<$Res, _$CustomerPaymentStatsImpl>
    implements _$$CustomerPaymentStatsImplCopyWith<$Res> {
  __$$CustomerPaymentStatsImplCopyWithImpl(_$CustomerPaymentStatsImpl _value,
      $Res Function(_$CustomerPaymentStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paidInvoiceCount = null,
    Object? averageDaysToPay = freezed,
    Object? onTimeRate = freezed,
  }) {
    return _then(_$CustomerPaymentStatsImpl(
      paidInvoiceCount: null == paidInvoiceCount
          ? _value.paidInvoiceCount
          : paidInvoiceCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageDaysToPay: freezed == averageDaysToPay
          ? _value.averageDaysToPay
          : averageDaysToPay // ignore: cast_nullable_to_non_nullable
              as int?,
      onTimeRate: freezed == onTimeRate
          ? _value.onTimeRate
          : onTimeRate // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerPaymentStatsImpl implements _CustomerPaymentStats {
  const _$CustomerPaymentStatsImpl(
      {required this.paidInvoiceCount, this.averageDaysToPay, this.onTimeRate});

  factory _$CustomerPaymentStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerPaymentStatsImplFromJson(json);

  @override
  final int paidInvoiceCount;
  @override
  final int? averageDaysToPay;
  @override
  final int? onTimeRate;

  @override
  String toString() {
    return 'CustomerPaymentStats(paidInvoiceCount: $paidInvoiceCount, averageDaysToPay: $averageDaysToPay, onTimeRate: $onTimeRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerPaymentStatsImpl &&
            (identical(other.paidInvoiceCount, paidInvoiceCount) ||
                other.paidInvoiceCount == paidInvoiceCount) &&
            (identical(other.averageDaysToPay, averageDaysToPay) ||
                other.averageDaysToPay == averageDaysToPay) &&
            (identical(other.onTimeRate, onTimeRate) ||
                other.onTimeRate == onTimeRate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, paidInvoiceCount, averageDaysToPay, onTimeRate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerPaymentStatsImplCopyWith<_$CustomerPaymentStatsImpl>
      get copyWith =>
          __$$CustomerPaymentStatsImplCopyWithImpl<_$CustomerPaymentStatsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerPaymentStatsImplToJson(
      this,
    );
  }
}

abstract class _CustomerPaymentStats implements CustomerPaymentStats {
  const factory _CustomerPaymentStats(
      {required final int paidInvoiceCount,
      final int? averageDaysToPay,
      final int? onTimeRate}) = _$CustomerPaymentStatsImpl;

  factory _CustomerPaymentStats.fromJson(Map<String, dynamic> json) =
      _$CustomerPaymentStatsImpl.fromJson;

  @override
  int get paidInvoiceCount;
  @override
  int? get averageDaysToPay;
  @override
  int? get onTimeRate;
  @override
  @JsonKey(ignore: true)
  _$$CustomerPaymentStatsImplCopyWith<_$CustomerPaymentStatsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
