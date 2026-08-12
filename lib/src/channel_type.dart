/// Fluxer's channel type discriminant, verified against
/// `packages/constants/src/ChannelConstants.ts` (`export const ChannelTypes`)
/// in the Fluxer source. Notably smaller than Discord's equivalent enum —
/// no announcement channels, threads, or stage channels — plus two
/// Fluxer-specific types with deliberately high values.
enum ChannelType {
  guildText(0),
  dm(1),
  guildVoice(2),
  groupDm(3),
  guildCategory(4),
  guildLink(998),
  dmPersonalNotes(999);

  const ChannelType(this.value);

  final int value;

  static ChannelType fromValue(int value) =>
      tryFromValue(value) ??
      (throw ArgumentError('Unknown ChannelType: $value'));

  /// Like [fromValue], but `null` instead of throwing for a value this
  /// version of `fluxer_dart_core` doesn't recognize — the usual case at
  /// call sites that already have their own fallback (e.g.
  /// [UnknownChannel]) rather than wanting a thrown error.
  static ChannelType? tryFromValue(int value) {
    for (final candidate in values) {
      if (candidate.value == value) return candidate;
    }
    return null;
  }
}
