// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SessionInfo _$SessionInfoFromJson(Map<String, dynamic> json) {
  return _SessionInfo.fromJson(json);
}

/// @nodoc
mixin _$SessionInfo {
  String get id => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;
  bool get isCurrent => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SessionInfoCopyWith<SessionInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionInfoCopyWith<$Res> {
  factory $SessionInfoCopyWith(
          SessionInfo value, $Res Function(SessionInfo) then) =
      _$SessionInfoCopyWithImpl<$Res, SessionInfo>;
  @useResult
  $Res call({String id, String createdAt, String expiresAt, bool isCurrent});
}

/// @nodoc
class _$SessionInfoCopyWithImpl<$Res, $Val extends SessionInfo>
    implements $SessionInfoCopyWith<$Res> {
  _$SessionInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? isCurrent = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
      isCurrent: null == isCurrent
          ? _value.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionInfoImplCopyWith<$Res>
    implements $SessionInfoCopyWith<$Res> {
  factory _$$SessionInfoImplCopyWith(
          _$SessionInfoImpl value, $Res Function(_$SessionInfoImpl) then) =
      __$$SessionInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String createdAt, String expiresAt, bool isCurrent});
}

/// @nodoc
class __$$SessionInfoImplCopyWithImpl<$Res>
    extends _$SessionInfoCopyWithImpl<$Res, _$SessionInfoImpl>
    implements _$$SessionInfoImplCopyWith<$Res> {
  __$$SessionInfoImplCopyWithImpl(
      _$SessionInfoImpl _value, $Res Function(_$SessionInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? isCurrent = null,
  }) {
    return _then(_$SessionInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
      isCurrent: null == isCurrent
          ? _value.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionInfoImpl implements _SessionInfo {
  const _$SessionInfoImpl(
      {required this.id,
      required this.createdAt,
      required this.expiresAt,
      required this.isCurrent});

  factory _$SessionInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String createdAt;
  @override
  final String expiresAt;
  @override
  final bool isCurrent;

  @override
  String toString() {
    return 'SessionInfo(id: $id, createdAt: $createdAt, expiresAt: $expiresAt, isCurrent: $isCurrent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, createdAt, expiresAt, isCurrent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionInfoImplCopyWith<_$SessionInfoImpl> get copyWith =>
      __$$SessionInfoImplCopyWithImpl<_$SessionInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionInfoImplToJson(
      this,
    );
  }
}

abstract class _SessionInfo implements SessionInfo {
  const factory _SessionInfo(
      {required final String id,
      required final String createdAt,
      required final String expiresAt,
      required final bool isCurrent}) = _$SessionInfoImpl;

  factory _SessionInfo.fromJson(Map<String, dynamic> json) =
      _$SessionInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get createdAt;
  @override
  String get expiresAt;
  @override
  bool get isCurrent;
  @override
  @JsonKey(ignore: true)
  _$$SessionInfoImplCopyWith<_$SessionInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
