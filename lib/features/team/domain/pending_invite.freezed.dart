// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_invite.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PendingInvite _$PendingInviteFromJson(Map<String, dynamic> json) {
  return _PendingInvite.fromJson(json);
}

/// @nodoc
mixin _$PendingInvite {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(fromJson: teamRoleFromJson, toJson: teamRoleToJson)
  TeamRole get role => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get link => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PendingInviteCopyWith<PendingInvite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PendingInviteCopyWith<$Res> {
  factory $PendingInviteCopyWith(
          PendingInvite value, $Res Function(PendingInvite) then) =
      _$PendingInviteCopyWithImpl<$Res, PendingInvite>;
  @useResult
  $Res call(
      {String id,
      String email,
      @JsonKey(fromJson: teamRoleFromJson, toJson: teamRoleToJson)
      TeamRole role,
      String expiresAt,
      String createdAt,
      String link});
}

/// @nodoc
class _$PendingInviteCopyWithImpl<$Res, $Val extends PendingInvite>
    implements $PendingInviteCopyWith<$Res> {
  _$PendingInviteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? role = null,
    Object? expiresAt = null,
    Object? createdAt = null,
    Object? link = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as TeamRole,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PendingInviteImplCopyWith<$Res>
    implements $PendingInviteCopyWith<$Res> {
  factory _$$PendingInviteImplCopyWith(
          _$PendingInviteImpl value, $Res Function(_$PendingInviteImpl) then) =
      __$$PendingInviteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      @JsonKey(fromJson: teamRoleFromJson, toJson: teamRoleToJson)
      TeamRole role,
      String expiresAt,
      String createdAt,
      String link});
}

/// @nodoc
class __$$PendingInviteImplCopyWithImpl<$Res>
    extends _$PendingInviteCopyWithImpl<$Res, _$PendingInviteImpl>
    implements _$$PendingInviteImplCopyWith<$Res> {
  __$$PendingInviteImplCopyWithImpl(
      _$PendingInviteImpl _value, $Res Function(_$PendingInviteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? role = null,
    Object? expiresAt = null,
    Object? createdAt = null,
    Object? link = null,
  }) {
    return _then(_$PendingInviteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as TeamRole,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PendingInviteImpl implements _PendingInvite {
  const _$PendingInviteImpl(
      {required this.id,
      required this.email,
      @JsonKey(fromJson: teamRoleFromJson, toJson: teamRoleToJson)
      required this.role,
      required this.expiresAt,
      required this.createdAt,
      required this.link});

  factory _$PendingInviteImpl.fromJson(Map<String, dynamic> json) =>
      _$$PendingInviteImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  @JsonKey(fromJson: teamRoleFromJson, toJson: teamRoleToJson)
  final TeamRole role;
  @override
  final String expiresAt;
  @override
  final String createdAt;
  @override
  final String link;

  @override
  String toString() {
    return 'PendingInvite(id: $id, email: $email, role: $role, expiresAt: $expiresAt, createdAt: $createdAt, link: $link)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PendingInviteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.link, link) || other.link == link));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, email, role, expiresAt, createdAt, link);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PendingInviteImplCopyWith<_$PendingInviteImpl> get copyWith =>
      __$$PendingInviteImplCopyWithImpl<_$PendingInviteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PendingInviteImplToJson(
      this,
    );
  }
}

abstract class _PendingInvite implements PendingInvite {
  const factory _PendingInvite(
      {required final String id,
      required final String email,
      @JsonKey(fromJson: teamRoleFromJson, toJson: teamRoleToJson)
      required final TeamRole role,
      required final String expiresAt,
      required final String createdAt,
      required final String link}) = _$PendingInviteImpl;

  factory _PendingInvite.fromJson(Map<String, dynamic> json) =
      _$PendingInviteImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  @JsonKey(fromJson: teamRoleFromJson, toJson: teamRoleToJson)
  TeamRole get role;
  @override
  String get expiresAt;
  @override
  String get createdAt;
  @override
  String get link;
  @override
  @JsonKey(ignore: true)
  _$$PendingInviteImplCopyWith<_$PendingInviteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
