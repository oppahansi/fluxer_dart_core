import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

/// Payloads here are recorded from a live instance. The channel follower
/// webhook and the `CHANNEL_FOLLOW_ADD` reference both omit a field that
/// every other response of their shape carries, which is what made them
/// worth locking in.
void main() {
  group('announcement channels', () {
    test('type 5 decodes to its own variant', () {
      final channel = Channel.fromJson({
        'id': '1555684131914907651',
        'type': 5,
        'name': 'sdk-announce',
        'guild_id': '1536791058510249984',
        'topic': null,
        'position': 6,
        'parent_id': null,
        'last_message_id': null,
        'nsfw': false,
        'rate_limit_per_user': 0,
      });

      expect(channel, isA<GuildAnnouncementChannel>());
      expect(channel.type, ChannelType.guildAnnouncement);
      expect(channel.guildId, Snowflake.parse('1536791058510249984'));
      expect(channel.name, 'sdk-announce');
    });

    test('guildId getter covers the announcement variant', () {
      const channel = GuildAnnouncementChannel(
        id: Snowflake(1),
        name: 'a',
        guildId: Snowflake(2),
        topic: null,
        position: 0,
        parentId: null,
        lastMessageId: null,
        nsfw: false,
        rateLimitPerUser: 0,
      );

      expect(channel.guildId, const Snowflake(2));
    });
  });

  group('channel follower webhook', () {
    // A webhook created by following an announcement channel carries no
    // token at all. Decoding `token` as a non-null String threw on it.
    const followerJson = {
      'id': '1555684131914907653',
      'guild_id': '1536791058510249984',
      'channel_id': '1536791058510249987',
      'name': 'sdk-announce',
      'avatar': null,
      'type': 2,
      'user': {
        'id': '1536790964075495424',
        'username': 'MarlinMammut',
        'discriminator': '9784',
        'global_name': null,
        'avatar': null,
        'avatar_color': null,
        'bot': true,
        'system': false,
      },
      'source_channel': {
        'id': '1555684131914907651',
        'name': 'sdk-announce',
        'type': 5,
      },
      'source_guild': {
        'id': '1536791058510249984',
        'name': 'fluxer.dart test server',
        'icon': null,
        'features': <String>[],
      },
    };

    test('decodes without a token', () {
      final webhook = Webhook.fromJson(followerJson);

      expect(webhook.token, isNull);
      expect(webhook.isExecutable, isFalse);
      expect(webhook.type, WebhookType.channelFollower);
    });

    test('exposes the followed source channel and guild', () {
      final webhook = Webhook.fromJson(followerJson);

      expect(webhook.sourceChannel?.id, Snowflake.parse('1555684131914907651'));
      expect(webhook.sourceChannel?.type, ChannelType.guildAnnouncement);
      expect(webhook.sourceGuild?.name, 'fluxer.dart test server');
    });

    test('an incoming webhook still carries a token and is executable', () {
      final webhook = Webhook.fromJson({
        ...followerJson,
        'type': 1,
        'token': 'secret',
        'source_channel': null,
        'source_guild': null,
      });

      expect(webhook.type, WebhookType.incoming);
      expect(webhook.token, 'secret');
      expect(webhook.isExecutable, isTrue);
    });

    test('a missing type defaults to incoming', () {
      final json = {...followerJson, 'token': 'secret'}..remove('type');

      expect(Webhook.fromJson(json).type, WebhookType.incoming);
    });
  });

  group('message reference', () {
    test('a CHANNEL_FOLLOW_ADD reference has no message id', () {
      final reference = MessageReference.fromJson({
        'channel_id': '1555684131914907651',
        'guild_id': '1536791058510249984',
        'type': 0,
      });

      expect(reference.messageId, isNull);
      expect(reference.channelId, Snowflake.parse('1555684131914907651'));
      expect(reference.type, MessageReferenceType.reply);
    });

    test('a reply reference carries its message id', () {
      final reference = MessageReference.fromJson({
        'channel_id': '1',
        'message_id': '2',
        'guild_id': '3',
        'type': 1,
      });

      expect(reference.messageId, const Snowflake(2));
      expect(reference.type, MessageReferenceType.forward);
    });

    test('toJson omits a null message id', () {
      const reference = MessageReference(
        messageId: null,
        channelId: Snowflake(5),
      );

      expect(reference.toJson(), {'channel_id': '5'});
    });
  });

  group('crosspost flags and types', () {
    Message message(int flags, int type) => Message.fromJson({
      'id': '1',
      'channel_id': '2',
      'author': {
        'id': '3',
        'username': 'bot',
        'discriminator': '0',
        'global_name': null,
        'avatar': null,
        'avatar_color': null,
        'bot': true,
        'system': false,
      },
      'type': type,
      'flags': flags,
      'content': 'hi',
      'timestamp': '2026-10-02T12:00:00.000Z',
      'edited_timestamp': null,
      'pinned': false,
      'mention_everyone': false,
      'tts': false,
      'mentions': <dynamic>[],
      'mention_roles': <dynamic>[],
    });

    test('a published source message reports crossposted', () {
      final published = message(1, 0);

      expect(published.isCrossposted, isTrue);
      expect(published.isCrosspost, isFalse);
      expect(published.type, MessageType.default_);
    });

    test('a delivered copy reports isCrosspost', () {
      expect(message(2, 0).isCrosspost, isTrue);
    });

    test('a copy whose source was deleted keeps both flags', () {
      final orphaned = message(10, 0);

      expect(orphaned.isCrosspost, isTrue);
      expect(orphaned.hasFlag(MessageFlag.sourceMessageDeleted), isTrue);
    });

    test('CHANNEL_FOLLOW_ADD decodes as a message type', () {
      expect(message(0, 12).type, MessageType.channelFollowAdd);
    });

    test('an unmodelled message type leaves type null but keeps rawType', () {
      final unknown = message(0, 99);

      expect(unknown.type, isNull);
      expect(unknown.rawType, 99);
    });
  });
}
