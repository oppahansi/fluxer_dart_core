import 'snowflake.dart';

/// The emoji referenced by a reaction — not a full [GuildEmoji]: reactions
/// carry only an identity reference (verified against
/// `MessageReactionAdd.ts`'s `ReactionEmojiPayload`), which for a custom
/// guild emoji is `{id, name}` and for a standard Unicode emoji is just
/// `{name}` with a `null` id.
final class ReactionEmoji {
  const ReactionEmoji({required this.id, required this.name});

  factory ReactionEmoji.fromJson(Map<String, dynamic> json) => ReactionEmoji(
    id: (json['id'] as String?) == null
        ? null
        : Snowflake.parse(json['id'] as String),
    name: json['name'] as String?,
  );

  /// `null` for a standard Unicode emoji.
  final Snowflake? id;

  /// The Unicode character for a standard emoji, or the custom emoji's
  /// name.
  final String? name;

  /// Whether this is a custom guild emoji rather than a standard Unicode
  /// one.
  bool get isCustom => id != null;

  @override
  bool operator ==(Object other) =>
      other is ReactionEmoji && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() =>
      isCustom ? 'ReactionEmoji($id, :$name:)' : 'ReactionEmoji($name)';
}
