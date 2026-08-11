import 'channel_type.dart';
import 'snowflake.dart';

/// A Fluxer channel.
///
/// Sealed so callers get exhaustive-`switch` safety: adding a new channel
/// type variant later is a compile error at every call site that doesn't
/// handle it, rather than a silent runtime gap. Modeled after
/// `ChannelResponse` in Fluxer's OpenAPI spec.
///
/// [ChannelType.guildLink] and [ChannelType.dmPersonalNotes] (both
/// Fluxer-specific, low-traffic types), along with any type this version
/// of `fluxer_dart_core` doesn't recognize at all, decode to [UnknownChannel]
/// rather than throwing.
sealed class Channel {
  const Channel({required this.id, required this.type, required this.name});

  factory Channel.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as int;
    final type = ChannelType.tryFromValue(rawType);
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
        recipientIds: _recipientIds(json),
        lastMessageId: (json['last_message_id'] as String?).let(
          Snowflake.parse,
        ),
      ),
      ChannelType.guildVoice => GuildVoiceChannel(
        id: id,
        name: name!,
        guildId: Snowflake.parse(json['guild_id'] as String),
        position: json['position'] as int? ?? 0,
        parentId: (json['parent_id'] as String?).let(Snowflake.parse),
        bitrate: json['bitrate'] as int?,
        userLimit: json['user_limit'] as int?,
        voiceConnectionLimit: json['voice_connection_limit'] as int?,
        rtcRegion: json['rtc_region'] as String?,
      ),
      ChannelType.groupDm => GroupDmChannel(
        id: id,
        name: name,
        icon: json['icon'] as String?,
        ownerId: (json['owner_id'] as String?).let(Snowflake.parse),
        recipientIds: _recipientIds(json),
        lastMessageId: (json['last_message_id'] as String?).let(
          Snowflake.parse,
        ),
      ),
      ChannelType.guildCategory => GuildCategoryChannel(
        id: id,
        name: name!,
        guildId: Snowflake.parse(json['guild_id'] as String),
        position: json['position'] as int? ?? 0,
      ),
      _ => UnknownChannel(id: id, type: type, rawType: rawType, name: name),
    };
  }

  final Snowflake id;
  final ChannelType? type;
  final String? name;

  /// The guild this channel belongs to, or `null` for a channel kind
  /// with no guild (a DM or group DM). Every guild-scoped variant
  /// carries its own `guildId` field; this just unifies them behind one
  /// getter so callers that only care "is this guild-scoped, and if so
  /// which one" don't need their own exhaustive `switch`.
  Snowflake? get guildId => switch (this) {
    GuildTextChannel(:final guildId) => guildId,
    GuildVoiceChannel(:final guildId) => guildId,
    GuildCategoryChannel(:final guildId) => guildId,
    DmChannel() || GroupDmChannel() || UnknownChannel() => null,
  };

  Map<String, dynamic> toJson();
}

List<Snowflake> _recipientIds(Map<String, dynamic> json) =>
    ((json['recipients'] as List<dynamic>?) ?? const [])
        .map(
          (r) => Snowflake.parse((r as Map<String, dynamic>)['id'] as String),
        )
        .toList(growable: false);

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

  @override
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

final class GuildVoiceChannel extends Channel {
  const GuildVoiceChannel({
    required super.id,
    required String super.name,
    required this.guildId,
    required this.position,
    required this.parentId,
    required this.bitrate,
    required this.userLimit,
    required this.voiceConnectionLimit,
    required this.rtcRegion,
  }) : super(type: ChannelType.guildVoice);

  @override
  final Snowflake guildId;
  final int position;
  final Snowflake? parentId;
  final int? bitrate;
  final int? userLimit;
  final int? voiceConnectionLimit;

  /// `null` means automatic region selection.
  final String? rtcRegion;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': ChannelType.guildVoice.value,
    'name': name,
    'guild_id': guildId.toJson(),
    'position': position,
    'parent_id': parentId?.toJson(),
    'bitrate': bitrate,
    'user_limit': userLimit,
    'voice_connection_limit': voiceConnectionLimit,
    'rtc_region': rtcRegion,
  };

  @override
  String toString() => 'GuildVoiceChannel($id, #$name)';
}

final class GroupDmChannel extends Channel {
  const GroupDmChannel({
    required super.id,
    required super.name,
    required this.icon,
    required this.ownerId,
    required this.recipientIds,
    required this.lastMessageId,
  }) : super(type: ChannelType.groupDm);

  final String? icon;

  /// The member who created (and can manage) this group DM.
  final Snowflake? ownerId;
  final List<Snowflake> recipientIds;
  final Snowflake? lastMessageId;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': ChannelType.groupDm.value,
    'name': name,
    'icon': icon,
    'owner_id': ownerId?.toJson(),
    'recipients': recipientIds.map((r) => {'id': r.toJson()}).toList(),
    'last_message_id': lastMessageId?.toJson(),
  };

  @override
  String toString() => 'GroupDmChannel($id, $name)';
}

final class GuildCategoryChannel extends Channel {
  const GuildCategoryChannel({
    required super.id,
    required String super.name,
    required this.guildId,
    required this.position,
  }) : super(type: ChannelType.guildCategory);

  @override
  final Snowflake guildId;
  final int position;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': ChannelType.guildCategory.value,
    'name': name,
    'guild_id': guildId.toJson(),
    'position': position,
  };

  @override
  String toString() => 'GuildCategoryChannel($id, $name)';
}

/// A channel of a known-but-unmodeled type ([ChannelType.guildLink],
/// [ChannelType.dmPersonalNotes]), or of a type this version of
/// `fluxer_dart_core` doesn't recognize at all. Carries [rawType] so callers
/// can still branch on the raw integer.
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
