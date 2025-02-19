class Session {
  final String apiUrl;
  final String downloadUrl;
  final String uploadUrl;
  final List<String> capabilities;
  final Map<String, dynamic> accounts;

  Session({
    required this.apiUrl,
    required this.downloadUrl,
    required this.uploadUrl,
    required this.capabilities,
    required this.accounts,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    // Add debug print to see what we're getting
    print('Session JSON: $json');

    try {
      return Session(
        apiUrl: json['apiUrl'] as String? ?? '',
        downloadUrl: json['downloadUrl'] as String? ?? '',
        uploadUrl: json['uploadUrl'] as String? ?? '',
        capabilities:
            (json['capabilities'] as Map<String, dynamic>?)?.keys.toList() ??
                [],
        accounts: (json['accounts'] as Map<String, dynamic>?) ?? {},
      );
    } catch (e, stackTrace) {
      print('Error parsing Session: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  String? getPrimaryAccount() {
    if (accounts.isEmpty) return null;
    return accounts.keys.first;
  }

  List<String> getAccountIds() {
    return accounts.keys.toList();
  }

  Map<String, dynamic>? getAccountCapabilities(String accountId) {
    return accounts[accountId] as Map<String, dynamic>?;
  }

  // Debug method to print session details
  void printDebug() {
    print('''
    Session Details:
    - API URL: $apiUrl
    - Download URL: $downloadUrl
    - Upload URL: $uploadUrl
    - Capabilities: $capabilities
    - Accounts: $accounts
    - Primary Account: ${getPrimaryAccount()}
    - Account IDs: ${getAccountIds()}
    - Account Capabilities: {getAccountCapabilities(getPrimaryAccount() ?? '')}
    ''');
  }
}
