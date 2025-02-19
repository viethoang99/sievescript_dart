import 'package:sievescript_dart/src/core/client.dart';

void main() async {
  // Initialize the JMAP client
  final client = JmapClient(
    baseUrl: 'http://adx.netadx.id.vn:8080',
    accessToken: 'YWRAbmV0YWR4Ldsfsdfsdfs4dfaADS==',
  );

  try {
    // Create a new Sieve script
    final script = await client.sieveScripts.create(
      name: 'my-filter',
      content: '''
        require ["fileinto"];
        if header :contains "subject" "important" {
          fileinto "INBOX.important";
        }
      ''',
    );
    print('Created script: ${script.id}');

    // List all scripts
    final scripts = await client.sieveScripts.list();
    print('Available scripts: ${scripts.length}');

    // Upload a blob
    final blob = await client.blobs.upload(
      [/* your binary data here */],
      type: 'application/sieve',
    );
    print('Uploaded blob: ${blob.id}');
  } catch (e) {
    print('Error: $e');
  }
}
