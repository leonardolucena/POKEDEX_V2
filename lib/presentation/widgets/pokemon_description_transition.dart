import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/presentation/widgets/pokemon_description_section.dart';
import 'package:pokedex/providers/pokemon_providers.dart';

class PokemonDescriptionTransition extends ConsumerStatefulWidget {
  const PokemonDescriptionTransition({super.key});

  @override
  ConsumerState<PokemonDescriptionTransition> createState() =>
      _PokemonDescriptionTransitionState();
}

class _PokemonDescriptionTransitionState
    extends ConsumerState<PokemonDescriptionTransition>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 320);

  late final AnimationController _controller;
  late Animation<Offset> _outgoingSlide;
  late Animation<Offset> _incomingSlide;
  late Animation<double> _outgoingOpacity;

  FeaturedPokemonDetails? _displayedDetails;
  FeaturedPokemonDetails? _outgoingDetails;
  FeaturedPokemonDetails? _incomingDetails;

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
        _displayedDetails = _incomingDetails ?? _displayedDetails;
        _outgoingDetails = null;
        _incomingDetails = null;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _setInitialDetails());
  }

  void _setInitialDetails() {
    if (!mounted || _controller.isAnimating) return;

    final navigation = ref.read(pokedexNavigationProvider);
    final cached = _detailsForIndex(navigation.index);
    if (cached != null) {
      setState(() => _displayedDetails = cached);
      return;
    }

    final featured = ref.read(featuredPokemonProvider);
    featured.whenData((details) {
      if (mounted && _displayedDetails == null) {
        setState(() => _displayedDetails = details);
      }
    });
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
      end: Offset(0, forward ? 1 : -1),
    );
    _incomingSlide = _offsetAnimation(
      begin: Offset(0, forward ? 1 : -1),
      end: Offset.zero,
    );
    _outgoingOpacity = _opacityAnimation(begin: 1, end: 0);
  }

  FeaturedPokemonDetails? _detailsForIndex(int index) {
    final listState = ref.read(pokemonListNotifierProvider);
    if (index < 0 || index >= listState.items.length) return null;

    return ref
        .read(pokemonRepositoryProvider)
        .getCachedFeaturedDetails(listState.items[index].name);
  }

  void _animateTo(
    FeaturedPokemonDetails newDetails,
    PokedexNavigationDirection direction,
  ) {
    if (_displayedDetails?.pokemon.id == newDetails.pokemon.id &&
        !_controller.isAnimating) {
      return;
    }
    if (_controller.isAnimating &&
        _incomingDetails?.pokemon.id == newDetails.pokemon.id) {
      return;
    }

    setState(() {
      _outgoingDetails = _displayedDetails;
      _incomingDetails = newDetails;
      _configureAnimations(direction);
    });
    _controller.forward(from: 0);
  }

  void _tryUpdateDetails(int index, PokedexNavigationDirection direction) {
    final details = _detailsForIndex(index);
    if (details == null) return;
    _animateTo(details, direction);
  }

  Widget _sectionFor(
    FeaturedPokemonDetails details, {
    bool animated = false,
  }) {
    return PokemonDescriptionSection(
      key: ValueKey('${details.pokemon.id}-$animated'),
      pokemon: details.pokemon,
      description: details.description,
      genus: details.genus,
      scrollEnabled: !animated,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredAsync = ref.watch(featuredPokemonProvider);

    ref.listen(pokedexNavigationProvider, (previous, next) {
      if (previous == null || previous.index == next.index) return;
      _tryUpdateDetails(next.index, next.direction);
    });

    ref.listen(featuredPokemonProvider, (previous, next) {
      if (_controller.isAnimating) return;

      next.whenData((featured) {
        final navigation = ref.read(pokedexNavigationProvider);
        final cached = _detailsForIndex(navigation.index);
        final details = cached ?? featured;
        if (_displayedDetails?.pokemon.id == details.pokemon.id) return;

        _animateTo(details, navigation.direction);
      });
    });

    if (_displayedDetails == null) {
      return featuredAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
        error: (error, stackTrace) => _errorContent(),
        data: (featured) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _displayedDetails == null) {
              setState(() => _displayedDetails = featured);
            }
          });
          return _sectionFor(featured);
        },
      );
    }

    final isAnimating = _outgoingDetails != null &&
        _incomingDetails != null &&
        (_controller.isAnimating || _controller.value > 0);

    if (isAnimating) {
      return ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SlideTransition(
              position: _incomingSlide,
              child: _sectionFor(_incomingDetails!, animated: true),
            ),
            FadeTransition(
              opacity: _outgoingOpacity,
              child: SlideTransition(
                position: _outgoingSlide,
                child: _sectionFor(_outgoingDetails!, animated: true),
              ),
            ),
          ],
        ),
      );
    }

    return featuredAsync.maybeWhen(
      error: (error, stackTrace) => _errorContent(),
      orElse: () => _sectionFor(_displayedDetails!),
    );
  }

  Widget _errorContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Falha ao carregar os dados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => reloadPokedexData(ref),
              child: const Text(
                'Tentar novamente',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
