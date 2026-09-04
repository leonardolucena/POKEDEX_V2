import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/core/constants/app_assets.dart';
import 'package:pokedex/providers/pokemon_providers.dart';

class PokemonBackgroundTransition extends ConsumerStatefulWidget {
  const PokemonBackgroundTransition({super.key});

  @override
  ConsumerState<PokemonBackgroundTransition> createState() =>
      _PokemonBackgroundTransitionState();
}

class _PokemonBackgroundTransitionState
    extends ConsumerState<PokemonBackgroundTransition>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 320);

  late final AnimationController _controller;
  late Animation<Offset> _outgoingSlide;
  late Animation<Offset> _incomingSlide;
  late Animation<double> _outgoingOpacity;

  String _displayedAsset = AppAssets.campo;
  String? _outgoingAsset;
  String? _incomingAsset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _outgoingSlide = _offsetAnimation(begin: Offset.zero, end: Offset.zero);
    _incomingSlide = _offsetAnimation(begin: Offset.zero, end: Offset.zero);
    _outgoingOpacity = const AlwaysStoppedAnimation(1);
    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed || !mounted) return;
      setState(() {
        _displayedAsset = _incomingAsset ?? _displayedAsset;
        _outgoingAsset = null;
        _incomingAsset = null;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _setInitialAsset());
  }

  void _setInitialAsset() {
    if (!mounted || _controller.isAnimating) return;

    final navigation = ref.read(pokedexNavigationProvider);
    final listState = ref.read(pokemonListNotifierProvider);
    if (listState.items.isEmpty) return;

    final index = navigation.index.clamp(0, listState.items.length - 1);
    final asset = _assetForIndex(index);
    if (asset == null || asset == _displayedAsset) return;

    setState(() => _displayedAsset = asset);
  }

  Animation<Offset> _offsetAnimation({
    required Offset begin,
    required Offset end,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  Animation<double> _opacityAnimation({required double begin, required double end}) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  void _configureAnimations(PokedexNavigationDirection direction) {
    final forward = direction == PokedexNavigationDirection.forward;
    _outgoingSlide = _offsetAnimation(
      begin: Offset.zero,
      end: Offset(0, forward ? -1 : 1),
    );
    _incomingSlide = _offsetAnimation(
      begin: Offset(0, forward ? 1 : -1),
      end: Offset.zero,
    );
    _outgoingOpacity = _opacityAnimation(begin: 1, end: 0);
  }

  String? _assetForIndex(int index) {
    final listState = ref.read(pokemonListNotifierProvider);
    if (index < 0 || index >= listState.items.length) return null;

    final pokemonName = listState.items[index].name;
    final cached = ref
        .read(pokemonRepositoryProvider)
        .getCachedFeaturedDetails(pokemonName);
    if (cached == null) return null;

    return AppAssets.backgroundForTypes(cached.pokemon.types);
  }

  void _animateTo(String newAsset, PokedexNavigationDirection direction) {
    if (newAsset == _displayedAsset && !_controller.isAnimating) return;
    if (_controller.isAnimating && _incomingAsset == newAsset) return;

    setState(() {
      _outgoingAsset = _displayedAsset;
      _incomingAsset = newAsset;
      _configureAnimations(direction);
    });
    _controller.forward(from: 0);
  }

  void _tryUpdateBackground(int index, PokedexNavigationDirection direction) {
    final asset = _assetForIndex(index);
    if (asset == null) return;
    _animateTo(asset, direction);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(pokedexNavigationProvider);
    ref.watch(pokemonListNotifierProvider);

    ref.listen(pokedexNavigationProvider, (previous, next) {
      if (previous == null || previous.index == next.index) return;
      _tryUpdateBackground(next.index, next.direction);
    });

    ref.listen(featuredPokemonProvider, (previous, next) {
      if (_controller.isAnimating) return;

      next.whenData((featured) {
        final navigation = ref.read(pokedexNavigationProvider);
        final asset = _assetForIndex(navigation.index);
        if (asset == null) return;
        if (asset == _displayedAsset) return;

        _animateTo(asset, navigation.direction);
      });
    });

    final isAnimating = _outgoingAsset != null &&
        _incomingAsset != null &&
        (_controller.isAnimating || _controller.value > 0);

    if (isAnimating) {
      return ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SlideTransition(
              position: _incomingSlide,
              child: _wallpaper(_incomingAsset!),
            ),
            FadeTransition(
              opacity: _outgoingOpacity,
              child: SlideTransition(
                position: _outgoingSlide,
                child: _wallpaper(_outgoingAsset!),
              ),
            ),
          ],
        ),
      );
    }

    return _wallpaper(_displayedAsset);
  }

  Widget _wallpaper(String assetPath) {
    return SizedBox.expand(
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
      ),
    );
  }
}
