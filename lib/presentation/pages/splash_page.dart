import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/presentation/widgets/pokeball_face.dart';
import 'package:pokedex/providers/pokemon_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _topSlide;
  late final Animation<Offset> _bottomSlide;
  var _isDisposed = false;
  var _showOverlay = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _topSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(curve);

    _bottomSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(curve);

    _startSplash();
  }

  Future<void> _startSplash() async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await preloadPokedexData(ref);
        break;
      } catch (_) {
        if (attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          if (_isDisposed || !mounted) return;
        }
      }
    }

    if (_isDisposed || !mounted) return;

    await _controller.forward();

    if (_isDisposed || !mounted) return;

    setState(() => _showOverlay = false);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_showOverlay)
          Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SlideTransition(
                  position: _topSlide,
                  child: const PokeballTopHalf(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: _bottomSlide,
                  child: const PokeballBottomHalf(),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
