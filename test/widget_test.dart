import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/main.dart';
import 'package:pokedex/presentation/widgets/pokedex_device_header.dart';

void main() {
  testWidgets('Exibe a listagem após a splash', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PokedexApp()));

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.byType(PokedexDeviceHeader), findsOneWidget);
  });
}
