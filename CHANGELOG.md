# Changelog

## 0.4.0

- Threads. `ChannelType` gained `announcementThread`, `publicThread` and
  `privateThread`, with `ChannelType.isThread`, and the sealed `Channel`
  hierarchy gained `ThreadChannel`. Without it a thread decoded as
  `UnknownChannel`. `ThreadMetadata` holds the archive and lock state.
- Forum and media channels: `ChannelType.guildForum` and `guildMedia`,
  both decoding to `GuildForumChannel`, with `ForumTag` and `ChannelFlag`.
- **Breaking for exhaustive switches:** a `switch` over `Channel` or
  `ChannelType` without a default now has to handle the new variants.
- `ThreadMember` and `ThreadMemberFlag`. Most of its fields are nullable
  because the same object arrives with different fields depending on
  where it appears.
- `ThreadList`, for listings that return threads and the caller's
  memberships side by side, and `ForumPost`, a thread plus its first
  message.
- `ThreadAutoArchiveDuration`, the four durations the API accepts.
- `PermissionFlag` gained `manageThreads`, `createPublicThreads`,
  `createPrivateThreads` and `sendMessagesInThreads`.
- `MessageType` gained `threadCreated` and `threadStarterMessage`, and
  `MessageFlag` gained `hasThread` and
  `failedToMentionSomeRolesInThread`. `Message.thread` holds the thread a
  message started.

## 0.3.0

- **Fixed:** `Webhook.token` is now nullable. A channel follower webhook
  carries no token, so decoding one threw and took down any call that
  listed webhooks in a channel following an announcement channel.
  `Webhook.isExecutable` reports whether it can be posted to.
- **Fixed:** `MessageReference.messageId` is now nullable. A
  `CHANNEL_FOLLOW_ADD` system message references the announcement channel
  being followed and carries no message id, which threw while decoding
  any message list containing one.
- **Breaking:** `Message.type` is now a `MessageType?` and the wire value
  moved to `Message.rawType`; `Message.flags` is now `MessageFlags`
  rather than `int`. `Message.hasFlag` is unchanged.
- `ChannelType.guildAnnouncement` and `GuildAnnouncementChannel`. Without
  it an announcement channel decoded as `UnknownChannel`.
- `MessageFlag` gained `crossposted`, `isCrosspost` and
  `sourceMessageDeleted`, with `Message.isCrossposted` and
  `Message.isCrosspost` reading the first two.
- `MessageType` and `MessageReferenceType` enums, both now documented by
  the API reference.
- `WebhookType`, plus `Webhook.sourceChannel` and `Webhook.sourceGuild`
  for channel follower webhooks.
- `FollowedChannel`, `ChannelFollowerStats` and `CrosspostSource`.
- `PartialChannel` and `PartialGuild`, for the places a payload names a
  channel or guild it points at rather than embedding the resource.
- `RefreshedAttachmentUrl`.

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
