import 'channel_type.dart';
import 'snowflake.dart';

/// A Fluxer channel.
///
/// Sealed so callers get exhaustive-`switch` safety: adding a new channel
/// type variant later is a compile error at every call site that doesn't
/// handle it, rather than a silent runtime gap. Modeled after
/// `ChannelResponse` in Fluxer's OpenAPI spec.
///
/// M1 only distinguishes the two channel shapes the "hello gateway" slice
/// actually needs ([GuildTextChannel], [DmChannel]); every other known
/// type (voice, group DM, category, ...) decodes to [UnknownChannel]
/// rather than throwing, so messages arriving in channel kinds we haven't
/// modeled yet don't take the whole gateway connection down. Broadened in
/// M2.
sealed class Channel {
  const Channel({required this.id, required this.type, required this.name});

  factory Channel.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as int;
    ChannelType? type;
    for (final candidate in ChannelType.values) {
      if (candidate.value == rawType) {
        type = candidate;
        break;
      }
    }
    final id = Snowflake.parse(json['id'] as String);
    final name = json['name'] as String?;

    return switch (type) {
      ChannelType.guildText => GuildTextChannel(
        id: id,
        name: name!,
        guildId: Snowflake.parse(json['guild_id'] as String),
        topic: json['topic'] as String?,
        position: json['position'] as int? ?? 0,
        parentId: (json['parent_id'] as String?).let(Snowflake.parse),
        lastMessageId: (json['last_message_id'] as String?).let(
          Snowflake.parse,
        ),
        nsfw: json['nsfw'] as bool? ?? false,
        rateLimitPerUser: json['rate_limit_per_user'] as int? ?? 0,
      ),
      ChannelType.dm => DmChannel(
        id: id,
        recipientIds: ((json['recipients'] as List<dynamic>?) ?? const [])
            .map(
              (r) =>
                  Snowflake.parse((r as Map<String, dynamic>)['id'] as String),
            )
            .toList(growable: false),
        lastMessageId: (json['last_message_id'] as String?).let(
          Snowflake.parse,
        ),
      ),
      _ => UnknownChannel(id: id, type: type, rawType: rawType, name: name),
    };
  }

  final Snowflake id;
  final ChannelType? type;
  final String? name;

  Map<String, dynamic> toJson();
}

final class GuildTextChannel extends Channel {
  const GuildTextChannel({
    required super.id,
    required String super.name,
    required this.guildId,
    required this.topic,
    required this.position,
    required this.parentId,
    required this.lastMessageId,
    required this.nsfw,
    required this.rateLimitPerUser,
  }) : super(type: ChannelType.guildText);

  final Snowflake guildId;
  final String? topic;
  final int position;
  final Snowflake? parentId;
  final Snowflake? lastMessageId;
  final bool nsfw;
  final int rateLimitPerUser;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': ChannelType.guildText.value,
    'name': name,
    'guild_id': guildId.toJson(),
    'topic': topic,
    'position': position,
    'parent_id': parentId?.toJson(),
    'last_message_id': lastMessageId?.toJson(),
    'nsfw': nsfw,
    'rate_limit_per_user': rateLimitPerUser,
  };

  @override
  String toString() => 'GuildTextChannel($id, #$name)';
}

final class DmChannel extends Channel {
  const DmChannel({
    required super.id,
    required this.recipientIds,
    required this.lastMessageId,
  }) : super(type: ChannelType.dm, name: null);

  final List<Snowflake> recipientIds;
  final Snowflake? lastMessageId;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': ChannelType.dm.value,
    'recipients': recipientIds.map((r) => {'id': r.toJson()}).toList(),
    'last_message_id': lastMessageId?.toJson(),
  };

  @override
  String toString() => 'DmChannel($id)';
}

/// A channel of a known-but-not-yet-modeled type (voice, group DM,
/// category, ...), or of a type this version of `fluxer_core` has never
/// seen at all. Carries [rawType] so callers that need it can still branch
/// on the raw integer while a proper variant is added in a later
/// milestone.
final class UnknownChannel extends Channel {
  const UnknownChannel({
    required super.id,
    required super.type,
    required this.rawType,
    required super.name,
  });

  final int rawType;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': rawType,
    'name': name,
  };

  @override
  String toString() => 'UnknownChannel($id, rawType=$rawType)';
}

extension _Let<T> on T? {
  R? let<R>(R Function(T) f) {
    final self = this;
    return self == null ? null : f(self);
  }
}
