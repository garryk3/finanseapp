/// Справочник банков и брокеров (domain_model §3).
final class Subgroup {
  const Subgroup({required this.id, required this.kind, required this.name});

  final int id;
  final SubgroupKind kind;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subgroup &&
          other.id == id &&
          other.kind == kind &&
          other.name == name;

  @override
  int get hashCode => Object.hash(id, kind, name);
}

/// Вид справочника банков/брокеров.
enum SubgroupKind { bank, broker }
