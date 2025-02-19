# Sievescript Dart

A Dart package for managing Sieve scripts and blobs through JMAP protocol, with full Flutter support.

## Platform Support

- ✅ Flutter Android
- ✅ Flutter iOS
- ✅ Flutter Web
- ✅ Flutter Desktop
- ✅ Pure Dart projects

## Features

- JMAP Sieve script management
  - Create, read, update, and delete Sieve scripts
  - Activate/deactivate scripts
  - Validate scripts
  - List all scripts

- JMAP Blob operations
  - Upload blobs with text or binary data
  - Download blobs
  - Support for multiple data formats (text, base64)
  - Handle content types properly

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  sievescript_dart:
    git:
      url: https://github.com/viethoang99/sievescript_dart.git
      ref: main  # or specify a tag/commit
```

Or use a specific version:

```yaml
dependencies:
  sievescript_dart:
    git:
      url: https://github.com/viethoang99/sievescript_dart.git
      ref: v1.0.0  # Replace with desired version tag
```

## Usage

### Initialize Client

```dart
final client = JmapClient(
  baseUrl: 'https://your-jmap-server.com',
  accessToken: 'your-access-token',
);

await client.initialize();
```

### Working with Sieve Scripts

```dart
// Create a new script
final script = await client.sieveScripts.create(
  name: 'my-filter',
  content: '''
    require ["fileinto"];
    if header :contains "subject" "important" {
      fileinto "INBOX.important";
    }
  ''',
  activate: true,
);

// List all scripts
final scripts = await client.sieveScripts.list();
for (final script in scripts) {
  print('${script.name} (${script.isActive ? "active" : "inactive"})');
}

// Validate a script
await client.sieveScripts.validate(scriptContent);
```

## Flutter Example

### Basic Usage in Flutter

```dart
class EmailFilterScreen extends StatefulWidget {
  @override
  _EmailFilterScreenState createState() => _EmailFilterScreenState();
}

class _EmailFilterScreenState extends State<EmailFilterScreen> {
  late JmapClient _client;
  List<SieveScript> _scripts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeClient();
  }

  Future<void> _initializeClient() async {
    _client = JmapClient(
      baseUrl: 'https://your-jmap-server.com',
      accessToken: 'your-access-token',
    );
    
    try {
      await _client.initialize();
      await _loadScripts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _loadScripts() async {
    try {
      final scripts = await _client.sieveScripts.list();
      setState(() {
        _scripts = scripts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      rethrow;
    }
  }

  Future<void> _createScript(String name, String content) async {
    try {
      final script = await _client.sieveScripts.create(
        name: name,
        content: content,
        activate: true,
      );
      
      setState(() {
        _scripts.add(script);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create script: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Email Filters')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _scripts.length,
              itemBuilder: (context, index) {
                final script = _scripts[index];
                return ListTile(
                  title: Text(script.name ?? 'Unnamed Script'),
                  subtitle: Text(script.isActive ? 'Active' : 'Inactive'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _client.sieveScripts.delete(script.id!);
                      await _loadScripts();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateScriptDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _client.dispose();
    super.dispose();
  }
}
```

### Working with Blobs

```dart
// Upload text data
final textBlob = await client.blobs.upload(
  utf8.encode('Hello World'),
  type: 'text/plain',
);

// Upload binary data
final binaryBlob = await client.blobs.upload(
  binaryData,
  type: 'application/octet-stream',
);

// Download a blob
final downloadedBlob = await client.blobs.download(blobId);
print(downloadedBlob.dataAsText); // For text data
print(downloadedBlob.dataAsBase64); // For binary data
```

### Working with Blobs in Flutter

```dart
// Upload file from device
Future<void> uploadFile() async {
  final result = await FilePicker.platform.pickFiles();
  
  if (result != null) {
    final file = result.files.first;
    final blob = await _client.blobs.upload(
      file.bytes!,
      type: file.extension == 'txt' ? 'text/plain' : 'application/octet-stream',
    );
    
    // Use the blob ID
    print('File uploaded: ${blob.id}');
  }
}

// Download and display content
Future<void> displayBlobContent(String blobId) async {
  final blob = await _client.blobs.download(blobId);
  
  if (blob.dataAsText != null) {
    // Show text content
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(blob.dataAsText!),
      ),
    );
  } else {
    // Handle binary data
    final bytes = base64Decode(blob.dataAsBase64!);
    // Use bytes as needed
  }
}
```

## Error Handling

```dart
try {
  await client.sieveScripts.validate(invalidScript);
} catch (e) {
  if (e is JmapError) {
    print('JMAP error: ${e.message}');
  } else {
    print('Unexpected error: $e');
  }
}
```

## Logging

The package includes detailed logging for debugging:
- Request/response logging
- Session information
- Error details
- Operation results

Enable debug output in your client initialization:

```dart
final client = JmapClient(
  baseUrl: 'https://your-jmap-server.com',
  accessToken: 'your-access-token',
  debug: true,
);
```

## Testing

Run the test suite:

```bash
dart test
```

Run specific tests:

```bash
dart test test/blob_test.dart
dart test test/sieve_script_test.dart
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
