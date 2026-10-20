import 'snowflake.dart';
import 'user.dart';

/// The OAuth2 application this bot belongs to, from
/// `GET /applications/@me`.
///
/// The response also carries the bot's own token under `bot`; it is
/// deliberately not decoded.
final class BotApplication {
  const BotApplication({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.botPublic,
    required this.botRequireCodeGrant,
    required this.owner,
    required this.redirectUris,
  });

  factory BotApplication.fromJson(Map<String, dynamic> json) => BotApplication(
    id: Snowflake.parse(json['id'] as String),
    name: json['name'] as String,
    icon: json['icon'] as String?,
    description: json['description'] as String?,
    botPublic: json['bot_public'] as bool? ?? false,
    botRequireCodeGrant: json['bot_require_code_grant'] as bool? ?? false,
    owner: User.fromJson(json['owner'] as Map<String, dynamic>),
    redirectUris: (json['redirect_uris'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toList(growable: false),
  );

  final Snowflake id;
  final String name;
  final String? icon;
  final String? description;

  /// Whether anyone, not only the owner, can add the bot to a guild.
  final bool botPublic;

  /// Whether adding the bot requires the full OAuth2 code grant.
  final bool botRequireCodeGrant;

  final User owner;
  final List<String> redirectUris;

  @override
  String toString() => 'BotApplication($id, $name)';
}
