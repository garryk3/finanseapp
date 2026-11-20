import 'package:finanseapp/core/features/settings/data/github_update_service.dart';
import 'package:finanseapp/core/features/settings/domain/update_service.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

GithubUpdateService service(int status, String body) =>
    GithubUpdateService(httpGet: () async => (status: status, body: body));

void main() {
  test('404 → no releases, invalid JSON/tag → invalid', () async {
    expect(await service(404, '').fetchLatestRelease(), isNull);

    for (final body in ['not json', '{}', '{"tag_name": ""}']) {
      await expectLater(
        service(200, body).fetchLatestRelease(),
        throwsA(
          isA<UpdateException>().having(
            (error) => error.kind,
            'kind',
            UpdateErrorKind.invalid,
          ),
        ),
        reason: body,
      );
    }
  });

  test('500 → network', () async {
    await expectLater(
      service(500, '').fetchLatestRelease(),
      throwsA(
        isA<UpdateException>().having(
          (error) => error.kind,
          'kind',
          UpdateErrorKind.network,
        ),
      ),
    );
  });

  test('валидный ответ и только https-ссылки', () async {
    const body = '''
{"tag_name":"v1.2.3","html_url":"https://github.com/x","assets":[
 {"name":"app-release.apk","browser_download_url":"https://github.com/app.apk"},
 {"name":"other.apk","browser_download_url":"http://insecure"}
]}
''';
    final release = await service(200, body).fetchLatestRelease();
    expect(release?.tagName, 'v1.2.3');
    expect(release?.apkUrl, 'https://github.com/app.apk');
    expect(release?.htmlUrl, 'https://github.com/x');

    final insecure = await service(
      200,
      '{"tag_name":"v1","html_url":"http://x","assets":[{"name":"app-release.apk","browser_download_url":"javascript:alert(1)"}]}',
    ).fetchLatestRelease();
    expect(insecure?.htmlUrl, isNull);
    expect(insecure?.apkUrl, isNull);
  });

  test('timeout/offline → network', () async {
    for (final error in <Object>[
      TimeoutException('timeout'),
      const SocketException('offline'),
    ]) {
      await expectLater(
        GithubUpdateService(httpGet: () => Future.error(error))
            .fetchLatestRelease(),
        throwsA(
          isA<UpdateException>().having(
            (exception) => exception.kind,
            'kind',
            UpdateErrorKind.network,
          ),
        ),
      );
    }
  });
}
