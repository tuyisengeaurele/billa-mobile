import 'package:freezed_annotation/freezed_annotation.dart';

part 'two_factor_setup.freezed.dart';
part 'two_factor_setup.g.dart';

@freezed
class TwoFactorSetup with _$TwoFactorSetup {
  const factory TwoFactorSetup({
    required String secret,
    required String otpauthUrl,
    required String qrCodeDataUri,
  }) = _TwoFactorSetup;

  factory TwoFactorSetup.fromJson(Map<String, dynamic> json) => _$TwoFactorSetupFromJson(json);
}
