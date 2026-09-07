import 'snowflake.dart';

/// A category of mention that may be parsed out of message content.
enum MentionType {
  users('users'),
  roles('roles'),

  /// Covers both `@everyone` and `@here`.
  everyone('everyone');

  const MentionType(this.value);

  final String value;
}

/// Which mentions in a message are allowed to notify anyone.
///
/// Without this, every mention the content parses to notifies its target.
/// Sending it restricts that: [parse] names the categories still resolved
/// from the text, while [users] and [roles] whitelist specific ids. A
/// category listed in [parse] and also given an explicit id list is
/// rejected by the API — use one or the other per category.
///
/// [AllowedMentions.none] is the useful default for a bot echoing
/// user-supplied text, which otherwise lets a caller make the bot ping
/// `@everyone`.
final class AllowedMentions {
  const AllowedMentions({
    this.parse = const [],
    this.users = const [],
    this.roles = const [],
    this.repliedUser,
  });

  /// Suppresses every mention in the message.
  static const AllowedMentions none = AllowedMentions();

  /// The categories parsed from the message content.
  final List<MentionType> parse;

  /// Up to 100 user ids allowed to be notified.
  final List<Snowflake> users;

  /// Up to 100 role ids allowed to be notified.
  final List<Snowflake> roles;

  /// Whether replying to a message notifies its author. Omitted leaves
  /// the API default in place.
  final bool? repliedUser;

  Map<String, dynamic> toJson() => {
    'parse': parse.map((p) => p.value).toList(growable: false),
    if (users.isNotEmpty)
      'users': users.map((u) => u.toJson()).toList(growable: false),
    if (roles.isNotEmpty)
      'roles': roles.map((r) => r.toJson()).toList(growable: false),
    if (repliedUser != null) 'replied_user': repliedUser,
  };

  @override
  String toString() =>
      'AllowedMentions(parse: ${parse.map((p) => p.value).join(', ')})';
}
