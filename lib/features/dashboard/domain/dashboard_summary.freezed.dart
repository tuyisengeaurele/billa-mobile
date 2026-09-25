// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecentDocument _$RecentDocumentFromJson(Map<String, dynamic> json) {
  return _RecentDocument.fromJson(json);
}

/// @nodoc
mixin _$RecentDocument {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
  DocumentType get type => throw _privateConstructorUsedError;
  String? get number => throw _privateConstructorUsedError;
  @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson)
  DocumentStatus get status => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get issueDate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
  PaymentStatus? get paymentStatus => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecentDocumentCopyWith<RecentDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentDocumentCopyWith<$Res> {
  factory $RecentDocumentCopyWith(
          RecentDocument value, $Res Function(RecentDocument) then) =
      _$RecentDocumentCopyWithImpl<$Res, RecentDocument>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      DocumentType type,
      String? number,
      @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson)
      DocumentStatus status,
      String customerName,
      String issueDate,
      @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
      PaymentStatus? paymentStatus});
}

/// @nodoc
class _$RecentDocumentCopyWithImpl<$Res, $Val extends RecentDocument>
    implements $RecentDocumentCopyWith<$Res> {
  _$RecentDocumentCopyWithImpl(this._value, this._then);

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
    Object? customerName = null,
    Object? issueDate = null,
    Object? paymentStatus = freezed,
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
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      issueDate: null == issueDate
          ? _value.issueDate
          : issueDate // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: freezed == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecentDocumentImplCopyWith<$Res>
    implements $RecentDocumentCopyWith<$Res> {
  factory _$$RecentDocumentImplCopyWith(_$RecentDocumentImpl value,
          $Res Function(_$RecentDocumentImpl) then) =
      __$$RecentDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      DocumentType type,
      String? number,
      @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson)
      DocumentStatus status,
      String customerName,
      String issueDate,
      @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
      PaymentStatus? paymentStatus});
}

/// @nodoc
class __$$RecentDocumentImplCopyWithImpl<$Res>
    extends _$RecentDocumentCopyWithImpl<$Res, _$RecentDocumentImpl>
    implements _$$RecentDocumentImplCopyWith<$Res> {
  __$$RecentDocumentImplCopyWithImpl(
      _$RecentDocumentImpl _value, $Res Function(_$RecentDocumentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? number = freezed,
    Object? status = null,
    Object? customerName = null,
    Object? issueDate = null,
    Object? paymentStatus = freezed,
  }) {
    return _then(_$RecentDocumentImpl(
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
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      issueDate: null == issueDate
          ? _value.issueDate
          : issueDate // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: freezed == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecentDocumentImpl implements _RecentDocument {
  const _$RecentDocumentImpl(
      {required this.id,
      @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      required this.type,
      this.number,
      @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson)
      required this.status,
      required this.customerName,
      required this.issueDate,
      @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
      this.paymentStatus});

  factory _$RecentDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecentDocumentImplFromJson(json);

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
  final String customerName;
  @override
  final String issueDate;
  @override
  @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
  final PaymentStatus? paymentStatus;

  @override
  String toString() {
    return 'RecentDocument(id: $id, type: $type, number: $number, status: $status, customerName: $customerName, issueDate: $issueDate, paymentStatus: $paymentStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentDocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.issueDate, issueDate) ||
                other.issueDate == issueDate) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, number, status,
      customerName, issueDate, paymentStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentDocumentImplCopyWith<_$RecentDocumentImpl> get copyWith =>
      __$$RecentDocumentImplCopyWithImpl<_$RecentDocumentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecentDocumentImplToJson(
      this,
    );
  }
}

abstract class _RecentDocument implements RecentDocument {
  const factory _RecentDocument(
      {required final String id,
      @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      required final DocumentType type,
      final String? number,
      @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson)
      required final DocumentStatus status,
      required final String customerName,
      required final String issueDate,
      @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
      final PaymentStatus? paymentStatus}) = _$RecentDocumentImpl;

  factory _RecentDocument.fromJson(Map<String, dynamic> json) =
      _$RecentDocumentImpl.fromJson;

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
  String get customerName;
  @override
  String get issueDate;
  @override
  @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
  PaymentStatus? get paymentStatus;
  @override
  @JsonKey(ignore: true)
  _$$RecentDocumentImplCopyWith<_$RecentDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DashboardSummary _$DashboardSummaryFromJson(Map<String, dynamic> json) {
  return _DashboardSummary.fromJson(json);
}

/// @nodoc
mixin _$DashboardSummary {
  int get draftCount => throw _privateConstructorUsedError;
  int get overdueInvoiceCount => throw _privateConstructorUsedError;
  int get expiringQuoteCount => throw _privateConstructorUsedError;
  List<RecentDocument> get recentDocuments =>
      throw _privateConstructorUsedError;
  int get documentsThisMonth => throw _privateConstructorUsedError;
  int get documentsLastMonth => throw _privateConstructorUsedError;
  int get customerCount => throw _privateConstructorUsedError;
  bool get hasLogo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardSummaryCopyWith<DashboardSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardSummaryCopyWith<$Res> {
  factory $DashboardSummaryCopyWith(
          DashboardSummary value, $Res Function(DashboardSummary) then) =
      _$DashboardSummaryCopyWithImpl<$Res, DashboardSummary>;
  @useResult
  $Res call(
      {int draftCount,
      int overdueInvoiceCount,
      int expiringQuoteCount,
      List<RecentDocument> recentDocuments,
      int documentsThisMonth,
      int documentsLastMonth,
      int customerCount,
      bool hasLogo});
}

/// @nodoc
class _$DashboardSummaryCopyWithImpl<$Res, $Val extends DashboardSummary>
    implements $DashboardSummaryCopyWith<$Res> {
  _$DashboardSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? draftCount = null,
    Object? overdueInvoiceCount = null,
    Object? expiringQuoteCount = null,
    Object? recentDocuments = null,
    Object? documentsThisMonth = null,
    Object? documentsLastMonth = null,
    Object? customerCount = null,
    Object? hasLogo = null,
  }) {
    return _then(_value.copyWith(
      draftCount: null == draftCount
          ? _value.draftCount
          : draftCount // ignore: cast_nullable_to_non_nullable
              as int,
      overdueInvoiceCount: null == overdueInvoiceCount
          ? _value.overdueInvoiceCount
          : overdueInvoiceCount // ignore: cast_nullable_to_non_nullable
              as int,
      expiringQuoteCount: null == expiringQuoteCount
          ? _value.expiringQuoteCount
          : expiringQuoteCount // ignore: cast_nullable_to_non_nullable
              as int,
      recentDocuments: null == recentDocuments
          ? _value.recentDocuments
          : recentDocuments // ignore: cast_nullable_to_non_nullable
              as List<RecentDocument>,
      documentsThisMonth: null == documentsThisMonth
          ? _value.documentsThisMonth
          : documentsThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      documentsLastMonth: null == documentsLastMonth
          ? _value.documentsLastMonth
          : documentsLastMonth // ignore: cast_nullable_to_non_nullable
              as int,
      customerCount: null == customerCount
          ? _value.customerCount
          : customerCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasLogo: null == hasLogo
          ? _value.hasLogo
          : hasLogo // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardSummaryImplCopyWith<$Res>
    implements $DashboardSummaryCopyWith<$Res> {
  factory _$$DashboardSummaryImplCopyWith(_$DashboardSummaryImpl value,
          $Res Function(_$DashboardSummaryImpl) then) =
      __$$DashboardSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int draftCount,
      int overdueInvoiceCount,
      int expiringQuoteCount,
      List<RecentDocument> recentDocuments,
      int documentsThisMonth,
      int documentsLastMonth,
      int customerCount,
      bool hasLogo});
}

/// @nodoc
class __$$DashboardSummaryImplCopyWithImpl<$Res>
    extends _$DashboardSummaryCopyWithImpl<$Res, _$DashboardSummaryImpl>
    implements _$$DashboardSummaryImplCopyWith<$Res> {
  __$$DashboardSummaryImplCopyWithImpl(_$DashboardSummaryImpl _value,
      $Res Function(_$DashboardSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? draftCount = null,
    Object? overdueInvoiceCount = null,
    Object? expiringQuoteCount = null,
    Object? recentDocuments = null,
    Object? documentsThisMonth = null,
    Object? documentsLastMonth = null,
    Object? customerCount = null,
    Object? hasLogo = null,
  }) {
    return _then(_$DashboardSummaryImpl(
      draftCount: null == draftCount
          ? _value.draftCount
          : draftCount // ignore: cast_nullable_to_non_nullable
              as int,
      overdueInvoiceCount: null == overdueInvoiceCount
          ? _value.overdueInvoiceCount
          : overdueInvoiceCount // ignore: cast_nullable_to_non_nullable
              as int,
      expiringQuoteCount: null == expiringQuoteCount
          ? _value.expiringQuoteCount
          : expiringQuoteCount // ignore: cast_nullable_to_non_nullable
              as int,
      recentDocuments: null == recentDocuments
          ? _value._recentDocuments
          : recentDocuments // ignore: cast_nullable_to_non_nullable
              as List<RecentDocument>,
      documentsThisMonth: null == documentsThisMonth
          ? _value.documentsThisMonth
          : documentsThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      documentsLastMonth: null == documentsLastMonth
          ? _value.documentsLastMonth
          : documentsLastMonth // ignore: cast_nullable_to_non_nullable
              as int,
      customerCount: null == customerCount
          ? _value.customerCount
          : customerCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasLogo: null == hasLogo
          ? _value.hasLogo
          : hasLogo // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardSummaryImpl extends _DashboardSummary {
  const _$DashboardSummaryImpl(
      {required this.draftCount,
      required this.overdueInvoiceCount,
      required this.expiringQuoteCount,
      required final List<RecentDocument> recentDocuments,
      required this.documentsThisMonth,
      required this.documentsLastMonth,
      required this.customerCount,
      this.hasLogo = false})
      : _recentDocuments = recentDocuments,
        super._();

  factory _$DashboardSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardSummaryImplFromJson(json);

  @override
  final int draftCount;
  @override
  final int overdueInvoiceCount;
  @override
  final int expiringQuoteCount;
  final List<RecentDocument> _recentDocuments;
  @override
  List<RecentDocument> get recentDocuments {
    if (_recentDocuments is EqualUnmodifiableListView) return _recentDocuments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentDocuments);
  }

  @override
  final int documentsThisMonth;
  @override
  final int documentsLastMonth;
  @override
  final int customerCount;
  @override
  @JsonKey()
  final bool hasLogo;

  @override
  String toString() {
    return 'DashboardSummary(draftCount: $draftCount, overdueInvoiceCount: $overdueInvoiceCount, expiringQuoteCount: $expiringQuoteCount, recentDocuments: $recentDocuments, documentsThisMonth: $documentsThisMonth, documentsLastMonth: $documentsLastMonth, customerCount: $customerCount, hasLogo: $hasLogo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardSummaryImpl &&
            (identical(other.draftCount, draftCount) ||
                other.draftCount == draftCount) &&
            (identical(other.overdueInvoiceCount, overdueInvoiceCount) ||
                other.overdueInvoiceCount == overdueInvoiceCount) &&
            (identical(other.expiringQuoteCount, expiringQuoteCount) ||
                other.expiringQuoteCount == expiringQuoteCount) &&
            const DeepCollectionEquality()
                .equals(other._recentDocuments, _recentDocuments) &&
            (identical(other.documentsThisMonth, documentsThisMonth) ||
                other.documentsThisMonth == documentsThisMonth) &&
            (identical(other.documentsLastMonth, documentsLastMonth) ||
                other.documentsLastMonth == documentsLastMonth) &&
            (identical(other.customerCount, customerCount) ||
                other.customerCount == customerCount) &&
            (identical(other.hasLogo, hasLogo) || other.hasLogo == hasLogo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      draftCount,
      overdueInvoiceCount,
      expiringQuoteCount,
      const DeepCollectionEquality().hash(_recentDocuments),
      documentsThisMonth,
      documentsLastMonth,
      customerCount,
      hasLogo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardSummaryImplCopyWith<_$DashboardSummaryImpl> get copyWith =>
      __$$DashboardSummaryImplCopyWithImpl<_$DashboardSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardSummaryImplToJson(
      this,
    );
  }
}

abstract class _DashboardSummary extends DashboardSummary {
  const factory _DashboardSummary(
      {required final int draftCount,
      required final int overdueInvoiceCount,
      required final int expiringQuoteCount,
      required final List<RecentDocument> recentDocuments,
      required final int documentsThisMonth,
      required final int documentsLastMonth,
      required final int customerCount,
      final bool hasLogo}) = _$DashboardSummaryImpl;
  const _DashboardSummary._() : super._();

  factory _DashboardSummary.fromJson(Map<String, dynamic> json) =
      _$DashboardSummaryImpl.fromJson;

  @override
  int get draftCount;
  @override
  int get overdueInvoiceCount;
  @override
  int get expiringQuoteCount;
  @override
  List<RecentDocument> get recentDocuments;
  @override
  int get documentsThisMonth;
  @override
  int get documentsLastMonth;
  @override
  int get customerCount;
  @override
  bool get hasLogo;
  @override
  @JsonKey(ignore: true)
  _$$DashboardSummaryImplCopyWith<_$DashboardSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
