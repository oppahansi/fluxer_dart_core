import 'snowflake.dart';

/// A custom guild sticker. Modeled after `GuildStickerResponse` in
/// Fluxer's OpenAPI spec.
final class GuildSticker {
  const GuildSticker({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    required this.animated,
    required this.nsfw,
  });

  factory GuildSticker.fromJson(Map<String, dynamic> json) => GuildSticker(
    id: Snowflake.parse(json['id'] as String),
    name: json['name'] as String,
    description: json['description'] as String,
    tags: (json['tags'] as List<dynamic>).cast<String>(),
    animated: json['animated'] as bool,
    nsfw: json['nsfw'] as bool,
  );

  final Snowflake id;
  final String name;
  final String description;
  final List<String> tags;
  final bool animated;
  final bool nsfw;

  @override
  bool operator ==(Object other) => other is GuildSticker && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GuildSticker($id, $name)';
}
