// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DocumentRef _$DocumentRefFromJson(Map<String, dynamic> json) {
  return _DocumentRef.fromJson(json);
}

/// @nodoc
mixin _$DocumentRef {
  String get id => throw _privateConstructorUsedError;
  String? get number => throw _privateConstructorUsedError;
  @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
  DocumentType get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentRefCopyWith<DocumentRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentRefCopyWith<$Res> {
  factory $DocumentRefCopyWith(
          DocumentRef value, $Res Function(DocumentRef) then) =
      _$DocumentRefCopyWithImpl<$Res, DocumentRef>;
  @useResult
  $Res call(
      {String id,
      String? number,
      @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      DocumentType type});
}

/// @nodoc
class _$DocumentRefCopyWithImpl<$Res, $Val extends DocumentRef>
    implements $DocumentRefCopyWith<$Res> {
  _$DocumentRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = freezed,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      number: freezed == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DocumentType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentRefImplCopyWith<$Res>
    implements $DocumentRefCopyWith<$Res> {
  factory _$$DocumentRefImplCopyWith(
          _$DocumentRefImpl value, $Res Function(_$DocumentRefImpl) then) =
      __$$DocumentRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? number,
      @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      DocumentType type});
}

/// @nodoc
class __$$DocumentRefImplCopyWithImpl<$Res>
    extends _$DocumentRefCopyWithImpl<$Res, _$DocumentRefImpl>
    implements _$$DocumentRefImplCopyWith<$Res> {
  __$$DocumentRefImplCopyWithImpl(
      _$DocumentRefImpl _value, $Res Function(_$DocumentRefImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = freezed,
    Object? type = null,
  }) {
    return _then(_$DocumentRefImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      number: freezed == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DocumentType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentRefImpl implements _DocumentRef {
  const _$DocumentRefImpl(
      {required this.id,
      this.number,
      @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      required this.type});

  factory _$DocumentRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentRefImplFromJson(json);

  @override
  final String id;
  @override
  final String? number;
  @override
  @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
  final DocumentType type;

  @override
  String toString() {
    return 'DocumentRef(id: $id, number: $number, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentRefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, number, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentRefImplCopyWith<_$DocumentRefImpl> get copyWith =>
      __$$DocumentRefImplCopyWithImpl<_$DocumentRefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentRefImplToJson(
      this,
    );
  }
}

abstract class _DocumentRef implements DocumentRef {
  const factory _DocumentRef(
      {required final String id,
      final String? number,
      @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      required final DocumentType type}) = _$DocumentRefImpl;

  factory _DocumentRef.fromJson(Map<String, dynamic> json) =
      _$DocumentRefImpl.fromJson;

  @override
  String get id;
  @override
  String? get number;
  @override
  @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
  DocumentType get type;
  @override
  @JsonKey(ignore: true)
  _$$DocumentRefImplCopyWith<_$DocumentRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DocumentInstallment _$DocumentInstallmentFromJson(Map<String, dynamic> json) {
  return _DocumentInstallment.fromJson(json);
}

/// @nodoc
mixin _$DocumentInstallment {
  String? get label => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  String get dueDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentInstallmentCopyWith<DocumentInstallment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentInstallmentCopyWith<$Res> {
  factory $DocumentInstallmentCopyWith(
          DocumentInstallment value, $Res Function(DocumentInstallment) then) =
      _$DocumentInstallmentCopyWithImpl<$Res, DocumentInstallment>;
  @useResult
  $Res call({String? label, int amount, String dueDate});
}

/// @nodoc
class _$DocumentInstallmentCopyWithImpl<$Res, $Val extends DocumentInstallment>
    implements $DocumentInstallmentCopyWith<$Res> {
  _$DocumentInstallmentCopyWithImpl(this._value, this._then);

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
abstract class _$$DocumentInstallmentImplCopyWith<$Res>
    implements $DocumentInstallmentCopyWith<$Res> {
  factory _$$DocumentInstallmentImplCopyWith(_$DocumentInstallmentImpl value,
          $Res Function(_$DocumentInstallmentImpl) then) =
      __$$DocumentInstallmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? label, int amount, String dueDate});
}

/// @nodoc
class __$$DocumentInstallmentImplCopyWithImpl<$Res>
    extends _$DocumentInstallmentCopyWithImpl<$Res, _$DocumentInstallmentImpl>
    implements _$$DocumentInstallmentImplCopyWith<$Res> {
  __$$DocumentInstallmentImplCopyWithImpl(_$DocumentInstallmentImpl _value,
      $Res Function(_$DocumentInstallmentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = freezed,
    Object? amount = null,
    Object? dueDate = null,
  }) {
    return _then(_$DocumentInstallmentImpl(
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
@JsonSerializable()
class _$DocumentInstallmentImpl implements _DocumentInstallment {
  const _$DocumentInstallmentImpl(
      {this.label, required this.amount, required this.dueDate});

  factory _$DocumentInstallmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentInstallmentImplFromJson(json);

  @override
  final String? label;
  @override
  final int amount;
  @override
  final String dueDate;

  @override
  String toString() {
    return 'DocumentInstallment(label: $label, amount: $amount, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentInstallmentImpl &&
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
  _$$DocumentInstallmentImplCopyWith<_$DocumentInstallmentImpl> get copyWith =>
      __$$DocumentInstallmentImplCopyWithImpl<_$DocumentInstallmentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentInstallmentImplToJson(
      this,
    );
  }
}

abstract class _DocumentInstallment implements DocumentInstallment {
  const factory _DocumentInstallment(
      {final String? label,
      required final int amount,
      required final String dueDate}) = _$DocumentInstallmentImpl;

  factory _DocumentInstallment.fromJson(Map<String, dynamic> json) =
      _$DocumentInstallmentImpl.fromJson;

  @override
  String? get label;
  @override
  int get amount;
  @override
  String get dueDate;
  @override
  @JsonKey(ignore: true)
  _$$DocumentInstallmentImplCopyWith<_$DocumentInstallmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DocumentNextInstallment _$DocumentNextInstallmentFromJson(
    Map<String, dynamic> json) {
  return _DocumentNextInstallment.fromJson(json);
}

/// @nodoc
mixin _$DocumentNextInstallment {
  String? get label => throw _privateConstructorUsedError;
  int get remaining => throw _privateConstructorUsedError;
  String get dueDate => throw _privateConstructorUsedError;
  int? get number => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentNextInstallmentCopyWith<DocumentNextInstallment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentNextInstallmentCopyWith<$Res> {
  factory $DocumentNextInstallmentCopyWith(DocumentNextInstallment value,
          $Res Function(DocumentNextInstallment) then) =
      _$DocumentNextInstallmentCopyWithImpl<$Res, DocumentNextInstallment>;
  @useResult
  $Res call({String? label, int remaining, String dueDate, int? number});
}

/// @nodoc
class _$DocumentNextInstallmentCopyWithImpl<$Res,
        $Val extends DocumentNextInstallment>
    implements $DocumentNextInstallmentCopyWith<$Res> {
  _$DocumentNextInstallmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = freezed,
    Object? remaining = null,
    Object? dueDate = null,
    Object? number = freezed,
  }) {
    return _then(_value.copyWith(
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      remaining: null == remaining
          ? _value.remaining
          : remaining // ignore: cast_nullable_to_non_nullable
              as int,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as String,
      number: freezed == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentNextInstallmentImplCopyWith<$Res>
    implements $DocumentNextInstallmentCopyWith<$Res> {
  factory _$$DocumentNextInstallmentImplCopyWith(
          _$DocumentNextInstallmentImpl value,
          $Res Function(_$DocumentNextInstallmentImpl) then) =
      __$$DocumentNextInstallmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? label, int remaining, String dueDate, int? number});
}

/// @nodoc
class __$$DocumentNextInstallmentImplCopyWithImpl<$Res>
    extends _$DocumentNextInstallmentCopyWithImpl<$Res,
        _$DocumentNextInstallmentImpl>
    implements _$$DocumentNextInstallmentImplCopyWith<$Res> {
  __$$DocumentNextInstallmentImplCopyWithImpl(
      _$DocumentNextInstallmentImpl _value,
      $Res Function(_$DocumentNextInstallmentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = freezed,
    Object? remaining = null,
    Object? dueDate = null,
    Object? number = freezed,
  }) {
    return _then(_$DocumentNextInstallmentImpl(
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      remaining: null == remaining
          ? _value.remaining
          : remaining // ignore: cast_nullable_to_non_nullable
              as int,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as String,
      number: freezed == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentNextInstallmentImpl implements _DocumentNextInstallment {
  const _$DocumentNextInstallmentImpl(
      {this.label,
      required this.remaining,
      required this.dueDate,
      this.number});

  factory _$DocumentNextInstallmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentNextInstallmentImplFromJson(json);

  @override
  final String? label;
  @override
  final int remaining;
  @override
  final String dueDate;
  @override
  final int? number;

  @override
  String toString() {
    return 'DocumentNextInstallment(label: $label, remaining: $remaining, dueDate: $dueDate, number: $number)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentNextInstallmentImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.remaining, remaining) ||
                other.remaining == remaining) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.number, number) || other.number == number));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, label, remaining, dueDate, number);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentNextInstallmentImplCopyWith<_$DocumentNextInstallmentImpl>
      get copyWith => __$$DocumentNextInstallmentImplCopyWithImpl<
          _$DocumentNextInstallmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentNextInstallmentImplToJson(
      this,
    );
  }
}

abstract class _DocumentNextInstallment implements DocumentNextInstallment {
  const factory _DocumentNextInstallment(
      {final String? label,
      required final int remaining,
      required final String dueDate,
      final int? number}) = _$DocumentNextInstallmentImpl;

  factory _DocumentNextInstallment.fromJson(Map<String, dynamic> json) =
      _$DocumentNextInstallmentImpl.fromJson;

  @override
  String? get label;
  @override
  int get remaining;
  @override
  String get dueDate;
  @override
  int? get number;
  @override
  @JsonKey(ignore: true)
  _$$DocumentNextInstallmentImplCopyWith<_$DocumentNextInstallmentImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DocumentScheduleStep _$DocumentScheduleStepFromJson(Map<String, dynamic> json) {
  return _DocumentScheduleStep.fromJson(json);
}

/// @nodoc
mixin _$DocumentScheduleStep {
  String? get label => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  String get dueDate => throw _privateConstructorUsedError;
  int get paid => throw _privateConstructorUsedError;
  int get remaining =>
      throw _privateConstructorUsedError; // PAID, PARTIALLY_PAID, OVERDUE or UNPAID, as the server works it out.
  String get status => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentScheduleStepCopyWith<DocumentScheduleStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentScheduleStepCopyWith<$Res> {
  factory $DocumentScheduleStepCopyWith(DocumentScheduleStep value,
          $Res Function(DocumentScheduleStep) then) =
      _$DocumentScheduleStepCopyWithImpl<$Res, DocumentScheduleStep>;
  @useResult
  $Res call(
      {String? label,
      int amount,
      String dueDate,
      int paid,
      int remaining,
      String status,
      int number});
}

/// @nodoc
class _$DocumentScheduleStepCopyWithImpl<$Res,
        $Val extends DocumentScheduleStep>
    implements $DocumentScheduleStepCopyWith<$Res> {
  _$DocumentScheduleStepCopyWithImpl(this._value, this._then);

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
    Object? paid = null,
    Object? remaining = null,
    Object? status = null,
    Object? number = null,
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
      paid: null == paid
          ? _value.paid
          : paid // ignore: cast_nullable_to_non_nullable
              as int,
      remaining: null == remaining
          ? _value.remaining
          : remaining // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentScheduleStepImplCopyWith<$Res>
    implements $DocumentScheduleStepCopyWith<$Res> {
  factory _$$DocumentScheduleStepImplCopyWith(_$DocumentScheduleStepImpl value,
          $Res Function(_$DocumentScheduleStepImpl) then) =
      __$$DocumentScheduleStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? label,
      int amount,
      String dueDate,
      int paid,
      int remaining,
      String status,
      int number});
}

/// @nodoc
class __$$DocumentScheduleStepImplCopyWithImpl<$Res>
    extends _$DocumentScheduleStepCopyWithImpl<$Res, _$DocumentScheduleStepImpl>
    implements _$$DocumentScheduleStepImplCopyWith<$Res> {
  __$$DocumentScheduleStepImplCopyWithImpl(_$DocumentScheduleStepImpl _value,
      $Res Function(_$DocumentScheduleStepImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = freezed,
    Object? amount = null,
    Object? dueDate = null,
    Object? paid = null,
    Object? remaining = null,
    Object? status = null,
    Object? number = null,
  }) {
    return _then(_$DocumentScheduleStepImpl(
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
      paid: null == paid
          ? _value.paid
          : paid // ignore: cast_nullable_to_non_nullable
              as int,
      remaining: null == remaining
          ? _value.remaining
          : remaining // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentScheduleStepImpl implements _DocumentScheduleStep {
  const _$DocumentScheduleStepImpl(
      {this.label,
      required this.amount,
      required this.dueDate,
      required this.paid,
      required this.remaining,
      required this.status,
      required this.number});

  factory _$DocumentScheduleStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentScheduleStepImplFromJson(json);

  @override
  final String? label;
  @override
  final int amount;
  @override
  final String dueDate;
  @override
  final int paid;
  @override
  final int remaining;
// PAID, PARTIALLY_PAID, OVERDUE or UNPAID, as the server works it out.
  @override
  final String status;
  @override
  final int number;

  @override
  String toString() {
    return 'DocumentScheduleStep(label: $label, amount: $amount, dueDate: $dueDate, paid: $paid, remaining: $remaining, status: $status, number: $number)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentScheduleStepImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.paid, paid) || other.paid == paid) &&
            (identical(other.remaining, remaining) ||
                other.remaining == remaining) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.number, number) || other.number == number));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, label, amount, dueDate, paid, remaining, status, number);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentScheduleStepImplCopyWith<_$DocumentScheduleStepImpl>
      get copyWith =>
          __$$DocumentScheduleStepImplCopyWithImpl<_$DocumentScheduleStepImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentScheduleStepImplToJson(
      this,
    );
  }
}

abstract class _DocumentScheduleStep implements DocumentScheduleStep {
  const factory _DocumentScheduleStep(
      {final String? label,
      required final int amount,
      required final String dueDate,
      required final int paid,
      required final int remaining,
      required final String status,
      required final int number}) = _$DocumentScheduleStepImpl;

  factory _DocumentScheduleStep.fromJson(Map<String, dynamic> json) =
      _$DocumentScheduleStepImpl.fromJson;

  @override
  String? get label;
  @override
  int get amount;
  @override
  String get dueDate;
  @override
  int get paid;
  @override
  int get remaining;
  @override // PAID, PARTIALLY_PAID, OVERDUE or UNPAID, as the server works it out.
  String get status;
  @override
  int get number;
  @override
  @JsonKey(ignore: true)
  _$$DocumentScheduleStepImplCopyWith<_$DocumentScheduleStepImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DocumentAttachment _$DocumentAttachmentFromJson(Map<String, dynamic> json) {
  return _DocumentAttachment.fromJson(json);
}

/// @nodoc
mixin _$DocumentAttachment {
  String get id => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;
  int get sizeBytes => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentAttachmentCopyWith<DocumentAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentAttachmentCopyWith<$Res> {
  factory $DocumentAttachmentCopyWith(
          DocumentAttachment value, $Res Function(DocumentAttachment) then) =
      _$DocumentAttachmentCopyWithImpl<$Res, DocumentAttachment>;
  @useResult
  $Res call(
      {String id,
      String fileName,
      String url,
      String contentType,
      int sizeBytes,
      String createdAt});
}

/// @nodoc
class _$DocumentAttachmentCopyWithImpl<$Res, $Val extends DocumentAttachment>
    implements $DocumentAttachmentCopyWith<$Res> {
  _$DocumentAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? url = null,
    Object? contentType = null,
    Object? sizeBytes = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      sizeBytes: null == sizeBytes
          ? _value.sizeBytes
          : sizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentAttachmentImplCopyWith<$Res>
    implements $DocumentAttachmentCopyWith<$Res> {
  factory _$$DocumentAttachmentImplCopyWith(_$DocumentAttachmentImpl value,
          $Res Function(_$DocumentAttachmentImpl) then) =
      __$$DocumentAttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String fileName,
      String url,
      String contentType,
      int sizeBytes,
      String createdAt});
}

/// @nodoc
class __$$DocumentAttachmentImplCopyWithImpl<$Res>
    extends _$DocumentAttachmentCopyWithImpl<$Res, _$DocumentAttachmentImpl>
    implements _$$DocumentAttachmentImplCopyWith<$Res> {
  __$$DocumentAttachmentImplCopyWithImpl(_$DocumentAttachmentImpl _value,
      $Res Function(_$DocumentAttachmentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? url = null,
    Object? contentType = null,
    Object? sizeBytes = null,
    Object? createdAt = null,
  }) {
    return _then(_$DocumentAttachmentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
      sizeBytes: null == sizeBytes
          ? _value.sizeBytes
          : sizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentAttachmentImpl extends _DocumentAttachment {
  const _$DocumentAttachmentImpl(
      {required this.id,
      required this.fileName,
      required this.url,
      required this.contentType,
      required this.sizeBytes,
      required this.createdAt})
      : super._();

  factory _$DocumentAttachmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentAttachmentImplFromJson(json);

  @override
  final String id;
  @override
  final String fileName;
  @override
  final String url;
  @override
  final String contentType;
  @override
  final int sizeBytes;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'DocumentAttachment(id: $id, fileName: $fileName, url: $url, contentType: $contentType, sizeBytes: $sizeBytes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentAttachmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, fileName, url, contentType, sizeBytes, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentAttachmentImplCopyWith<_$DocumentAttachmentImpl> get copyWith =>
      __$$DocumentAttachmentImplCopyWithImpl<_$DocumentAttachmentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentAttachmentImplToJson(
      this,
    );
  }
}

abstract class _DocumentAttachment extends DocumentAttachment {
  const factory _DocumentAttachment(
      {required final String id,
      required final String fileName,
      required final String url,
      required final String contentType,
      required final int sizeBytes,
      required final String createdAt}) = _$DocumentAttachmentImpl;
  const _DocumentAttachment._() : super._();

  factory _DocumentAttachment.fromJson(Map<String, dynamic> json) =
      _$DocumentAttachmentImpl.fromJson;

  @override
  String get id;
  @override
  String get fileName;
  @override
  String get url;
  @override
  String get contentType;
  @override
  int get sizeBytes;
  @override
  String get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$DocumentAttachmentImplCopyWith<_$DocumentAttachmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DocumentBusinessRef _$DocumentBusinessRefFromJson(Map<String, dynamic> json) {
  return _DocumentBusinessRef.fromJson(json);
}

/// @nodoc
mixin _$DocumentBusinessRef {
  bool get momoEnabled => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentBusinessRefCopyWith<DocumentBusinessRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentBusinessRefCopyWith<$Res> {
  factory $DocumentBusinessRefCopyWith(
          DocumentBusinessRef value, $Res Function(DocumentBusinessRef) then) =
      _$DocumentBusinessRefCopyWithImpl<$Res, DocumentBusinessRef>;
  @useResult
  $Res call({bool momoEnabled});
}

/// @nodoc
class _$DocumentBusinessRefCopyWithImpl<$Res, $Val extends DocumentBusinessRef>
    implements $DocumentBusinessRefCopyWith<$Res> {
  _$DocumentBusinessRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? momoEnabled = null,
  }) {
    return _then(_value.copyWith(
      momoEnabled: null == momoEnabled
          ? _value.momoEnabled
          : momoEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentBusinessRefImplCopyWith<$Res>
    implements $DocumentBusinessRefCopyWith<$Res> {
  factory _$$DocumentBusinessRefImplCopyWith(_$DocumentBusinessRefImpl value,
          $Res Function(_$DocumentBusinessRefImpl) then) =
      __$$DocumentBusinessRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool momoEnabled});
}

/// @nodoc
class __$$DocumentBusinessRefImplCopyWithImpl<$Res>
    extends _$DocumentBusinessRefCopyWithImpl<$Res, _$DocumentBusinessRefImpl>
    implements _$$DocumentBusinessRefImplCopyWith<$Res> {
  __$$DocumentBusinessRefImplCopyWithImpl(_$DocumentBusinessRefImpl _value,
      $Res Function(_$DocumentBusinessRefImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? momoEnabled = null,
  }) {
    return _then(_$DocumentBusinessRefImpl(
      momoEnabled: null == momoEnabled
          ? _value.momoEnabled
          : momoEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentBusinessRefImpl implements _DocumentBusinessRef {
  const _$DocumentBusinessRefImpl({this.momoEnabled = false});

  factory _$DocumentBusinessRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentBusinessRefImplFromJson(json);

  @override
  @JsonKey()
  final bool momoEnabled;

  @override
  String toString() {
    return 'DocumentBusinessRef(momoEnabled: $momoEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentBusinessRefImpl &&
            (identical(other.momoEnabled, momoEnabled) ||
                other.momoEnabled == momoEnabled));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, momoEnabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentBusinessRefImplCopyWith<_$DocumentBusinessRefImpl> get copyWith =>
      __$$DocumentBusinessRefImplCopyWithImpl<_$DocumentBusinessRefImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentBusinessRefImplToJson(
      this,
    );
  }
}

abstract class _DocumentBusinessRef implements DocumentBusinessRef {
  const factory _DocumentBusinessRef({final bool momoEnabled}) =
      _$DocumentBusinessRefImpl;

  factory _DocumentBusinessRef.fromJson(Map<String, dynamic> json) =
      _$DocumentBusinessRefImpl.fromJson;

  @override
  bool get momoEnabled;
  @override
  @JsonKey(ignore: true)
  _$$DocumentBusinessRefImplCopyWith<_$DocumentBusinessRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DocumentCustomerRef _$DocumentCustomerRefFromJson(Map<String, dynamic> json) {
  return _DocumentCustomerRef.fromJson(json);
}

/// @nodoc
mixin _$DocumentCustomerRef {
  String get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentCustomerRefCopyWith<DocumentCustomerRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentCustomerRefCopyWith<$Res> {
  factory $DocumentCustomerRefCopyWith(
          DocumentCustomerRef value, $Res Function(DocumentCustomerRef) then) =
      _$DocumentCustomerRefCopyWithImpl<$Res, DocumentCustomerRef>;
  @useResult
  $Res call({String name, String? email});
}

/// @nodoc
class _$DocumentCustomerRefCopyWithImpl<$Res, $Val extends DocumentCustomerRef>
    implements $DocumentCustomerRefCopyWith<$Res> {
  _$DocumentCustomerRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? email = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentCustomerRefImplCopyWith<$Res>
    implements $DocumentCustomerRefCopyWith<$Res> {
  factory _$$DocumentCustomerRefImplCopyWith(_$DocumentCustomerRefImpl value,
          $Res Function(_$DocumentCustomerRefImpl) then) =
      __$$DocumentCustomerRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? email});
}

/// @nodoc
class __$$DocumentCustomerRefImplCopyWithImpl<$Res>
    extends _$DocumentCustomerRefCopyWithImpl<$Res, _$DocumentCustomerRefImpl>
    implements _$$DocumentCustomerRefImplCopyWith<$Res> {
  __$$DocumentCustomerRefImplCopyWithImpl(_$DocumentCustomerRefImpl _value,
      $Res Function(_$DocumentCustomerRefImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? email = freezed,
  }) {
    return _then(_$DocumentCustomerRefImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentCustomerRefImpl implements _DocumentCustomerRef {
  const _$DocumentCustomerRefImpl({required this.name, this.email});

  factory _$DocumentCustomerRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentCustomerRefImplFromJson(json);

  @override
  final String name;
  @override
  final String? email;

  @override
  String toString() {
    return 'DocumentCustomerRef(name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentCustomerRefImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, email);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentCustomerRefImplCopyWith<_$DocumentCustomerRefImpl> get copyWith =>
      __$$DocumentCustomerRefImplCopyWithImpl<_$DocumentCustomerRefImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentCustomerRefImplToJson(
      this,
    );
  }
}

abstract class _DocumentCustomerRef implements DocumentCustomerRef {
  const factory _DocumentCustomerRef(
      {required final String name,
      final String? email}) = _$DocumentCustomerRefImpl;

  factory _DocumentCustomerRef.fromJson(Map<String, dynamic> json) =
      _$DocumentCustomerRefImpl.fromJson;

  @override
  String get name;
  @override
  String? get email;
  @override
  @JsonKey(ignore: true)
  _$$DocumentCustomerRefImplCopyWith<_$DocumentCustomerRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DocumentLine _$DocumentLineFromJson(Map<String, dynamic> json) {
  return _DocumentLine.fromJson(json);
}

/// @nodoc
mixin _$DocumentLine {
  String get id => throw _privateConstructorUsedError;
  String? get itemId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  double get quantity => throw _privateConstructorUsedError;
  int get unitPrice => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  double get taxRate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
  DiscountType? get discountType => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _nullableDecimalFromJson, toJson: _nullableDecimalToJson)
  double? get discountValue => throw _privateConstructorUsedError;
  int get lineTotal => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentLineCopyWith<DocumentLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentLineCopyWith<$Res> {
  factory $DocumentLineCopyWith(
          DocumentLine value, $Res Function(DocumentLine) then) =
      _$DocumentLineCopyWithImpl<$Res, DocumentLine>;
  @useResult
  $Res call(
      {String id,
      String? itemId,
      String description,
      @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
      double quantity,
      int unitPrice,
      @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
      double taxRate,
      @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
      DiscountType? discountType,
      @JsonKey(
          fromJson: _nullableDecimalFromJson, toJson: _nullableDecimalToJson)
      double? discountValue,
      int lineTotal,
      int sortOrder});
}

/// @nodoc
class _$DocumentLineCopyWithImpl<$Res, $Val extends DocumentLine>
    implements $DocumentLineCopyWith<$Res> {
  _$DocumentLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = freezed,
    Object? description = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? taxRate = null,
    Object? discountType = freezed,
    Object? discountValue = freezed,
    Object? lineTotal = null,
    Object? sortOrder = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      lineTotal: null == lineTotal
          ? _value.lineTotal
          : lineTotal // ignore: cast_nullable_to_non_nullable
              as int,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentLineImplCopyWith<$Res>
    implements $DocumentLineCopyWith<$Res> {
  factory _$$DocumentLineImplCopyWith(
          _$DocumentLineImpl value, $Res Function(_$DocumentLineImpl) then) =
      __$$DocumentLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? itemId,
      String description,
      @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
      double quantity,
      int unitPrice,
      @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
      double taxRate,
      @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
      DiscountType? discountType,
      @JsonKey(
          fromJson: _nullableDecimalFromJson, toJson: _nullableDecimalToJson)
      double? discountValue,
      int lineTotal,
      int sortOrder});
}

/// @nodoc
class __$$DocumentLineImplCopyWithImpl<$Res>
    extends _$DocumentLineCopyWithImpl<$Res, _$DocumentLineImpl>
    implements _$$DocumentLineImplCopyWith<$Res> {
  __$$DocumentLineImplCopyWithImpl(
      _$DocumentLineImpl _value, $Res Function(_$DocumentLineImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = freezed,
    Object? description = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? taxRate = null,
    Object? discountType = freezed,
    Object? discountValue = freezed,
    Object? lineTotal = null,
    Object? sortOrder = null,
  }) {
    return _then(_$DocumentLineImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      lineTotal: null == lineTotal
          ? _value.lineTotal
          : lineTotal // ignore: cast_nullable_to_non_nullable
              as int,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentLineImpl implements _DocumentLine {
  const _$DocumentLineImpl(
      {required this.id,
      this.itemId,
      required this.description,
      @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
      required this.quantity,
      required this.unitPrice,
      @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
      required this.taxRate,
      @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
      this.discountType,
      @JsonKey(
          fromJson: _nullableDecimalFromJson, toJson: _nullableDecimalToJson)
      this.discountValue,
      required this.lineTotal,
      required this.sortOrder});

  factory _$DocumentLineImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentLineImplFromJson(json);

  @override
  final String id;
  @override
  final String? itemId;
  @override
  final String description;
  @override
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  final double quantity;
  @override
  final int unitPrice;
  @override
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  final double taxRate;
  @override
  @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
  final DiscountType? discountType;
  @override
  @JsonKey(fromJson: _nullableDecimalFromJson, toJson: _nullableDecimalToJson)
  final double? discountValue;
  @override
  final int lineTotal;
  @override
  final int sortOrder;

  @override
  String toString() {
    return 'DocumentLine(id: $id, itemId: $itemId, description: $description, quantity: $quantity, unitPrice: $unitPrice, taxRate: $taxRate, discountType: $discountType, discountValue: $discountValue, lineTotal: $lineTotal, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentLineImpl &&
            (identical(other.id, id) || other.id == id) &&
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
                other.discountValue == discountValue) &&
            (identical(other.lineTotal, lineTotal) ||
                other.lineTotal == lineTotal) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      itemId,
      description,
      quantity,
      unitPrice,
      taxRate,
      discountType,
      discountValue,
      lineTotal,
      sortOrder);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentLineImplCopyWith<_$DocumentLineImpl> get copyWith =>
      __$$DocumentLineImplCopyWithImpl<_$DocumentLineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentLineImplToJson(
      this,
    );
  }
}

abstract class _DocumentLine implements DocumentLine {
  const factory _DocumentLine(
      {required final String id,
      final String? itemId,
      required final String description,
      @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
      required final double quantity,
      required final int unitPrice,
      @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
      required final double taxRate,
      @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
      final DiscountType? discountType,
      @JsonKey(
          fromJson: _nullableDecimalFromJson, toJson: _nullableDecimalToJson)
      final double? discountValue,
      required final int lineTotal,
      required final int sortOrder}) = _$DocumentLineImpl;

  factory _DocumentLine.fromJson(Map<String, dynamic> json) =
      _$DocumentLineImpl.fromJson;

  @override
  String get id;
  @override
  String? get itemId;
  @override
  String get description;
  @override
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  double get quantity;
  @override
  int get unitPrice;
  @override
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  double get taxRate;
  @override
  @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson)
  DiscountType? get discountType;
  @override
  @JsonKey(fromJson: _nullableDecimalFromJson, toJson: _nullableDecimalToJson)
  double? get discountValue;
  @override
  int get lineTotal;
  @override
  int get sortOrder;
  @override
  @JsonKey(ignore: true)
  _$$DocumentLineImplCopyWith<_$DocumentLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Document _$DocumentFromJson(Map<String, dynamic> json) {
  return _Document.fromJson(json);
}

/// @nodoc
mixin _$Document {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
  DocumentType get type => throw _privateConstructorUsedError;
  String? get number => throw _privateConstructorUsedError;
  @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson)
  DocumentStatus get status => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  DocumentCustomerRef get customer => throw _privateConstructorUsedError;
  String get issueDate => throw _privateConstructorUsedError;
  String? get dueDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get customerReference => throw _privateConstructorUsedError;
  int get subtotal => throw _privateConstructorUsedError;
  int get taxTotal => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
  Currency get currency => throw _privateConstructorUsedError;
  @JsonKey(fromJson: rateFromJson)
  double? get exchangeRate => throw _privateConstructorUsedError;
  List<DocumentInstallment> get installments =>
      throw _privateConstructorUsedError;
  String? get recurrenceInterval => throw _privateConstructorUsedError;
  String? get recurrenceEndDate => throw _privateConstructorUsedError;
  String? get nextRecurrenceAt => throw _privateConstructorUsedError;
  DocumentNextInstallment? get nextInstallment =>
      throw _privateConstructorUsedError;
  List<DocumentScheduleStep> get schedule => throw _privateConstructorUsedError;
  List<DocumentAttachment> get attachments =>
      throw _privateConstructorUsedError;
  DocumentBusinessRef? get business => throw _privateConstructorUsedError;
  @JsonKey(fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
  DocumentLanguage get language => throw _privateConstructorUsedError;
  String? get sentAt =>
      throw _privateConstructorUsedError; // When the customer opened the public page: first, last, and how many times, as the server counts them.
  String? get firstViewedAt => throw _privateConstructorUsedError;
  String? get lastViewedAt => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  String? get publicToken => throw _privateConstructorUsedError;
  int get amountPaid => throw _privateConstructorUsedError;
  @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
  PaymentStatus? get paymentStatus => throw _privateConstructorUsedError;
  String? get writtenOffAt => throw _privateConstructorUsedError;
  String? get writeOffReason => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  String? get convertedFromId => throw _privateConstructorUsedError;
  String? get referencedDocumentId => throw _privateConstructorUsedError;
  List<DocumentLine> get lines => throw _privateConstructorUsedError;
  DocumentRef? get convertedFrom => throw _privateConstructorUsedError;
  DocumentRef? get convertedTo => throw _privateConstructorUsedError;
  DocumentRef? get referencedDocument => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentCopyWith<Document> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentCopyWith<$Res> {
  factory $DocumentCopyWith(Document value, $Res Function(Document) then) =
      _$DocumentCopyWithImpl<$Res, Document>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      DocumentType type,
      String? number,
      @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson)
      DocumentStatus status,
      String customerId,
      DocumentCustomerRef customer,
      String issueDate,
      String? dueDate,
      String? notes,
      String? customerReference,
      int subtotal,
      int taxTotal,
      int total,
      @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
      Currency currency,
      @JsonKey(fromJson: rateFromJson) double? exchangeRate,
      List<DocumentInstallment> installments,
      String? recurrenceInterval,
      String? recurrenceEndDate,
      String? nextRecurrenceAt,
      DocumentNextInstallment? nextInstallment,
      List<DocumentScheduleStep> schedule,
      List<DocumentAttachment> attachments,
      DocumentBusinessRef? business,
      @JsonKey(
          fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
      DocumentLanguage language,
      String? sentAt,
      String? firstViewedAt,
      String? lastViewedAt,
      int viewCount,
      String? publicToken,
      int amountPaid,
      @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
      PaymentStatus? paymentStatus,
      String? writtenOffAt,
      String? writeOffReason,
      String createdAt,
      String updatedAt,
      String? convertedFromId,
      String? referencedDocumentId,
      List<DocumentLine> lines,
      DocumentRef? convertedFrom,
      DocumentRef? convertedTo,
      DocumentRef? referencedDocument});

  $DocumentCustomerRefCopyWith<$Res> get customer;
  $DocumentNextInstallmentCopyWith<$Res>? get nextInstallment;
  $DocumentBusinessRefCopyWith<$Res>? get business;
  $DocumentRefCopyWith<$Res>? get convertedFrom;
  $DocumentRefCopyWith<$Res>? get convertedTo;
  $DocumentRefCopyWith<$Res>? get referencedDocument;
}

/// @nodoc
class _$DocumentCopyWithImpl<$Res, $Val extends Document>
    implements $DocumentCopyWith<$Res> {
  _$DocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? number = freezed,
    Object? status = null,
    Object? customerId = null,
    Object? customer = null,
    Object? issueDate = null,
    Object? dueDate = freezed,
    Object? notes = freezed,
    Object? customerReference = freezed,
    Object? subtotal = null,
    Object? taxTotal = null,
    Object? total = null,
    Object? currency = null,
    Object? exchangeRate = freezed,
    Object? installments = null,
    Object? recurrenceInterval = freezed,
    Object? recurrenceEndDate = freezed,
    Object? nextRecurrenceAt = freezed,
    Object? nextInstallment = freezed,
    Object? schedule = null,
    Object? attachments = null,
    Object? business = freezed,
    Object? language = null,
    Object? sentAt = freezed,
    Object? firstViewedAt = freezed,
    Object? lastViewedAt = freezed,
    Object? viewCount = null,
    Object? publicToken = freezed,
    Object? amountPaid = null,
    Object? paymentStatus = freezed,
    Object? writtenOffAt = freezed,
    Object? writeOffReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? convertedFromId = freezed,
    Object? referencedDocumentId = freezed,
    Object? lines = null,
    Object? convertedFrom = freezed,
    Object? convertedTo = freezed,
    Object? referencedDocument = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DocumentType,
      number: freezed == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DocumentStatus,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      customer: null == customer
          ? _value.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as DocumentCustomerRef,
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
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as int,
      taxTotal: null == taxTotal
          ? _value.taxTotal
          : taxTotal // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as Currency,
      exchangeRate: freezed == exchangeRate
          ? _value.exchangeRate
          : exchangeRate // ignore: cast_nullable_to_non_nullable
              as double?,
      installments: null == installments
          ? _value.installments
          : installments // ignore: cast_nullable_to_non_nullable
              as List<DocumentInstallment>,
      recurrenceInterval: freezed == recurrenceInterval
          ? _value.recurrenceInterval
          : recurrenceInterval // ignore: cast_nullable_to_non_nullable
              as String?,
      recurrenceEndDate: freezed == recurrenceEndDate
          ? _value.recurrenceEndDate
          : recurrenceEndDate // ignore: cast_nullable_to_non_nullable
              as String?,
      nextRecurrenceAt: freezed == nextRecurrenceAt
          ? _value.nextRecurrenceAt
          : nextRecurrenceAt // ignore: cast_nullable_to_non_nullable
              as String?,
      nextInstallment: freezed == nextInstallment
          ? _value.nextInstallment
          : nextInstallment // ignore: cast_nullable_to_non_nullable
              as DocumentNextInstallment?,
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as List<DocumentScheduleStep>,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<DocumentAttachment>,
      business: freezed == business
          ? _value.business
          : business // ignore: cast_nullable_to_non_nullable
              as DocumentBusinessRef?,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as DocumentLanguage,
      sentAt: freezed == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as String?,
      firstViewedAt: freezed == firstViewedAt
          ? _value.firstViewedAt
          : firstViewedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      lastViewedAt: freezed == lastViewedAt
          ? _value.lastViewedAt
          : lastViewedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      publicToken: freezed == publicToken
          ? _value.publicToken
          : publicToken // ignore: cast_nullable_to_non_nullable
              as String?,
      amountPaid: null == amountPaid
          ? _value.amountPaid
          : amountPaid // ignore: cast_nullable_to_non_nullable
              as int,
      paymentStatus: freezed == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus?,
      writtenOffAt: freezed == writtenOffAt
          ? _value.writtenOffAt
          : writtenOffAt // ignore: cast_nullable_to_non_nullable
              as String?,
      writeOffReason: freezed == writeOffReason
          ? _value.writeOffReason
          : writeOffReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      convertedFromId: freezed == convertedFromId
          ? _value.convertedFromId
          : convertedFromId // ignore: cast_nullable_to_non_nullable
              as String?,
      referencedDocumentId: freezed == referencedDocumentId
          ? _value.referencedDocumentId
          : referencedDocumentId // ignore: cast_nullable_to_non_nullable
              as String?,
      lines: null == lines
          ? _value.lines
          : lines // ignore: cast_nullable_to_non_nullable
              as List<DocumentLine>,
      convertedFrom: freezed == convertedFrom
          ? _value.convertedFrom
          : convertedFrom // ignore: cast_nullable_to_non_nullable
              as DocumentRef?,
      convertedTo: freezed == convertedTo
          ? _value.convertedTo
          : convertedTo // ignore: cast_nullable_to_non_nullable
              as DocumentRef?,
      referencedDocument: freezed == referencedDocument
          ? _value.referencedDocument
          : referencedDocument // ignore: cast_nullable_to_non_nullable
              as DocumentRef?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DocumentCustomerRefCopyWith<$Res> get customer {
    return $DocumentCustomerRefCopyWith<$Res>(_value.customer, (value) {
      return _then(_value.copyWith(customer: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DocumentNextInstallmentCopyWith<$Res>? get nextInstallment {
    if (_value.nextInstallment == null) {
      return null;
    }

    return $DocumentNextInstallmentCopyWith<$Res>(_value.nextInstallment!,
        (value) {
      return _then(_value.copyWith(nextInstallment: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DocumentBusinessRefCopyWith<$Res>? get business {
    if (_value.business == null) {
      return null;
    }

    return $DocumentBusinessRefCopyWith<$Res>(_value.business!, (value) {
      return _then(_value.copyWith(business: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DocumentRefCopyWith<$Res>? get convertedFrom {
    if (_value.convertedFrom == null) {
      return null;
    }

    return $DocumentRefCopyWith<$Res>(_value.convertedFrom!, (value) {
      return _then(_value.copyWith(convertedFrom: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DocumentRefCopyWith<$Res>? get convertedTo {
    if (_value.convertedTo == null) {
      return null;
    }

    return $DocumentRefCopyWith<$Res>(_value.convertedTo!, (value) {
      return _then(_value.copyWith(convertedTo: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DocumentRefCopyWith<$Res>? get referencedDocument {
    if (_value.referencedDocument == null) {
      return null;
    }

    return $DocumentRefCopyWith<$Res>(_value.referencedDocument!, (value) {
      return _then(_value.copyWith(referencedDocument: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DocumentImplCopyWith<$Res>
    implements $DocumentCopyWith<$Res> {
  factory _$$DocumentImplCopyWith(
          _$DocumentImpl value, $Res Function(_$DocumentImpl) then) =
      __$$DocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      DocumentType type,
      String? number,
      @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson)
      DocumentStatus status,
      String customerId,
      DocumentCustomerRef customer,
      String issueDate,
      String? dueDate,
      String? notes,
      String? customerReference,
      int subtotal,
      int taxTotal,
      int total,
      @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
      Currency currency,
      @JsonKey(fromJson: rateFromJson) double? exchangeRate,
      List<DocumentInstallment> installments,
      String? recurrenceInterval,
      String? recurrenceEndDate,
      String? nextRecurrenceAt,
      DocumentNextInstallment? nextInstallment,
      List<DocumentScheduleStep> schedule,
      List<DocumentAttachment> attachments,
      DocumentBusinessRef? business,
      @JsonKey(
          fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
      DocumentLanguage language,
      String? sentAt,
      String? firstViewedAt,
      String? lastViewedAt,
      int viewCount,
      String? publicToken,
      int amountPaid,
      @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
      PaymentStatus? paymentStatus,
      String? writtenOffAt,
      String? writeOffReason,
      String createdAt,
      String updatedAt,
      String? convertedFromId,
      String? referencedDocumentId,
      List<DocumentLine> lines,
      DocumentRef? convertedFrom,
      DocumentRef? convertedTo,
      DocumentRef? referencedDocument});

  @override
  $DocumentCustomerRefCopyWith<$Res> get customer;
  @override
  $DocumentNextInstallmentCopyWith<$Res>? get nextInstallment;
  @override
  $DocumentBusinessRefCopyWith<$Res>? get business;
  @override
  $DocumentRefCopyWith<$Res>? get convertedFrom;
  @override
  $DocumentRefCopyWith<$Res>? get convertedTo;
  @override
  $DocumentRefCopyWith<$Res>? get referencedDocument;
}

/// @nodoc
class __$$DocumentImplCopyWithImpl<$Res>
    extends _$DocumentCopyWithImpl<$Res, _$DocumentImpl>
    implements _$$DocumentImplCopyWith<$Res> {
  __$$DocumentImplCopyWithImpl(
      _$DocumentImpl _value, $Res Function(_$DocumentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? number = freezed,
    Object? status = null,
    Object? customerId = null,
    Object? customer = null,
    Object? issueDate = null,
    Object? dueDate = freezed,
    Object? notes = freezed,
    Object? customerReference = freezed,
    Object? subtotal = null,
    Object? taxTotal = null,
    Object? total = null,
    Object? currency = null,
    Object? exchangeRate = freezed,
    Object? installments = null,
    Object? recurrenceInterval = freezed,
    Object? recurrenceEndDate = freezed,
    Object? nextRecurrenceAt = freezed,
    Object? nextInstallment = freezed,
    Object? schedule = null,
    Object? attachments = null,
    Object? business = freezed,
    Object? language = null,
    Object? sentAt = freezed,
    Object? firstViewedAt = freezed,
    Object? lastViewedAt = freezed,
    Object? viewCount = null,
    Object? publicToken = freezed,
    Object? amountPaid = null,
    Object? paymentStatus = freezed,
    Object? writtenOffAt = freezed,
    Object? writeOffReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? convertedFromId = freezed,
    Object? referencedDocumentId = freezed,
    Object? lines = null,
    Object? convertedFrom = freezed,
    Object? convertedTo = freezed,
    Object? referencedDocument = freezed,
  }) {
    return _then(_$DocumentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DocumentType,
      number: freezed == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DocumentStatus,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      customer: null == customer
          ? _value.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as DocumentCustomerRef,
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
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as int,
      taxTotal: null == taxTotal
          ? _value.taxTotal
          : taxTotal // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as Currency,
      exchangeRate: freezed == exchangeRate
          ? _value.exchangeRate
          : exchangeRate // ignore: cast_nullable_to_non_nullable
              as double?,
      installments: null == installments
          ? _value._installments
          : installments // ignore: cast_nullable_to_non_nullable
              as List<DocumentInstallment>,
      recurrenceInterval: freezed == recurrenceInterval
          ? _value.recurrenceInterval
          : recurrenceInterval // ignore: cast_nullable_to_non_nullable
              as String?,
      recurrenceEndDate: freezed == recurrenceEndDate
          ? _value.recurrenceEndDate
          : recurrenceEndDate // ignore: cast_nullable_to_non_nullable
              as String?,
      nextRecurrenceAt: freezed == nextRecurrenceAt
          ? _value.nextRecurrenceAt
          : nextRecurrenceAt // ignore: cast_nullable_to_non_nullable
              as String?,
      nextInstallment: freezed == nextInstallment
          ? _value.nextInstallment
          : nextInstallment // ignore: cast_nullable_to_non_nullable
              as DocumentNextInstallment?,
      schedule: null == schedule
          ? _value._schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as List<DocumentScheduleStep>,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<DocumentAttachment>,
      business: freezed == business
          ? _value.business
          : business // ignore: cast_nullable_to_non_nullable
              as DocumentBusinessRef?,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as DocumentLanguage,
      sentAt: freezed == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as String?,
      firstViewedAt: freezed == firstViewedAt
          ? _value.firstViewedAt
          : firstViewedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      lastViewedAt: freezed == lastViewedAt
          ? _value.lastViewedAt
          : lastViewedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      publicToken: freezed == publicToken
          ? _value.publicToken
          : publicToken // ignore: cast_nullable_to_non_nullable
              as String?,
      amountPaid: null == amountPaid
          ? _value.amountPaid
          : amountPaid // ignore: cast_nullable_to_non_nullable
              as int,
      paymentStatus: freezed == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus?,
      writtenOffAt: freezed == writtenOffAt
          ? _value.writtenOffAt
          : writtenOffAt // ignore: cast_nullable_to_non_nullable
              as String?,
      writeOffReason: freezed == writeOffReason
          ? _value.writeOffReason
          : writeOffReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      convertedFromId: freezed == convertedFromId
          ? _value.convertedFromId
          : convertedFromId // ignore: cast_nullable_to_non_nullable
              as String?,
      referencedDocumentId: freezed == referencedDocumentId
          ? _value.referencedDocumentId
          : referencedDocumentId // ignore: cast_nullable_to_non_nullable
              as String?,
      lines: null == lines
          ? _value._lines
          : lines // ignore: cast_nullable_to_non_nullable
              as List<DocumentLine>,
      convertedFrom: freezed == convertedFrom
          ? _value.convertedFrom
          : convertedFrom // ignore: cast_nullable_to_non_nullable
              as DocumentRef?,
      convertedTo: freezed == convertedTo
          ? _value.convertedTo
          : convertedTo // ignore: cast_nullable_to_non_nullable
              as DocumentRef?,
      referencedDocument: freezed == referencedDocument
          ? _value.referencedDocument
          : referencedDocument // ignore: cast_nullable_to_non_nullable
              as DocumentRef?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentImpl implements _Document {
  const _$DocumentImpl(
      {required this.id,
      @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      required this.type,
      this.number,
      @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson)
      required this.status,
      required this.customerId,
      required this.customer,
      required this.issueDate,
      this.dueDate,
      this.notes,
      this.customerReference,
      required this.subtotal,
      required this.taxTotal,
      required this.total,
      @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
      this.currency = Currency.rwf,
      @JsonKey(fromJson: rateFromJson) this.exchangeRate,
      final List<DocumentInstallment> installments =
          const <DocumentInstallment>[],
      this.recurrenceInterval,
      this.recurrenceEndDate,
      this.nextRecurrenceAt,
      this.nextInstallment,
      final List<DocumentScheduleStep> schedule =
          const <DocumentScheduleStep>[],
      final List<DocumentAttachment> attachments = const <DocumentAttachment>[],
      this.business,
      @JsonKey(
          fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
      this.language = DocumentLanguage.en,
      this.sentAt,
      this.firstViewedAt,
      this.lastViewedAt,
      this.viewCount = 0,
      this.publicToken,
      required this.amountPaid,
      @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
      this.paymentStatus,
      this.writtenOffAt,
      this.writeOffReason,
      required this.createdAt,
      required this.updatedAt,
      this.convertedFromId,
      this.referencedDocumentId,
      final List<DocumentLine> lines = const <DocumentLine>[],
      this.convertedFrom,
      this.convertedTo,
      this.referencedDocument})
      : _installments = installments,
        _schedule = schedule,
        _attachments = attachments,
        _lines = lines;

  factory _$DocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
  final DocumentType type;
  @override
  final String? number;
  @override
  @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson)
  final DocumentStatus status;
  @override
  final String customerId;
  @override
  final DocumentCustomerRef customer;
  @override
  final String issueDate;
  @override
  final String? dueDate;
  @override
  final String? notes;
  @override
  final String? customerReference;
  @override
  final int subtotal;
  @override
  final int taxTotal;
  @override
  final int total;
  @override
  @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
  final Currency currency;
  @override
  @JsonKey(fromJson: rateFromJson)
  final double? exchangeRate;
  final List<DocumentInstallment> _installments;
  @override
  @JsonKey()
  List<DocumentInstallment> get installments {
    if (_installments is EqualUnmodifiableListView) return _installments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_installments);
  }

  @override
  final String? recurrenceInterval;
  @override
  final String? recurrenceEndDate;
  @override
  final String? nextRecurrenceAt;
  @override
  final DocumentNextInstallment? nextInstallment;
  final List<DocumentScheduleStep> _schedule;
  @override
  @JsonKey()
  List<DocumentScheduleStep> get schedule {
    if (_schedule is EqualUnmodifiableListView) return _schedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedule);
  }

  final List<DocumentAttachment> _attachments;
  @override
  @JsonKey()
  List<DocumentAttachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  final DocumentBusinessRef? business;
  @override
  @JsonKey(fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
  final DocumentLanguage language;
  @override
  final String? sentAt;
// When the customer opened the public page: first, last, and how many times, as the server counts them.
  @override
  final String? firstViewedAt;
  @override
  final String? lastViewedAt;
  @override
  @JsonKey()
  final int viewCount;
  @override
  final String? publicToken;
  @override
  final int amountPaid;
  @override
  @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
  final PaymentStatus? paymentStatus;
  @override
  final String? writtenOffAt;
  @override
  final String? writeOffReason;
  @override
  final String createdAt;
  @override
  final String updatedAt;
  @override
  final String? convertedFromId;
  @override
  final String? referencedDocumentId;
  final List<DocumentLine> _lines;
  @override
  @JsonKey()
  List<DocumentLine> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  final DocumentRef? convertedFrom;
  @override
  final DocumentRef? convertedTo;
  @override
  final DocumentRef? referencedDocument;

  @override
  String toString() {
    return 'Document(id: $id, type: $type, number: $number, status: $status, customerId: $customerId, customer: $customer, issueDate: $issueDate, dueDate: $dueDate, notes: $notes, customerReference: $customerReference, subtotal: $subtotal, taxTotal: $taxTotal, total: $total, currency: $currency, exchangeRate: $exchangeRate, installments: $installments, recurrenceInterval: $recurrenceInterval, recurrenceEndDate: $recurrenceEndDate, nextRecurrenceAt: $nextRecurrenceAt, nextInstallment: $nextInstallment, schedule: $schedule, attachments: $attachments, business: $business, language: $language, sentAt: $sentAt, firstViewedAt: $firstViewedAt, lastViewedAt: $lastViewedAt, viewCount: $viewCount, publicToken: $publicToken, amountPaid: $amountPaid, paymentStatus: $paymentStatus, writtenOffAt: $writtenOffAt, writeOffReason: $writeOffReason, createdAt: $createdAt, updatedAt: $updatedAt, convertedFromId: $convertedFromId, referencedDocumentId: $referencedDocumentId, lines: $lines, convertedFrom: $convertedFrom, convertedTo: $convertedTo, referencedDocument: $referencedDocument)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.issueDate, issueDate) ||
                other.issueDate == issueDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.customerReference, customerReference) ||
                other.customerReference == customerReference) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.taxTotal, taxTotal) ||
                other.taxTotal == taxTotal) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.exchangeRate, exchangeRate) ||
                other.exchangeRate == exchangeRate) &&
            const DeepCollectionEquality()
                .equals(other._installments, _installments) &&
            (identical(other.recurrenceInterval, recurrenceInterval) ||
                other.recurrenceInterval == recurrenceInterval) &&
            (identical(other.recurrenceEndDate, recurrenceEndDate) ||
                other.recurrenceEndDate == recurrenceEndDate) &&
            (identical(other.nextRecurrenceAt, nextRecurrenceAt) ||
                other.nextRecurrenceAt == nextRecurrenceAt) &&
            (identical(other.nextInstallment, nextInstallment) ||
                other.nextInstallment == nextInstallment) &&
            const DeepCollectionEquality().equals(other._schedule, _schedule) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.business, business) ||
                other.business == business) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.firstViewedAt, firstViewedAt) ||
                other.firstViewedAt == firstViewedAt) &&
            (identical(other.lastViewedAt, lastViewedAt) ||
                other.lastViewedAt == lastViewedAt) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.publicToken, publicToken) ||
                other.publicToken == publicToken) &&
            (identical(other.amountPaid, amountPaid) ||
                other.amountPaid == amountPaid) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.writtenOffAt, writtenOffAt) ||
                other.writtenOffAt == writtenOffAt) &&
            (identical(other.writeOffReason, writeOffReason) ||
                other.writeOffReason == writeOffReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.convertedFromId, convertedFromId) ||
                other.convertedFromId == convertedFromId) &&
            (identical(other.referencedDocumentId, referencedDocumentId) ||
                other.referencedDocumentId == referencedDocumentId) &&
            const DeepCollectionEquality().equals(other._lines, _lines) &&
            (identical(other.convertedFrom, convertedFrom) ||
                other.convertedFrom == convertedFrom) &&
            (identical(other.convertedTo, convertedTo) ||
                other.convertedTo == convertedTo) &&
            (identical(other.referencedDocument, referencedDocument) ||
                other.referencedDocument == referencedDocument));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        type,
        number,
        status,
        customerId,
        customer,
        issueDate,
        dueDate,
        notes,
        customerReference,
        subtotal,
        taxTotal,
        total,
        currency,
        exchangeRate,
        const DeepCollectionEquality().hash(_installments),
        recurrenceInterval,
        recurrenceEndDate,
        nextRecurrenceAt,
        nextInstallment,
        const DeepCollectionEquality().hash(_schedule),
        const DeepCollectionEquality().hash(_attachments),
        business,
        language,
        sentAt,
        firstViewedAt,
        lastViewedAt,
        viewCount,
        publicToken,
        amountPaid,
        paymentStatus,
        writtenOffAt,
        writeOffReason,
        createdAt,
        updatedAt,
        convertedFromId,
        referencedDocumentId,
        const DeepCollectionEquality().hash(_lines),
        convertedFrom,
        convertedTo,
        referencedDocument
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentImplCopyWith<_$DocumentImpl> get copyWith =>
      __$$DocumentImplCopyWithImpl<_$DocumentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentImplToJson(
      this,
    );
  }
}

abstract class _Document implements Document {
  const factory _Document(
      {required final String id,
      @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      required final DocumentType type,
      final String? number,
      @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson)
      required final DocumentStatus status,
      required final String customerId,
      required final DocumentCustomerRef customer,
      required final String issueDate,
      final String? dueDate,
      final String? notes,
      final String? customerReference,
      required final int subtotal,
      required final int taxTotal,
      required final int total,
      @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
      final Currency currency,
      @JsonKey(fromJson: rateFromJson) final double? exchangeRate,
      final List<DocumentInstallment> installments,
      final String? recurrenceInterval,
      final String? recurrenceEndDate,
      final String? nextRecurrenceAt,
      final DocumentNextInstallment? nextInstallment,
      final List<DocumentScheduleStep> schedule,
      final List<DocumentAttachment> attachments,
      final DocumentBusinessRef? business,
      @JsonKey(
          fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
      final DocumentLanguage language,
      final String? sentAt,
      final String? firstViewedAt,
      final String? lastViewedAt,
      final int viewCount,
      final String? publicToken,
      required final int amountPaid,
      @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
      final PaymentStatus? paymentStatus,
      final String? writtenOffAt,
      final String? writeOffReason,
      required final String createdAt,
      required final String updatedAt,
      final String? convertedFromId,
      final String? referencedDocumentId,
      final List<DocumentLine> lines,
      final DocumentRef? convertedFrom,
      final DocumentRef? convertedTo,
      final DocumentRef? referencedDocument}) = _$DocumentImpl;

  factory _Document.fromJson(Map<String, dynamic> json) =
      _$DocumentImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
  DocumentType get type;
  @override
  String? get number;
  @override
  @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson)
  DocumentStatus get status;
  @override
  String get customerId;
  @override
  DocumentCustomerRef get customer;
  @override
  String get issueDate;
  @override
  String? get dueDate;
  @override
  String? get notes;
  @override
  String? get customerReference;
  @override
  int get subtotal;
  @override
  int get taxTotal;
  @override
  int get total;
  @override
  @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
  Currency get currency;
  @override
  @JsonKey(fromJson: rateFromJson)
  double? get exchangeRate;
  @override
  List<DocumentInstallment> get installments;
  @override
  String? get recurrenceInterval;
  @override
  String? get recurrenceEndDate;
  @override
  String? get nextRecurrenceAt;
  @override
  DocumentNextInstallment? get nextInstallment;
  @override
  List<DocumentScheduleStep> get schedule;
  @override
  List<DocumentAttachment> get attachments;
  @override
  DocumentBusinessRef? get business;
  @override
  @JsonKey(fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
  DocumentLanguage get language;
  @override
  String? get sentAt;
  @override // When the customer opened the public page: first, last, and how many times, as the server counts them.
  String? get firstViewedAt;
  @override
  String? get lastViewedAt;
  @override
  int get viewCount;
  @override
  String? get publicToken;
  @override
  int get amountPaid;
  @override
  @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
  PaymentStatus? get paymentStatus;
  @override
  String? get writtenOffAt;
  @override
  String? get writeOffReason;
  @override
  String get createdAt;
  @override
  String get updatedAt;
  @override
  String? get convertedFromId;
  @override
  String? get referencedDocumentId;
  @override
  List<DocumentLine> get lines;
  @override
  DocumentRef? get convertedFrom;
  @override
  DocumentRef? get convertedTo;
  @override
  DocumentRef? get referencedDocument;
  @override
  @JsonKey(ignore: true)
  _$$DocumentImplCopyWith<_$DocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
