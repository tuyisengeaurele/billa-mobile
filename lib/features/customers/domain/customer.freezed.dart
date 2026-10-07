// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OutstandingTotal _$OutstandingTotalFromJson(Map<String, dynamic> json) {
  return _OutstandingTotal.fromJson(json);
}

/// @nodoc
mixin _$OutstandingTotal {
  @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
  Currency get currency => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OutstandingTotalCopyWith<OutstandingTotal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutstandingTotalCopyWith<$Res> {
  factory $OutstandingTotalCopyWith(
          OutstandingTotal value, $Res Function(OutstandingTotal) then) =
      _$OutstandingTotalCopyWithImpl<$Res, OutstandingTotal>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
      Currency currency,
      int amount});
}

/// @nodoc
class _$OutstandingTotalCopyWithImpl<$Res, $Val extends OutstandingTotal>
    implements $OutstandingTotalCopyWith<$Res> {
  _$OutstandingTotalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currency = null,
    Object? amount = null,
  }) {
    return _then(_value.copyWith(
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as Currency,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OutstandingTotalImplCopyWith<$Res>
    implements $OutstandingTotalCopyWith<$Res> {
  factory _$$OutstandingTotalImplCopyWith(_$OutstandingTotalImpl value,
          $Res Function(_$OutstandingTotalImpl) then) =
      __$$OutstandingTotalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
      Currency currency,
      int amount});
}

/// @nodoc
class __$$OutstandingTotalImplCopyWithImpl<$Res>
    extends _$OutstandingTotalCopyWithImpl<$Res, _$OutstandingTotalImpl>
    implements _$$OutstandingTotalImplCopyWith<$Res> {
  __$$OutstandingTotalImplCopyWithImpl(_$OutstandingTotalImpl _value,
      $Res Function(_$OutstandingTotalImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currency = null,
    Object? amount = null,
  }) {
    return _then(_$OutstandingTotalImpl(
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as Currency,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OutstandingTotalImpl implements _OutstandingTotal {
  const _$OutstandingTotalImpl(
      {@JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
      required this.currency,
      required this.amount});

  factory _$OutstandingTotalImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutstandingTotalImplFromJson(json);

  @override
  @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
  final Currency currency;
  @override
  final int amount;

  @override
  String toString() {
    return 'OutstandingTotal(currency: $currency, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutstandingTotalImpl &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, currency, amount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OutstandingTotalImplCopyWith<_$OutstandingTotalImpl> get copyWith =>
      __$$OutstandingTotalImplCopyWithImpl<_$OutstandingTotalImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutstandingTotalImplToJson(
      this,
    );
  }
}

abstract class _OutstandingTotal implements OutstandingTotal {
  const factory _OutstandingTotal(
      {@JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
      required final Currency currency,
      required final int amount}) = _$OutstandingTotalImpl;

  factory _OutstandingTotal.fromJson(Map<String, dynamic> json) =
      _$OutstandingTotalImpl.fromJson;

  @override
  @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson)
  Currency get currency;
  @override
  int get amount;
  @override
  @JsonKey(ignore: true)
  _$$OutstandingTotalImplCopyWith<_$OutstandingTotalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return _Customer.fromJson(json);
}

/// @nodoc
mixin _$Customer {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get tin => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get createdAt =>
      throw _privateConstructorUsedError; // Whole RWF; only a warning on new invoices, never a block.
  int? get creditLimit => throw _privateConstructorUsedError;
  String? get portalToken =>
      throw _privateConstructorUsedError; // Only the single-customer response carries these two.
  int get outstandingBalance => throw _privateConstructorUsedError;
  List<OutstandingTotal> get outstandingTotals =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CustomerCopyWith<Customer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerCopyWith<$Res> {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) then) =
      _$CustomerCopyWithImpl<$Res, Customer>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? tin,
      String? address,
      String? phone,
      String? email,
      bool isActive,
      String createdAt,
      int? creditLimit,
      String? portalToken,
      int outstandingBalance,
      List<OutstandingTotal> outstandingTotals});
}

/// @nodoc
class _$CustomerCopyWithImpl<$Res, $Val extends Customer>
    implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? tin = freezed,
    Object? address = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? creditLimit = freezed,
    Object? portalToken = freezed,
    Object? outstandingBalance = null,
    Object? outstandingTotals = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      tin: freezed == tin
          ? _value.tin
          : tin // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      creditLimit: freezed == creditLimit
          ? _value.creditLimit
          : creditLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      portalToken: freezed == portalToken
          ? _value.portalToken
          : portalToken // ignore: cast_nullable_to_non_nullable
              as String?,
      outstandingBalance: null == outstandingBalance
          ? _value.outstandingBalance
          : outstandingBalance // ignore: cast_nullable_to_non_nullable
              as int,
      outstandingTotals: null == outstandingTotals
          ? _value.outstandingTotals
          : outstandingTotals // ignore: cast_nullable_to_non_nullable
              as List<OutstandingTotal>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomerImplCopyWith<$Res>
    implements $CustomerCopyWith<$Res> {
  factory _$$CustomerImplCopyWith(
          _$CustomerImpl value, $Res Function(_$CustomerImpl) then) =
      __$$CustomerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? tin,
      String? address,
      String? phone,
      String? email,
      bool isActive,
      String createdAt,
      int? creditLimit,
      String? portalToken,
      int outstandingBalance,
      List<OutstandingTotal> outstandingTotals});
}

/// @nodoc
class __$$CustomerImplCopyWithImpl<$Res>
    extends _$CustomerCopyWithImpl<$Res, _$CustomerImpl>
    implements _$$CustomerImplCopyWith<$Res> {
  __$$CustomerImplCopyWithImpl(
      _$CustomerImpl _value, $Res Function(_$CustomerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? tin = freezed,
    Object? address = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? creditLimit = freezed,
    Object? portalToken = freezed,
    Object? outstandingBalance = null,
    Object? outstandingTotals = null,
  }) {
    return _then(_$CustomerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      tin: freezed == tin
          ? _value.tin
          : tin // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      creditLimit: freezed == creditLimit
          ? _value.creditLimit
          : creditLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      portalToken: freezed == portalToken
          ? _value.portalToken
          : portalToken // ignore: cast_nullable_to_non_nullable
              as String?,
      outstandingBalance: null == outstandingBalance
          ? _value.outstandingBalance
          : outstandingBalance // ignore: cast_nullable_to_non_nullable
              as int,
      outstandingTotals: null == outstandingTotals
          ? _value._outstandingTotals
          : outstandingTotals // ignore: cast_nullable_to_non_nullable
              as List<OutstandingTotal>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerImpl implements _Customer {
  const _$CustomerImpl(
      {required this.id,
      required this.name,
      this.tin,
      this.address,
      this.phone,
      this.email,
      required this.isActive,
      required this.createdAt,
      this.creditLimit,
      this.portalToken,
      this.outstandingBalance = 0,
      final List<OutstandingTotal> outstandingTotals =
          const <OutstandingTotal>[]})
      : _outstandingTotals = outstandingTotals;

  factory _$CustomerImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? tin;
  @override
  final String? address;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final bool isActive;
  @override
  final String createdAt;
// Whole RWF; only a warning on new invoices, never a block.
  @override
  final int? creditLimit;
  @override
  final String? portalToken;
// Only the single-customer response carries these two.
  @override
  @JsonKey()
  final int outstandingBalance;
  final List<OutstandingTotal> _outstandingTotals;
  @override
  @JsonKey()
  List<OutstandingTotal> get outstandingTotals {
    if (_outstandingTotals is EqualUnmodifiableListView)
      return _outstandingTotals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_outstandingTotals);
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, tin: $tin, address: $address, phone: $phone, email: $email, isActive: $isActive, createdAt: $createdAt, creditLimit: $creditLimit, portalToken: $portalToken, outstandingBalance: $outstandingBalance, outstandingTotals: $outstandingTotals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.tin, tin) || other.tin == tin) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.creditLimit, creditLimit) ||
                other.creditLimit == creditLimit) &&
            (identical(other.portalToken, portalToken) ||
                other.portalToken == portalToken) &&
            (identical(other.outstandingBalance, outstandingBalance) ||
                other.outstandingBalance == outstandingBalance) &&
            const DeepCollectionEquality()
                .equals(other._outstandingTotals, _outstandingTotals));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      tin,
      address,
      phone,
      email,
      isActive,
      createdAt,
      creditLimit,
      portalToken,
      outstandingBalance,
      const DeepCollectionEquality().hash(_outstandingTotals));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      __$$CustomerImplCopyWithImpl<_$CustomerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerImplToJson(
      this,
    );
  }
}

abstract class _Customer implements Customer {
  const factory _Customer(
      {required final String id,
      required final String name,
      final String? tin,
      final String? address,
      final String? phone,
      final String? email,
      required final bool isActive,
      required final String createdAt,
      final int? creditLimit,
      final String? portalToken,
      final int outstandingBalance,
      final List<OutstandingTotal> outstandingTotals}) = _$CustomerImpl;

  factory _Customer.fromJson(Map<String, dynamic> json) =
      _$CustomerImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get tin;
  @override
  String? get address;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  bool get isActive;
  @override
  String get createdAt;
  @override // Whole RWF; only a warning on new invoices, never a block.
  int? get creditLimit;
  @override
  String? get portalToken;
  @override // Only the single-customer response carries these two.
  int get outstandingBalance;
  @override
  List<OutstandingTotal> get outstandingTotals;
  @override
  @JsonKey(ignore: true)
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
