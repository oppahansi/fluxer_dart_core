/// Fluxer's snowflake ID epoch: 2015-01-01T00:00:00.000Z in milliseconds
/// since the Unix epoch. Verified against `fluxer_snowflakes/src/generator.rs`
/// (`FLUXER_EPOCH_MS`) in the Fluxer source — it happens to match Discord's
/// epoch exactly, but this is Fluxer's own constant, not an assumption.
const int fluxerEpochMs = 1420070400000;

/// Number of bits the timestamp portion of a snowflake is shifted left by
/// (10 worker-id bits + 12 sequence bits). Verified against
/// `fluxer_snowflakes/src/generator.rs` (`TIMESTAMP_SHIFT`).
const int _timestampShift = 22;

/// A Fluxer snowflake ID: a 64-bit integer encoding a creation timestamp,
/// a worker ID, and a per-worker sequence number.
///
/// Implemented as a Dart 3 extension type over [int] — a zero-cost wrapper
/// at runtime, not a boxed class — while still giving IDs a distinct type
/// from arbitrary ints and from each other's raw values.
///
/// Fluxer's REST/gateway APIs represent snowflakes as JSON strings (to
/// avoid precision loss in JS number handling), so construction goes
/// through [Snowflake.parse] in practice.
extension type const Snowflake(int value) {
  /// Parses a snowflake from its decimal string representation, as found
  /// in JSON payloads.
  factory Snowflake.parse(String value) => Snowflake(int.parse(value));

  /// The moment this ID was created, extracted from its embedded
  /// timestamp bits.
  DateTime get timestamp => DateTime.fromMillisecondsSinceEpoch(
    (value >> _timestampShift) + fluxerEpochMs,
    isUtc: true,
  );

  /// The decimal string form, matching how Fluxer serializes it in JSON.
  String toJson() => value.toString();

  // No toString/==/hashCode overrides: extension types with no `implements`
  // clause forward Object members to the representation type at runtime
  // (there's no wrapper object to box), so these already delegate to
  // int's implementations — exactly the value equality and decimal
  // toString this type needs, for free.
}
