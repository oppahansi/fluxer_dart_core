import 'snowflake.dart';

/// What anyone can learn about a custom emoji or sticker from its id
/// alone, including the guild it belongs to and whether it may be cloned
/// into another guild.
final class ExpressionMetadata {
  const ExpressionMetadata({
    required this.id,
    required this.guildId,
    required this.name,
    required this.animated,
    required this.allowCloning,
  });

  factory ExpressionMetadata.fromJson(Map<String, dynamic> json) =>
      ExpressionMetadata(
        id: Snowflake.parse(json['id'] as String),
        guildId: Snowflake.parse(json['guild_id'] as String),
        name: json['name'] as String,
        animated: json['animated'] as bool? ?? false,
        allowCloning: json['allow_cloning'] as bool? ?? false,
      );

  final Snowflake id;
  final Snowflake guildId;
  final String name;
  final bool animated;
  final bool allowCloning;
}

/// The outcome of a bulk emoji or sticker create.
///
/// A request with an invalid entry is rejected as a whole before
/// anything is created; [failed] lists entries that passed validation
/// but could not be created.
final class BulkCreateResult<T> {
  const BulkCreateResult({required this.created, required this.failed});

  factory BulkCreateResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) decode,
  ) => BulkCreateResult(
    created: (json['success'] as List<dynamic>? ?? const [])
        .map((e) => decode(e as Map<String, dynamic>))
        .toList(growable: false),
    failed: [
      for (final f in json['failed'] as List<dynamic>? ?? const [])
        (
          name: (f as Map<String, dynamic>)['name'] as String,
          error: f['error'] as String,
        ),
    ],
  );

  final List<T> created;
  final List<({String name, String error})> failed;
}
