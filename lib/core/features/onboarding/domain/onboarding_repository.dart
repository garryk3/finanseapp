/// Флаг первичного онбординга; хранится в app_settings и переносится backup.
abstract interface class OnboardingRepository {
  Future<bool> isCompleted();

  Future<void> complete();
}
