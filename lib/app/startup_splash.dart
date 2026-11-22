import 'dart:async';

import 'package:finanseapp/app/splash_screen.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Гейт холодного старта: видео-заставка до [duration], затем приложение.
///
/// Показывается с первого кадра, даже если DI/БД ещё собираются. Если приложение
/// не готово к концу заставки, показывается статичный loading-экран; как только
/// [child] появляется, он заменяет loading. За последние [fadeDuration] до
/// [duration] приложение монтируется поверх заставки и проявляется (видимая
/// заставка не дольше [duration]); при reduce-motion смена мгновенная.
/// Повторный child не перезапускает заставку (важно для restart после импорта
/// backup).
///
/// На не-Android (`enabled == false`) гейт прозрачен: child или пустой виджет,
/// поэтому Linux e2e не ждёт видео.
class StartupSplash extends StatefulWidget {
  const StartupSplash({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 2500),
    this.fadeDuration = const Duration(milliseconds: 200),
    this.splashBuilder,
  });

  /// Приложение; null — DI ещё не готов.
  final Widget? child;
  final bool enabled;
  final Duration duration;

  /// Проявление приложения поверх заставки в конце [duration].
  final Duration fadeDuration;

  /// Тестовый/альтернативный splash; по умолчанию [SplashScreen].
  final WidgetBuilder? splashBuilder;

  @override
  State<StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends State<StartupSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  Timer? _revealTimer;
  Timer? _finishTimer;
  late bool _done = !widget.enabled;
  bool _revealed = false;
  bool _fadeEnabled = false;

  @override
  void initState() {
    super.initState();
    // Создаём сразу: на Linux/в e2e (_done) dispose не должен трогать Ticker
    // деактивированного элемента.
    _fade = AnimationController(vsync: this, duration: widget.fadeDuration);
    // Отсчёт 2.5 с — от первого отрисованного кадра: прогрев движка/видео не
    // должен «съедать» заставку (QA TC-149).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _done) return;
      // _reset мог уже запустить таймеры до первого кадра.
      if (_revealTimer != null || _finishTimer != null) return;
      _start();
    });
  }

  @override
  void didUpdateWidget(covariant StartupSplash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child == null && widget.child != null) {
      if (!_done && _revealed) {
        // DI успел в окне 2.3–2.5 с: не появляемся на середине чужого фейда.
        if (_fadeEnabled && _fade.value < 1) {
          _fade
            ..value = 0
            ..forward();
        }
        return;
      }
      if (_done) {
        // DI дольше заставки: проявляем приложение вместо резкой подмены loading.
        if (_fadeEnabled) {
          _fade
            ..value = 0
            ..forward();
        }
        return;
      }
    }
    final restarted =
        oldWidget.enabled != widget.enabled ||
        oldWidget.duration != widget.duration ||
        oldWidget.fadeDuration != widget.fadeDuration;
    if (!restarted) return;
    _reset();
  }

  void _reset() {
    _revealTimer?.cancel();
    _finishTimer?.cancel();
    _fade
      ..stop()
      ..reset()
      ..duration = widget.fadeDuration;
    _done = !widget.enabled;
    _revealed = false;
    _fadeEnabled = false;
    _start();
  }

  void _start() {
    if (!widget.enabled || _done) return;
    final reduce = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    final fade = reduce ? Duration.zero : widget.fadeDuration;
    final revealAt = widget.duration - fade;
    if (fade > Duration.zero && revealAt > Duration.zero) {
      _fadeEnabled = true;
      _revealTimer = Timer(revealAt, () {
        if (!mounted) return;
        setState(() => _revealed = true);
        unawaited(_fade.forward());
      });
    }
    _finishTimer = Timer(widget.duration, () {
      if (!mounted) return;
      _fade.value = 1;
      setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _finishTimer?.cancel();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child ?? const SizedBox.shrink();
    final child = widget.child;
    final showSplash = !_done || child == null;
    final showApp = child != null && (_revealed || _done);
    return Stack(
      fit: StackFit.expand,
      // StartupSplash стоит выше MaterialApp: alignment не-directional.
      alignment: Alignment.topLeft,
      children: [
        // Непрозрачная база: под фейдом не проступает фон окна (light).
        const ColoredBox(color: AppTheme.splashBackground),
        if (showSplash)
          _splashApp(
            _done
                ? const StartupLoadingScreen()
                : widget.splashBuilder?.call(context) ?? const SplashScreen(),
          )
        else
          const SizedBox.shrink(),
        if (showApp) _appOverlay(child) else const SizedBox.shrink(),
      ],
    );
  }

  Widget _appOverlay(Widget child) => FadeTransition(
    opacity: _fade,
    child: AnimatedBuilder(
      animation: _fade,
      builder: (context, child) => IgnorePointer(
        ignoring: _fade.value < 1,
        child: ExcludeSemantics(excluding: _fade.value < 1, child: child),
      ),
      child: child,
    ),
  );

  Widget _splashApp(Widget home) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: ThemeMode.system,
    localizationsDelegates: const [
      ...GlobalMaterialLocalizations.delegates,
      AppLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ru')],
    home: home,
  );
}

/// Статичный экран между заставкой и готовым приложением (DI дольше 2.5 с).
class StartupLoadingScreen extends StatelessWidget {
  const StartupLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppTheme.splashForeground,
        ),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.splashOverlayStyle,
        child: ColoredBox(
          color: AppTheme.splashBackground,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpinner(semanticLabel: l10n.commonLoading),
                const SizedBox(height: AppSpacing.md),
                AppText(
                  l10n.appTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.splashForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
