import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/items/domain/item.dart';

void main() {
  test('Item.fromJson handles an integer-valued taxRate (JSON numbers can decode as int)', () {
    final item = Item.fromJson({
      'id': 'i1',
      'description': 'Exported goods',
      'unitPrice': 5000,
      'unit': 'piece',
      'taxRate': 0,
      'category': null,
      'isActive': true,
    });

    expect(item.taxRate, 0.0);
    expect(item.category, isNull);
  });

  test('Item.fromJson handles a decimal taxRate and a category', () {
    final item = Item.fromJson({
      'id': 'i2',
      'description': 'Cement',
      'unitPrice': 13000,
      'unit': 'bag',
      'taxRate': 18.0,
      'category': 'Materials',
      'isActive': true,
    });

    expect(item.taxRate, 18.0);
    expect(item.category, 'Materials');
  });
}
