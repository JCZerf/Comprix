import 'package:intl/intl.dart';

class PriceHelper {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final NumberFormat _formatterNoSymbol = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  /// Converte centavos para string formatada (ex: 150000 -> "R\$ 1.500,00")
  static String centavosToFormattedString(int centavos) {
    double reais = centavos / 100.0;
    return _formatter.format(reais);
  }

  /// Converte centavos para string formatada sem símbolo (ex: 150000 -> "1.500,00")
  static String centavosToFormattedStringNoSymbol(int centavos) {
    double reais = centavos / 100.0;
    return _formatterNoSymbol.format(reais).trim();
  }

  /// Converte string formatada para centavos (ex: "1.500,00" -> 150000)
  static int formattedStringToCentavos(String formatted) {
    // Remove todos os caracteres não numéricos exceto vírgula
    String cleanValue = formatted.replaceAll(RegExp(r'[^\d,]'), '');

    // Se estiver vazio, retorna 0
    if (cleanValue.isEmpty) return 0;

    // Se não tem vírgula, assume que são reais inteiros
    if (!cleanValue.contains(',')) {
      return int.tryParse(cleanValue + '00') ?? 0;
    }

    // Separa reais e centavos
    List<String> parts = cleanValue.split(',');
    int reais = int.tryParse(parts[0]) ?? 0;

    // Garante que centavos tem 2 dígitos
    String centavosStr = parts.length > 1 ? parts[1] : '00';
    if (centavosStr.length == 1) centavosStr += '0';
    if (centavosStr.length > 2) centavosStr = centavosStr.substring(0, 2);

    int centavos = int.tryParse(centavosStr) ?? 0;

    return (reais * 100) + centavos;
  }

  /// Converte centavos para double (para compatibilidade)
  static double centavosToDouble(int centavos) {
    return centavos / 100.0;
  }

  /// Converte double para centavos
  static int doubleToCentavos(double value) {
    return (value * 100).round();
  }

  /// Valida se a string é um valor monetário válido
  static bool isValidMoneyString(String value) {
    if (value.isEmpty) return true; // Permite vazio

    // Remove caracteres permitidos e verifica se sobra algo inválido
    String cleaned = value.replaceAll(RegExp(r'[\d\.,\s]'), '');
    return cleaned.isEmpty;
  }

  /// Formata valor durante a digitação
  static String formatWhileTyping(String value) {
    // Remove tudo exceto números
    String numbers = value.replaceAll(RegExp(r'[^\d]'), '');

    if (numbers.isEmpty) return '';

    // Converte para centavos
    int centavos = int.parse(numbers);

    // Converte para formato brasileiro
    return centavosToFormattedStringNoSymbol(centavos);
  }
}
