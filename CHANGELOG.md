# Changelog

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
