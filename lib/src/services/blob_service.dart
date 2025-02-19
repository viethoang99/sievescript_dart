import 'dart:convert';
import '../core/client.dart';
import '../models/blob.dart';
import '../core/errors.dart';

class BlobService {
  final JmapClient _client;

  BlobService(this._client);

  Future<Blob> upload(
    List<int> data, {
    String type = 'application/sieve',
  }) async {
    final request = {
      'using': [
        'urn:ietf:params:jmap:core',
        'urn:ietf:params:jmap:blob',
      ],
      'methodCalls': [
        [
          'Blob/upload',
          {
            'accountId': _client.getDefaultAccountId(),
            'create': {
              'A': {
                'data': [
                  {
                    'data:asText': utf8.decode(data),
                  }
                ],
                'type': type,
              }
            }
          },
          '1'
        ]
      ]
    };

    try {
      final response = await _client.sendRequest(request);
      final methodResponse = response['methodResponses'][0][1];

      if (!methodResponse.containsKey('created')) {
        throw JmapError('No created response in upload reply');
      }

      final created = methodResponse['created']['A'];
      if (created == null) {
        throw JmapError('No blob data in created response');
      }

      return Blob(
        id: created['id'],
        size: created['size'],
        dataAsText: utf8.decode(data),
        dataAsBase64: base64Encode(data),
      );
    } catch (e) {
      print('❌ Error uploading blob: $e');
      throw JmapError('Failed to upload blob: $e');
    }
  }

  Future<Blob> download(String blobId) async {
    final request = {
      'using': ['urn:ietf:params:jmap:core', 'urn:ietf:params:jmap:blob'],
      'methodCalls': [
        [
          'Blob/get',
          {
            'accountId': _client.getDefaultAccountId(),
            'ids': [blobId],
            'properties': ['id', 'size', 'data:asText', 'data:asBase64']
          },
          '1'
        ]
      ]
    };

    try {
      final response = await _client.sendRequest(request);
      final methodResponse = response['methodResponses'][0][1];
      final list = methodResponse['list'] as List;

      if (list.isEmpty) {
        throw JmapError('Blob not found: $blobId');
      }

      final blob = list[0] as Map<String, dynamic>;
      return Blob(
        id: blobId,
        size: blob['size'],
        dataAsText: blob['data:asText'],
        dataAsBase64: blob['data:asBase64'],
      );
    } catch (e) {
      print('❌ Error downloading blob: $e');
      throw JmapError('Failed to download blob: $e');
    }
  }

  Future<void> destroy(String blobId) async {
    final request = {
      'using': ['urn:ietf:params:jmap:core', 'urn:ietf:params:jmap:blob'],
      'methodCalls': [
        [
          'Blob/set',
          {
            'accountId': _client.getDefaultAccountId(),
            'destroy': [blobId],
          },
          '1'
        ]
      ]
    };

    try {
      await _client.sendRequest(request);
    } catch (e) {
      print('❌ Error destroying blob: $e');
      throw JmapError('Failed to destroy blob: $e');
    }
  }
}
