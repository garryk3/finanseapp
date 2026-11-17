/// Справочник банков и брокеров (domain_model §3).
final class Subgroup {
  const Subgroup({required this.id, required this.kind, required this.name});

  final int id;
  final SubgroupKind kind;
  final String name;
}

/// Вид справочника банков/брокеров.
enum SubgroupKind { bank, broker }
