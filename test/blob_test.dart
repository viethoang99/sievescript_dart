import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:sievescript_dart/src/core/client.dart';
import 'dart:convert';

void main() {
  late JmapClient client;
  const testServer = 'http://adx.netadx.id.vn:8080';
  const testToken = 'YWRAbmV0YWR4Ldsfsdfsdfs4dfaADS==';

  setUp(() async {
    client = JmapClient(
      baseUrl: testServer,
      accessToken: testToken,
      httpClient: http.Client(),
    );
    await client.initialize();
    print('\n🔄 Starting Blob test...');
  });

  group('Blob Operations', () {
    test('upload and download blob with text data', () async {
      print('\n📦 Testing Blob Text Operations...');

      final testText = 'Test blob content';
      final testData = utf8.encode(testText);

      try {
        print('⬆️ Uploading blob as text...');
        final uploadedBlob = await client.blobs.upload(
          testData,
          type: 'text/plain',
        );

        expect(uploadedBlob.id, isNotEmpty);
        expect(uploadedBlob.size, equals(testData.length));
        expect(uploadedBlob.dataAsBase64, isNotNull);
        print('✅ Blob uploaded: ${uploadedBlob.id}');

        print('⬇️ Downloading blob...');
        final downloadedBlob = await client.blobs.download(uploadedBlob.id);

        expect(downloadedBlob.id, equals(uploadedBlob.id));
        expect(downloadedBlob.size, equals(uploadedBlob.size));
        expect(downloadedBlob.dataAsText, equals(testText));

        print('✅ Blob downloaded successfully');
        print('   Size: ${downloadedBlob.size} bytes');
        print('   Content: ${downloadedBlob.dataAsText}');
      } catch (e) {
        print('❌ Error in blob operations: $e');
        rethrow;
      }
    });

    test('upload and download blob with binary data', () async {
      print('\n📦 Testing Blob Binary Operations...');

      final testData = List<int>.generate(100, (i) => i % 256);

      try {
        print('⬆️ Uploading blob as binary...');
        final uploadedBlob = await client.blobs.upload(
          testData,
          type: 'application/octet-stream',
        );

        expect(uploadedBlob.id, isNotEmpty);
        expect(uploadedBlob.size, equals(testData.length));
        print('✅ Blob uploaded: ${uploadedBlob.id}');

        print('⬇️ Downloading blob...');
        final downloadedBlob = await client.blobs.download(uploadedBlob.id);

        final decodedData = base64Decode(downloadedBlob.dataAsBase64!);
        expect(decodedData, equals(testData));

        print('✅ Blob downloaded successfully');
        print('   Size: ${downloadedBlob.size} bytes');
        print('   Data matches: ${listEquals(decodedData, testData)}');
      } catch (e) {
        print('❌ Error in blob operations: $e');
        rethrow;
      }
    });
  });

  tearDown(() {
    try {
      client.dispose();
    } catch (e) {
      print('Warning: Error during client disposal: $e');
    }
    print('🏁 Blob test completed\n');
  });
}

bool listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
