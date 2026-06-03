class ServerException implements Exception {
  final String? message;
  final int? statusCode;

  ServerException({this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {}

class NetworkException implements Exception {}
