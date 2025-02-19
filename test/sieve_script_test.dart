import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:sievescript_dart/src/core/client.dart';
import 'dart:convert';

void main() {
  late JmapClient client;
  const testServer = 'http://adx.netadx.id.vn:8080';
  const testToken = 'YWRAbmV0YWR4Ldsfsdfsdfs4dfaADS==';

  void logRequest(String title, dynamic data) {
    print('\n=== $title ===');
    print(const JsonEncoder.withIndent('  ').convert(data));
  }

  setUp(() async {
    client = JmapClient(
      baseUrl: testServer,
      accessToken: testToken,
      httpClient: http.Client(),
    );
    await client.initialize();
    print('\n🔄 Starting SieveScript test...');
  });

  group('SieveScript Operations', () {
    test('create and activate sieve script', () async {
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
      print('\n📋 Testing Sieve Script Listing...');

      try {
        final scripts = await client.sieveScripts.list();

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
    print('🏁 SieveScript test completed\n');
  });
}
