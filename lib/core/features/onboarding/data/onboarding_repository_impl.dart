import 'package:finanseapp/core/database/daos/settings_dao.dart';
import 'package:finanseapp/core/features/onboarding/domain/onboarding_repository.dart';

final class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._dao);

  static const completedKey = 'onboardingCompleted';

  final SettingsDao _dao;

  @override
  Future<bool> isCompleted() async =>
      await _dao.getValue(completedKey) == 'true';

  @override
  Future<void> complete() => _dao.setValue(completedKey, 'true');
}
