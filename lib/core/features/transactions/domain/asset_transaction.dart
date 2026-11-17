/// Вид операции по активу (domain_model §5); стабильное TEXT-значение в БД.
enum AssetTransactionKind { deposit, withdrawal, transferOut, transferIn }
