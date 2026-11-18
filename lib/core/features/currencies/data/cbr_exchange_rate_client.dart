import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/data/cbr_xml_parser.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

/// Клиент ЦБ РФ (`XML_daily.asp`), без кэша — его ведёт repository.
final class CbrExchangeRateClient {
  CbrExchangeRateClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;
  static const _endpoint = 'https://www.cbr.ru/scripts/XML_daily.asp';

  Future<CbrRateQuote> fetch(String currencyCode, LocalDate date) async {
    final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(_endpoint)
                .replace(queryParameters: {'date_req': _formatDate(date)}),
          )
          .timeout(timeout);
    } on Exception {
      throw const DomainException(
        DomainErrorCode.networkUnavailable,
        fieldErrors: {'network': 'validationNetworkUnavailable'},
      );
    }
    if (response.statusCode != 200) {
      throw const DomainException(
        DomainErrorCode.networkUnavailable,
        fieldErrors: {'network': 'validationNetworkUnavailable'},
      );
    }
    try {
      // ЦБ отдаёт windows-1251; для Valute/CharCode/Value достаточно ASCII,
      // а жёсткое декодирование latin1 не зависит от заголовка charset.
      return const CbrXmlParser().parse(
        latin1.decode(response.bodyBytes),
        currencyCode: currencyCode,
        requestedDate: date,
      );
    } on DomainException {
      rethrow;
    } on Exception {
      throw const DomainException(
        DomainErrorCode.rateUnavailable,
        fieldErrors: {'rate': 'validationRateUnavailable'},
      );
    }
  }

  static String _formatDate(LocalDate date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
