import 'guild_member.dart';
import 'snowflake.dart';
import 'user.dart';

/// A user's profile from `GET /users/{id}/profile`.
///
/// [guildMember] and [guildBio] and the other guild fields are present
/// only when the request named a guild; [mutualGuilds] only when asked
/// for.
final class UserProfile {
  const UserProfile({
    required this.user,
    required this.bio,
    required this.pronouns,
    required this.banner,
    required this.accentColor,
    required this.timezoneOffset,
    this.guildMember,
    this.guildBio,
    this.guildPronouns,
    this.mutualGuilds = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profile = json['user_profile'] as Map<String, dynamic>? ?? const {};
    final guildProfile = json['guild_member_profile'] as Map<String, dynamic>?;
    return UserProfile(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      bio: profile['bio'] as String?,
      pronouns: profile['pronouns'] as String?,
      banner: profile['banner'] as String?,
      accentColor: profile['accent_color'] as int?,
      timezoneOffset: json['timezone_offset'] as int?,
      guildMember: switch (json['guild_member']) {
        final Map<String, dynamic> m => GuildMember.fromJson(m),
        _ => null,
      },
      guildBio: guildProfile?['bio'] as String?,
      guildPronouns: guildProfile?['pronouns'] as String?,
      mutualGuilds: [
        for (final g in json['mutual_guilds'] as List<dynamic>? ?? const [])
          (
            id: Snowflake.parse((g as Map<String, dynamic>)['id'] as String),
            nick: g['nick'] as String?,
          ),
      ],
    );
  }

  final User user;
  final String? bio;
  final String? pronouns;
  final String? banner;
  final int? accentColor;

  /// Minutes from UTC, when the user shares it.
  final int? timezoneOffset;

  final GuildMember? guildMember;

  /// The user's bio and pronouns in the requested guild, overriding the
  /// account-wide ones there.
  final String? guildBio;
  final String? guildPronouns;

  /// Guilds this bot shares with the user, with the user's nickname in
  /// each.
  final List<({Snowflake id, String? nick})> mutualGuilds;

  @override
  String toString() => 'UserProfile(${user.id})';
}
