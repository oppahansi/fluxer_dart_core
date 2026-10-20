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

/// How a forum lists its posts by default.
enum ForumSortOrder {
  latestActivity(0),
  creationTime(1);

  const ForumSortOrder(this.value);

  final int value;

  static ForumSortOrder? tryFromValue(int? value) {
    for (final candidate in values) {
      if (candidate.value == value) return candidate;
    }
    return null;
  }
}

/// How clients lay a forum's posts out by default. [notSet] leaves it to
/// the client.
enum ForumLayout {
  notSet(0),
  list(1),
  grid(2);

  const ForumLayout(this.value);

  final int value;

  static ForumLayout? tryFromValue(int? value) {
    for (final candidate in values) {
      if (candidate.value == value) return candidate;
    }
    return null;
  }
}

/// Whether filtering a forum by several tags matches posts carrying any
/// of them or all of them.
enum ForumTagSetting {
  matchSome('match_some'),
  matchAll('match_all');

  const ForumTagSetting(this.value);

  final String value;

  static ForumTagSetting? tryFromValue(String? value) {
    for (final candidate in values) {
      if (candidate.value == value) return candidate;
    }
    return null;
  }
}

/// The reaction clients offer on every post of a forum: a custom emoji by
/// [emojiId], or a Unicode one in [emojiName].
final class ForumDefaultReaction {
  const ForumDefaultReaction({this.emojiId, this.emojiName});

  factory ForumDefaultReaction.fromJson(Map<String, dynamic> json) =>
      ForumDefaultReaction(
        emojiId: switch (json['emoji_id']) {
          final String id => Snowflake.parse(id),
          _ => null,
        },
        emojiName: json['emoji_name'] as String?,
      );

  final Snowflake? emojiId;
  final String? emojiName;

  Map<String, dynamic> toJson() => {
    'emoji_id': emojiId?.toJson(),
    'emoji_name': emojiName,
  };
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
