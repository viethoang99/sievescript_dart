class JmapError implements Exception {
  final String message;
  final String? type;
  final int? status;

  JmapError(this.message, {this.type, this.status});

  @override
  String toString() => 'JmapError: $message${type != null ? ' ($type)' : ''}';
}

class SieveScriptError extends JmapError {
  SieveScriptError(String message, {String? type, int? status})
      : super(message, type: type, status: status);
}

class BlobError extends JmapError {
  BlobError(String message, {String? type, int? status})
      : super(message, type: type, status: status);
}
