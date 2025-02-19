import '../core/client.dart';
import '../models/sieve_script.dart';
import '../core/errors.dart';

class SieveService {
  final JmapClient _client;

  SieveService(this._client);

  Future<SieveScript> create({
    required String name,
    required String content,
    bool activate = false,
  }) async {
    // First upload the content as a blob
    final blobResponse = await _client.blobs.upload(
      content.codeUnits,
      type: 'application/sieve',
    );

    // Then create the script
    final response = await _client.sendRequest({
      'using': ['urn:ietf:params:jmap:core', 'urn:ietf:params:jmap:sieve'],
      'methodCalls': [
        [
          'SieveScript/set',
          {
            "accountId": _client.getDefaultAccountId(),
            'create': {
              'new': {
                'name': name,
                'blobId': blobResponse.id,
              }
            },
            if (activate) 'onSuccessActivateScript': '#new',
          },
          '0',
        ],
      ],
    });

    try {
      final methodResponse = response['methodResponses'][0][1];

      // Check if we have a created response
      if (!methodResponse.containsKey('created')) {
        throw JmapError('No created response in server reply');
      }

      final created = methodResponse['created'];
      if (!created.containsKey('new')) {
        throw JmapError('No new script in created response');
      }

      final newScript = created['new'] as Map<String, dynamic>;
      return SieveScript.fromJson({
        'id': newScript['id'],
        'name': name,
        'blobId': newScript['blobId'],
        'isActive': newScript['isActive'] ?? false,
      });
    } catch (e) {
      print('❌ Error parsing create response: $e');
      print('📦 Response: $response');
      throw JmapError('Failed to parse create response: $e');
    }
  }

  Future<List<SieveScript>> list() async {
    final request = {
      'using': ['urn:ietf:params:jmap:core', 'urn:ietf:params:jmap:sieve'],
      'methodCalls': [
        [
          'SieveScript/get',
          {
            'accountId': _client.getDefaultAccountId(),
          },
          '0'
        ]
      ]
    };

    final response = await _client.sendRequest(request);

    try {
      final methodResponse = response['methodResponses'][0][1];
      //log response
      // print('List Scripts methodResponse: ${methodResponse}');
      if (methodResponse == null) {
        throw JmapError('Failed to list scripts: method response is null');
      }

      final listResponse = methodResponse['list'];
      //log list response
      // print('List Scripts List Response: ${listResponse}');

      if (listResponse == null) {
        throw JmapError('7 Failed to list scripts: list response is null');
      }

      final List<dynamic> list;
      try {
        list = listResponse as List<dynamic>;
      } catch (e) {
        throw JmapError('6 Failed to parse list response: $e');
      }

      return list.map((item) {
        if (item == null) {
          throw JmapError(
              ' 5 Failed to parse sieve scripts list: item is null');
        }
        try {
          return SieveScript.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          throw JmapError('4 Failed to parse sieve script: $e');
        }
      }).toList();
    } catch (e) {
      throw JmapError('3 Failed to parse sieve scripts list: $e');
    }
  }

  Future<void> delete(String id) async {
    await _client.sendRequest({
      'using': ['urn:ietf:params:jmap:core', 'urn:ietf:params:jmap:sieve'],
      'methodCalls': [
        [
          'SieveScript/set',
          {
            'destroy': [id],
          },
          '0',
        ],
      ],
    });
  }

  Future<void> validate(String scriptContent) async {
    try {
      // First upload the script content as a blob
      final blobResponse = await _client.blobs.upload(
        scriptContent.codeUnits,
        type: 'application/sieve',
      );

      // Then validate the script using the blob ID
      final response = await _client.sendRequest({
        'using': ['urn:ietf:params:jmap:core', 'urn:ietf:params:jmap:sieve'],
        'methodCalls': [
          [
            'SieveScript/validate',
            {
              "accountId": _client.getDefaultAccountId(),
              'blobId': blobResponse.id,
            },
            '0',
          ],
        ],
      });

      // Check for validation errors
      final methodResponse = response['methodResponses'][0];
      if (methodResponse[0] == 'error') {
        throw JmapError(
          'Validation failed: ${methodResponse[1]['description']}',
          type: methodResponse[1]['type'],
        );
      }
    } catch (e) {
      if (e is JmapError) {
        rethrow;
      }
      throw JmapError('Failed to validate script: $e');
    }
  }
}
