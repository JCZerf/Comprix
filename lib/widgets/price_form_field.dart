import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/price_helper.dart';

class BrazilianCurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Se o texto está sendo apagado
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove tudo exceto números
    String numbers = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (numbers.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Limita a 8 dígitos (999.999,99)
    if (numbers.length > 8) {
      numbers = numbers.substring(0, 8);
    }

    // Converte para formato brasileiro
    int centavos = int.parse(numbers);
    String formatted = PriceHelper.centavosToFormattedStringNoSymbol(centavos);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PriceFormField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final int? initialCentavos;
  final Function(int centavos)? onSaved;
  final Function(int centavos)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final InputDecoration? decoration;

  const PriceFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.initialCentavos,
    this.onSaved,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialCentavos != null
          ? PriceHelper.centavosToFormattedStringNoSymbol(initialCentavos!)
          : '',
      decoration:
          decoration ??
          InputDecoration(
            labelText: labelText ?? 'Preço',
            hintText: hintText ?? '0,00',
            prefixIcon: const Icon(Icons.attach_money),
            prefixText: 'R\$ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
      keyboardType: TextInputType.number,
      inputFormatters: [BrazilianCurrencyInputFormatter()],
      enabled: enabled,
      onChanged: (value) {
        if (onChanged != null) {
          int centavos = PriceHelper.formattedStringToCentavos(value);
          onChanged!(centavos);
        }
      },
      onSaved: (value) {
        if (onSaved != null) {
          int centavos = PriceHelper.formattedStringToCentavos(value ?? '');
          onSaved!(centavos);
        }
      },
      validator: validator != null ? (value) => validator!(value) : null,
    );
  }
}
