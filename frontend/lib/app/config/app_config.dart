class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static Uri buildApiUri(String path, [Map<String, dynamic>? queryParameters]) {
    final base = Uri.parse(apiBaseUrl);
    return base.replace(path: path, queryParameters: queryParameters);
  }

  static String buildWsUrl(String roomId, String token) {
    final base = Uri.parse(apiBaseUrl);
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    final wsUri = base.replace(
      scheme: scheme,
      path: '/ws',
      queryParameters: {'room_id': roomId, 'token': token},
    );
    return wsUri.toString();
  }
}
