/// Действие, породившее ревизию журнала (data_schema §1).
///
/// [restore] зарезервирован для P2, но входит в стабильный набор значений.
enum RevisionAction { create, edit, delete, restore }
