import 'curl_command.dart';

class CurlTransaction {
  final String id;
  final CurlCommand request;
  final CurlCommand? resolvedRequest;
  final int statusCode;
  final String responseBody;
  final Duration latency;
  final int responseSize;
  final DateTime timestamp;

  const CurlTransaction({
    required this.id,
    required this.request,
    this.resolvedRequest,
    required this.statusCode,
    required this.responseBody,
    required this.latency,
    required this.responseSize,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request': request.toJson(),
      'resolvedRequest': resolvedRequest?.toJson(),
      'statusCode': statusCode,
      'responseBody': responseBody,
      'latency': latency.inMicroseconds,
      'responseSize': responseSize,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CurlTransaction.fromJson(Map<String, dynamic> json) {
    return CurlTransaction(
      id: json['id'] as String,
      request: CurlCommand.fromJson(json['request'] as Map<String, dynamic>),
      resolvedRequest: json['resolvedRequest'] != null
          ? CurlCommand.fromJson(json['resolvedRequest'] as Map<String, dynamic>)
          : null,
      statusCode: json['statusCode'] as int,
      responseBody: json['responseBody'] as String,
      latency: Duration(microseconds: json['latency'] as int),
      responseSize: json['responseSize'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  CurlTransaction copyWith({
    String? id,
    CurlCommand? request,
    CurlCommand? resolvedRequest,
    int? statusCode,
    String? responseBody,
    Duration? latency,
    int? responseSize,
    DateTime? timestamp,
  }) {
    return CurlTransaction(
      id: id ?? this.id,
      request: request ?? this.request,
      resolvedRequest: resolvedRequest ?? this.resolvedRequest,
      statusCode: statusCode ?? this.statusCode,
      responseBody: responseBody ?? this.responseBody,
      latency: latency ?? this.latency,
      responseSize: responseSize ?? this.responseSize,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
