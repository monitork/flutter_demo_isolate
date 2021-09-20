import 'package:slug_it/slug_it.dart';

class CustomSlug extends SlugIT {
  @override
  String makeSlug(String text, {String separator = '-'}) {
    var old = super.makeSlug(text, separator: separator);
    return _addAbc(old);
  }

  _addAbc(String text) {
    return text + 'abc';
  }
}
