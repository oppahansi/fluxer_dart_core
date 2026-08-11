import 'snowflake.dart';
import 'user.dart';

/// A channel webhook. Modeled after `WebhookResponse` in Fluxer's OpenAPI
/// spec.
final class Webhook {
  const Webhook({
    required this.id,
    required this.guildId,
    required this.channelId,
    required this.name,
    required this.avatar,
    required this.token,
    required this.creator,
  });

  factory Webhook.fromJson(Map<String, dynamic> json) => Webhook(
    id: Snowflake.parse(json['id'] as String),
    guildId: Snowflake.parse(json['guild_id'] as String),
    channelId: Snowflake.parse(json['channel_id'] as String),
    name: json['name'] as String,
    avatar: json['avatar'] as String?,
    token: json['token'] as String,
    creator: User.fromJson(json['user'] as Map<String, dynamic>),
  );

  final Snowflake id;
  final Snowflake guildId;
  final Snowflake channelId;
  final String name;
  final String? avatar;

  /// Secret used to post messages through this webhook without a bot
  /// token — treat like any other credential.
  final String token;

  final User creator;

  @override
  bool operator ==(Object other) => other is Webhook && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Webhook($id, $name)';
}
