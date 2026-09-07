# Changelog

## 0.2.0

- `Presence`, `PresenceStatus`, `CustomStatus` and `SessionPresence` for
  publishing a session's presence and reading the account's live session
  set.
- `AllowedMentions` and `MentionType`, controlling which mentions in a
  message notify anyone. `AllowedMentions.none` suppresses all of them,
  which is the safe default when echoing user-supplied text.
- `MessageFlags`, a set type over the existing `MessageFlag` enum.
- The attachment upload types: `AttachmentUploadRequest`, the sealed
  `AttachmentUploadTarget` (`AttachmentUploadSinglepart` /
  `AttachmentUploadMultipart`), `AttachmentUploadPart` and
  `UploadedAttachment`.
- `InstanceDiscovery` and `InstanceEndpoints`, decoding a deployment's
  `/.well-known/fluxer` document.
- `Page<T>` for the `{items, has_more, next_after}` envelope the pinned
  message and reaction user routes return.
- `PinnedMessage`, pairing a message with the time it was pinned.
- `GuildMemberSearchResult` and `GuildMemberSearchPage`. The search index
  returns a flattened shape with a numeric `joined_at`, not the
  `GuildMember` the member routes return.

## 0.1.0 — Initial release

- `Snowflake` — a zero-cost extension type over `int` wrapping Fluxer's
  64-bit snowflake ID format, with timestamp extraction.
- `Permissions` — the full guild/channel permission bitfield as a value
  object.
- `ChannelType` and a sealed `Channel` hierarchy: `GuildTextChannel`,
  `DmChannel`, `GuildVoiceChannel`, `GroupDmChannel`,
  `GuildCategoryChannel`, and `UnknownChannel` as a forward-compatible
  fallback for channel types not yet modeled. `Channel.guildId` unifies
  the guild-scoped variants behind one getter.
- Models: `User`, `Message` (with `Embed`, `Attachment`,
  `MessageReference`), `Guild` (with `onlineCount`, `vanityUrlCode`,
  and a separate `Guild.fromGuildCreateJson` for the gateway's
  nested-`properties` payload shape), `GuildRole`, `GuildMember`,
  `GuildEmoji`, `GuildSticker`, `GuildBan`, `PermissionOverwrite`,
  `Webhook`, `Invite`, `ReactionEmoji`, `GuildAuditLogEntry`,
  `GatewayBotInfo`.
- `effectiveGuildPermissions` — resolves a member's effective guild-level
  permissions from their roles, handling guild ownership and
  `administrator` correctly.
- `FluxerException` sealed hierarchy: `FluxerApiException`,
  `FluxerGatewayException`.

Every field on every model was verified against Fluxer's own live
OpenAPI spec (or, where the spec doesn't cover it, `fluxerapp/fluxer`'s
source directly) rather than assumed from Discord parity.
