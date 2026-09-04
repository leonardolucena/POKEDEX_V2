import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/presentation/widgets/pokemon_animated_sprite.dart';
import 'package:pokedex/providers/pokemon_providers.dart';

class PokemonSpriteTransition extends ConsumerStatefulWidget {
  const PokemonSpriteTransition({
    super.key,
    required this.stageWidth,
    required this.stageHeight,
    required this.maxWidth,
    required this.maxHeight,
  });

  final double stageWidth;
  final double stageHeight;
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

  int? _displayedIndex;
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
        if (_incomingName != null) {
          final listState = ref.read(pokemonListNotifierProvider);
          final index = listState.items.indexWhere(
            (item) => item.name == _incomingName,
          );
          if (index >= 0) {
            _displayedIndex = index;
          }
        }
        _outgoingName = null;
        _incomingName = null;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncInitialSprite());
  }

  void _syncInitialSprite() {
    if (!mounted || _displayedIndex != null || _controller.isAnimating) return;

    final navigation = ref.read(pokedexNavigationProvider);
    final listState = ref.read(pokemonListNotifierProvider);
    if (listState.items.isEmpty) return;

    final index = navigation.index.clamp(0, listState.items.length - 1);
    setState(() {
      _displayedIndex = index;
      _displayedName = listState.items[index].name;
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
    if (_controller.isAnimating && _incomingName == newName) return;

    unawaited(_startAnimation(newName, direction));
  }

  Future<void> _startAnimation(
    String newName,
    PokedexNavigationDirection direction,
  ) async {
    await ref.read(pokemonSpritePreloaderProvider)(newName);
    if (!mounted) return;

    final listState = ref.read(pokemonListNotifierProvider);
    if (listState.items.isEmpty) return;

    final navigation = ref.read(pokedexNavigationProvider);
    final targetIndex = navigation.index.clamp(0, listState.items.length - 1);
    final targetName = listState.items[targetIndex].name;
    if (targetName != newName) return;

    if (_controller.isAnimating && _incomingName == newName) return;
    if (_displayedName == newName && !_controller.isAnimating) return;

    setState(() {
      _outgoingName = _displayedName ?? newName;
      _incomingName = newName;
      _configureAnimations(direction);
    });
    _controller.forward(from: 0);
  }

  void _handleNavigationChange(
    PokedexNavigationState? previous,
    PokedexNavigationState next,
  ) {
    if (previous?.index == next.index) return;

    final listState = ref.read(pokemonListNotifierProvider);
    if (listState.items.isEmpty) return;

    final safeIndex = next.index.clamp(0, listState.items.length - 1);
    final newName = listState.items[safeIndex].name;

    if (_displayedIndex == null) {
      if (previous != null && previous.index != next.index) {
        final previousIndex = previous.index.clamp(0, listState.items.length - 1);
        setState(() {
          _displayedIndex = previousIndex;
          _displayedName = listState.items[previousIndex].name;
        });
        _animateTo(newName, next.direction);
        return;
      }

      setState(() {
        _displayedIndex = safeIndex;
        _displayedName = newName;
      });
      return;
    }

    if (_displayedIndex == safeIndex && !_controller.isAnimating) return;
    _animateTo(newName, next.direction);
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

    ref.listen(pokemonListNotifierProvider, (previous, next) {
      if (next.items.isEmpty || _displayedIndex != null) return;
      _syncInitialSprite();
    });

    ref.listen(pokedexNavigationProvider, (previous, next) {
      _handleNavigationChange(previous, next);
    });

    final isAnimating = _outgoingName != null &&
        _incomingName != null &&
        (_controller.isAnimating || _controller.value > 0);

    if (isAnimating) {
      return ClipRect(
        child: SizedBox(
          width: widget.stageWidth,
          height: widget.stageHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _slideLayer(_incomingSlide, _incomingName!),
              _slideLayer(_outgoingSlide, _outgoingName!),
            ],
          ),
        ),
      );
    }

    return Center(child: _spriteFor(_displayedName ?? currentName));
  }

  Widget _slideLayer(Animation<Offset> animation, String pokemonName) {
    return SlideTransition(
      position: animation,
      child: SizedBox(
        width: widget.stageWidth,
        height: widget.stageHeight,
        child: Center(child: _spriteFor(pokemonName)),
      ),
    );
  }

  Widget _spriteFor(String pokemonName) {
    return PokemonAnimatedSprite(
      pokemonName: pokemonName,
      maxWidth: widget.maxWidth,
      maxHeight: widget.maxHeight,
    );
  }
}
