import 'package:sievescript_dart/src/core/client.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  late JmapClient client;
  const testServer = 'http://adx.netadx.id.vn:8080';
  const testToken = 'YWRAbmV0YWR4Ldsfsdfsdfs4dfaADS==';

  void logRequest(String title, dynamic data) {
    print('\n=== $title ===');
    print(const JsonEncoder.withIndent('  ').convert(data));
  }

  void logResponse(String title, http.Response response) {
    print('\n=== $title ===');
    print('Status: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print(
        'Body: ${const JsonEncoder.withIndent('  ').convert(jsonDecode(response.body))}');
  }

  setUp(() async {
    client = JmapClient(
      baseUrl: testServer,
      accessToken: testToken,
      httpClient: http.Client(),
    );
    await client.initialize();
    print('\n🔄 Starting new test...');
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

  group('SieveScript Operations', () {
    test('create and activate sieve script', () async {
      // Remove redundant initialization
      print('\n📝 Testing Sieve Script Creation...');

      final scriptContent = '''
        require ["fileinto"];
        if header :contains "subject" "important" {
          fileinto "INBOX.important";
        }
      ''';

      try {
        var scriptname = 'test-filter-${DateTime.now().millisecondsSinceEpoch}';
        final script = await client.sieveScripts.create(
          name: scriptname,
          content: scriptContent,
          activate: true,
        );

        logRequest('Create Script Request',
            {'name': scriptname, 'content': scriptContent, 'activate': true});

        expect(script.name, equals(scriptname));
        expect(script.isActive, isTrue);
        print('✅ Script created successfully: ${script.id}');
      } catch (e) {
        print('❌ Error creating script: $e');
        rethrow;
      }
    });

    test('list all sieve scripts', () async {
      // Remove redundant initialization
      print('\n📋 Testing Sieve Script Listing...');

      try {
        final scripts = await client.sieveScripts.list();

        logRequest('List Scripts Request',
            {'method': 'SieveScript/get', 'accountId': 'default'});

        expect(scripts, isNotEmpty);
        print('✅ Found ${scripts.length} scripts:');
        for (final script in scripts) {
          print(
              '  - ${script.name} (${script.isActive ? "active" : "inactive"})');
        }
      } catch (e) {
        print('❌ Error listing scripts: $e');
        rethrow;
      }
    });

    test('validate sieve script', () async {
      // Remove redundant initialization
      print('\n✔️ Testing Sieve Script Validation...');

      final validScript = '''
        require ["fileinto"];
        if header :contains "from" "important@example.com" {
          fileinto "INBOX.important";
        }
      ''';

      final invalidScript = '''
        require ["unknown_extension"];
        if invalid_command {
          fileinto "INBOX";
        }
      ''';

      try {
        print('🔍 Testing valid script...');
        await client.sieveScripts.validate(validScript);
        print('✅ Valid script passed validation');

        print('🔍 Testing invalid script...');
        try {
          await client.sieveScripts.validate(invalidScript);
          fail('Invalid script should not validate');
        } catch (e) {
          print('✅ Invalid script correctly failed validation: $e');
        }
      } catch (e) {
        print('❌ Unexpected error in validation: $e');
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
    print('🏁 Test completed\n');
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
