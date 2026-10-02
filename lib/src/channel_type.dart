/// A channel's type discriminant.
///
/// There are no thread or stage types. [guildLink] and [dmPersonalNotes]
/// carry deliberately high values, outside the contiguous range.
enum ChannelType {
  guildText(0),
  dm(1),
  guildVoice(2),
  groupDm(3),
  guildCategory(4),
  guildAnnouncement(5),
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
