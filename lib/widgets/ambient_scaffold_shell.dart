import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';

@immutable
class _AmbientStagePayload {
  final TrainingEnvironmentData environment;
  final bool showAura;

  const _AmbientStagePayload({
    required this.environment,
    required this.showAura,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AmbientStagePayload &&
          environment == other.environment &&
          showAura == other.showAura;

  @override
  int get hashCode => Object.hash(environment, showAura);
}

/// Coordinates active screen [TrainingEnvironmentData] for a single root
/// [GlobalAmbientStage] behind all routes and tabs.
class _AmbientStageController extends ChangeNotifier {
  static const _AmbientStagePayload _defaultPayload = _AmbientStagePayload(
    environment: TrainingEnvironmentData.idle(),
    showAura: true,
  );

  final Map<Object, _AmbientStagePayload> _entries =
      <Object, _AmbientStagePayload>{};
  bool _notifyScheduled = false;
  bool _disposed = false;

  _AmbientStagePayload get current =>
      _entries.isEmpty ? _defaultPayload : _entries.values.last;

  void activate(
    Object token,
    TrainingEnvironmentData environment, {
    required bool showAura,
  }) {
    final next = _AmbientStagePayload(
      environment: environment,
      showAura: showAura,
    );
    final before = current;
    final existing = _entries[token];
    if (existing == next &&
        _entries.isNotEmpty &&
        identical(_entries.keys.last, token)) {
      return;
    }
    _entries.remove(token);
    _entries[token] = next;
    if (before != current) {
      _scheduleNotify();
    }
  }

  void deactivate(Object token) {
    if (!_entries.containsKey(token)) return;
    final before = current;
    _entries.remove(token);
    if (before != current) {
      _scheduleNotify();
    }
  }

  void _scheduleNotify() {
    if (_disposed) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
      return;
    }
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      if (!_disposed) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class _AmbientStageScope extends InheritedWidget {
  final _AmbientStageController controller;

  const _AmbientStageScope({
    required this.controller,
    required super.child,
  });

  static _AmbientStageController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_AmbientStageScope>()
      ?.controller;

  @override
  bool updateShouldNotify(covariant _AmbientStageScope oldWidget) =>
      !identical(controller, oldWidget.controller);
}

Color _resolveSecondaryAuraColor(
  TrainingEnvironmentData env,
  InstrumentTheme instrument,
) {
  return switch (env.state) {
    TrainingEnvironmentState.cnsStorm => InstrumentPalette.stormCoral,
    TrainingEnvironmentState.deload => instrument.workingAura,
    TrainingEnvironmentState.workingVolume => instrument.deloadAura,
    TrainingEnvironmentState.liveExecution => env.accentColor(instrument),
  };
}

/// Root persistent obsidian canvas and continuously drifting physiological aura
/// placed in `MaterialApp.builder` behind the entire [Navigator].
///
/// Keeping one aura layer behind transparent routes and screens prevents phase
/// resets or hard page-edge gradient seams during navigation and ensures every
/// screen in the app inherits the ambient atmosphere.
class GlobalAmbientStage extends StatefulWidget {
  final Widget child;
  final bool? disableAnimationsOverride;

  const GlobalAmbientStage({
    super.key,
    required this.child,
    this.disableAnimationsOverride,
  });

  @override
  State<GlobalAmbientStage> createState() => _GlobalAmbientStageState();
}

class _GlobalAmbientStageState extends State<GlobalAmbientStage> {
  final _AmbientStageController _controller = _AmbientStageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final instrument = InstrumentTheme.of(context);
    final reducedMotion = widget.disableAnimationsOverride ??
        MediaQuery.disableAnimationsOf(context);
    final canvasColor =
        isDark ? InstrumentPalette.obsidianCanvas : theme.scaffoldBackgroundColor;

    return _AmbientStageScope(
      controller: _controller,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: canvasColor),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final active = _controller.current;
              final env = active.environment;
              final suppressAura = !active.showAura ||
                  env.state == TrainingEnvironmentState.liveExecution;
              if (suppressAura) {
                return const SizedBox.shrink();
              }
              final auraColor = env.accentColor(instrument);
              final isStorm = env.state == TrainingEnvironmentState.cnsStorm;
              return _DriftingAmbientAura(
                auraColor: auraColor,
                secondaryColor: _resolveSecondaryAuraColor(env, instrument),
                isDark: isDark,
                isStorm: isStorm,
                reducedMotion: reducedMotion,
              );
            },
          ),
          Theme(
            data: theme.copyWith(scaffoldBackgroundColor: Colors.transparent),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

/// Seamless foreground widget glide transition builder used across routes so
/// navigation moves UI modules over [GlobalAmbientStage] without page-edge
/// gradient cuts.
class SeamlessWidgetPageTransitionsBuilder extends PageTransitionsBuilder {
  const SeamlessWidgetPageTransitionsBuilder();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 340);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 280);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }

    final enterSlide = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    );
    final enterFade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.12, 1.0, curve: Curves.easeOutCubic),
    );
    final enterScale = Tween<double>(
      begin: 0.982,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    );

    final exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.05, 0),
    ).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOutCubic),
    );
    final exitFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    final exitScale = Tween<double>(
      begin: 1.0,
      end: 0.985,
    ).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOutCubic),
    );

    return FadeTransition(
      opacity: exitFade,
      child: SlideTransition(
        position: exitSlide,
        child: ScaleTransition(
          scale: exitScale,
          child: FadeTransition(
            opacity: enterFade,
            child: SlideTransition(
              position: enterSlide,
              child: ScaleTransition(
                scale: enterScale,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Layer 0 continuous obsidian canvas and top physiological radial aura shell.
///
/// Wraps [Scaffold] with `extendBody: true` and `extendBodyBehindAppBar: true`
/// so detached glass orbs/pills and scrolling telemetry cards share one
/// unbroken ambient surface.
///
/// Inside [GlobalAmbientStage], forwards its active [environment] to the shared
/// root aura so transitions remain continuous without duplicating gradient layers.
/// When rendered standalone (e.g. isolated widget tests), renders the cached
/// [RepaintBoundary] drifting aura locally. Automatically suppresses decorative
/// gradients and animations during [TrainingEnvironmentState.liveExecution] or
/// when `MediaQuery.disableAnimations` is true.
class AmbientScaffoldShell extends StatefulWidget {
  final TrainingEnvironmentData environment;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool showAura;
  final bool featherTopEdge;
  final bool? disableAnimationsOverride;

  const AmbientScaffoldShell({
    super.key,
    this.environment = const TrainingEnvironmentData.idle(),
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = true,
    this.extendBodyBehindAppBar = true,
    this.showAura = true,
    this.featherTopEdge = true,
    this.disableAnimationsOverride,
  });

  /// Returns `true` when mounted underneath a root [GlobalAmbientStage].
  static bool isHosted(BuildContext context) =>
      _AmbientStageScope.maybeOf(context) != null;

  /// Recommended top padding for scroll views underneath a detached header bar.
  static double topContentInset(BuildContext context, {double extra = 12}) {
    final safeTop = MediaQuery.paddingOf(context).top;
    return safeTop + kToolbarHeight + extra;
  }

  /// Recommended bottom padding for scroll views floating behind [CustomBottomNavBar].
  static double bottomContentInset(BuildContext context, {double extra = 16}) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return safeBottom + 86 + extra;
  }

  @override
  State<AmbientScaffoldShell> createState() => _AmbientScaffoldShellState();
}

class _AmbientScaffoldShellState extends State<AmbientScaffoldShell> {
  _AmbientStageController? _stage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextStage = _AmbientStageScope.maybeOf(context);
    if (!identical(_stage, nextStage)) {
      _stage?.deactivate(this);
      _stage = nextStage;
    }
    _syncStage();
  }

  @override
  void didUpdateWidget(covariant AmbientScaffoldShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.environment != widget.environment ||
        oldWidget.showAura != widget.showAura) {
      _syncStage();
    }
  }

  void _syncStage() {
    final stage = _stage;
    if (stage == null || !mounted) return;
    final routeCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    final tickerEnabled = TickerMode.of(context);
    if (routeCurrent && tickerEnabled) {
      stage.activate(this, widget.environment, showAura: widget.showAura);
    } else {
      stage.deactivate(this);
    }
  }

  @override
  void dispose() {
    _stage?.deactivate(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHosted = _stage != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final instrument = InstrumentTheme.of(context);
    final reducedMotion = widget.disableAnimationsOverride ??
        MediaQuery.disableAnimationsOf(context);
    final suppressAura = !widget.showAura ||
        widget.environment.state == TrainingEnvironmentState.liveExecution;

    final canvasColor = isHosted
        ? Colors.transparent
        : (isDark
            ? InstrumentPalette.obsidianCanvas
            : theme.scaffoldBackgroundColor);
    final auraColor = widget.environment.accentColor(instrument);
    final isStorm = widget.environment.state == TrainingEnvironmentState.cnsStorm;
    final safeTop = MediaQuery.paddingOf(context).top;
    final Widget maskedBody =
        widget.extendBodyBehindAppBar && widget.featherTopEdge && safeTop > 0
            ? ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) {
                  if (rect.height <= safeTop + 34) {
                    return const LinearGradient(
                      colors: [Colors.white, Colors.white],
                    ).createShader(rect);
                  }
                  final start = ((safeTop + 4.0) / rect.height).clamp(0.0, 1.0);
                  final end = ((safeTop + 34.0) / rect.height).clamp(start + 0.001, 1.0);
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                    ],
                    stops: [0.0, start, end, 1.0],
                  ).createShader(rect);
                },
                child: widget.body,
              )
            : widget.body;

    return Scaffold(
      backgroundColor: canvasColor,
      extendBody: widget.extendBody,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      appBar: widget.appBar,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      body: isHosted
          ? maskedBody
          : Stack(
              fit: StackFit.expand,
              children: [
                if (!suppressAura)
                  _DriftingAmbientAura(
                    auraColor: auraColor,
                    secondaryColor: _resolveSecondaryAuraColor(
                      widget.environment,
                      instrument,
                    ),
                    isDark: isDark,
                    isStorm: isStorm,
                    reducedMotion: reducedMotion,
                  ),
                maskedBody,
              ],
            ),
    );
  }
}

class _DriftingAmbientAura extends StatefulWidget {
  final Color auraColor;
  final Color secondaryColor;
  final bool isDark;
  final bool isStorm;
  final bool reducedMotion;

  const _DriftingAmbientAura({
    required this.auraColor,
    required this.secondaryColor,
    required this.isDark,
    required this.isStorm,
    required this.reducedMotion,
  });

  @override
  State<_DriftingAmbientAura> createState() => _DriftingAmbientAuraState();
}

class _DriftingAmbientAuraState extends State<_DriftingAmbientAura>
    with SingleTickerProviderStateMixin {
  static const Duration _orbitDuration = Duration(seconds: 9);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _orbitDuration,
    );
    _syncTickerState();
  }

  @override
  void didUpdateWidget(covariant _DriftingAmbientAura oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion) {
      _syncTickerState();
    }
  }

  void _syncTickerState() {
    if (widget.reducedMotion) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
      _controller.value = 0.0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAuraLayer(BoxDecoration decoration) {
    return RepaintBoundary(
      child: widget.reducedMotion
          ? DecoratedBox(decoration: decoration)
          : AnimatedContainer(
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              decoration: decoration,
            ),
    );
  }

  Widget _buildOrbitingLobe({
    required Widget child,
    required double xAmplitude,
    required double yAmplitude,
    required double yOffset,
    required double baseScale,
    required double scaleXAmplitude,
    required double scaleYAmplitude,
    required double phase,
    bool cosX = false,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      child: child,
      builder: (context, cachedChild) {
        final angle = _controller.value * 2 * math.pi + phase;
        final dx = (cosX ? math.cos(angle) : math.sin(angle)) * xAmplitude +
            math.sin(angle * 2 + phase) * (xAmplitude * 0.22);
        final dy = yOffset + math.sin(angle * 2 + 0.6) * yAmplitude;
        final sx = baseScale + math.sin(angle + 0.4) * scaleXAmplitude;
        final sy = baseScale + math.cos(angle * 2) * scaleYAmplitude;
        return Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.translationValues(dx, dy, 0.0)
            ..scaleByDouble(sx, sy, 1.0, 1.0),
          child: cachedChild,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryDecoration = BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(0, -0.72),
        radius: 0.62,
        colors: [
          widget.auraColor.withValues(alpha: widget.isDark ? 0.36 : 0.20),
          (widget.isStorm ? InstrumentPalette.stormCoral : widget.auraColor)
              .withValues(alpha: widget.isDark ? 0.14 : 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.38, 1.0],
      ),
    );

    final secondaryDecoration = BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(0.18, -0.64),
        radius: 0.54,
        colors: [
          widget.secondaryColor.withValues(alpha: widget.isDark ? 0.26 : 0.14),
          widget.auraColor.withValues(alpha: widget.isDark ? 0.08 : 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 1.0],
      ),
    );

    final primaryLayer = _buildAuraLayer(primaryDecoration);
    final secondaryLayer = _buildAuraLayer(secondaryDecoration);

    if (widget.reducedMotion) {
      return Positioned(
        top: -90,
        left: -180,
        right: -180,
        height: 540,
        child: IgnorePointer(
          key: const ValueKey<String>('drifting_ambient_aura'),
          child: primaryLayer,
        ),
      );
    }

    return Positioned(
      top: -90,
      left: -200,
      right: -200,
      height: 540,
      child: IgnorePointer(
        key: const ValueKey<String>('drifting_ambient_aura'),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildOrbitingLobe(
              child: primaryLayer,
              xAmplitude: 108.0,
              yAmplitude: 32.0,
              yOffset: 8.0,
              baseScale: 1.0,
              scaleXAmplitude: 0.14,
              scaleYAmplitude: 0.12,
              phase: 0.0,
            ),
            _buildOrbitingLobe(
              child: secondaryLayer,
              xAmplitude: 132.0,
              yAmplitude: 40.0,
              yOffset: 14.0,
              baseScale: 1.02,
              scaleXAmplitude: 0.16,
              scaleYAmplitude: 0.12,
              phase: 1.4,
              cosX: true,
            ),
          ],
        ),
      ),
    );
  }
}
