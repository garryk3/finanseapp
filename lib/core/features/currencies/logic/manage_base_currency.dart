import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';

/// Смена базовой валюты: меняет только presentation-базу, audit snapshots
/// в RUB остаются неизменными (BR-C-5).
abstract final class ManageBaseCurrency {
  static Future<void> call(SettingsRepository repository, String code) =>
      repository.setBaseCurrency(code);
}
