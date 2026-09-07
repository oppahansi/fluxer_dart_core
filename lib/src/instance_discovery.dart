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
  });

  factory InstanceDiscovery.fromJson(Map<String, dynamic> json) =>
      InstanceDiscovery(
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

  /// The undecoded document.
  final Map<String, dynamic> raw;

  /// Whether [name] is present and enabled in [features].
  bool hasFeature(String name) => features[name] == true;

  @override
  String toString() => 'InstanceDiscovery(${endpoints.apiPublic})';
}
