import 'dart:convert';
import 'dart:io';

import 'package:finanseapp/core/features/settings/domain/update_service.dart';

/// GitHub latest release через dart:io (UP-2), без отдельного http-клиента.
final class GithubUpdateService implements UpdateService {
  GithubUpdateService({
    this.timeout = const Duration(seconds: 12),
    this.httpGet,
  });

  static const apiUrl =
      'https://api.github.com/repos/garryk3/finanseapp/releases/latest';
  static const _apkSuffix = 'app-release.apk';

  final Duration timeout;
  final Future<({int status, String body})> Function()? httpGet;

  @override
  Future<ReleaseInfo?> fetchLatestRelease() async {
    final override = httpGet;
    if (override != null) {
      try {
        final response = await override();
        return _parse(response.status, response.body);
      } on UpdateException {
        rethrow;
      } on Exception {
        throw const UpdateException(UpdateErrorKind.network);
      }
    }
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(apiUrl)).timeout(timeout);
      final response = await request.close().timeout(timeout);
      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) {
        throw const UpdateException(UpdateErrorKind.network);
      }
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout);
      return _parse(200, body);
    } on UpdateException {
      rethrow;
    } on Exception {
      throw const UpdateException(UpdateErrorKind.network);
    } finally {
      client.close(force: true);
    }
  }

  ReleaseInfo? _parse(int status, String body) {
    if (status == 404) return null;
    if (status != 200) throw const UpdateException(UpdateErrorKind.network);
    try {
      final json = jsonDecode(body);
      if (json is! Map<String, dynamic>) {
        throw const UpdateException(UpdateErrorKind.invalid);
      }
      final tag = json['tag_name'];
      if (tag is! String || tag.trim().isEmpty) {
        throw const UpdateException(UpdateErrorKind.invalid);
      }
      final html = json['html_url'];
      final assets = json['assets'];
      String? apk;
      if (assets is List) {
        for (final asset in assets) {
          if (asset is Map &&
              asset['name'] == _apkSuffix &&
              asset['browser_download_url'] is String) {
            apk = asset['browser_download_url'] as String;
            break;
          }
        }
      }
      return ReleaseInfo(
        tagName: tag,
        htmlUrl: _safeHttps(html),
        apkUrl: _safeHttps(apk),
      );
    } on UpdateException {
      rethrow;
    } on FormatException {
      throw const UpdateException(UpdateErrorKind.invalid);
    } on Exception {
      throw const UpdateException(UpdateErrorKind.invalid);
    }
  }

  static String? _safeHttps(Object? value) {
    if (value is! String) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'https') return null;
    return value;
  }
}
