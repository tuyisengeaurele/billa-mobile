// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BusinessSettings _$BusinessSettingsFromJson(Map<String, dynamic> json) {
  return _BusinessSettings.fromJson(json);
}

/// @nodoc
mixin _$BusinessSettings {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get tin => throw _privateConstructorUsedError;
  String? get industry => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get rraEbmNumber => throw _privateConstructorUsedError;
  String? get bankName => throw _privateConstructorUsedError;
  String? get bankAccountNumber => throw _privateConstructorUsedError;
  String? get signatoryName => throw _privateConstructorUsedError;
  String? get signatoryTitle => throw _privateConstructorUsedError;
  String? get signatureUrl => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String? get primaryColor => throw _privateConstructorUsedError;
  List<String> get accentColors => throw _privateConstructorUsedError;
  bool get remindersEnabled => throw _privateConstructorUsedError;
  int get reminderCadenceDays => throw _privateConstructorUsedError;
  bool get requireApprovalToFinalize => throw _privateConstructorUsedError;
  @JsonKey(fromJson: documentTemplateFromJson, toJson: documentTemplateToJson)
  DocumentTemplate get defaultTemplate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BusinessSettingsCopyWith<BusinessSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusinessSettingsCopyWith<$Res> {
  factory $BusinessSettingsCopyWith(
          BusinessSettings value, $Res Function(BusinessSettings) then) =
      _$BusinessSettingsCopyWithImpl<$Res, BusinessSettings>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? tin,
      String? industry,
      String? phone,
      String? email,
      String? address,
      String? rraEbmNumber,
      String? bankName,
      String? bankAccountNumber,
      String? signatoryName,
      String? signatoryTitle,
      String? signatureUrl,
      String? logoUrl,
      String? primaryColor,
      List<String> accentColors,
      bool remindersEnabled,
      int reminderCadenceDays,
      bool requireApprovalToFinalize,
      @JsonKey(
          fromJson: documentTemplateFromJson, toJson: documentTemplateToJson)
      DocumentTemplate defaultTemplate});
}

/// @nodoc
class _$BusinessSettingsCopyWithImpl<$Res, $Val extends BusinessSettings>
    implements $BusinessSettingsCopyWith<$Res> {
  _$BusinessSettingsCopyWithImpl(this._value, this._then);

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
    Object? industry = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? address = freezed,
    Object? rraEbmNumber = freezed,
    Object? bankName = freezed,
    Object? bankAccountNumber = freezed,
    Object? signatoryName = freezed,
    Object? signatoryTitle = freezed,
    Object? signatureUrl = freezed,
    Object? logoUrl = freezed,
    Object? primaryColor = freezed,
    Object? accentColors = null,
    Object? remindersEnabled = null,
    Object? reminderCadenceDays = null,
    Object? requireApprovalToFinalize = null,
    Object? defaultTemplate = null,
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
      industry: freezed == industry
          ? _value.industry
          : industry // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      rraEbmNumber: freezed == rraEbmNumber
          ? _value.rraEbmNumber
          : rraEbmNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      bankName: freezed == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String?,
      bankAccountNumber: freezed == bankAccountNumber
          ? _value.bankAccountNumber
          : bankAccountNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      signatoryName: freezed == signatoryName
          ? _value.signatoryName
          : signatoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      signatoryTitle: freezed == signatoryTitle
          ? _value.signatoryTitle
          : signatoryTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      signatureUrl: freezed == signatureUrl
          ? _value.signatureUrl
          : signatureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryColor: freezed == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String?,
      accentColors: null == accentColors
          ? _value.accentColors
          : accentColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      remindersEnabled: null == remindersEnabled
          ? _value.remindersEnabled
          : remindersEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderCadenceDays: null == reminderCadenceDays
          ? _value.reminderCadenceDays
          : reminderCadenceDays // ignore: cast_nullable_to_non_nullable
              as int,
      requireApprovalToFinalize: null == requireApprovalToFinalize
          ? _value.requireApprovalToFinalize
          : requireApprovalToFinalize // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultTemplate: null == defaultTemplate
          ? _value.defaultTemplate
          : defaultTemplate // ignore: cast_nullable_to_non_nullable
              as DocumentTemplate,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BusinessSettingsImplCopyWith<$Res>
    implements $BusinessSettingsCopyWith<$Res> {
  factory _$$BusinessSettingsImplCopyWith(_$BusinessSettingsImpl value,
          $Res Function(_$BusinessSettingsImpl) then) =
      __$$BusinessSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? tin,
      String? industry,
      String? phone,
      String? email,
      String? address,
      String? rraEbmNumber,
      String? bankName,
      String? bankAccountNumber,
      String? signatoryName,
      String? signatoryTitle,
      String? signatureUrl,
      String? logoUrl,
      String? primaryColor,
      List<String> accentColors,
      bool remindersEnabled,
      int reminderCadenceDays,
      bool requireApprovalToFinalize,
      @JsonKey(
          fromJson: documentTemplateFromJson, toJson: documentTemplateToJson)
      DocumentTemplate defaultTemplate});
}

/// @nodoc
class __$$BusinessSettingsImplCopyWithImpl<$Res>
    extends _$BusinessSettingsCopyWithImpl<$Res, _$BusinessSettingsImpl>
    implements _$$BusinessSettingsImplCopyWith<$Res> {
  __$$BusinessSettingsImplCopyWithImpl(_$BusinessSettingsImpl _value,
      $Res Function(_$BusinessSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? tin = freezed,
    Object? industry = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? address = freezed,
    Object? rraEbmNumber = freezed,
    Object? bankName = freezed,
    Object? bankAccountNumber = freezed,
    Object? signatoryName = freezed,
    Object? signatoryTitle = freezed,
    Object? signatureUrl = freezed,
    Object? logoUrl = freezed,
    Object? primaryColor = freezed,
    Object? accentColors = null,
    Object? remindersEnabled = null,
    Object? reminderCadenceDays = null,
    Object? requireApprovalToFinalize = null,
    Object? defaultTemplate = null,
  }) {
    return _then(_$BusinessSettingsImpl(
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
      industry: freezed == industry
          ? _value.industry
          : industry // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      rraEbmNumber: freezed == rraEbmNumber
          ? _value.rraEbmNumber
          : rraEbmNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      bankName: freezed == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String?,
      bankAccountNumber: freezed == bankAccountNumber
          ? _value.bankAccountNumber
          : bankAccountNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      signatoryName: freezed == signatoryName
          ? _value.signatoryName
          : signatoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      signatoryTitle: freezed == signatoryTitle
          ? _value.signatoryTitle
          : signatoryTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      signatureUrl: freezed == signatureUrl
          ? _value.signatureUrl
          : signatureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryColor: freezed == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String?,
      accentColors: null == accentColors
          ? _value._accentColors
          : accentColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      remindersEnabled: null == remindersEnabled
          ? _value.remindersEnabled
          : remindersEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderCadenceDays: null == reminderCadenceDays
          ? _value.reminderCadenceDays
          : reminderCadenceDays // ignore: cast_nullable_to_non_nullable
              as int,
      requireApprovalToFinalize: null == requireApprovalToFinalize
          ? _value.requireApprovalToFinalize
          : requireApprovalToFinalize // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultTemplate: null == defaultTemplate
          ? _value.defaultTemplate
          : defaultTemplate // ignore: cast_nullable_to_non_nullable
              as DocumentTemplate,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusinessSettingsImpl implements _BusinessSettings {
  const _$BusinessSettingsImpl(
      {required this.id,
      required this.name,
      this.tin,
      this.industry,
      this.phone,
      this.email,
      this.address,
      this.rraEbmNumber,
      this.bankName,
      this.bankAccountNumber,
      this.signatoryName,
      this.signatoryTitle,
      this.signatureUrl,
      this.logoUrl,
      this.primaryColor,
      final List<String> accentColors = const [],
      this.remindersEnabled = true,
      this.reminderCadenceDays = 7,
      this.requireApprovalToFinalize = false,
      @JsonKey(
          fromJson: documentTemplateFromJson, toJson: documentTemplateToJson)
      this.defaultTemplate = DocumentTemplate.minimal})
      : _accentColors = accentColors;

  factory _$BusinessSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusinessSettingsImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? tin;
  @override
  final String? industry;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? address;
  @override
  final String? rraEbmNumber;
  @override
  final String? bankName;
  @override
  final String? bankAccountNumber;
  @override
  final String? signatoryName;
  @override
  final String? signatoryTitle;
  @override
  final String? signatureUrl;
  @override
  final String? logoUrl;
  @override
  final String? primaryColor;
  final List<String> _accentColors;
  @override
  @JsonKey()
  List<String> get accentColors {
    if (_accentColors is EqualUnmodifiableListView) return _accentColors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_accentColors);
  }

  @override
  @JsonKey()
  final bool remindersEnabled;
  @override
  @JsonKey()
  final int reminderCadenceDays;
  @override
  @JsonKey()
  final bool requireApprovalToFinalize;
  @override
  @JsonKey(fromJson: documentTemplateFromJson, toJson: documentTemplateToJson)
  final DocumentTemplate defaultTemplate;

  @override
  String toString() {
    return 'BusinessSettings(id: $id, name: $name, tin: $tin, industry: $industry, phone: $phone, email: $email, address: $address, rraEbmNumber: $rraEbmNumber, bankName: $bankName, bankAccountNumber: $bankAccountNumber, signatoryName: $signatoryName, signatoryTitle: $signatoryTitle, signatureUrl: $signatureUrl, logoUrl: $logoUrl, primaryColor: $primaryColor, accentColors: $accentColors, remindersEnabled: $remindersEnabled, reminderCadenceDays: $reminderCadenceDays, requireApprovalToFinalize: $requireApprovalToFinalize, defaultTemplate: $defaultTemplate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessSettingsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.tin, tin) || other.tin == tin) &&
            (identical(other.industry, industry) ||
                other.industry == industry) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.rraEbmNumber, rraEbmNumber) ||
                other.rraEbmNumber == rraEbmNumber) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.bankAccountNumber, bankAccountNumber) ||
                other.bankAccountNumber == bankAccountNumber) &&
            (identical(other.signatoryName, signatoryName) ||
                other.signatoryName == signatoryName) &&
            (identical(other.signatoryTitle, signatoryTitle) ||
                other.signatoryTitle == signatoryTitle) &&
            (identical(other.signatureUrl, signatureUrl) ||
                other.signatureUrl == signatureUrl) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            const DeepCollectionEquality()
                .equals(other._accentColors, _accentColors) &&
            (identical(other.remindersEnabled, remindersEnabled) ||
                other.remindersEnabled == remindersEnabled) &&
            (identical(other.reminderCadenceDays, reminderCadenceDays) ||
                other.reminderCadenceDays == reminderCadenceDays) &&
            (identical(other.requireApprovalToFinalize,
                    requireApprovalToFinalize) ||
                other.requireApprovalToFinalize == requireApprovalToFinalize) &&
            (identical(other.defaultTemplate, defaultTemplate) ||
                other.defaultTemplate == defaultTemplate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        tin,
        industry,
        phone,
        email,
        address,
        rraEbmNumber,
        bankName,
        bankAccountNumber,
        signatoryName,
        signatoryTitle,
        signatureUrl,
        logoUrl,
        primaryColor,
        const DeepCollectionEquality().hash(_accentColors),
        remindersEnabled,
        reminderCadenceDays,
        requireApprovalToFinalize,
        defaultTemplate
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessSettingsImplCopyWith<_$BusinessSettingsImpl> get copyWith =>
      __$$BusinessSettingsImplCopyWithImpl<_$BusinessSettingsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusinessSettingsImplToJson(
      this,
    );
  }
}

abstract class _BusinessSettings implements BusinessSettings {
  const factory _BusinessSettings(
      {required final String id,
      required final String name,
      final String? tin,
      final String? industry,
      final String? phone,
      final String? email,
      final String? address,
      final String? rraEbmNumber,
      final String? bankName,
      final String? bankAccountNumber,
      final String? signatoryName,
      final String? signatoryTitle,
      final String? signatureUrl,
      final String? logoUrl,
      final String? primaryColor,
      final List<String> accentColors,
      final bool remindersEnabled,
      final int reminderCadenceDays,
      final bool requireApprovalToFinalize,
      @JsonKey(
          fromJson: documentTemplateFromJson, toJson: documentTemplateToJson)
      final DocumentTemplate defaultTemplate}) = _$BusinessSettingsImpl;

  factory _BusinessSettings.fromJson(Map<String, dynamic> json) =
      _$BusinessSettingsImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get tin;
  @override
  String? get industry;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get address;
  @override
  String? get rraEbmNumber;
  @override
  String? get bankName;
  @override
  String? get bankAccountNumber;
  @override
  String? get signatoryName;
  @override
  String? get signatoryTitle;
  @override
  String? get signatureUrl;
  @override
  String? get logoUrl;
  @override
  String? get primaryColor;
  @override
  List<String> get accentColors;
  @override
  bool get remindersEnabled;
  @override
  int get reminderCadenceDays;
  @override
  bool get requireApprovalToFinalize;
  @override
  @JsonKey(fromJson: documentTemplateFromJson, toJson: documentTemplateToJson)
  DocumentTemplate get defaultTemplate;
  @override
  @JsonKey(ignore: true)
  _$$BusinessSettingsImplCopyWith<_$BusinessSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
