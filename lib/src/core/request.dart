import 'dart:convert';

class JmapRequest {
  final List<String> using;
  final List<List<dynamic>> methodCalls;
  final String? createdIds;

  JmapRequest({
    required this.using,
    required this.methodCalls,
    this.createdIds,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'using': using,
      'methodCalls': methodCalls,
    };

    if (createdIds != null) {
      map['createdIds'] = createdIds as List<Object>;
    }

    return map;
  }

  String encode() => jsonEncode(toJson());
}

class MethodCall {
  final String name;
  final Map<String, dynamic> arguments;
  final String clientId;

  MethodCall({
    required this.name,
    required this.arguments,
    required this.clientId,
  });

  List<dynamic> toList() => [name, arguments, clientId];

  static const Set<String> supportedMethods = {
    'Blob/upload',
    'Blob/copy',
    'SieveScript/get',
    'SieveScript/set',
    'SieveScript/validate',
    'SieveScript/query',
  };
}

class RequestBuilder {
  final List<String> _capabilities = [
    'urn:ietf:params:jmap:core',
    'urn:ietf:params:jmap:blob',
    'urn:ietf:params:jmap:sieve',
  ];
  final List<List<dynamic>> _methodCalls = [];
  String? _createdIds;

  void addCapability(String capability) {
    if (!_capabilities.contains(capability)) {
      _capabilities.add(capability);
    }
  }

  void addMethodCall(MethodCall call) {
    _methodCalls.add(call.toList());
  }

  void setCreatedIds(String ids) {
    _createdIds = ids;
  }

  JmapRequest build() {
    return JmapRequest(
      using: _capabilities,
      methodCalls: _methodCalls,
      createdIds: _createdIds,
    );
  }
}
