import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:finanseapp/app/theme/app_theme.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

/// Полноэкранная видео-заставка холодного старта (S1/S2).
///
/// Показывает центральный квадрат 1:1 из `finsplash.mp4`: исходник 16:9
/// обрезается по бокам, кошелёк/график остаются в центре. Звук выключен.
/// До готовности видео (и при `disableAnimations`) виден постер — первый кадр
/// в той же геометрии, поэтому подмена незаметна. Ошибка инициализации не
/// блокирует приложение: остаётся постер.
///
/// Длительность показа контролирует [StartupSplash] (2.5 с), а не этот экран.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.assetPath = 'assets/video/finsplash.mp4',
    this.posterPath = 'assets/video/finsplash_poster.png',
  });

  final String assetPath;
  final String posterPath;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  bool _reduceMotion = false;
  bool _showVideo = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initVideo());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce == _reduceMotion) return;
    _reduceMotion = reduce;
    if (reduce) {
      if (_showVideo) setState(() => _showVideo = false);
      unawaited(_controller?.pause() ?? Future<void>.value());
    }
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset(
      widget.assetPath,
      // Без звука и без захвата аудиофокуса: музыка пользователя не встаёт на паузу.
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setVolume(0);
      await controller.setLooping(false);
      await controller.seekTo(Duration.zero);
      if (!mounted || _reduceMotion) return;
      await controller.play();
      if (!mounted) return;
      setState(() => _showVideo = true);
    } catch (error, stackTrace) {
      // Постер уже на экране: заставка остаётся брендированной без видео.
      developer.log(
        'Splash video unavailable, showing poster',
        name: 'finanseapp.splash',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void dispose() {
    unawaited(_controller?.dispose() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.splashOverlayStyle,
      child: ColoredBox(
        color: AppTheme.splashBackground,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = math.min(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              return Semantics(
                container: true,
                image: true,
                label: l10n.appTitle,
                child: ExcludeSemantics(
                  child: SizedBox(
                    width: side,
                    height: side,
                    child: ClipRect(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _zoomed(_poster()),
                          if (_showVideo) _zoomed(_video()),
                          const _EdgeFades(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _poster() => DecoratedBox(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(widget.posterPath),
        fit: BoxFit.cover,
      ),
    ),
  );

  Widget _video() {
    final controller = _controller!;
    final size = controller.value.size;
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(controller),
      ),
    );
  }

  /// Небольшой зум прячет яркую кромку боковых панелей исходника.
  Widget _zoomed(Widget child) => Transform.scale(scale: 1.03, child: child);
}

/// Градиентные шторки по краям квадрата: стык видео с фоном не виден.
class _EdgeFades extends StatelessWidget {
  const _EdgeFades();

  static const double _vertical = 40;
  static const double _horizontal = 24;

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _vertical,
            child: _EdgeFade(begin: Alignment.topCenter),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: _vertical,
            child: _EdgeFade(begin: Alignment.bottomCenter),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: _horizontal,
            child: _EdgeFade(begin: Alignment.centerLeft),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: _horizontal,
            child: _EdgeFade(begin: Alignment.centerRight),
          ),
        ],
      ),
    );
  }
}

/// Одна шторка: [begin] — непрозрачный фон заставки, к центру — прозрачность.
class _EdgeFade extends StatelessWidget {
  const _EdgeFade({required this.begin});

  final Alignment begin;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: Alignment(-begin.x, -begin.y),
          colors: const [
            AppTheme.splashBackground,
            AppTheme.splashBackgroundTransparent,
          ],
        ),
      ),
    );
  }
}
