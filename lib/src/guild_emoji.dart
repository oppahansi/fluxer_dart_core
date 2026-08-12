import 'snowflake.dart';

/// A custom guild emoji. Modeled after `GuildEmojiResponse` in Fluxer's
/// OpenAPI spec.
final class GuildEmoji {
  const GuildEmoji({
    required this.id,
    required this.name,
    required this.animated,
    required this.nsfw,
  });

  factory GuildEmoji.fromJson(Map<String, dynamic> json) => GuildEmoji(
    id: Snowflake.parse(json['id'] as String),
    name: json['name'] as String,
    animated: json['animated'] as bool,
    nsfw: json['nsfw'] as bool,
  );

  final Snowflake id;
  final String name;
  final bool animated;
  final bool nsfw;

  @override
  bool operator ==(Object other) => other is GuildEmoji && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GuildEmoji($id, :$name:)';
}
