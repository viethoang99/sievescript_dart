import 'dart:convert';

class JmapResponse {
  final List<List<dynamic>> methodResponses;
  final String sessionState;
  final Map<String, dynamic>? createdIds;

  JmapResponse({
    required this.methodResponses,
    required this.sessionState,
    this.createdIds,
  });

  factory JmapResponse.fromJson(Map<String, dynamic> json) {
    return JmapResponse(
      methodResponses: List<List<dynamic>>.from(json['methodResponses']),
      sessionState: json['sessionState'] as String,
      createdIds: json['createdIds'] as Map<String, dynamic>?,
    );
  }

  factory JmapResponse.fromString(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return JmapResponse.fromJson(json);
  }

  T? getMethodResponse<T>(String methodName) {
    for (final response in methodResponses) {
      if (response[0] == methodName) {
        return response[1] as T?;
      }
    }
    return null;
  }

  Map<String, dynamic>? getFirstResponse() {
    if (methodResponses.isNotEmpty && methodResponses[0].length > 1) {
      return methodResponses[0][1] as Map<String, dynamic>;
    }
    return null;
  }

  String? getCreatedId(String tempId) {
    return createdIds?[tempId] as String?;
  }

  bool hasError() {
    for (final response in methodResponses) {
      if (response.length > 1) {
        final methodResponse = response[1];
        if (methodResponse is Map<String, dynamic> &&
            methodResponse.containsKey('error')) {
          return true;
        }
      }
    }
    return false;
  }

  String? getError() {
    for (final response in methodResponses) {
      if (response.length > 1) {
        final methodResponse = response[1];
        if (methodResponse is Map<String, dynamic> &&
            methodResponse.containsKey('error')) {
          return methodResponse['error'] as String?;
        }
      }
    }
    return null;
  }
}

class MethodResponse {
  final String name;
  final Map<String, dynamic> arguments;
  final String clientId;

  MethodResponse({
    required this.name,
    required this.arguments,
    required this.clientId,
  });

  factory MethodResponse.fromList(List<dynamic> list) {
    return MethodResponse(
      name: list[0] as String,
      arguments: list[1] as Map<String, dynamic>,
      clientId: list[2] as String,
    );
  }
}
