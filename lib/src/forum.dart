import 'snowflake.dart';

/// Flags on a forum or media channel, or on a post inside one.
enum ChannelFlag {
  /// The post is the pinned post of its channel. A channel holds at most
  /// one, and archiving the post clears it.
  pinned(1 << 1),

  /// A new post in the channel needs at least one tag.
  requireTag(1 << 4),

  /// Clients hide the media download options. Media channels only.
  hideMediaDownloadOptions(1 << 15);

  const ChannelFlag(this.bit);

  final int bit;
}

/// A tag a post in a forum or media channel can apply.
///
/// At most one of [emojiId] and [emojiName] is set.
final class ForumTag {
  const ForumTag({
    required this.id,
    required this.name,
    required this.moderated,
    this.emojiId,
    this.emojiName,
  });

  factory ForumTag.fromJson(Map<String, dynamic> json) => ForumTag(
    id: Snowflake.parse(json['id'] as String),
    name: json['name'] as String,
    moderated: json['moderated'] as bool? ?? false,
    emojiId: switch (json['emoji_id']) {
      final String id => Snowflake.parse(id),
      _ => null,
    },
    emojiName: json['emoji_name'] as String?,
  );

  final Snowflake id;

  /// Unique within the channel, compared case-sensitively.
  final String name;

  /// Whether only thread moderators can apply or remove the tag.
  final bool moderated;

  /// A custom emoji of the guild.
  final Snowflake? emojiId;

  /// A single Unicode emoji.
  final String? emojiName;

  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'name': name,
    'moderated': moderated,
    'emoji_id': emojiId?.toJson(),
    'emoji_name': emojiName,
  };

  @override
  bool operator ==(Object other) => other is ForumTag && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ForumTag($id, $name)';
}
