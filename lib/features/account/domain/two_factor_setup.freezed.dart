// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'two_factor_setup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TwoFactorSetup _$TwoFactorSetupFromJson(Map<String, dynamic> json) {
  return _TwoFactorSetup.fromJson(json);
}

/// @nodoc
mixin _$TwoFactorSetup {
  String get secret => throw _privateConstructorUsedError;
  String get otpauthUrl => throw _privateConstructorUsedError;
  String get qrCodeDataUri => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TwoFactorSetupCopyWith<TwoFactorSetup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TwoFactorSetupCopyWith<$Res> {
  factory $TwoFactorSetupCopyWith(
          TwoFactorSetup value, $Res Function(TwoFactorSetup) then) =
      _$TwoFactorSetupCopyWithImpl<$Res, TwoFactorSetup>;
  @useResult
  $Res call({String secret, String otpauthUrl, String qrCodeDataUri});
}

/// @nodoc
class _$TwoFactorSetupCopyWithImpl<$Res, $Val extends TwoFactorSetup>
    implements $TwoFactorSetupCopyWith<$Res> {
  _$TwoFactorSetupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? secret = null,
    Object? otpauthUrl = null,
    Object? qrCodeDataUri = null,
  }) {
    return _then(_value.copyWith(
      secret: null == secret
          ? _value.secret
          : secret // ignore: cast_nullable_to_non_nullable
              as String,
      otpauthUrl: null == otpauthUrl
          ? _value.otpauthUrl
          : otpauthUrl // ignore: cast_nullable_to_non_nullable
              as String,
      qrCodeDataUri: null == qrCodeDataUri
          ? _value.qrCodeDataUri
          : qrCodeDataUri // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TwoFactorSetupImplCopyWith<$Res>
    implements $TwoFactorSetupCopyWith<$Res> {
  factory _$$TwoFactorSetupImplCopyWith(_$TwoFactorSetupImpl value,
          $Res Function(_$TwoFactorSetupImpl) then) =
      __$$TwoFactorSetupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String secret, String otpauthUrl, String qrCodeDataUri});
}

/// @nodoc
class __$$TwoFactorSetupImplCopyWithImpl<$Res>
    extends _$TwoFactorSetupCopyWithImpl<$Res, _$TwoFactorSetupImpl>
    implements _$$TwoFactorSetupImplCopyWith<$Res> {
  __$$TwoFactorSetupImplCopyWithImpl(
      _$TwoFactorSetupImpl _value, $Res Function(_$TwoFactorSetupImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? secret = null,
    Object? otpauthUrl = null,
    Object? qrCodeDataUri = null,
  }) {
    return _then(_$TwoFactorSetupImpl(
      secret: null == secret
          ? _value.secret
          : secret // ignore: cast_nullable_to_non_nullable
              as String,
      otpauthUrl: null == otpauthUrl
          ? _value.otpauthUrl
          : otpauthUrl // ignore: cast_nullable_to_non_nullable
              as String,
      qrCodeDataUri: null == qrCodeDataUri
          ? _value.qrCodeDataUri
          : qrCodeDataUri // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TwoFactorSetupImpl implements _TwoFactorSetup {
  const _$TwoFactorSetupImpl(
      {required this.secret,
      required this.otpauthUrl,
      required this.qrCodeDataUri});

  factory _$TwoFactorSetupImpl.fromJson(Map<String, dynamic> json) =>
      _$$TwoFactorSetupImplFromJson(json);

  @override
  final String secret;
  @override
  final String otpauthUrl;
  @override
  final String qrCodeDataUri;

  @override
  String toString() {
    return 'TwoFactorSetup(secret: $secret, otpauthUrl: $otpauthUrl, qrCodeDataUri: $qrCodeDataUri)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TwoFactorSetupImpl &&
            (identical(other.secret, secret) || other.secret == secret) &&
            (identical(other.otpauthUrl, otpauthUrl) ||
                other.otpauthUrl == otpauthUrl) &&
            (identical(other.qrCodeDataUri, qrCodeDataUri) ||
                other.qrCodeDataUri == qrCodeDataUri));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, secret, otpauthUrl, qrCodeDataUri);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TwoFactorSetupImplCopyWith<_$TwoFactorSetupImpl> get copyWith =>
      __$$TwoFactorSetupImplCopyWithImpl<_$TwoFactorSetupImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TwoFactorSetupImplToJson(
      this,
    );
  }
}

abstract class _TwoFactorSetup implements TwoFactorSetup {
  const factory _TwoFactorSetup(
      {required final String secret,
      required final String otpauthUrl,
      required final String qrCodeDataUri}) = _$TwoFactorSetupImpl;

  factory _TwoFactorSetup.fromJson(Map<String, dynamic> json) =
      _$TwoFactorSetupImpl.fromJson;

  @override
  String get secret;
  @override
  String get otpauthUrl;
  @override
  String get qrCodeDataUri;
  @override
  @JsonKey(ignore: true)
  _$$TwoFactorSetupImplCopyWith<_$TwoFactorSetupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
