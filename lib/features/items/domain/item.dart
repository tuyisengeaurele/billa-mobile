import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';
part 'item.g.dart';

// The server serialises database decimals as strings ("18.00"), while older
// responses and tests carry plain numbers, so both must parse.
double _taxRateFromJson(dynamic value) => value is num ? value.toDouble() : double.parse(value as String);

@freezed
class Item with _$Item {
  const factory Item({
    required String id,
    required String description,
    required int unitPrice,
    required String unit,
    @JsonKey(fromJson: _taxRateFromJson) required double taxRate,
    String? category,
    required bool isActive,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
