/// The full set of Fluxer guild/channel permission flags, verified against
/// `packages/constants/src/ChannelConstants.ts` (`export const Permissions`)
/// in the Fluxer source. Bit positions are not sequential — Fluxer reserves
/// gaps (e.g. nothing at bit 19, or between 30 and 37) presumably for
/// removed or future flags, matching the source exactly rather than
/// renumbering them.
enum PermissionFlag {
  createInstantInvite(1 << 0),
  kickMembers(1 << 1),
  banMembers(1 << 2),
  administrator(1 << 3),
  manageChannels(1 << 4),
  manageGuild(1 << 5),
  addReactions(1 << 6),
  viewAuditLog(1 << 7),
  prioritySpeaker(1 << 8),
  stream(1 << 9),
  viewChannel(1 << 10),
  sendMessages(1 << 11),
  sendTtsMessages(1 << 12),
  manageMessages(1 << 13),
  embedLinks(1 << 14),
  attachFiles(1 << 15),
  readMessageHistory(1 << 16),
  mentionEveryone(1 << 17),
  useExternalEmojis(1 << 18),
  connect(1 << 20),
  speak(1 << 21),
  muteMembers(1 << 22),
  deafenMembers(1 << 23),
  moveMembers(1 << 24),
  useVad(1 << 25),
  changeNickname(1 << 26),
  manageNicknames(1 << 27),
  manageRoles(1 << 28),
  manageWebhooks(1 << 29),
  manageExpressions(1 << 30),
  useExternalStickers(1 << 37),
  moderateMembers(1 << 40),
  createExpressions(1 << 43),
  pinMessages(1 << 51),
  bypassSlowmode(1 << 52),
  updateRtcRegion(1 << 53),
  viewChannelMembers(1 << 54);

  const PermissionFlag(this.bit);

  /// The raw bit value, as an `int`. Fits comfortably in Dart's 64-bit
  /// native `int` (highest flag here is bit 54), unlike JS which needs
  /// `bigint` for this — see `Permissions.fromJson`'s note on why the
  /// wire format is still a decimal string regardless.
  final int bit;
}

/// A permission bitfield, as attached to a [GuildRole][] or computed for a
/// member in a channel.
///
/// [GuildRole]: package:fluxer_dart_core/src/guild_role.dart
final class Permissions {
  const Permissions(this.raw);

  /// No permissions set.
  static const Permissions none = Permissions(0);

  /// Every known permission flag set at once.
  static Permissions get all =>
      Permissions(PermissionFlag.values.fold(0, (acc, f) => acc | f.bit));

  /// Parses the wire format: Fluxer sends permissions as a decimal
  /// *string* (`GuildRoleResponse.permissions: string`) rather than a raw
  /// JSON number, to avoid precision loss on clients using 64-bit doubles
  /// (e.g. JavaScript). Dart's native `int` doesn't have that problem, but
  /// we still parse the string form to match the wire format.
  factory Permissions.fromJson(String raw) => Permissions(int.parse(raw));

  final int raw;

  bool has(PermissionFlag flag) {
    if (raw & PermissionFlag.administrator.bit ==
        PermissionFlag.administrator.bit) {
      return true;
    }
    return raw & flag.bit == flag.bit;
  }

  /// All flags set in this bitfield, decoded to their named form.
  Set<PermissionFlag> toSet() => {
    for (final f in PermissionFlag.values)
      if (raw & f.bit == f.bit) f,
  };

  Permissions operator |(Permissions other) => Permissions(raw | other.raw);

  Permissions operator &(Permissions other) => Permissions(raw & other.raw);

  Permissions withFlag(PermissionFlag flag) => Permissions(raw | flag.bit);

  Permissions withoutFlag(PermissionFlag flag) => Permissions(raw & ~flag.bit);

  String toJson() => raw.toString();

  @override
  bool operator ==(Object other) => other is Permissions && other.raw == raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => 'Permissions(${toSet().map((f) => f.name).join('|')})';
}
