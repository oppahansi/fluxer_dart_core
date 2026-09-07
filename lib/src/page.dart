import 'snowflake.dart';

/// One page of a cursor-paginated list route.
///
/// The API returns these as `{items, has_more, next_after}`. Routes that
/// page without exposing a cursor omit `next_after`, leaving [nextAfter]
/// null while [hasMore] can still be true — in that case the next page is
/// requested using the last item's own id.
final class Page<T> {
  const Page({
    required this.items,
    required this.hasMore,
    required this.nextAfter,
  });

  /// Decodes an envelope whose `items` entries are decoded by [fromJson].
  factory Page.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) => Page(
    items: (json['items'] as List<dynamic>)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    hasMore: json['has_more'] as bool? ?? false,
    nextAfter: (json['next_after'] as String?)?.let(Snowflake.parse),
  );

  final List<T> items;

  /// Whether a further page exists.
  final bool hasMore;

  /// Cursor to pass as `after` when requesting the next page.
  final Snowflake? nextAfter;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;

  @override
  String toString() => 'Page(${items.length} items, hasMore: $hasMore)';
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
