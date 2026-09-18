// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Payment _$PaymentFromJson(Map<String, dynamic> json) {
  return _Payment.fromJson(json);
}

/// @nodoc
mixin _$Payment {
  String get id => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson)
  PaymentMethod get method => throw _privateConstructorUsedError;
  String get paidOn => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get referenceNumber => throw _privateConstructorUsedError;
  String? get payerName => throw _privateConstructorUsedError;
  String? get receiptImageUrl => throw _privateConstructorUsedError;
  String? get receiptDocumentId => throw _privateConstructorUsedError;
  String? get voidedAt => throw _privateConstructorUsedError;
  String? get voidReason => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaymentCopyWith<Payment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentCopyWith<$Res> {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) then) =
      _$PaymentCopyWithImpl<$Res, Payment>;
  @useResult
  $Res call(
      {String id,
      int amount,
      @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson)
      PaymentMethod method,
      String paidOn,
      String? notes,
      String? referenceNumber,
      String? payerName,
      String? receiptImageUrl,
      String? receiptDocumentId,
      String? voidedAt,
      String? voidReason,
      String createdAt});
}

/// @nodoc
class _$PaymentCopyWithImpl<$Res, $Val extends Payment>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? method = null,
    Object? paidOn = null,
    Object? notes = freezed,
    Object? referenceNumber = freezed,
    Object? payerName = freezed,
    Object? receiptImageUrl = freezed,
    Object? receiptDocumentId = freezed,
    Object? voidedAt = freezed,
    Object? voidReason = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      receiptDocumentId: freezed == receiptDocumentId
          ? _value.receiptDocumentId
          : receiptDocumentId // ignore: cast_nullable_to_non_nullable
              as String?,
      voidedAt: freezed == voidedAt
          ? _value.voidedAt
          : voidedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      voidReason: freezed == voidReason
          ? _value.voidReason
          : voidReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentImplCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$$PaymentImplCopyWith(
          _$PaymentImpl value, $Res Function(_$PaymentImpl) then) =
      __$$PaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int amount,
      @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson)
      PaymentMethod method,
      String paidOn,
      String? notes,
      String? referenceNumber,
      String? payerName,
      String? receiptImageUrl,
      String? receiptDocumentId,
      String? voidedAt,
      String? voidReason,
      String createdAt});
}

/// @nodoc
class __$$PaymentImplCopyWithImpl<$Res>
    extends _$PaymentCopyWithImpl<$Res, _$PaymentImpl>
    implements _$$PaymentImplCopyWith<$Res> {
  __$$PaymentImplCopyWithImpl(
      _$PaymentImpl _value, $Res Function(_$PaymentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? method = null,
    Object? paidOn = null,
    Object? notes = freezed,
    Object? referenceNumber = freezed,
    Object? payerName = freezed,
    Object? receiptImageUrl = freezed,
    Object? receiptDocumentId = freezed,
    Object? voidedAt = freezed,
    Object? voidReason = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$PaymentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      receiptDocumentId: freezed == receiptDocumentId
          ? _value.receiptDocumentId
          : receiptDocumentId // ignore: cast_nullable_to_non_nullable
              as String?,
      voidedAt: freezed == voidedAt
          ? _value.voidedAt
          : voidedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      voidReason: freezed == voidReason
          ? _value.voidReason
          : voidReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentImpl implements _Payment {
  const _$PaymentImpl(
      {required this.id,
      required this.amount,
      @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson)
      required this.method,
      required this.paidOn,
      this.notes,
      this.referenceNumber,
      this.payerName,
      this.receiptImageUrl,
      this.receiptDocumentId,
      this.voidedAt,
      this.voidReason,
      required this.createdAt});

  factory _$PaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentImplFromJson(json);

  @override
  final String id;
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
  final String? receiptDocumentId;
  @override
  final String? voidedAt;
  @override
  final String? voidReason;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'Payment(id: $id, amount: $amount, method: $method, paidOn: $paidOn, notes: $notes, referenceNumber: $referenceNumber, payerName: $payerName, receiptImageUrl: $receiptImageUrl, receiptDocumentId: $receiptDocumentId, voidedAt: $voidedAt, voidReason: $voidReason, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
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
            (identical(other.receiptDocumentId, receiptDocumentId) ||
                other.receiptDocumentId == receiptDocumentId) &&
            (identical(other.voidedAt, voidedAt) ||
                other.voidedAt == voidedAt) &&
            (identical(other.voidReason, voidReason) ||
                other.voidReason == voidReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      amount,
      method,
      paidOn,
      notes,
      referenceNumber,
      payerName,
      receiptImageUrl,
      receiptDocumentId,
      voidedAt,
      voidReason,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      __$$PaymentImplCopyWithImpl<_$PaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentImplToJson(
      this,
    );
  }
}

abstract class _Payment implements Payment {
  const factory _Payment(
      {required final String id,
      required final int amount,
      @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson)
      required final PaymentMethod method,
      required final String paidOn,
      final String? notes,
      final String? referenceNumber,
      final String? payerName,
      final String? receiptImageUrl,
      final String? receiptDocumentId,
      final String? voidedAt,
      final String? voidReason,
      required final String createdAt}) = _$PaymentImpl;

  factory _Payment.fromJson(Map<String, dynamic> json) = _$PaymentImpl.fromJson;

  @override
  String get id;
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
  String? get receiptDocumentId;
  @override
  String? get voidedAt;
  @override
  String? get voidReason;
  @override
  String get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
