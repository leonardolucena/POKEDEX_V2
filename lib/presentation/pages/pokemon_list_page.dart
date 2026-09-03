import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/core/theme/app_status_bar_style.dart';
import 'package:pokedex/presentation/widgets/pokedex_device_header.dart';

class PokemonListPage extends StatelessWidget {
  const PokemonListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppStatusBarStyle.light,
      child: Scaffold(
        backgroundColor: PokedexDeviceColors.backgroundRed,
        body: const SizedBox.expand(
          child: PokedexDeviceHeader(),
        ),
      ),
    );
  }
}
