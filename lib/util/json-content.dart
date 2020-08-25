import 'dart:convert';

/// Returns a serialized, reproduceable string from the JSON body, used to compute signatures
String serializeJsonBody(dynamic body) {
  // Ensure alphabetically ordered key names
  final sortedData = sortJsonFields(body);
  return jsonEncode(sortedData);
}

/// Signatures need to be computed over objects that can be 100% reproduceable.
/// Since the ordering is not guaranteed, this function returns a recursively
/// ordered map
dynamic sortJsonFields(dynamic data) {
  if (!(data is Map) && !(data is List))
    return data;
  else if (data is List) {
    return data.map((item) => sortJsonFields(item)).cast().toList();
  }

  final keys = <String>[];
  final result = Map<String, dynamic>();

  data.forEach((k, v) {
    keys.add(k);
  });
  keys.sort((String a, String b) => a.compareTo(b));
  keys.forEach((k) {
    result[k] = sortJsonFields(data[k]);
  });
  return result;
}
