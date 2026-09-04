import 'package:translator/translator.dart';

abstract interface class DescriptionTranslator {
  Future<String> translateEnglishToPortuguese(String text);
}

class GoogleDescriptionTranslator implements DescriptionTranslator {
  GoogleDescriptionTranslator({GoogleTranslator? translator})
      : _translator = translator ?? GoogleTranslator();

  final GoogleTranslator _translator;

  @override
  Future<String> translateEnglishToPortuguese(String text) async {
    if (text.trim().isEmpty) return text;

    try {
      final result = await _translator.translate(text, from: 'en', to: 'pt');
      return result.text;
    } catch (_) {
      return text;
    }
  }
}

class PassthroughDescriptionTranslator implements DescriptionTranslator {
  @override
  Future<String> translateEnglishToPortuguese(String text) => Future.value(text);
}
