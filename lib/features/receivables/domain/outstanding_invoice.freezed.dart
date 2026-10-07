// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outstanding_invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OutstandingInvoice _$OutstandingInvoiceFromJson(Map<String, dynamic> json) {
  return _OutstandingInvoice.fromJson(json);
}

/// @nodoc
mixin _$OutstandingInvoice {
  String get id => throw _privateConstructorUsedError;
  String? get number => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get amountOwed => throw _privateConstructorUsedError;
  String? get dueDate => throw _privateConstructorUsedError;
  int get daysOverdue => throw _privateConstructorUsedError;
  String get agingBucket => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OutstandingInvoiceCopyWith<OutstandingInvoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutstandingInvoiceCopyWith<$Res> {
  factory $OutstandingInvoiceCopyWith(
          OutstandingInvoice value, $Res Function(OutstandingInvoice) then) =
      _$OutstandingInvoiceCopyWithImpl<$Res, OutstandingInvoice>;
  @useResult
  $Res call(
      {String id,
      String? number,
      String customerName,
      int total,
      int amountOwed,
      String? dueDate,
      int daysOverdue,
      String agingBucket});
}

/// @nodoc
class _$OutstandingInvoiceCopyWithImpl<$Res, $Val extends OutstandingInvoice>
    implements $OutstandingInvoiceCopyWith<$Res> {
  _$OutstandingInvoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = freezed,
    Object? customerName = null,
    Object? total = null,
    Object? amountOwed = null,
    Object? dueDate = freezed,
    Object? daysOverdue = null,
    Object? agingBucket = null,
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
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      amountOwed: null == amountOwed
          ? _value.amountOwed
          : amountOwed // ignore: cast_nullable_to_non_nullable
              as int,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as String?,
      daysOverdue: null == daysOverdue
          ? _value.daysOverdue
          : daysOverdue // ignore: cast_nullable_to_non_nullable
              as int,
      agingBucket: null == agingBucket
          ? _value.agingBucket
          : agingBucket // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OutstandingInvoiceImplCopyWith<$Res>
    implements $OutstandingInvoiceCopyWith<$Res> {
  factory _$$OutstandingInvoiceImplCopyWith(_$OutstandingInvoiceImpl value,
          $Res Function(_$OutstandingInvoiceImpl) then) =
      __$$OutstandingInvoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? number,
      String customerName,
      int total,
      int amountOwed,
      String? dueDate,
      int daysOverdue,
      String agingBucket});
}

/// @nodoc
class __$$OutstandingInvoiceImplCopyWithImpl<$Res>
    extends _$OutstandingInvoiceCopyWithImpl<$Res, _$OutstandingInvoiceImpl>
    implements _$$OutstandingInvoiceImplCopyWith<$Res> {
  __$$OutstandingInvoiceImplCopyWithImpl(_$OutstandingInvoiceImpl _value,
      $Res Function(_$OutstandingInvoiceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = freezed,
    Object? customerName = null,
    Object? total = null,
    Object? amountOwed = null,
    Object? dueDate = freezed,
    Object? daysOverdue = null,
    Object? agingBucket = null,
  }) {
    return _then(_$OutstandingInvoiceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      number: freezed == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      amountOwed: null == amountOwed
          ? _value.amountOwed
          : amountOwed // ignore: cast_nullable_to_non_nullable
              as int,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as String?,
      daysOverdue: null == daysOverdue
          ? _value.daysOverdue
          : daysOverdue // ignore: cast_nullable_to_non_nullable
              as int,
      agingBucket: null == agingBucket
          ? _value.agingBucket
          : agingBucket // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OutstandingInvoiceImpl implements _OutstandingInvoice {
  const _$OutstandingInvoiceImpl(
      {required this.id,
      this.number,
      required this.customerName,
      required this.total,
      required this.amountOwed,
      this.dueDate,
      required this.daysOverdue,
      required this.agingBucket});

  factory _$OutstandingInvoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutstandingInvoiceImplFromJson(json);

  @override
  final String id;
  @override
  final String? number;
  @override
  final String customerName;
  @override
  final int total;
  @override
  final int amountOwed;
  @override
  final String? dueDate;
  @override
  final int daysOverdue;
  @override
  final String agingBucket;

  @override
  String toString() {
    return 'OutstandingInvoice(id: $id, number: $number, customerName: $customerName, total: $total, amountOwed: $amountOwed, dueDate: $dueDate, daysOverdue: $daysOverdue, agingBucket: $agingBucket)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutstandingInvoiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.amountOwed, amountOwed) ||
                other.amountOwed == amountOwed) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.daysOverdue, daysOverdue) ||
                other.daysOverdue == daysOverdue) &&
            (identical(other.agingBucket, agingBucket) ||
                other.agingBucket == agingBucket));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, number, customerName, total,
      amountOwed, dueDate, daysOverdue, agingBucket);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OutstandingInvoiceImplCopyWith<_$OutstandingInvoiceImpl> get copyWith =>
      __$$OutstandingInvoiceImplCopyWithImpl<_$OutstandingInvoiceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutstandingInvoiceImplToJson(
      this,
    );
  }
}

abstract class _OutstandingInvoice implements OutstandingInvoice {
  const factory _OutstandingInvoice(
      {required final String id,
      final String? number,
      required final String customerName,
      required final int total,
      required final int amountOwed,
      final String? dueDate,
      required final int daysOverdue,
      required final String agingBucket}) = _$OutstandingInvoiceImpl;

  factory _OutstandingInvoice.fromJson(Map<String, dynamic> json) =
      _$OutstandingInvoiceImpl.fromJson;

  @override
  String get id;
  @override
  String? get number;
  @override
  String get customerName;
  @override
  int get total;
  @override
  int get amountOwed;
  @override
  String? get dueDate;
  @override
  int get daysOverdue;
  @override
  String get agingBucket;
  @override
  @JsonKey(ignore: true)
  _$$OutstandingInvoiceImplCopyWith<_$OutstandingInvoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
