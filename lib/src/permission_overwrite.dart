import 'permissions.dart';

/// Whether a [PermissionOverwrite] targets a role or a specific member —
/// the `type` discriminant on `PermissionOverwriteCreateRequest` in
/// Fluxer's OpenAPI spec.
enum PermissionOverwriteType {
  role(0),
  member(1);

  const PermissionOverwriteType(this.value);

  final int value;
}

/// A permission grant/deny for one role or member on one channel. Send-
/// only for now — nothing decodes a channel's existing overwrites yet,
/// so there's no `fromJson`/embedding on the `Channel` models until
/// something actually needs to read them back (see the bot roadmap's
/// note on effective-permission resolution deliberately staying
/// guild-level-only for this pass).
final class PermissionOverwrite {
  const PermissionOverwrite({
    required this.type,
    required this.allow,
    required this.deny,
  });

  final PermissionOverwriteType type;
  final Permissions allow;
  final Permissions deny;

  Map<String, dynamic> toJson() => {
    'type': type.value,
    'allow': allow.toJson(),
    'deny': deny.toJson(),
  };
}
