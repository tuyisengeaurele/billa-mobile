// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PaymentInput _$PaymentInputFromJson(Map<String, dynamic> json) {
  return _PaymentInput.fromJson(json);
}

/// @nodoc
mixin _$PaymentInput {
  int get amount => throw _privateConstructorUsedError;
  @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson)
  PaymentMethod get method => throw _privateConstructorUsedError;
  String get paidOn => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get referenceNumber => throw _privateConstructorUsedError;
  String? get payerName => throw _privateConstructorUsedError;
  String? get receiptImageUrl => throw _privateConstructorUsedError;
  bool get generateReceipt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaymentInputCopyWith<PaymentInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentInputCopyWith<$Res> {
  factory $PaymentInputCopyWith(
          PaymentInput value, $Res Function(PaymentInput) then) =
      _$PaymentInputCopyWithImpl<$Res, PaymentInput>;
  @useResult
  $Res call(
      {int amount,
      @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson)
      PaymentMethod method,
      String paidOn,
      String? notes,
      String? referenceNumber,
      String? payerName,
      String? receiptImageUrl,
      bool generateReceipt});
}

/// @nodoc
class _$PaymentInputCopyWithImpl<$Res, $Val extends PaymentInput>
    implements $PaymentInputCopyWith<$Res> {
  _$PaymentInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? method = null,
    Object? paidOn = null,
    Object? notes = freezed,
    Object? referenceNumber = freezed,
    Object? payerName = freezed,
    Object? receiptImageUrl = freezed,
    Object? generateReceipt = null,
  }) {
    return _then(_value.copyWith(
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      paidOn: null == paidOn
          ? _value.paidOn
          : paidOn // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      payerName: freezed == payerName
          ? _value.payerName
          : payerName // ignore: cast_nullable_to_non_nullable
              as String?,
      receiptImageUrl: freezed == receiptImageUrl
          ? _value.receiptImageUrl
          : receiptImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      generateReceipt: null == generateReceipt
          ? _value.generateReceipt
          : generateReceipt // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentInputImplCopyWith<$Res>
    implements $PaymentInputCopyWith<$Res> {
  factory _$$PaymentInputImplCopyWith(
          _$PaymentInputImpl value, $Res Function(_$PaymentInputImpl) then) =
      __$$PaymentInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int amount,
      @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson)
      PaymentMethod method,
      String paidOn,
      String? notes,
      String? referenceNumber,
      String? payerName,
      String? receiptImageUrl,
      bool generateReceipt});
}

/// @nodoc
class __$$PaymentInputImplCopyWithImpl<$Res>
    extends _$PaymentInputCopyWithImpl<$Res, _$PaymentInputImpl>
    implements _$$PaymentInputImplCopyWith<$Res> {
  __$$PaymentInputImplCopyWithImpl(
      _$PaymentInputImpl _value, $Res Function(_$PaymentInputImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? method = null,
    Object? paidOn = null,
    Object? notes = freezed,
    Object? referenceNumber = freezed,
    Object? payerName = freezed,
    Object? receiptImageUrl = freezed,
    Object? generateReceipt = null,
  }) {
    return _then(_$PaymentInputImpl(
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      paidOn: null == paidOn
          ? _value.paidOn
          : paidOn // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      payerName: freezed == payerName
          ? _value.payerName
          : payerName // ignore: cast_nullable_to_non_nullable
              as String?,
      receiptImageUrl: freezed == receiptImageUrl
          ? _value.receiptImageUrl
          : receiptImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      generateReceipt: null == generateReceipt
          ? _value.generateReceipt
          : generateReceipt // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentInputImpl implements _PaymentInput {
  const _$PaymentInputImpl(
      {required this.amount,
      @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson)
      required this.method,
      required this.paidOn,
      this.notes,
      this.referenceNumber,
      this.payerName,
      this.receiptImageUrl,
      this.generateReceipt = false});

  factory _$PaymentInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentInputImplFromJson(json);

  @override
  final int amount;
  @override
  @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson)
  final PaymentMethod method;
  @override
  final String paidOn;
  @override
  final String? notes;
  @override
  final String? referenceNumber;
  @override
  final String? payerName;
  @override
  final String? receiptImageUrl;
  @override
  @JsonKey()
  final bool generateReceipt;

  @override
  String toString() {
    return 'PaymentInput(amount: $amount, method: $method, paidOn: $paidOn, notes: $notes, referenceNumber: $referenceNumber, payerName: $payerName, receiptImageUrl: $receiptImageUrl, generateReceipt: $generateReceipt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentInputImpl &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.paidOn, paidOn) || other.paidOn == paidOn) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.payerName, payerName) ||
                other.payerName == payerName) &&
            (identical(other.receiptImageUrl, receiptImageUrl) ||
                other.receiptImageUrl == receiptImageUrl) &&
            (identical(other.generateReceipt, generateReceipt) ||
                other.generateReceipt == generateReceipt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, amount, method, paidOn, notes,
      referenceNumber, payerName, receiptImageUrl, generateReceipt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentInputImplCopyWith<_$PaymentInputImpl> get copyWith =>
      __$$PaymentInputImplCopyWithImpl<_$PaymentInputImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentInputImplToJson(
      this,
    );
  }
}

abstract class _PaymentInput implements PaymentInput {
  const factory _PaymentInput(
      {required final int amount,
      @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson)
      required final PaymentMethod method,
      required final String paidOn,
      final String? notes,
      final String? referenceNumber,
      final String? payerName,
      final String? receiptImageUrl,
      final bool generateReceipt}) = _$PaymentInputImpl;

  factory _PaymentInput.fromJson(Map<String, dynamic> json) =
      _$PaymentInputImpl.fromJson;

  @override
  int get amount;
  @override
  @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson)
  PaymentMethod get method;
  @override
  String get paidOn;
  @override
  String? get notes;
  @override
  String? get referenceNumber;
  @override
  String? get payerName;
  @override
  String? get receiptImageUrl;
  @override
  bool get generateReceipt;
  @override
  @JsonKey(ignore: true)
  _$$PaymentInputImplCopyWith<_$PaymentInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
