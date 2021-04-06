import 'package:dvote/util/normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void normalize() {
  test("Normalize latin diacritics", () {
    final paragraph = "àèìòùáéíóúâêîôûäëïöüãõÀÈÌÒÙÁÉÍÓÚÂÊÎÔÛÄËÏÖÜÃÕ";
    expect(Normalize.removeDiacritics(paragraph),
        "aeiouaeiouaeiouaeiouaoAEIOUAEIOUAEIOUAEIOUAO");
  });
}
