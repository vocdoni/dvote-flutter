class ContentURI {
  List<String> _contentUri;

  /// The raw content URI string
  @override
  String toString() => _contentUri.join(",");

  /// The array of endpoints
  List<String> get items => _contentUri;

  /// The hash of all IPFS items
  String get ipfsHash {
    final val = _contentUri.firstWhere((item) => item.startsWith("ipfs://"),
        orElse: () => null);

    if (val != null)
      return val.replaceAll(RegExp("^ipfs://"), "");
    else
      return null;
  }

  /// The https endpoints
  List<String> get httpsItems =>
      _contentUri.where((item) => item.startsWith("https://")).toList();

  /// The http endpoints
  List<String> get httpItems =>
      _contentUri.where((item) => item.startsWith("http://")).toList();

  /// Parses the given string into a Content URI
  ContentURI(String contentUri) {
    if (contentUri == null || contentUri == "")
      throw Exception("Invalid contentUri");
    _contentUri = contentUri.split(",");
  }
}
