import 'snowflake.dart';

/// A category guilds can be listed under in discovery.
final class DiscoveryCategory {
  const DiscoveryCategory({required this.id, required this.name});

  factory DiscoveryCategory.fromJson(Map<String, dynamic> json) =>
      DiscoveryCategory(id: json['id'] as int, name: json['name'] as String);

  final int id;
  final String name;

  @override
  String toString() => 'DiscoveryCategory($id, $name)';
}

/// A guild as discovery lists it.
final class DiscoveryGuild {
  const DiscoveryGuild({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.categoryType,
    required this.primaryLanguage,
    required this.customTags,
    required this.memberCount,
    required this.onlineCount,
    required this.features,
    this.badgeIds = const [],
  });

  factory DiscoveryGuild.fromJson(Map<String, dynamic> json) => DiscoveryGuild(
    id: Snowflake.parse(json['id'] as String),
    name: json['name'] as String,
    icon: json['icon'] as String?,
    description: json['description'] as String?,
    categoryType: (json['category_type'] as num).toInt(),
    primaryLanguage: json['primary_language'] as String?,
    customTags: (json['custom_tags'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toList(growable: false),
    memberCount: (json['member_count'] as num).toInt(),
    onlineCount: (json['online_count'] as num).toInt(),
    features: (json['features'] as List<dynamic>? ?? const [])
        .cast<String>()
        .toList(growable: false),
    badgeIds: [
      for (final id in json['badge_ids'] as List<dynamic>? ?? const [])
        Snowflake.parse(id as String),
    ],
  );

  final Snowflake id;
  final String name;
  final String? icon;
  final String? description;

  /// A [DiscoveryCategory.id].
  final int categoryType;
  final String? primaryLanguage;
  final List<String> customTags;
  final int memberCount;
  final int onlineCount;
  final List<String> features;

  /// The custom badge ids of the guild; see `Guild.badgeIds`.
  final List<Snowflake> badgeIds;

  @override
  String toString() => 'DiscoveryGuild($id, $name)';
}

/// One page of a discovery search.
final class DiscoveryGuildPage {
  const DiscoveryGuildPage({
    required this.guilds,
    required this.total,
    required this.categoryCounts,
  });

  factory DiscoveryGuildPage.fromJson(Map<String, dynamic> json) =>
      DiscoveryGuildPage(
        guilds: (json['guilds'] as List<dynamic>)
            .map((g) => DiscoveryGuild.fromJson(g as Map<String, dynamic>))
            .toList(growable: false),
        total: (json['total'] as num).toInt(),
        categoryCounts: {
          for (final c in json['category_counts'] as List<dynamic>? ?? const [])
            ((c as Map<String, dynamic>)['category_type'] as num).toInt():
                (c['count'] as num).toInt(),
        },
      );

  final List<DiscoveryGuild> guilds;

  /// Matches across every page.
  final int total;

  /// Matches per [DiscoveryCategory.id].
  final Map<int, int> categoryCounts;
}

/// A guild's application to be listed in discovery.
///
/// [status] is the review state as the server names it, such as
/// `pending`.
final class DiscoveryApplication {
  const DiscoveryApplication({
    required this.guildId,
    required this.status,
    required this.description,
    required this.categoryType,
    required this.primaryLanguage,
    required this.customTags,
    required this.appliedAt,
    this.reviewedAt,
    this.reviewReason,
    this.removedAt,
    this.removalReason,
  });

  factory DiscoveryApplication.fromJson(Map<String, dynamic> json) =>
      DiscoveryApplication(
        guildId: Snowflake.parse(json['guild_id'] as String),
        status: json['status'] as String,
        description: json['description'] as String?,
        categoryType: (json['category_type'] as num).toInt(),
        primaryLanguage: json['primary_language'] as String?,
        customTags: (json['custom_tags'] as List<dynamic>? ?? const [])
            .cast<String>()
            .toList(growable: false),
        appliedAt: DateTime.parse(json['applied_at'] as String),
        reviewedAt: _date(json['reviewed_at']),
        reviewReason: json['review_reason'] as String?,
        removedAt: _date(json['removed_at']),
        removalReason: json['removal_reason'] as String?,
      );

  final Snowflake guildId;
  final String status;
  final String? description;
  final int categoryType;
  final String? primaryLanguage;
  final List<String> customTags;
  final DateTime appliedAt;
  final DateTime? reviewedAt;
  final String? reviewReason;
  final DateTime? removedAt;
  final String? removalReason;

  bool get isPending => status == 'pending';

  @override
  String toString() => 'DiscoveryApplication($guildId, $status)';
}

/// Whether a guild can apply for discovery, and its application if any.
final class DiscoveryStatus {
  const DiscoveryStatus({
    required this.application,
    required this.eligible,
    required this.minMemberCount,
  });

  factory DiscoveryStatus.fromJson(Map<String, dynamic> json) =>
      DiscoveryStatus(
        application: switch (json['application']) {
          final Map<String, dynamic> a => DiscoveryApplication.fromJson(a),
          _ => null,
        },
        eligible: json['eligible'] as bool,
        minMemberCount: (json['min_member_count'] as num).toInt(),
      );

  final DiscoveryApplication? application;
  final bool eligible;

  /// The member count a guild needs before it can apply.
  final int minMemberCount;
}

DateTime? _date(Object? value) => switch (value) {
  final String s => DateTime.parse(s),
  _ => null,
};
