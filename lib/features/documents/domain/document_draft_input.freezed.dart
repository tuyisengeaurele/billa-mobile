// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_draft_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DocumentLineInput _$DocumentLineInputFromJson(Map<String, dynamic> json) {
  return _DocumentLineInput.fromJson(json);
}

/// @nodoc
mixin _$DocumentLineInput {
  String? get itemId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  int get unitPrice => throw _privateConstructorUsedError;
  double get taxRate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
  DiscountType? get discountType => throw _privateConstructorUsedError;
  double? get discountValue => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentLineInputCopyWith<DocumentLineInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentLineInputCopyWith<$Res> {
  factory $DocumentLineInputCopyWith(
          DocumentLineInput value, $Res Function(DocumentLineInput) then) =
      _$DocumentLineInputCopyWithImpl<$Res, DocumentLineInput>;
  @useResult
  $Res call(
      {String? itemId,
      String description,
      double quantity,
      int unitPrice,
      double taxRate,
      @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
      DiscountType? discountType,
      double? discountValue});
}

/// @nodoc
class _$DocumentLineInputCopyWithImpl<$Res, $Val extends DocumentLineInput>
    implements $DocumentLineInputCopyWith<$Res> {
  _$DocumentLineInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = freezed,
    Object? description = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? taxRate = null,
    Object? discountType = freezed,
    Object? discountValue = freezed,
  }) {
    return _then(_value.copyWith(
      itemId: freezed == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as int,
      taxRate: null == taxRate
          ? _value.taxRate
          : taxRate // ignore: cast_nullable_to_non_nullable
              as double,
      discountType: freezed == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as DiscountType?,
      discountValue: freezed == discountValue
          ? _value.discountValue
          : discountValue // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentLineInputImplCopyWith<$Res>
    implements $DocumentLineInputCopyWith<$Res> {
  factory _$$DocumentLineInputImplCopyWith(_$DocumentLineInputImpl value,
          $Res Function(_$DocumentLineInputImpl) then) =
      __$$DocumentLineInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? itemId,
      String description,
      double quantity,
      int unitPrice,
      double taxRate,
      @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
      DiscountType? discountType,
      double? discountValue});
}

/// @nodoc
class __$$DocumentLineInputImplCopyWithImpl<$Res>
    extends _$DocumentLineInputCopyWithImpl<$Res, _$DocumentLineInputImpl>
    implements _$$DocumentLineInputImplCopyWith<$Res> {
  __$$DocumentLineInputImplCopyWithImpl(_$DocumentLineInputImpl _value,
      $Res Function(_$DocumentLineInputImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = freezed,
    Object? description = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? taxRate = null,
    Object? discountType = freezed,
    Object? discountValue = freezed,
  }) {
    return _then(_$DocumentLineInputImpl(
      itemId: freezed == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as int,
      taxRate: null == taxRate
          ? _value.taxRate
          : taxRate // ignore: cast_nullable_to_non_nullable
              as double,
      discountType: freezed == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as DiscountType?,
      discountValue: freezed == discountValue
          ? _value.discountValue
          : discountValue // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$DocumentLineInputImpl implements _DocumentLineInput {
  const _$DocumentLineInputImpl(
      {this.itemId,
      required this.description,
      required this.quantity,
      required this.unitPrice,
      required this.taxRate,
      @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
      this.discountType,
      this.discountValue});

  factory _$DocumentLineInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentLineInputImplFromJson(json);

  @override
  final String? itemId;
  @override
  final String description;
  @override
  final double quantity;
  @override
  final int unitPrice;
  @override
  final double taxRate;
  @override
  @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
  final DiscountType? discountType;
  @override
  final double? discountValue;

  @override
  String toString() {
    return 'DocumentLineInput(itemId: $itemId, description: $description, quantity: $quantity, unitPrice: $unitPrice, taxRate: $taxRate, discountType: $discountType, discountValue: $discountValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentLineInputImpl &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.taxRate, taxRate) || other.taxRate == taxRate) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.discountValue, discountValue) ||
                other.discountValue == discountValue));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, itemId, description, quantity,
      unitPrice, taxRate, discountType, discountValue);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentLineInputImplCopyWith<_$DocumentLineInputImpl> get copyWith =>
      __$$DocumentLineInputImplCopyWithImpl<_$DocumentLineInputImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentLineInputImplToJson(
      this,
    );
  }
}

abstract class _DocumentLineInput implements DocumentLineInput {
  const factory _DocumentLineInput(
      {final String? itemId,
      required final String description,
      required final double quantity,
      required final int unitPrice,
      required final double taxRate,
      @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
      final DiscountType? discountType,
      final double? discountValue}) = _$DocumentLineInputImpl;

  factory _DocumentLineInput.fromJson(Map<String, dynamic> json) =
      _$DocumentLineInputImpl.fromJson;

  @override
  String? get itemId;
  @override
  String get description;
  @override
  double get quantity;
  @override
  int get unitPrice;
  @override
  double get taxRate;
  @override
  @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
  DiscountType? get discountType;
  @override
  double? get discountValue;
  @override
  @JsonKey(ignore: true)
  _$$DocumentLineInputImplCopyWith<_$DocumentLineInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InstallmentInput _$InstallmentInputFromJson(Map<String, dynamic> json) {
  return _InstallmentInput.fromJson(json);
}

/// @nodoc
mixin _$InstallmentInput {
  String? get label => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  String get dueDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InstallmentInputCopyWith<InstallmentInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InstallmentInputCopyWith<$Res> {
  factory $InstallmentInputCopyWith(
          InstallmentInput value, $Res Function(InstallmentInput) then) =
      _$InstallmentInputCopyWithImpl<$Res, InstallmentInput>;
  @useResult
  $Res call({String? label, int amount, String dueDate});
}

/// @nodoc
class _$InstallmentInputCopyWithImpl<$Res, $Val extends InstallmentInput>
    implements $InstallmentInputCopyWith<$Res> {
  _$InstallmentInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = freezed,
    Object? amount = null,
    Object? dueDate = null,
  }) {
    return _then(_value.copyWith(
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InstallmentInputImplCopyWith<$Res>
    implements $InstallmentInputCopyWith<$Res> {
  factory _$$InstallmentInputImplCopyWith(_$InstallmentInputImpl value,
          $Res Function(_$InstallmentInputImpl) then) =
      __$$InstallmentInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? label, int amount, String dueDate});
}

/// @nodoc
class __$$InstallmentInputImplCopyWithImpl<$Res>
    extends _$InstallmentInputCopyWithImpl<$Res, _$InstallmentInputImpl>
    implements _$$InstallmentInputImplCopyWith<$Res> {
  __$$InstallmentInputImplCopyWithImpl(_$InstallmentInputImpl _value,
      $Res Function(_$InstallmentInputImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = freezed,
    Object? amount = null,
    Object? dueDate = null,
  }) {
    return _then(_$InstallmentInputImpl(
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$InstallmentInputImpl implements _InstallmentInput {
  const _$InstallmentInputImpl(
      {this.label, required this.amount, required this.dueDate});

  factory _$InstallmentInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$InstallmentInputImplFromJson(json);

  @override
  final String? label;
  @override
  final int amount;
  @override
  final String dueDate;

  @override
  String toString() {
    return 'InstallmentInput(label: $label, amount: $amount, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InstallmentInputImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, label, amount, dueDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InstallmentInputImplCopyWith<_$InstallmentInputImpl> get copyWith =>
      __$$InstallmentInputImplCopyWithImpl<_$InstallmentInputImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InstallmentInputImplToJson(
      this,
    );
  }
}

abstract class _InstallmentInput implements InstallmentInput {
  const factory _InstallmentInput(
      {final String? label,
      required final int amount,
      required final String dueDate}) = _$InstallmentInputImpl;

  factory _InstallmentInput.fromJson(Map<String, dynamic> json) =
      _$InstallmentInputImpl.fromJson;

  @override
  String? get label;
  @override
  int get amount;
  @override
  String get dueDate;
  @override
  @JsonKey(ignore: true)
  _$$InstallmentInputImplCopyWith<_$InstallmentInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecurrenceInput _$RecurrenceInputFromJson(Map<String, dynamic> json) {
  return _RecurrenceInput.fromJson(json);
}

/// @nodoc
mixin _$RecurrenceInput {
  String get interval => throw _privateConstructorUsedError;
  String? get endDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecurrenceInputCopyWith<RecurrenceInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurrenceInputCopyWith<$Res> {
  factory $RecurrenceInputCopyWith(
          RecurrenceInput value, $Res Function(RecurrenceInput) then) =
      _$RecurrenceInputCopyWithImpl<$Res, RecurrenceInput>;
  @useResult
  $Res call({String interval, String? endDate});
}

/// @nodoc
class _$RecurrenceInputCopyWithImpl<$Res, $Val extends RecurrenceInput>
    implements $RecurrenceInputCopyWith<$Res> {
  _$RecurrenceInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? interval = null,
    Object? endDate = freezed,
  }) {
    return _then(_value.copyWith(
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecurrenceInputImplCopyWith<$Res>
    implements $RecurrenceInputCopyWith<$Res> {
  factory _$$RecurrenceInputImplCopyWith(_$RecurrenceInputImpl value,
          $Res Function(_$RecurrenceInputImpl) then) =
      __$$RecurrenceInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String interval, String? endDate});
}

/// @nodoc
class __$$RecurrenceInputImplCopyWithImpl<$Res>
    extends _$RecurrenceInputCopyWithImpl<$Res, _$RecurrenceInputImpl>
    implements _$$RecurrenceInputImplCopyWith<$Res> {
  __$$RecurrenceInputImplCopyWithImpl(
      _$RecurrenceInputImpl _value, $Res Function(_$RecurrenceInputImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? interval = null,
    Object? endDate = freezed,
  }) {
    return _then(_$RecurrenceInputImpl(
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$RecurrenceInputImpl implements _RecurrenceInput {
  const _$RecurrenceInputImpl({required this.interval, this.endDate});

  factory _$RecurrenceInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecurrenceInputImplFromJson(json);

  @override
  final String interval;
  @override
  final String? endDate;

  @override
  String toString() {
    return 'RecurrenceInput(interval: $interval, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurrenceInputImpl &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, interval, endDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurrenceInputImplCopyWith<_$RecurrenceInputImpl> get copyWith =>
      __$$RecurrenceInputImplCopyWithImpl<_$RecurrenceInputImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurrenceInputImplToJson(
      this,
    );
  }
}

abstract class _RecurrenceInput implements RecurrenceInput {
  const factory _RecurrenceInput(
      {required final String interval,
      final String? endDate}) = _$RecurrenceInputImpl;

  factory _RecurrenceInput.fromJson(Map<String, dynamic> json) =
      _$RecurrenceInputImpl.fromJson;

  @override
  String get interval;
  @override
  String? get endDate;
  @override
  @JsonKey(ignore: true)
  _$$RecurrenceInputImplCopyWith<_$RecurrenceInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DocumentDraftInput _$DocumentDraftInputFromJson(Map<String, dynamic> json) {
  return _DocumentDraftInput.fromJson(json);
}

/// @nodoc
mixin _$DocumentDraftInput {
  @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
  DocumentType get type => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  String get issueDate => throw _privateConstructorUsedError;
  String? get dueDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get customerReference => throw _privateConstructorUsedError;
  String? get referencedDocumentId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
  DocumentLanguage get language => throw _privateConstructorUsedError;
  @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
  Currency get currency => throw _privateConstructorUsedError;
  double? get exchangeRate => throw _privateConstructorUsedError;
  List<InstallmentInput>? get installments =>
      throw _privateConstructorUsedError;
  RecurrenceInput? get recurrence => throw _privateConstructorUsedError;
  List<DocumentLineInput> get lines => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentDraftInputCopyWith<DocumentDraftInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentDraftInputCopyWith<$Res> {
  factory $DocumentDraftInputCopyWith(
          DocumentDraftInput value, $Res Function(DocumentDraftInput) then) =
      _$DocumentDraftInputCopyWithImpl<$Res, DocumentDraftInput>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      DocumentType type,
      String customerId,
      String issueDate,
      String? dueDate,
      String? notes,
      String? customerReference,
      String? referencedDocumentId,
      @JsonKey(
          fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
      DocumentLanguage language,
      @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
      Currency currency,
      double? exchangeRate,
      List<InstallmentInput>? installments,
      RecurrenceInput? recurrence,
      List<DocumentLineInput> lines});

  $RecurrenceInputCopyWith<$Res>? get recurrence;
}

/// @nodoc
class _$DocumentDraftInputCopyWithImpl<$Res, $Val extends DocumentDraftInput>
    implements $DocumentDraftInputCopyWith<$Res> {
  _$DocumentDraftInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? customerId = null,
    Object? issueDate = null,
    Object? dueDate = freezed,
    Object? notes = freezed,
    Object? customerReference = freezed,
    Object? referencedDocumentId = freezed,
    Object? language = null,
    Object? currency = null,
    Object? exchangeRate = freezed,
    Object? installments = freezed,
    Object? recurrence = freezed,
    Object? lines = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DocumentType,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      issueDate: null == issueDate
          ? _value.issueDate
          : issueDate // ignore: cast_nullable_to_non_nullable
              as String,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      customerReference: freezed == customerReference
          ? _value.customerReference
          : customerReference // ignore: cast_nullable_to_non_nullable
              as String?,
      referencedDocumentId: freezed == referencedDocumentId
          ? _value.referencedDocumentId
          : referencedDocumentId // ignore: cast_nullable_to_non_nullable
              as String?,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as DocumentLanguage,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as Currency,
      exchangeRate: freezed == exchangeRate
          ? _value.exchangeRate
          : exchangeRate // ignore: cast_nullable_to_non_nullable
              as double?,
      installments: freezed == installments
          ? _value.installments
          : installments // ignore: cast_nullable_to_non_nullable
              as List<InstallmentInput>?,
      recurrence: freezed == recurrence
          ? _value.recurrence
          : recurrence // ignore: cast_nullable_to_non_nullable
              as RecurrenceInput?,
      lines: null == lines
          ? _value.lines
          : lines // ignore: cast_nullable_to_non_nullable
              as List<DocumentLineInput>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RecurrenceInputCopyWith<$Res>? get recurrence {
    if (_value.recurrence == null) {
      return null;
    }

    return $RecurrenceInputCopyWith<$Res>(_value.recurrence!, (value) {
      return _then(_value.copyWith(recurrence: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DocumentDraftInputImplCopyWith<$Res>
    implements $DocumentDraftInputCopyWith<$Res> {
  factory _$$DocumentDraftInputImplCopyWith(_$DocumentDraftInputImpl value,
          $Res Function(_$DocumentDraftInputImpl) then) =
      __$$DocumentDraftInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      DocumentType type,
      String customerId,
      String issueDate,
      String? dueDate,
      String? notes,
      String? customerReference,
      String? referencedDocumentId,
      @JsonKey(
          fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
      DocumentLanguage language,
      @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
      Currency currency,
      double? exchangeRate,
      List<InstallmentInput>? installments,
      RecurrenceInput? recurrence,
      List<DocumentLineInput> lines});

  @override
  $RecurrenceInputCopyWith<$Res>? get recurrence;
}

/// @nodoc
class __$$DocumentDraftInputImplCopyWithImpl<$Res>
    extends _$DocumentDraftInputCopyWithImpl<$Res, _$DocumentDraftInputImpl>
    implements _$$DocumentDraftInputImplCopyWith<$Res> {
  __$$DocumentDraftInputImplCopyWithImpl(_$DocumentDraftInputImpl _value,
      $Res Function(_$DocumentDraftInputImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? customerId = null,
    Object? issueDate = null,
    Object? dueDate = freezed,
    Object? notes = freezed,
    Object? customerReference = freezed,
    Object? referencedDocumentId = freezed,
    Object? language = null,
    Object? currency = null,
    Object? exchangeRate = freezed,
    Object? installments = freezed,
    Object? recurrence = freezed,
    Object? lines = null,
  }) {
    return _then(_$DocumentDraftInputImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DocumentType,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      issueDate: null == issueDate
          ? _value.issueDate
          : issueDate // ignore: cast_nullable_to_non_nullable
              as String,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      customerReference: freezed == customerReference
          ? _value.customerReference
          : customerReference // ignore: cast_nullable_to_non_nullable
              as String?,
      referencedDocumentId: freezed == referencedDocumentId
          ? _value.referencedDocumentId
          : referencedDocumentId // ignore: cast_nullable_to_non_nullable
              as String?,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as DocumentLanguage,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as Currency,
      exchangeRate: freezed == exchangeRate
          ? _value.exchangeRate
          : exchangeRate // ignore: cast_nullable_to_non_nullable
              as double?,
      installments: freezed == installments
          ? _value._installments
          : installments // ignore: cast_nullable_to_non_nullable
              as List<InstallmentInput>?,
      recurrence: freezed == recurrence
          ? _value.recurrence
          : recurrence // ignore: cast_nullable_to_non_nullable
              as RecurrenceInput?,
      lines: null == lines
          ? _value._lines
          : lines // ignore: cast_nullable_to_non_nullable
              as List<DocumentLineInput>,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class _$DocumentDraftInputImpl implements _DocumentDraftInput {
  const _$DocumentDraftInputImpl(
      {@JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      required this.type,
      required this.customerId,
      required this.issueDate,
      this.dueDate,
      this.notes,
      this.customerReference,
      this.referencedDocumentId,
      @JsonKey(
          fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
      this.language = DocumentLanguage.en,
      @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
      this.currency = Currency.rwf,
      this.exchangeRate,
      final List<InstallmentInput>? installments,
      this.recurrence,
      final List<DocumentLineInput> lines = const <DocumentLineInput>[]})
      : _installments = installments,
        _lines = lines;

  factory _$DocumentDraftInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentDraftInputImplFromJson(json);

  @override
  @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
  final DocumentType type;
  @override
  final String customerId;
  @override
  final String issueDate;
  @override
  final String? dueDate;
  @override
  final String? notes;
  @override
  final String? customerReference;
  @override
  final String? referencedDocumentId;
  @override
  @JsonKey(fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
  final DocumentLanguage language;
  @override
  @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
  final Currency currency;
  @override
  final double? exchangeRate;
  final List<InstallmentInput>? _installments;
  @override
  List<InstallmentInput>? get installments {
    final value = _installments;
    if (value == null) return null;
    if (_installments is EqualUnmodifiableListView) return _installments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final RecurrenceInput? recurrence;
  final List<DocumentLineInput> _lines;
  @override
  @JsonKey()
  List<DocumentLineInput> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  String toString() {
    return 'DocumentDraftInput(type: $type, customerId: $customerId, issueDate: $issueDate, dueDate: $dueDate, notes: $notes, customerReference: $customerReference, referencedDocumentId: $referencedDocumentId, language: $language, currency: $currency, exchangeRate: $exchangeRate, installments: $installments, recurrence: $recurrence, lines: $lines)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentDraftInputImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.issueDate, issueDate) ||
                other.issueDate == issueDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.customerReference, customerReference) ||
                other.customerReference == customerReference) &&
            (identical(other.referencedDocumentId, referencedDocumentId) ||
                other.referencedDocumentId == referencedDocumentId) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.exchangeRate, exchangeRate) ||
                other.exchangeRate == exchangeRate) &&
            const DeepCollectionEquality()
                .equals(other._installments, _installments) &&
            (identical(other.recurrence, recurrence) ||
                other.recurrence == recurrence) &&
            const DeepCollectionEquality().equals(other._lines, _lines));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      customerId,
      issueDate,
      dueDate,
      notes,
      customerReference,
      referencedDocumentId,
      language,
      currency,
      exchangeRate,
      const DeepCollectionEquality().hash(_installments),
      recurrence,
      const DeepCollectionEquality().hash(_lines));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentDraftInputImplCopyWith<_$DocumentDraftInputImpl> get copyWith =>
      __$$DocumentDraftInputImplCopyWithImpl<_$DocumentDraftInputImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentDraftInputImplToJson(
      this,
    );
  }
}

abstract class _DocumentDraftInput implements DocumentDraftInput {
  const factory _DocumentDraftInput(
      {@JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      required final DocumentType type,
      required final String customerId,
      required final String issueDate,
      final String? dueDate,
      final String? notes,
      final String? customerReference,
      final String? referencedDocumentId,
      @JsonKey(
          fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
      final DocumentLanguage language,
      @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
      final Currency currency,
      final double? exchangeRate,
      final List<InstallmentInput>? installments,
      final RecurrenceInput? recurrence,
      final List<DocumentLineInput> lines}) = _$DocumentDraftInputImpl;

  factory _DocumentDraftInput.fromJson(Map<String, dynamic> json) =
      _$DocumentDraftInputImpl.fromJson;

  @override
  @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
  DocumentType get type;
  @override
  String get customerId;
  @override
  String get issueDate;
  @override
  String? get dueDate;
  @override
  String? get notes;
  @override
  String? get customerReference;
  @override
  String? get referencedDocumentId;
  @override
  @JsonKey(fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
  DocumentLanguage get language;
  @override
  @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
  Currency get currency;
  @override
  double? get exchangeRate;
  @override
  List<InstallmentInput>? get installments;
  @override
  RecurrenceInput? get recurrence;
  @override
  List<DocumentLineInput> get lines;
  @override
  @JsonKey(ignore: true)
  _$$DocumentDraftInputImplCopyWith<_$DocumentDraftInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
