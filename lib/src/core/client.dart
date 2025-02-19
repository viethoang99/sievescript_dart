import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/blob_service.dart';
import '../services/sieve_service.dart';
import 'session.dart';
import 'errors.dart';

class JmapClient {
  final String baseUrl;
  final String accessToken; // Changed from private to public
  final http.Client _httpClient;
  late final Session _session;
  late final BlobService blobs;
  late final SieveService sieveScripts;
  bool _isDisposed = false;

  JmapClient({
    required this.baseUrl,
    required this.accessToken,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  // Add logging utility methods
  void _logRequest(
      String method, Uri url, Map<String, String> headers, dynamic body) {
    print('\n🌐 JMAP Request:');
    print('📍 URL: ${url.toString()}');
    print('📝 Method: $method');
    print('🔑 Headers:');
    headers.forEach((key, value) => print(
        '  $key: ${key.toLowerCase() == 'authorization' ? '[REDACTED]' : value}'));
    if (body != null) {
      print('📦 Body:');
      print(const JsonEncoder.withIndent('  ').convert(body));
    }
  }

  void _logResponse(http.Response response, dynamic decodedBody) {
    print('\n📩 JMAP Response:');
    print('📊 Status: ${response.statusCode}');
    print('🔑 Headers:');
    response.headers.forEach((key, value) => print('  $key: $value'));
    print('📦 Body:');
    print(const JsonEncoder.withIndent('  ').convert(decodedBody));
  }

  Future<void> initialize() async {
    if (_isDisposed) {
      throw StateError('Client is disposed');
    }

    try {
      final url = Uri.parse('$baseUrl/.well-known/jmap');
      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      _logRequest('GET', url, headers, null);

      final response = await _httpClient.get(url, headers: headers);

      final decodedBody = jsonDecode(response.body);
      _logResponse(response, decodedBody);

      if (response.statusCode != 200) {
        throw JmapError('Failed to initialize session: ${response.statusCode}');
      }

      _session = Session.fromJson(decodedBody);
      _session.printDebug();

      blobs = BlobService(this);
      sieveScripts = SieveService(this);
    } catch (e, stackTrace) {
      print('❌ Error during initialization: $e');
      print('📚 Stack trace: $stackTrace');
      _isDisposed = true;
      _httpClient.close();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendRequest(Map<String, dynamic> request) async {
    final url = Uri.parse(_session.apiUrl);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json;jmapVersion=rfc-8621',
    };

    _logRequest('POST', url, headers, request);

    final response = await _httpClient.post(
      url,
      headers: headers,
      body: jsonEncode(request),
    );

    final decodedBody = jsonDecode(response.body);
    _logResponse(response, decodedBody);

    if (response.statusCode != 200) {
      throw JmapError(
        'Request failed: ${response.statusCode}',
        status: response.statusCode,
      );
    }

    return decodedBody;
  }

  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      _httpClient.close();
    }
  }

  bool get isDisposed => _isDisposed;

  // Add getter for internal access
  String get _accessToken => accessToken;

  String getDefaultAccountId() {
    //log the primary account
    // print('Primary Account: ${_session.getPrimaryAccount()}');
    return _session.getPrimaryAccount() ??
        (throw JmapError('No accounts available in session'));
  }

  // Add session getters
  Session get session => _session;
  String get sessionState => _session.getPrimaryAccount() ?? 'dc';
}
