/// Последний GitHub release.
final class ReleaseInfo {
  const ReleaseInfo({required this.tagName, this.htmlUrl, this.apkUrl});

  final String tagName;
  final String? htmlUrl;
  final String? apkUrl;
}

enum UpdateErrorKind { noReleases, network, invalid }

final class UpdateException implements Exception {
  const UpdateException(this.kind);

  final UpdateErrorKind kind;
}

abstract interface class UpdateService {
  Future<ReleaseInfo?> fetchLatestRelease();
}
