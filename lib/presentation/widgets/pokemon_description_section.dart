import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/presentation/widgets/pokemon_stats_radar_chart.dart';
import 'package:pokedex/presentation/widgets/pokemon_type_chip.dart';
import 'package:pokedex/providers/pokemon_providers.dart';
import 'package:pokedex/data/models/pokemon.dart';
import 'package:pokedex/data/models/pokemon_nature.dart';

abstract final class _DescriptionColors {
  static const infoLabelBlue = Color(0xFF00D4FF);
  static const infoValueYellow = Color(0xFFF0C84B);
}

class PokemonDescriptionSection extends ConsumerWidget {
  const PokemonDescriptionSection({
    super.key,
    required this.pokemon,
    required this.description,
    required this.genus,
    this.scrollEnabled = true,
  });

  final Pokemon pokemon;
  final String description;
  final String? genus;
  final bool scrollEnabled;

  static const _infoGap = 6.0;

  static const _sectionLabelStyle = TextStyle(
    color: _DescriptionColors.infoLabelBlue,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static const _descriptionStyle = TextStyle(
    color: _DescriptionColors.infoValueYellow,
    fontSize: 10,
    height: 1.55,
  );

  static const _metaStyle = TextStyle(
    color: _DescriptionColors.infoLabelBlue,
    fontSize: 9,
    height: 1.5,
    fontWeight: FontWeight.w600,
  );

  static const _metaValueStyle = TextStyle(
    color: _DescriptionColors.infoValueYellow,
    fontSize: 10,
    height: 1.5,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = scrollEnabled
        ? ref.watch(descriptionScrollControllerProvider)
        : null;
    final dexNumber = '#${pokemon.id.toString().padLeft(3, '0')}';
    final abilityText = pokemon.abilities
        .map(
          (ability) => ability.isHidden
              ? '${ability.displayName} (H)'
              : ability.displayName,
        )
        .join(', ');
    final nature = PokemonNature.forPokemonId(pokemon.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: scrollEnabled
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: pokemon.types.isNotEmpty ? 92 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Numero', style: _metaStyle),
                      const SizedBox(height: 2),
                      Text(dexNumber, style: _metaValueStyle),
                    ],
                  ),
                ),
                if (pokemon.types.isNotEmpty)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      alignment: WrapAlignment.end,
                      children: [
                        for (final type in pokemon.types)
                          PokemonTypeChip(type: type),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: _infoGap),
            if (genus != null)
              _MetaPair(
                leftLabel: 'Nome',
                leftValue: pokemon.displayName,
                rightLabel: 'Categoria',
                rightValue: genus!,
                labelStyle: _metaStyle,
                valueStyle: _metaValueStyle,
                minValueLines: 2,
                centerSingleLineValues: true,
              )
            else
              _MetaLine(
                label: 'Nome',
                value: pokemon.displayName,
                labelStyle: _metaStyle,
                valueStyle: _metaValueStyle,
                minValueLines: 2,
              ),
            const SizedBox(height: _infoGap),
            _MetaPair(
              leftLabel: 'Altura',
              leftValue: pokemon.formattedHeight,
              rightLabel: 'Peso',
              rightValue: pokemon.formattedWeight,
              labelStyle: _metaStyle,
              valueStyle: _metaValueStyle,
            ),
            if (abilityText.isNotEmpty) ...[
              const SizedBox(height: _infoGap),
              const Text('Habilidades', style: _metaStyle),
              const SizedBox(height: 2),
              Text(abilityText, style: _metaValueStyle),
            ],
            const SizedBox(height: _infoGap),
            _MetaLine(
              label: 'Natureza',
              value: nature.displayName,
              labelStyle: _metaStyle,
              valueStyle: _metaValueStyle,
            ),
            const SizedBox(height: 12),
            const Text('Descrição', style: _sectionLabelStyle),
            const SizedBox(height: 4),
            Text(description, style: _descriptionStyle),
            const SizedBox(height: 12),
            const Text('Estatísticas', style: _sectionLabelStyle),
            const SizedBox(height: 2),
            Align(
              child: PokemonStatsRadarChart(
                stats: pokemon.stats,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MetaPair extends StatelessWidget {
  const _MetaPair({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
    required this.labelStyle,
    required this.valueStyle,
    this.minValueLines = 1,
    this.centerSingleLineValues = false,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final int minValueLines;
  final bool centerSingleLineValues;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(leftLabel, style: labelStyle)),
            const SizedBox(width: 8),
            Expanded(child: Text(rightLabel, style: labelStyle)),
          ],
        ),
        const SizedBox(height: 2),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _MetaValueCell(
                  value: leftValue,
                  style: valueStyle,
                  minLines: minValueLines,
                  centerVertically: centerSingleLineValues,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetaValueCell(
                  value: rightValue,
                  style: valueStyle,
                  minLines: minValueLines,
                  centerVertically: centerSingleLineValues,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaValueCell extends StatelessWidget {
  const _MetaValueCell({
    required this.value,
    required this.style,
    required this.minLines,
    this.centerVertically = false,
  });

  final String value;
  final TextStyle style;
  final int minLines;
  final bool centerVertically;

  double get _lineHeight => (style.fontSize ?? 10) * (style.height ?? 1);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: _lineHeight * minLines),
      child: Align(
        alignment: centerVertically
            ? Alignment.centerLeft
            : Alignment.topLeft,
        child: Text(
          value,
          style: style,
          softWrap: true,
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
    this.minValueLines = 1,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final int minValueLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 2),
        _MetaValueCell(
          value: value,
          style: valueStyle,
          minLines: minValueLines,
        ),
      ],
    );
  }
}
