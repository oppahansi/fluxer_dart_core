import 'partial.dart';
import 'snowflake.dart';

/// The result of following an announcement channel.
///
/// Following creates a webhook in the target channel, which is what
/// actually delivers copies of published messages; [webhookId] names it,
/// so it can later be deleted to stop following.
final class FollowedChannel {
  const FollowedChannel({required this.channelId, required this.webhookId});

  factory FollowedChannel.fromJson(Map<String, dynamic> json) =>
      FollowedChannel(
        channelId: Snowflake.parse(json['channel_id'] as String),
        webhookId: Snowflake.parse(json['webhook_id'] as String),
      );

  /// The announcement channel now being followed.
  final Snowflake channelId;

  /// The channel follower webhook created in the target channel.
  final Snowflake webhookId;

  @override
  String toString() => 'FollowedChannel($channelId via $webhookId)';
}

/// How widely an announcement channel is followed.
final class ChannelFollowerStats {
  const ChannelFollowerStats({
    required this.channelCount,
    required this.guildCount,
  });

  factory ChannelFollowerStats.fromJson(Map<String, dynamic> json) =>
      ChannelFollowerStats(
        channelCount: json['channel_count'] as int? ?? 0,
        guildCount: json['guild_count'] as int? ?? 0,
      );

  /// Channels receiving copies.
  final int channelCount;

  /// Distinct guilds those channels belong to.
  final int guildCount;

  @override
  String toString() =>
      'ChannelFollowerStats($channelCount channels, $guildCount guilds)';
}

/// Where a crossposted message copy came from.
final class CrosspostSource {
  const CrosspostSource({required this.guild});

  factory CrosspostSource.fromJson(Map<String, dynamic> json) =>
      CrosspostSource(
        guild: PartialGuild.fromJson(json['guild'] as Map<String, dynamic>),
      );

  final PartialGuild guild;

  @override
  String toString() => 'CrosspostSource(${guild.name})';
}
