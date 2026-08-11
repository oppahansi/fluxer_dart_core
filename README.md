# fluxer_core

Domain models, enums, the `Snowflake` ID type, the `Permissions` bitfield,
and the shared exception hierarchy for the
[fluxer.dart](https://github.com/oppahansi/fluxer.dart) ecosystem.

Pure data, zero I/O — this package doesn't know how to talk to Fluxer's REST
API or gateway, only how to represent what comes back from them. See
[`fluxer_rest`](https://github.com/oppahansi/fluxer_rest) and
[`fluxer_gateway`](https://github.com/oppahansi/fluxer_gateway) for that.

Every field on every model here was verified against Fluxer's own OpenAPI
spec (`api.fluxer.app/openapi.json`) and, where the spec didn't have it (bit
values, the snowflake epoch), against `fluxerapp/fluxer`'s source directly —
nothing here is guessed.

## What's here (v0.1 — M1 slice)

- `Snowflake` — a zero-cost extension type over `int` wrapping Fluxer's
  64-bit snowflake ID format (epoch `1420070400000`ms, 42-bit timestamp /
  10-bit worker / 12-bit sequence), with timestamp extraction.
- `Permissions` — the full 36-flag guild/channel permission bitfield
  (`CREATE_INSTANT_INVITE` through `VIEW_CHANNEL_MEMBERS`), as a value
  object rather than raw ints scattered through call sites.
- `ChannelType` — `guildText`, `dm`, `guildVoice`, `groupDm`,
  `guildCategory`, `guildLink`, `dmPersonalNotes`.
- Models: `User`, `Message`, `GuildRole`, `Guild`, and a sealed `Channel`
  hierarchy (`GuildTextChannel`, `DmChannel`, `UnknownChannel` as a
  forward-compatible fallback for channel types not yet modeled).
- `FluxerException` sealed hierarchy: `FluxerApiException`,
  `FluxerGatewayException`.

Broader model coverage (emojis, stickers, webhooks, full role/member
surface, voice states, ...) lands in M2 — see the roadmap in this
ecosystem's planning docs.

## Part of the fluxer.dart ecosystem

| Package | Purpose |
|---|---|
| [`fluxer_utils`](https://github.com/oppahansi/fluxer_utils) | generic building blocks |
| [`fluxer_core`](https://github.com/oppahansi/fluxer_core) | *(this package)* domain models |
| [`fluxer_rest`](https://github.com/oppahansi/fluxer_rest) | REST client |
| [`fluxer_gateway`](https://github.com/oppahansi/fluxer_gateway) | WebSocket gateway client |
| [`fluxer.dart`](https://github.com/oppahansi/fluxer.dart) | main framework — the `Bot` facade |
| [`fluxer.dart-bot`](https://github.com/oppahansi/fluxer.dart-bot) | example bot |

## Installation

Not yet published to pub.dev. During development, depend on it via a path or
git dependency:

```yaml
dependencies:
  fluxer_core:
    git:
      url: https://github.com/oppahansi/fluxer_core.git
```

## License

MIT — see [LICENSE](LICENSE).
