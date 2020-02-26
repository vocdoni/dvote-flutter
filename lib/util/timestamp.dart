/// Returns a timestamp in seconds, as expected by the Gateway
int getTimestampForGateway() {
  return (DateTime.now().millisecondsSinceEpoch / 1000).floor();
}

/// Returns the current timestamp in milliseconds
int getTimestamp() {
  return DateTime.now().millisecondsSinceEpoch;
}
