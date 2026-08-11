# fluxer_dart_core

Domain models, enums, the `Snowflake` ID type, the `Permissions` bitfield,
and the shared exception hierarchy for the
[fluxer_dart](https://github.com/oppahansi/fluxer_dart) ecosystem.

Pure data, zero I/O — this package doesn't know how to talk to Fluxer's REST
API or gateway, only how to represent what comes back from them. See
[`fluxer_dart_rest`](https://github.com/oppahansi/fluxer_dart_rest) and
[`fluxer_dart_gateway`](https://github.com/oppahansi/fluxer_dart_gateway) for that.

Every field on every model here was verified against Fluxer's own OpenAPI
spec (`api.fluxer.app/openapi.json`) and, where the spec didn't have it (bit
values, the snowflake epoch), against `fluxerapp/fluxer`'s source directly —
nothing here is guessed.

## What's here

- `Snowflake` — a zero-cost extension type over `int` wrapping Fluxer's
  64-bit snowflake ID format (epoch `1420070400000`ms, 42-bit timestamp /
  10-bit worker / 12-bit sequence), with timestamp extraction.
- `Permissions` — the full 36-flag guild/channel permission bitfield
  (`CREATE_INSTANT_INVITE` through `VIEW_CHANNEL_MEMBERS`), as a value
  object rather than raw ints scattered through call sites.
- `ChannelType` — `guildText`, `dm`, `guildVoice`, `groupDm`,
  `guildCategory`, `guildLink`, `dmPersonalNotes`.
- Models: `User`, `Message`, `GuildRole`, `GuildMember`, `GuildEmoji`,
  `GuildSticker`, `GuildBan`, `Webhook`, `Invite`, `Guild`, and a sealed
  `Channel` hierarchy (`GuildTextChannel`, `DmChannel`,
  `GuildVoiceChannel`, `GroupDmChannel`, `GuildCategoryChannel`,
  `UnknownChannel` as a forward-compatible fallback for channel types not
  yet modeled).
- `FluxerException` sealed hierarchy: `FluxerApiException`,
  `FluxerGatewayException`.

Audit log entries and embedding channels/emojis directly on `Guild`
(currently fetched separately via `fluxer_dart_rest`'s managers) aren't
modeled yet — see the roadmap in this ecosystem's planning docs.

## Part of the fluxer_dart ecosystem

| Package | Purpose |
|---|---|
| [`fluxer_dart_utils`](https://github.com/oppahansi/fluxer_dart_utils) | generic building blocks |
| [`fluxer_dart_core`](https://github.com/oppahansi/fluxer_dart_core) | *(this package)* domain models |
| [`fluxer_dart_rest`](https://github.com/oppahansi/fluxer_dart_rest) | REST client |
| [`fluxer_dart_gateway`](https://github.com/oppahansi/fluxer_dart_gateway) | WebSocket gateway client |
| [`fluxer_dart_voice`](https://github.com/oppahansi/fluxer_dart_voice) | voice support |
| [`fluxer_dart`](https://github.com/oppahansi/fluxer_dart) | main framework — the `Bot` facade |
| [`fluxer_dart_bot`](https://github.com/oppahansi/fluxer_dart_bot) | example bot |

## Installation

Not yet published to pub.dev. During development, depend on it via a path or
git dependency:

```yaml
dependencies:
  fluxer_dart_core:
    git:
      url: https://github.com/oppahansi/fluxer_dart_core.git
```

## License

MIT — see [LICENSE](LICENSE).
