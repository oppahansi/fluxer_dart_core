import 'snowflake.dart';

/// The endpoint URLs a deployment publishes for itself.
///
/// A deployment may put each service on its own hostname or serve them
/// all as paths under one origin, so these are read rather than derived
/// from a base URL.
final class InstanceEndpoints {
  const InstanceEndpoints({
    required this.api,
    required this.apiClient,
    required this.apiPublic,
    required this.gateway,
    required this.media,
    required this.staticCdn,
    required this.marketing,
    required this.admin,
    required this.invite,
    required this.gift,
    required this.webapp,
  });

  factory InstanceEndpoints.fromJson(Map<String, dynamic> json) {
    Uri? read(String key) {
      final value = json[key] as String?;
      return value == null ? null : Uri.parse(value);
    }

    return InstanceEndpoints(
      api: read('api'),
      apiClient: read('api_client'),
      apiPublic: read('api_public'),
      gateway: read('gateway'),
      media: read('media'),
      staticCdn: read('static_cdn'),
      marketing: read('marketing'),
      admin: read('admin'),
      invite: read('invite'),
      gift: read('gift'),
      webapp: read('webapp'),
    );
  }

  /// Origin for authenticated API requests.
  final Uri? api;

  /// Origin first-party clients use.
  final Uri? apiClient;

  /// Origin third-party clients, including bots, should use.
  final Uri? apiPublic;

  /// WebSocket origin, carrying a `ws` or `wss` scheme.
  final Uri? gateway;

  final Uri? media;
  final Uri? staticCdn;
  final Uri? marketing;
  final Uri? admin;
  final Uri? invite;
  final Uri? gift;
  final Uri? webapp;

  @override
  String toString() => 'InstanceEndpoints($apiPublic)';
}

/// A custom badge a deployment's guilds can show next to their name,
/// listed in the discovery document and referenced by `Guild.badgeIds`.
final class InstanceGuildBadge {
  const InstanceGuildBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.assetUrl,
    required this.href,
  });

  factory InstanceGuildBadge.fromJson(Map<String, dynamic> json) =>
      InstanceGuildBadge(
        id: Snowflake.parse(json['id'] as String),
        name: json['name'] as String,
        description: json['description'] as String?,
        assetUrl: Uri.parse(json['asset_url'] as String),
        href: switch (json['href']) {
          final String s => Uri.parse(s),
          _ => null,
        },
      );

  final Snowflake id;
  final String name;

  /// Text shown under the name on hover.
  final String? description;

  /// The badge image, served as WebP by the media proxy.
  final Uri assetUrl;

  /// Where a click on the badge leads.
  final Uri? href;

  @override
  String toString() => 'InstanceGuildBadge($id, $name)';
}

/// A notice the deployment's administrator shows everyone, such as planned
/// maintenance.
final class InstanceNotice {
  const InstanceNotice({
    required this.id,
    required this.message,
    required this.url,
    required this.startsAt,
    required this.endsAt,
  });

  factory InstanceNotice.fromJson(Map<String, dynamic> json) => InstanceNotice(
    id: json['id'] as String,
    message: json['message'] as String,
    url: json['url'] as String?,
    startsAt: switch (json['starts_at']) {
      final String s => DateTime.parse(s),
      _ => null,
    },
    endsAt: switch (json['ends_at']) {
      final String s => DateTime.parse(s),
      _ => null,
    },
  );

  /// Changes whenever the text changes.
  final String id;
  final String message;

  /// An optional link shown with the notice.
  final String? url;

  /// When the notice starts showing; `null` means already.
  final DateTime? startsAt;

  /// When it stops showing; `null` means it does not end.
  final DateTime? endsAt;

  @override
  String toString() => 'InstanceNotice($id)';
}

/// A deployment's self-description, served unauthenticated from
/// `/.well-known/fluxer`.
///
/// Only the fields a bot acts on are decoded; everything else stays
/// available untouched in [raw], since the document also carries client
/// concerns such as captcha keys, branding, and registration policy.
final class InstanceDiscovery {
  const InstanceDiscovery({
    required this.apiCodeVersion,
    required this.endpoints,
    required this.features,
    required this.limits,
    required this.raw,
    this.guildBadges = const [],
    this.notice,
  });

  factory InstanceDiscovery.fromJson(Map<String, dynamic> json) =>
      InstanceDiscovery(
        guildBadges: [
          for (final b in json['guild_badges'] as List<dynamic>? ?? const [])
            InstanceGuildBadge.fromJson(b as Map<String, dynamic>),
        ],
        notice: switch (json['notice']) {
          final Map<String, dynamic> n => InstanceNotice.fromJson(n),
          _ => null,
        },
        apiCodeVersion: json['api_code_version'] as int?,
        endpoints: InstanceEndpoints.fromJson(
          json['endpoints'] as Map<String, dynamic>? ?? const {},
        ),
        features: json['features'] as Map<String, dynamic>? ?? const {},
        limits: json['limits'] as Map<String, dynamic>? ?? const {},
        raw: json,
      );

  /// Increments when the deployment's API contract changes.
  final int? apiCodeVersion;

  final InstanceEndpoints endpoints;

  /// Feature switches such as `voice_enabled`, whose set varies by
  /// deployment and version.
  final Map<String, dynamic> features;

  /// Deployment-configured ceilings, such as upload sizes.
  final Map<String, dynamic> limits;

  /// The custom guild badges guilds on this deployment can show, in display
  /// order.
  final List<InstanceGuildBadge> guildBadges;

  /// The administrator's notice, or `null` when there is none.
  final InstanceNotice? notice;

  /// The undecoded document.
  final Map<String, dynamic> raw;

  /// Whether [name] is present and enabled in [features].
  bool hasFeature(String name) => features[name] == true;

  /// The entries of [guildBadges] named by [ids], in the order of [ids].
  /// An id the document does not list is skipped.
  List<InstanceGuildBadge> resolveGuildBadges(Iterable<Snowflake> ids) {
    final byId = {for (final b in guildBadges) b.id: b};
    return [for (final id in ids) ?byId[id]];
  }

  @override
  String toString() => 'InstanceDiscovery(${endpoints.apiPublic})';
}
