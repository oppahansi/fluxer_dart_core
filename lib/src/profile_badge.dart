/// The structured tooltip some badges carry in place of a single line of
/// text.
final class ProfileBadgeDetails {
  const ProfileBadgeDetails({required this.title, required this.lines});

  factory ProfileBadgeDetails.fromJson(Map<String, dynamic> json) =>
      ProfileBadgeDetails(
        title: json['title'] as String,
        lines: (json['lines'] as List<dynamic>).cast<String>().toList(
          growable: false,
        ),
      );

  /// The first line, drawn under the larger badge art.
  final String title;

  /// The remaining lines, in order.
  final List<String> lines;

  @override
  String toString() => 'ProfileBadgeDetails($title)';
}

/// A badge shown on a user's profile.
///
/// [kind] is open-ended: the server lists `staff`, `partner`,
/// `bug_hunter`, `operator_pass`, `visionary`, `visionary_number`,
/// `plutonium`, `custom` and, on self-hosted instances, `premium`, and may
/// add more. Render an unknown kind from the other fields.
final class ProfileBadge {
  const ProfileBadge({
    required this.key,
    required this.kind,
    required this.label,
    required this.asset,
    required this.assetUrl,
    required this.aspectRatio,
    required this.caption,
    required this.href,
    this.smallAsset,
    this.count,
    this.accessibleLabel,
    this.details,
  });

  factory ProfileBadge.fromJson(Map<String, dynamic> json) => ProfileBadge(
    key: json['key'] as String,
    kind: json['kind'] as String,
    label: json['label'] as String,
    asset: json['asset'] as String?,
    assetUrl: json['asset_url'] as String?,
    aspectRatio: (json['aspect_ratio'] as num?)?.toDouble(),
    caption: json['caption'] as String?,
    href: json['href'] as String?,
    smallAsset: json['small_asset'] as String?,
    count: (json['count'] as num?)?.toInt(),
    accessibleLabel: json['accessible_label'] as String?,
    details: switch (json['details']) {
      final Map<String, dynamic> d => ProfileBadgeDetails.fromJson(d),
      _ => null,
    },
  );

  /// Stable identity: equal to [kind] for a built-in badge and
  /// `custom:<id>` for a custom one.
  final String key;
  final String kind;

  /// The full description, localized for the viewer.
  final String label;

  /// The image hash, served at `<static cdn>/badges/<asset>.webp`. `null`
  /// for a text badge and for one that has an [assetUrl].
  final String? asset;

  /// The absolute image URL of a badge whose image is not a static badge
  /// hash, such as a custom badge.
  final String? assetUrl;

  /// The image hash to draw at 20 pixels and smaller, when [asset] does
  /// not read well that small.
  final String? smallAsset;

  /// The image width divided by its height; `null` for a square badge.
  final double? aspectRatio;

  /// Short text such as `#42`, shown instead of an image when there is
  /// none and as its alt text otherwise.
  final String? caption;

  /// The absolute URL the badge links to.
  final String? href;

  /// How many passes the badge stands for, from 2. Absent below 2 and
  /// when the holder hides the number.
  final int? count;

  /// A screen-reader label that carries the full [count], used in place of
  /// [label] when present.
  final String? accessibleLabel;

  final ProfileBadgeDetails? details;

  @override
  String toString() => 'ProfileBadge($key)';
}
