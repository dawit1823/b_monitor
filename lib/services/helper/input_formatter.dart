import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter =
      NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 2);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-numeric characters
    final numericText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Format the number
    final doubleValue = double.tryParse(numericText) ?? 0.0;
    final formattedValue = _formatter.format(doubleValue);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
