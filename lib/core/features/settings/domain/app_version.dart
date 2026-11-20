/// Версия приложения: только numeric core, beta/build отбрасываются (UP-2).
final class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);

  final int major, minor, patch;

  factory AppVersion.parse(String value) {
    var text = value.trim();
    if (text.startsWith('v') || text.startsWith('V')) {
      text = text.substring(1);
    }
    final plus = text.indexOf('+');
    if (plus >= 0) text = text.substring(0, plus);
    final dash = text.indexOf('-');
    if (dash >= 0) text = text.substring(0, dash);
    final parts = text.split('.');
    if (parts.isEmpty || parts.length > 3) {
      throw const FormatException('version components');
    }
    final numbers = <int>[];
    for (final part in parts) {
      if (part.isEmpty) throw const FormatException('empty component');
      final number = int.tryParse(part);
      if (number == null || number < 0) {
        throw const FormatException('invalid component');
      }
      numbers.add(number);
    }
    while (numbers.length < 3) {
      numbers.add(0);
    }
    return AppVersion(numbers[0], numbers[1], numbers[2]);
  }

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator >(AppVersion other) => compareTo(other) > 0;

  @override
  String toString() => '$major.$minor.$patch';
}
