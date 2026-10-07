// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InvitePreview _$InvitePreviewFromJson(Map<String, dynamic> json) {
  return _InvitePreview.fromJson(json);
}

/// @nodoc
mixin _$InvitePreview {
  String get email => throw _privateConstructorUsedError;
  String get businessName => throw _privateConstructorUsedError;
  bool get expired => throw _privateConstructorUsedError;
  bool get alreadyAccepted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InvitePreviewCopyWith<InvitePreview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvitePreviewCopyWith<$Res> {
  factory $InvitePreviewCopyWith(
          InvitePreview value, $Res Function(InvitePreview) then) =
      _$InvitePreviewCopyWithImpl<$Res, InvitePreview>;
  @useResult
  $Res call(
      {String email, String businessName, bool expired, bool alreadyAccepted});
}

/// @nodoc
class _$InvitePreviewCopyWithImpl<$Res, $Val extends InvitePreview>
    implements $InvitePreviewCopyWith<$Res> {
  _$InvitePreviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? businessName = null,
    Object? expired = null,
    Object? alreadyAccepted = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      businessName: null == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String,
      expired: null == expired
          ? _value.expired
          : expired // ignore: cast_nullable_to_non_nullable
              as bool,
      alreadyAccepted: null == alreadyAccepted
          ? _value.alreadyAccepted
          : alreadyAccepted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InvitePreviewImplCopyWith<$Res>
    implements $InvitePreviewCopyWith<$Res> {
  factory _$$InvitePreviewImplCopyWith(
          _$InvitePreviewImpl value, $Res Function(_$InvitePreviewImpl) then) =
      __$$InvitePreviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String email, String businessName, bool expired, bool alreadyAccepted});
}

/// @nodoc
class __$$InvitePreviewImplCopyWithImpl<$Res>
    extends _$InvitePreviewCopyWithImpl<$Res, _$InvitePreviewImpl>
    implements _$$InvitePreviewImplCopyWith<$Res> {
  __$$InvitePreviewImplCopyWithImpl(
      _$InvitePreviewImpl _value, $Res Function(_$InvitePreviewImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? businessName = null,
    Object? expired = null,
    Object? alreadyAccepted = null,
  }) {
    return _then(_$InvitePreviewImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      businessName: null == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String,
      expired: null == expired
          ? _value.expired
          : expired // ignore: cast_nullable_to_non_nullable
              as bool,
      alreadyAccepted: null == alreadyAccepted
          ? _value.alreadyAccepted
          : alreadyAccepted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InvitePreviewImpl implements _InvitePreview {
  const _$InvitePreviewImpl(
      {required this.email,
      required this.businessName,
      required this.expired,
      required this.alreadyAccepted});

  factory _$InvitePreviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvitePreviewImplFromJson(json);

  @override
  final String email;
  @override
  final String businessName;
  @override
  final bool expired;
  @override
  final bool alreadyAccepted;

  @override
  String toString() {
    return 'InvitePreview(email: $email, businessName: $businessName, expired: $expired, alreadyAccepted: $alreadyAccepted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvitePreviewImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.expired, expired) || other.expired == expired) &&
            (identical(other.alreadyAccepted, alreadyAccepted) ||
                other.alreadyAccepted == alreadyAccepted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, email, businessName, expired, alreadyAccepted);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InvitePreviewImplCopyWith<_$InvitePreviewImpl> get copyWith =>
      __$$InvitePreviewImplCopyWithImpl<_$InvitePreviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvitePreviewImplToJson(
      this,
    );
  }
}

abstract class _InvitePreview implements InvitePreview {
  const factory _InvitePreview(
      {required final String email,
      required final String businessName,
      required final bool expired,
      required final bool alreadyAccepted}) = _$InvitePreviewImpl;

  factory _InvitePreview.fromJson(Map<String, dynamic> json) =
      _$InvitePreviewImpl.fromJson;

  @override
  String get email;
  @override
  String get businessName;
  @override
  bool get expired;
  @override
  bool get alreadyAccepted;
  @override
  @JsonKey(ignore: true)
  _$$InvitePreviewImplCopyWith<_$InvitePreviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
