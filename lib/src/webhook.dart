import 'partial.dart';
import 'snowflake.dart';
import 'user.dart';

/// What a webhook is for.
enum WebhookType {
  /// Created to be posted to with its own token.
  incoming(1),

  /// Created by following an announcement channel, to deliver copies of
  /// that channel's published messages. Carries no token.
  channelFollower(2);

  const WebhookType(this.value);

  final int value;

  /// `null` for a value this version does not recognise.
  static WebhookType? tryFromValue(int value) {
    for (final candidate in values) {
      if (candidate.value == value) return candidate;
    }
    return null;
  }
}

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
    required this.type,
    required this.sourceChannel,
    required this.sourceGuild,
  });

  factory Webhook.fromJson(Map<String, dynamic> json) => Webhook(
    id: Snowflake.parse(json['id'] as String),
    guildId: Snowflake.parse(json['guild_id'] as String),
    channelId: Snowflake.parse(json['channel_id'] as String),
    name: json['name'] as String,
    avatar: json['avatar'] as String?,
    token: json['token'] as String?,
    creator: User.fromJson(json['user'] as Map<String, dynamic>),
    type: WebhookType.tryFromValue(json['type'] as int? ?? 1),
    sourceChannel: (json['source_channel'] as Map<String, dynamic>?)?.let(
      PartialChannel.fromJson,
    ),
    sourceGuild: (json['source_guild'] as Map<String, dynamic>?)?.let(
      PartialGuild.fromJson,
    ),
  );

  final Snowflake id;
  final Snowflake guildId;
  final Snowflake channelId;
  final String name;
  final String? avatar;

  /// Secret used to post messages through this webhook without a bot
  /// token — treat like any other credential.
  ///
  /// `null` on a [WebhookType.channelFollower] webhook: the API drives
  /// those itself and exposes no token for them.
  final String? token;

  final User creator;

  /// `null` for a type this version does not model.
  final WebhookType? type;

  /// The followed announcement channel, on a channel follower webhook.
  /// Absent once the webhook's creator can no longer view it.
  final PartialChannel? sourceChannel;

  /// The guild of the followed announcement channel, on a channel
  /// follower webhook.
  final PartialGuild? sourceGuild;

  /// Whether this webhook can be posted to, which requires a [token].
  bool get isExecutable => token != null;

  @override
  bool operator ==(Object other) => other is Webhook && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Webhook($id, $name)';
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
