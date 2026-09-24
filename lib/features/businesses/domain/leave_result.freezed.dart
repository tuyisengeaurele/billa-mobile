// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LeaveResult _$LeaveResultFromJson(Map<String, dynamic> json) {
  return _LeaveResult.fromJson(json);
}

/// @nodoc
mixin _$LeaveResult {
  Business get business => throw _privateConstructorUsedError;
  bool get createdReplacement => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LeaveResultCopyWith<LeaveResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveResultCopyWith<$Res> {
  factory $LeaveResultCopyWith(
          LeaveResult value, $Res Function(LeaveResult) then) =
      _$LeaveResultCopyWithImpl<$Res, LeaveResult>;
  @useResult
  $Res call({Business business, bool createdReplacement});

  $BusinessCopyWith<$Res> get business;
}

/// @nodoc
class _$LeaveResultCopyWithImpl<$Res, $Val extends LeaveResult>
    implements $LeaveResultCopyWith<$Res> {
  _$LeaveResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? business = null,
    Object? createdReplacement = null,
  }) {
    return _then(_value.copyWith(
      business: null == business
          ? _value.business
          : business // ignore: cast_nullable_to_non_nullable
              as Business,
      createdReplacement: null == createdReplacement
          ? _value.createdReplacement
          : createdReplacement // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BusinessCopyWith<$Res> get business {
    return $BusinessCopyWith<$Res>(_value.business, (value) {
      return _then(_value.copyWith(business: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LeaveResultImplCopyWith<$Res>
    implements $LeaveResultCopyWith<$Res> {
  factory _$$LeaveResultImplCopyWith(
          _$LeaveResultImpl value, $Res Function(_$LeaveResultImpl) then) =
      __$$LeaveResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Business business, bool createdReplacement});

  @override
  $BusinessCopyWith<$Res> get business;
}

/// @nodoc
class __$$LeaveResultImplCopyWithImpl<$Res>
    extends _$LeaveResultCopyWithImpl<$Res, _$LeaveResultImpl>
    implements _$$LeaveResultImplCopyWith<$Res> {
  __$$LeaveResultImplCopyWithImpl(
      _$LeaveResultImpl _value, $Res Function(_$LeaveResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? business = null,
    Object? createdReplacement = null,
  }) {
    return _then(_$LeaveResultImpl(
      business: null == business
          ? _value.business
          : business // ignore: cast_nullable_to_non_nullable
              as Business,
      createdReplacement: null == createdReplacement
          ? _value.createdReplacement
          : createdReplacement // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaveResultImpl implements _LeaveResult {
  const _$LeaveResultImpl(
      {required this.business, required this.createdReplacement});

  factory _$LeaveResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaveResultImplFromJson(json);

  @override
  final Business business;
  @override
  final bool createdReplacement;

  @override
  String toString() {
    return 'LeaveResult(business: $business, createdReplacement: $createdReplacement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaveResultImpl &&
            (identical(other.business, business) ||
                other.business == business) &&
            (identical(other.createdReplacement, createdReplacement) ||
                other.createdReplacement == createdReplacement));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, business, createdReplacement);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaveResultImplCopyWith<_$LeaveResultImpl> get copyWith =>
      __$$LeaveResultImplCopyWithImpl<_$LeaveResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaveResultImplToJson(
      this,
    );
  }
}

abstract class _LeaveResult implements LeaveResult {
  const factory _LeaveResult(
      {required final Business business,
      required final bool createdReplacement}) = _$LeaveResultImpl;

  factory _LeaveResult.fromJson(Map<String, dynamic> json) =
      _$LeaveResultImpl.fromJson;

  @override
  Business get business;
  @override
  bool get createdReplacement;
  @override
  @JsonKey(ignore: true)
  _$$LeaveResultImplCopyWith<_$LeaveResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
