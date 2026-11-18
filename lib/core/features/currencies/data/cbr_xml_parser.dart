import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:xml/xml.dart';

/// Результат разбора строки ЦБ: курс к рублю на дату документа.
final class CbrRateQuote {
  const CbrRateQuote({required this.date, required this.rateToRub});

  final LocalDate date;
  final Decimal rateToRub;
}

/// Парсер `XML_daily.asp` ЦБ РФ (BR-C-1/2).
///
/// `rateToRub = Value / Nominal`; дата документа обязана совпадать с
/// запрошенной, иначе курс считается недоступным (никаких «ближайших» дат).
final class CbrXmlParser {
  const CbrXmlParser();

  CbrRateQuote parse(
    String xml, {
    required String currencyCode,
    required LocalDate requestedDate,
  }) {
    final document = XmlDocument.parse(xml);
    final documentDate = _parseDate(
      document.rootElement.getAttribute('Date') ?? '',
    );
    if (documentDate == null || documentDate != requestedDate) {
      throw const DomainException(
        DomainErrorCode.rateUnavailable,
        fieldErrors: {'date': 'validationRateUnavailable'},
      );
    }

    for (final valute in document.findAllElements('Valute')) {
      if (valute.getElement('CharCode')?.innerText.trim() != currencyCode) {
        continue;
      }
      final nominal = _decimal(valute.getElement('Nominal')?.innerText);
      final value = _decimal(valute.getElement('Value')?.innerText);
      if (nominal == null ||
          value == null ||
          nominal <= Decimal.zero ||
          value <= Decimal.zero) {
        break;
      }
      return CbrRateQuote(
        date: documentDate,
        rateToRub: _divide(value, nominal),
      );
    }
    throw const DomainException(
      DomainErrorCode.rateUnavailable,
      fieldErrors: {'currencyCode': 'validationRateUnavailable'},
    );
  }

  static Decimal _divide(Decimal value, Decimal nominal) {
    final rational = value.toRational() / nominal.toRational();
    // Курс хранится Decimal с точностью 10 знаков; типовые Nominal/Value
    // делятся нацело, округление затрагивает только редкие иррациональные
    // хвосты и не влияет на RUB-snapshot операций (они считаются из Value).
    final scaled = rational.numerator * BigInt.from(10).pow(10);
    final units = scaled ~/ rational.denominator;
    final rounded =
        (scaled % rational.denominator) * BigInt.two >= rational.denominator
        ? units + BigInt.one
        : units;
    return Decimal.fromBigInt(rounded).shift(-10);
  }

  static Decimal? _decimal(String? raw) {
    if (raw == null) return null;
    final normalized = raw.trim().replaceAll(',', '.');
    return Decimal.tryParse(normalized);
  }

  static LocalDate? _parseDate(String raw) {
    final parts = raw.split('.');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    try {
      return LocalDate(year, month, day);
    } on DomainException {
      return null;
    }
  }
}
