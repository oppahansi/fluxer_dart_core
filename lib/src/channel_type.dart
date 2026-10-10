/// A channel's type discriminant.
///
/// There is no stage type. [guildLink] and [dmPersonalNotes] carry
/// deliberately high values, outside the contiguous range.
enum ChannelType {
  guildText(0),
  dm(1),
  guildVoice(2),
  groupDm(3),
  guildCategory(4),
  guildAnnouncement(5),

  /// A thread in an announcement channel.
  announcementThread(10),

  /// A thread visible to everyone who can view its parent. Every forum
  /// or media post is one.
  publicThread(11),

  /// A thread in a text channel visible only to its members and to
  /// thread moderators.
  privateThread(12),

  /// A channel that holds posts and no messages of its own.
  guildForum(15),

  /// A forum channel that can hide media download options.
  guildMedia(16),
  guildLink(998),
  dmPersonalNotes(999);

  const ChannelType(this.value);

  final int value;

  /// Whether this is one of the three thread types.
  bool get isThread =>
      this == announcementThread ||
      this == publicThread ||
      this == privateThread;

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
