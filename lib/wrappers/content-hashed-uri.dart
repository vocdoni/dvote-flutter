import 'package:dvote/wrappers/content-uri.dart';

const CONTENT_URI_HASH_REGEX = r'![0-9a-f]+$';

class ContentHashedURI extends ContentURI {
  String _hash = "";

  String get hash => _hash;

  /// Parses the given string into a Content Hashed URI
  ContentHashedURI(String contentHashedUri)
      : super(contentHashedUri.replaceFirst(
            new RegExp(CONTENT_URI_HASH_REGEX), "")) {
    if (contentHashedUri == null || contentHashedUri == "")
      throw Exception("Invalid contentHashedUri");
    else if (0 < contentHashedUri.indexOf(new RegExp(CONTENT_URI_HASH_REGEX))) {
      // Extract the hash at the end
      RegExp regExp = new RegExp(CONTENT_URI_HASH_REGEX);
      final matches = regExp.allMatches(contentHashedUri);
      if (matches.length > 0) {
        _hash = matches.elementAt(0) as String;
      }
    }
  }
}
