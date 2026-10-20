import 'guild_member.dart';
import 'snowflake.dart';

/// One voice connection's state, as `VOICE_STATE_UPDATE` and a guild's
/// `voice_states` report it.
///
/// A user can hold several connections at once, so [connectionId], not
/// [userId], identifies the entry. A [channelId] of `null` means the
/// connection left.
final class VoiceState {
  const VoiceState({
    required this.guildId,
    required this.channelId,
    required this.userId,
    required this.connectionId,
    required this.sessionId,
    required this.member,
    required this.mute,
    required this.deaf,
    required this.selfMute,
    required this.selfDeaf,
    required this.selfVideo,
    required this.selfStream,
    required this.isMobile,
    required this.suppress,
    required this.viewerStreamKeys,
    required this.p2p,
    required this.version,
  });

  factory VoiceState.fromJson(Map<String, dynamic> json) => VoiceState(
    guildId: _id(json['guild_id']),
    channelId: _id(json['channel_id']),
    userId: _id(json['user_id']),
    connectionId: json['connection_id'] as String?,
    sessionId: json['session_id'] as String?,
    member: switch (json['member']) {
      final Map<String, dynamic> m => GuildMember.fromJson(m),
      _ => null,
    },
    mute: json['mute'] as bool? ?? false,
    deaf: json['deaf'] as bool? ?? false,
    selfMute: json['self_mute'] as bool? ?? false,
    selfDeaf: json['self_deaf'] as bool? ?? false,
    selfVideo: json['self_video'] as bool? ?? false,
    selfStream: json['self_stream'] as bool? ?? false,
    isMobile: json['is_mobile'] as bool? ?? false,
    suppress: json['suppress'] as bool? ?? false,
    viewerStreamKeys: (json['viewer_stream_keys'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toList(growable: false),
    p2p: json['p2p'] as bool? ?? false,
    version: json['version'] as int? ?? 0,
  );

  /// `null` in a DM or group DM call.
  final Snowflake? guildId;

  /// `null` once the connection has left.
  final Snowflake? channelId;

  final Snowflake? userId;
  final String? connectionId;

  /// The gateway session that owns the connection.
  final String? sessionId;

  /// `null` in a call.
  final GuildMember? member;

  /// Server mute and deafen.
  final bool mute;
  final bool deaf;

  final bool selfMute;
  final bool selfDeaf;
  final bool selfVideo;

  /// Whether the connection advertises a screenshare track.
  final bool selfStream;

  final bool isMobile;
  final bool suppress;

  /// Streams this connection is watching.
  final List<String> viewerStreamKeys;

  /// Whether media flows peer-to-peer rather than through LiveKit.
  final bool p2p;

  /// Increases with every change to this participant's state.
  final int version;

  @override
  String toString() => 'VoiceState($userId in $channelId, $connectionId)';
}

Snowflake? _id(Object? value) => switch (value) {
  final String id => Snowflake.parse(id),
  _ => null,
};
