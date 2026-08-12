/// The response of `GET /gateway/bot`: where to connect, and this bot's
/// current session-start allowance. Verified against `GatewayBotResponse`
/// in Fluxer's OpenAPI spec — field-for-field identical to Discord's
/// endpoint of the same name, including the sharding/session-limit shape.
///
/// Always fetch this fresh before connecting rather than caching or
/// hardcoding a gateway URL: it's what tells a client how many shards to
/// run and whether it's currently allowed to start a new session at all.
final class GatewayBotInfo {
  const GatewayBotInfo({
    required this.url,
    required this.shards,
    required this.sessionStartLimit,
  });

  factory GatewayBotInfo.fromJson(Map<String, dynamic> json) => GatewayBotInfo(
    url: json['url'] as String,
    shards: json['shards'] as int,
    sessionStartLimit: SessionStartLimit.fromJson(
      json['session_start_limit'] as Map<String, dynamic>,
    ),
  );

  /// WebSocket URL to connect to the gateway.
  final String url;

  /// Recommended number of shards to use when connecting.
  final int shards;

  final SessionStartLimit sessionStartLimit;
}

final class SessionStartLimit {
  const SessionStartLimit({
    required this.total,
    required this.remaining,
    required this.resetAfter,
    required this.maxConcurrency,
  });

  factory SessionStartLimit.fromJson(Map<String, dynamic> json) =>
      SessionStartLimit(
        total: json['total'] as int,
        remaining: json['remaining'] as int,
        resetAfter: Duration(milliseconds: json['reset_after'] as int),
        maxConcurrency: json['max_concurrency'] as int,
      );

  final int total;
  final int remaining;
  final Duration resetAfter;
  final int maxConcurrency;
}
