// Simple class representing a connection pair
class ConnectionPair {
  final String left;
  final String right;
  bool isConnected;

  ConnectionPair({
    required this.left,
    required this.right,
    this.isConnected = false,
  });
}
