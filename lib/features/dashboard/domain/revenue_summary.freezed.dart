// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'revenue_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MonthlyRevenue _$MonthlyRevenueFromJson(Map<String, dynamic> json) {
  return _MonthlyRevenue.fromJson(json);
}

/// @nodoc
mixin _$MonthlyRevenue {
  String get month => throw _privateConstructorUsedError;
  int get invoiced => throw _privateConstructorUsedError;
  int get credited => throw _privateConstructorUsedError;
  int get net => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MonthlyRevenueCopyWith<MonthlyRevenue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyRevenueCopyWith<$Res> {
  factory $MonthlyRevenueCopyWith(
          MonthlyRevenue value, $Res Function(MonthlyRevenue) then) =
      _$MonthlyRevenueCopyWithImpl<$Res, MonthlyRevenue>;
  @useResult
  $Res call({String month, int invoiced, int credited, int net});
}

/// @nodoc
class _$MonthlyRevenueCopyWithImpl<$Res, $Val extends MonthlyRevenue>
    implements $MonthlyRevenueCopyWith<$Res> {
  _$MonthlyRevenueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? invoiced = null,
    Object? credited = null,
    Object? net = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      invoiced: null == invoiced
          ? _value.invoiced
          : invoiced // ignore: cast_nullable_to_non_nullable
              as int,
      credited: null == credited
          ? _value.credited
          : credited // ignore: cast_nullable_to_non_nullable
              as int,
      net: null == net
          ? _value.net
          : net // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthlyRevenueImplCopyWith<$Res>
    implements $MonthlyRevenueCopyWith<$Res> {
  factory _$$MonthlyRevenueImplCopyWith(_$MonthlyRevenueImpl value,
          $Res Function(_$MonthlyRevenueImpl) then) =
      __$$MonthlyRevenueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String month, int invoiced, int credited, int net});
}

/// @nodoc
class __$$MonthlyRevenueImplCopyWithImpl<$Res>
    extends _$MonthlyRevenueCopyWithImpl<$Res, _$MonthlyRevenueImpl>
    implements _$$MonthlyRevenueImplCopyWith<$Res> {
  __$$MonthlyRevenueImplCopyWithImpl(
      _$MonthlyRevenueImpl _value, $Res Function(_$MonthlyRevenueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? invoiced = null,
    Object? credited = null,
    Object? net = null,
  }) {
    return _then(_$MonthlyRevenueImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      invoiced: null == invoiced
          ? _value.invoiced
          : invoiced // ignore: cast_nullable_to_non_nullable
              as int,
      credited: null == credited
          ? _value.credited
          : credited // ignore: cast_nullable_to_non_nullable
              as int,
      net: null == net
          ? _value.net
          : net // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyRevenueImpl implements _MonthlyRevenue {
  const _$MonthlyRevenueImpl(
      {required this.month,
      required this.invoiced,
      required this.credited,
      required this.net});

  factory _$MonthlyRevenueImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyRevenueImplFromJson(json);

  @override
  final String month;
  @override
  final int invoiced;
  @override
  final int credited;
  @override
  final int net;

  @override
  String toString() {
    return 'MonthlyRevenue(month: $month, invoiced: $invoiced, credited: $credited, net: $net)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyRevenueImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.invoiced, invoiced) ||
                other.invoiced == invoiced) &&
            (identical(other.credited, credited) ||
                other.credited == credited) &&
            (identical(other.net, net) || other.net == net));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, month, invoiced, credited, net);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyRevenueImplCopyWith<_$MonthlyRevenueImpl> get copyWith =>
      __$$MonthlyRevenueImplCopyWithImpl<_$MonthlyRevenueImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyRevenueImplToJson(
      this,
    );
  }
}

abstract class _MonthlyRevenue implements MonthlyRevenue {
  const factory _MonthlyRevenue(
      {required final String month,
      required final int invoiced,
      required final int credited,
      required final int net}) = _$MonthlyRevenueImpl;

  factory _MonthlyRevenue.fromJson(Map<String, dynamic> json) =
      _$MonthlyRevenueImpl.fromJson;

  @override
  String get month;
  @override
  int get invoiced;
  @override
  int get credited;
  @override
  int get net;
  @override
  @JsonKey(ignore: true)
  _$$MonthlyRevenueImplCopyWith<_$MonthlyRevenueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TopCustomer _$TopCustomerFromJson(Map<String, dynamic> json) {
  return _TopCustomer.fromJson(json);
}

/// @nodoc
mixin _$TopCustomer {
  String get customerId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TopCustomerCopyWith<TopCustomer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopCustomerCopyWith<$Res> {
  factory $TopCustomerCopyWith(
          TopCustomer value, $Res Function(TopCustomer) then) =
      _$TopCustomerCopyWithImpl<$Res, TopCustomer>;
  @useResult
  $Res call({String customerId, String name, int total});
}

/// @nodoc
class _$TopCustomerCopyWithImpl<$Res, $Val extends TopCustomer>
    implements $TopCustomerCopyWith<$Res> {
  _$TopCustomerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? name = null,
    Object? total = null,
  }) {
    return _then(_value.copyWith(
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TopCustomerImplCopyWith<$Res>
    implements $TopCustomerCopyWith<$Res> {
  factory _$$TopCustomerImplCopyWith(
          _$TopCustomerImpl value, $Res Function(_$TopCustomerImpl) then) =
      __$$TopCustomerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String customerId, String name, int total});
}

/// @nodoc
class __$$TopCustomerImplCopyWithImpl<$Res>
    extends _$TopCustomerCopyWithImpl<$Res, _$TopCustomerImpl>
    implements _$$TopCustomerImplCopyWith<$Res> {
  __$$TopCustomerImplCopyWithImpl(
      _$TopCustomerImpl _value, $Res Function(_$TopCustomerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? name = null,
    Object? total = null,
  }) {
    return _then(_$TopCustomerImpl(
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TopCustomerImpl implements _TopCustomer {
  const _$TopCustomerImpl(
      {required this.customerId, required this.name, required this.total});

  factory _$TopCustomerImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopCustomerImplFromJson(json);

  @override
  final String customerId;
  @override
  final String name;
  @override
  final int total;

  @override
  String toString() {
    return 'TopCustomer(customerId: $customerId, name: $name, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopCustomerImpl &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, customerId, name, total);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TopCustomerImplCopyWith<_$TopCustomerImpl> get copyWith =>
      __$$TopCustomerImplCopyWithImpl<_$TopCustomerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopCustomerImplToJson(
      this,
    );
  }
}

abstract class _TopCustomer implements TopCustomer {
  const factory _TopCustomer(
      {required final String customerId,
      required final String name,
      required final int total}) = _$TopCustomerImpl;

  factory _TopCustomer.fromJson(Map<String, dynamic> json) =
      _$TopCustomerImpl.fromJson;

  @override
  String get customerId;
  @override
  String get name;
  @override
  int get total;
  @override
  @JsonKey(ignore: true)
  _$$TopCustomerImplCopyWith<_$TopCustomerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RevenueSummary _$RevenueSummaryFromJson(Map<String, dynamic> json) {
  return _RevenueSummary.fromJson(json);
}

/// @nodoc
mixin _$RevenueSummary {
  int get invoicedThisMonth => throw _privateConstructorUsedError;
  int get invoicedLastMonth => throw _privateConstructorUsedError;
  int get invoicedYearToDate => throw _privateConstructorUsedError;
  int get creditedYearToDate => throw _privateConstructorUsedError;
  int get netYearToDate => throw _privateConstructorUsedError;
  int get totalCollected => throw _privateConstructorUsedError;
  int get totalOutstanding => throw _privateConstructorUsedError;
  int? get daysSalesOutstanding => throw _privateConstructorUsedError;
  List<MonthlyRevenue> get monthlyRevenue => throw _privateConstructorUsedError;
  List<TopCustomer> get topCustomers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RevenueSummaryCopyWith<RevenueSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RevenueSummaryCopyWith<$Res> {
  factory $RevenueSummaryCopyWith(
          RevenueSummary value, $Res Function(RevenueSummary) then) =
      _$RevenueSummaryCopyWithImpl<$Res, RevenueSummary>;
  @useResult
  $Res call(
      {int invoicedThisMonth,
      int invoicedLastMonth,
      int invoicedYearToDate,
      int creditedYearToDate,
      int netYearToDate,
      int totalCollected,
      int totalOutstanding,
      int? daysSalesOutstanding,
      List<MonthlyRevenue> monthlyRevenue,
      List<TopCustomer> topCustomers});
}

/// @nodoc
class _$RevenueSummaryCopyWithImpl<$Res, $Val extends RevenueSummary>
    implements $RevenueSummaryCopyWith<$Res> {
  _$RevenueSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? invoicedThisMonth = null,
    Object? invoicedLastMonth = null,
    Object? invoicedYearToDate = null,
    Object? creditedYearToDate = null,
    Object? netYearToDate = null,
    Object? totalCollected = null,
    Object? totalOutstanding = null,
    Object? daysSalesOutstanding = freezed,
    Object? monthlyRevenue = null,
    Object? topCustomers = null,
  }) {
    return _then(_value.copyWith(
      invoicedThisMonth: null == invoicedThisMonth
          ? _value.invoicedThisMonth
          : invoicedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      invoicedLastMonth: null == invoicedLastMonth
          ? _value.invoicedLastMonth
          : invoicedLastMonth // ignore: cast_nullable_to_non_nullable
              as int,
      invoicedYearToDate: null == invoicedYearToDate
          ? _value.invoicedYearToDate
          : invoicedYearToDate // ignore: cast_nullable_to_non_nullable
              as int,
      creditedYearToDate: null == creditedYearToDate
          ? _value.creditedYearToDate
          : creditedYearToDate // ignore: cast_nullable_to_non_nullable
              as int,
      netYearToDate: null == netYearToDate
          ? _value.netYearToDate
          : netYearToDate // ignore: cast_nullable_to_non_nullable
              as int,
      totalCollected: null == totalCollected
          ? _value.totalCollected
          : totalCollected // ignore: cast_nullable_to_non_nullable
              as int,
      totalOutstanding: null == totalOutstanding
          ? _value.totalOutstanding
          : totalOutstanding // ignore: cast_nullable_to_non_nullable
              as int,
      daysSalesOutstanding: freezed == daysSalesOutstanding
          ? _value.daysSalesOutstanding
          : daysSalesOutstanding // ignore: cast_nullable_to_non_nullable
              as int?,
      monthlyRevenue: null == monthlyRevenue
          ? _value.monthlyRevenue
          : monthlyRevenue // ignore: cast_nullable_to_non_nullable
              as List<MonthlyRevenue>,
      topCustomers: null == topCustomers
          ? _value.topCustomers
          : topCustomers // ignore: cast_nullable_to_non_nullable
              as List<TopCustomer>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RevenueSummaryImplCopyWith<$Res>
    implements $RevenueSummaryCopyWith<$Res> {
  factory _$$RevenueSummaryImplCopyWith(_$RevenueSummaryImpl value,
          $Res Function(_$RevenueSummaryImpl) then) =
      __$$RevenueSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int invoicedThisMonth,
      int invoicedLastMonth,
      int invoicedYearToDate,
      int creditedYearToDate,
      int netYearToDate,
      int totalCollected,
      int totalOutstanding,
      int? daysSalesOutstanding,
      List<MonthlyRevenue> monthlyRevenue,
      List<TopCustomer> topCustomers});
}

/// @nodoc
class __$$RevenueSummaryImplCopyWithImpl<$Res>
    extends _$RevenueSummaryCopyWithImpl<$Res, _$RevenueSummaryImpl>
    implements _$$RevenueSummaryImplCopyWith<$Res> {
  __$$RevenueSummaryImplCopyWithImpl(
      _$RevenueSummaryImpl _value, $Res Function(_$RevenueSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? invoicedThisMonth = null,
    Object? invoicedLastMonth = null,
    Object? invoicedYearToDate = null,
    Object? creditedYearToDate = null,
    Object? netYearToDate = null,
    Object? totalCollected = null,
    Object? totalOutstanding = null,
    Object? daysSalesOutstanding = freezed,
    Object? monthlyRevenue = null,
    Object? topCustomers = null,
  }) {
    return _then(_$RevenueSummaryImpl(
      invoicedThisMonth: null == invoicedThisMonth
          ? _value.invoicedThisMonth
          : invoicedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      invoicedLastMonth: null == invoicedLastMonth
          ? _value.invoicedLastMonth
          : invoicedLastMonth // ignore: cast_nullable_to_non_nullable
              as int,
      invoicedYearToDate: null == invoicedYearToDate
          ? _value.invoicedYearToDate
          : invoicedYearToDate // ignore: cast_nullable_to_non_nullable
              as int,
      creditedYearToDate: null == creditedYearToDate
          ? _value.creditedYearToDate
          : creditedYearToDate // ignore: cast_nullable_to_non_nullable
              as int,
      netYearToDate: null == netYearToDate
          ? _value.netYearToDate
          : netYearToDate // ignore: cast_nullable_to_non_nullable
              as int,
      totalCollected: null == totalCollected
          ? _value.totalCollected
          : totalCollected // ignore: cast_nullable_to_non_nullable
              as int,
      totalOutstanding: null == totalOutstanding
          ? _value.totalOutstanding
          : totalOutstanding // ignore: cast_nullable_to_non_nullable
              as int,
      daysSalesOutstanding: freezed == daysSalesOutstanding
          ? _value.daysSalesOutstanding
          : daysSalesOutstanding // ignore: cast_nullable_to_non_nullable
              as int?,
      monthlyRevenue: null == monthlyRevenue
          ? _value._monthlyRevenue
          : monthlyRevenue // ignore: cast_nullable_to_non_nullable
              as List<MonthlyRevenue>,
      topCustomers: null == topCustomers
          ? _value._topCustomers
          : topCustomers // ignore: cast_nullable_to_non_nullable
              as List<TopCustomer>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RevenueSummaryImpl extends _RevenueSummary {
  const _$RevenueSummaryImpl(
      {required this.invoicedThisMonth,
      required this.invoicedLastMonth,
      required this.invoicedYearToDate,
      required this.creditedYearToDate,
      required this.netYearToDate,
      required this.totalCollected,
      required this.totalOutstanding,
      this.daysSalesOutstanding,
      required final List<MonthlyRevenue> monthlyRevenue,
      required final List<TopCustomer> topCustomers})
      : _monthlyRevenue = monthlyRevenue,
        _topCustomers = topCustomers,
        super._();

  factory _$RevenueSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RevenueSummaryImplFromJson(json);

  @override
  final int invoicedThisMonth;
  @override
  final int invoicedLastMonth;
  @override
  final int invoicedYearToDate;
  @override
  final int creditedYearToDate;
  @override
  final int netYearToDate;
  @override
  final int totalCollected;
  @override
  final int totalOutstanding;
  @override
  final int? daysSalesOutstanding;
  final List<MonthlyRevenue> _monthlyRevenue;
  @override
  List<MonthlyRevenue> get monthlyRevenue {
    if (_monthlyRevenue is EqualUnmodifiableListView) return _monthlyRevenue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_monthlyRevenue);
  }

  final List<TopCustomer> _topCustomers;
  @override
  List<TopCustomer> get topCustomers {
    if (_topCustomers is EqualUnmodifiableListView) return _topCustomers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topCustomers);
  }

  @override
  String toString() {
    return 'RevenueSummary(invoicedThisMonth: $invoicedThisMonth, invoicedLastMonth: $invoicedLastMonth, invoicedYearToDate: $invoicedYearToDate, creditedYearToDate: $creditedYearToDate, netYearToDate: $netYearToDate, totalCollected: $totalCollected, totalOutstanding: $totalOutstanding, daysSalesOutstanding: $daysSalesOutstanding, monthlyRevenue: $monthlyRevenue, topCustomers: $topCustomers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RevenueSummaryImpl &&
            (identical(other.invoicedThisMonth, invoicedThisMonth) ||
                other.invoicedThisMonth == invoicedThisMonth) &&
            (identical(other.invoicedLastMonth, invoicedLastMonth) ||
                other.invoicedLastMonth == invoicedLastMonth) &&
            (identical(other.invoicedYearToDate, invoicedYearToDate) ||
                other.invoicedYearToDate == invoicedYearToDate) &&
            (identical(other.creditedYearToDate, creditedYearToDate) ||
                other.creditedYearToDate == creditedYearToDate) &&
            (identical(other.netYearToDate, netYearToDate) ||
                other.netYearToDate == netYearToDate) &&
            (identical(other.totalCollected, totalCollected) ||
                other.totalCollected == totalCollected) &&
            (identical(other.totalOutstanding, totalOutstanding) ||
                other.totalOutstanding == totalOutstanding) &&
            (identical(other.daysSalesOutstanding, daysSalesOutstanding) ||
                other.daysSalesOutstanding == daysSalesOutstanding) &&
            const DeepCollectionEquality()
                .equals(other._monthlyRevenue, _monthlyRevenue) &&
            const DeepCollectionEquality()
                .equals(other._topCustomers, _topCustomers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      invoicedThisMonth,
      invoicedLastMonth,
      invoicedYearToDate,
      creditedYearToDate,
      netYearToDate,
      totalCollected,
      totalOutstanding,
      daysSalesOutstanding,
      const DeepCollectionEquality().hash(_monthlyRevenue),
      const DeepCollectionEquality().hash(_topCustomers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RevenueSummaryImplCopyWith<_$RevenueSummaryImpl> get copyWith =>
      __$$RevenueSummaryImplCopyWithImpl<_$RevenueSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RevenueSummaryImplToJson(
      this,
    );
  }
}

abstract class _RevenueSummary extends RevenueSummary {
  const factory _RevenueSummary(
      {required final int invoicedThisMonth,
      required final int invoicedLastMonth,
      required final int invoicedYearToDate,
      required final int creditedYearToDate,
      required final int netYearToDate,
      required final int totalCollected,
      required final int totalOutstanding,
      final int? daysSalesOutstanding,
      required final List<MonthlyRevenue> monthlyRevenue,
      required final List<TopCustomer> topCustomers}) = _$RevenueSummaryImpl;
  const _RevenueSummary._() : super._();

  factory _RevenueSummary.fromJson(Map<String, dynamic> json) =
      _$RevenueSummaryImpl.fromJson;

  @override
  int get invoicedThisMonth;
  @override
  int get invoicedLastMonth;
  @override
  int get invoicedYearToDate;
  @override
  int get creditedYearToDate;
  @override
  int get netYearToDate;
  @override
  int get totalCollected;
  @override
  int get totalOutstanding;
  @override
  int? get daysSalesOutstanding;
  @override
  List<MonthlyRevenue> get monthlyRevenue;
  @override
  List<TopCustomer> get topCustomers;
  @override
  @JsonKey(ignore: true)
  _$$RevenueSummaryImplCopyWith<_$RevenueSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
