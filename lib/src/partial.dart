import 'channel_type.dart';
import 'snowflake.dart';

/// A channel referenced from inside another resource.
///
/// Several payloads nest a channel they are pointing at rather than
/// repeating the full resource — a webhook's followed source channel, an
/// invite's target channel. Only identity is guaranteed.
final class PartialChannel {
  const PartialChannel({
    required this.id,
    required this.name,
    required this.type,
  });

  factory PartialChannel.fromJson(Map<String, dynamic> json) => PartialChannel(
    id: Snowflake.parse(json['id'] as String),
    name: json['name'] as String?,
    type: switch (json['type']) {
      final int raw => ChannelType.tryFromValue(raw),
      _ => null,
    },
  );

  final Snowflake id;
  final String? name;

  /// `null` when absent from the payload, or a type this version does not
  /// model.
  final ChannelType? type;

  @override
  bool operator ==(Object other) => other is PartialChannel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PartialChannel($id, $name)';
}

/// A guild referenced from inside another resource.
///
/// Used where a payload names the guild something came from rather than
/// embedding the full resource: a crossposted message's source guild, the
/// guild owning an emoji or sticker, a channel follower webhook's source.
/// Which fields are populated depends on which of those it came from, so
/// everything beyond [id] and [name] is nullable.
final class PartialGuild {
  const PartialGuild({
    required this.id,
    required this.name,
    this.icon,
    this.banner,
    this.description,
    this.features = const [],
    this.approximateMemberCount,
    this.approximatePresenceCount,
    this.discoverable,
  });

  factory PartialGuild.fromJson(Map<String, dynamic> json) => PartialGuild(
    id: Snowflake.parse(json['id'] as String),
    name: json['name'] as String,
    icon: json['icon'] as String?,
    banner: json['banner'] as String?,
    description: json['description'] as String?,
    features:
        (json['features'] as List<dynamic>?)?.cast<String>().toList(
          growable: false,
        ) ??
        const [],
    approximateMemberCount: json['approximate_member_count'] as int?,
    approximatePresenceCount: json['approximate_presence_count'] as int?,
    discoverable: json['discoverable'] as bool?,
  );

  final Snowflake id;
  final String name;
  final String? icon;
  final String? banner;
  final String? description;
  final List<String> features;
  final int? approximateMemberCount;
  final int? approximatePresenceCount;
  final bool? discoverable;

  @override
  bool operator ==(Object other) => other is PartialGuild && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PartialGuild($id, $name)';
}
