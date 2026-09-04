import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/presentation/widgets/pokemon_animated_sprite.dart';
import 'package:pokedex/providers/pokemon_providers.dart';

class PokemonSpriteTransition extends ConsumerStatefulWidget {
  const PokemonSpriteTransition({
    super.key,
    required this.maxWidth,
    required this.maxHeight,
  });

  final double maxWidth;
  final double maxHeight;

  @override
  ConsumerState<PokemonSpriteTransition> createState() =>
      _PokemonSpriteTransitionState();
}

class _PokemonSpriteTransitionState extends ConsumerState<PokemonSpriteTransition>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 320);

  late final AnimationController _controller;
  late Animation<Offset> _outgoingSlide;
  late Animation<Offset> _incomingSlide;

  String? _displayedName;
  String? _outgoingName;
  String? _incomingName;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _outgoingSlide = _slideAnimation(begin: Offset.zero, end: Offset.zero);
    _incomingSlide = _slideAnimation(begin: Offset.zero, end: Offset.zero);
    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed || !mounted) return;
      setState(() {
        _displayedName = _incomingName;
        _outgoingName = null;
        _incomingName = null;
      });
    });
  }

  Animation<Offset> _slideAnimation({
    required Offset begin,
    required Offset end,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  void _configureAnimations(PokedexNavigationDirection direction) {
    final forward = direction == PokedexNavigationDirection.forward;
    _outgoingSlide = _slideAnimation(
      begin: Offset.zero,
      end: Offset(forward ? -1 : 1, 0),
    );
    _incomingSlide = _slideAnimation(
      begin: Offset(forward ? 1 : -1, 0),
      end: Offset.zero,
    );
  }

  void _animateTo(String newName, PokedexNavigationDirection direction) {
    if (_displayedName == newName) return;

    _outgoingName = _displayedName ?? newName;
    _incomingName = newName;
    _configureAnimations(direction);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigation = ref.watch(pokedexNavigationProvider);
    final listState = ref.watch(pokemonListNotifierProvider);

    if (listState.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final index = navigation.index.clamp(0, listState.items.length - 1);
    final currentName = listState.items[index].name;
    _displayedName ??= currentName;

    ref.listen(pokedexNavigationProvider, (previous, next) {
      if (previous == null || previous.index == next.index) return;

      final safeIndex = next.index.clamp(0, listState.items.length - 1);
      _animateTo(listState.items[safeIndex].name, next.direction);
    });

    final isAnimating =
        _outgoingName != null && _incomingName != null && _controller.isAnimating;

    if (isAnimating || (_controller.value > 0 && _incomingName != null)) {
      return ClipRect(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SlideTransition(
              position: _outgoingSlide,
              child: _spriteFor(_outgoingName!),
            ),
            SlideTransition(
              position: _incomingSlide,
              child: _spriteFor(_incomingName!),
            ),
          ],
        ),
      );
    }

    return Center(child: _spriteFor(_displayedName ?? currentName));
  }

  Widget _spriteFor(String pokemonName) {
    return PokemonAnimatedSprite(
      pokemonName: pokemonName,
      maxWidth: widget.maxWidth,
      maxHeight: widget.maxHeight,
    );
  }
}
