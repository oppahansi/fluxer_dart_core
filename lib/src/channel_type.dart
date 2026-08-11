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

  static ChannelType fromValue(int value) => values.firstWhere(
    (t) => t.value == value,
    orElse: () => throw ArgumentError('Unknown ChannelType: $value'),
  );
}
