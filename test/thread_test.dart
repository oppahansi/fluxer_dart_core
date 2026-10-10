import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

/// Payloads here are recorded from a live instance. The thread member
/// object in particular comes in several shapes depending on where it
/// appears, which is what the nullable fields on [ThreadMember] are for.
void main() {
  const publicThread = <String, dynamic>{
    'id': '1558481243627061250',
    'type': 11,
    'guild_id': '1536791058510249984',
    'parent_id': '1536791058510249987',
    'owner_id': '1536790964075495424',
    'name': 'probe public',
    'last_message_id': '1558481295896477696',
    'last_pin_timestamp': null,
    'rate_limit_per_user': 0,
    'flags': 0,
    'thread_metadata': {
      'archived': false,
      'auto_archive_duration': 4320,
      'archive_timestamp': '2026-10-10T14:08:03.771Z',
      'locked': false,
      'create_timestamp': '2026-10-10T14:08:03.771Z',
    },
    'message_count': 1,
    'total_message_sent': 1,
    'member_count': 1,
    'member': {
      'id': '1558481243627061250',
      'user_id': '1536790964075495424',
      'join_timestamp': '2026-10-10T14:08:03.771Z',
      'flags': 1,
      'muted': false,
      'mute_config': null,
    },
  };

  group('ChannelType', () {
    test('thread, forum and media values', () {
      expect(ChannelType.fromValue(10), ChannelType.announcementThread);
      expect(ChannelType.fromValue(11), ChannelType.publicThread);
      expect(ChannelType.fromValue(12), ChannelType.privateThread);
      expect(ChannelType.fromValue(15), ChannelType.guildForum);
      expect(ChannelType.fromValue(16), ChannelType.guildMedia);
    });

    test('isThread is true for exactly the three thread types', () {
      expect(ChannelType.values.where((t) => t.isThread), [
        ChannelType.announcementThread,
        ChannelType.publicThread,
        ChannelType.privateThread,
      ]);
    });
  });

  group('ThreadChannel', () {
    test('Channel.fromJson decodes a public thread', () {
      final channel = Channel.fromJson(publicThread);

      expect(channel, isA<ThreadChannel>());
      final thread = channel as ThreadChannel;
      expect(thread.type, ChannelType.publicThread);
      expect(thread.name, 'probe public');
      expect(thread.guildId, Snowflake.parse('1536791058510249984'));
      expect(thread.parentId, Snowflake.parse('1536791058510249987'));
      expect(thread.ownerId, Snowflake.parse('1536790964075495424'));
      expect(thread.lastMessageId, Snowflake.parse('1558481295896477696'));
      expect(thread.messageCount, 1);
      expect(thread.totalMessageSent, 1);
      expect(thread.memberCount, 1);
      expect(thread.appliedTagIds, isEmpty);
      expect(thread.isArchived, isFalse);
      expect(thread.isLocked, isFalse);
      expect(thread.isPrivate, isFalse);
      expect(thread.isPinned, isFalse);
    });

    test('metadata reads the archive state and both timestamps', () {
      final metadata = ThreadChannel.fromJson(publicThread).metadata;

      expect(metadata.autoArchiveMinutes, 4320);
      expect(metadata.createdAt, DateTime.utc(2026, 10, 10, 14, 8, 3, 771));
      expect(metadata.archiveTimestamp, metadata.createdAt);
      expect(metadata.invitable, isNull);
    });

    test('invitable is present only on a private thread', () {
      final thread = ThreadChannel.fromJson({
        ...publicThread,
        'type': 12,
        'thread_metadata': {
          'archived': true,
          'auto_archive_duration': 60,
          'archive_timestamp': '2026-10-10T14:08:30.560Z',
          'locked': true,
          'invitable': false,
          'create_timestamp': '2026-10-10T14:08:03.854Z',
        },
      });

      expect(thread.isPrivate, isTrue);
      expect(thread.isArchived, isTrue);
      expect(thread.isLocked, isTrue);
      expect(thread.metadata.invitable, isFalse);
    });

    test('a forum post carries applied tags and the pinned flag', () {
      final post = ThreadChannel.fromJson({
        ...publicThread,
        'flags': 2,
        'applied_tags': ['1558481293912571904'],
        'member_ids_preview': ['1536790964075495424'],
      });

      expect(post.appliedTagIds, [Snowflake.parse('1558481293912571904')]);
      expect(post.isPinned, isTrue);
    });

    test('decodes with only what the schema requires plus its ids', () {
      final thread = ThreadChannel.fromJson({
        'id': '1',
        'type': 11,
        'guild_id': '2',
        'parent_id': '3',
        'thread_metadata': {
          'archived': false,
          'auto_archive_duration': 60,
          'archive_timestamp': '2026-10-10T14:08:03.771Z',
          'locked': false,
          'create_timestamp': '2026-10-10T14:08:03.771Z',
        },
      });

      expect(thread.ownerId, isNull);
      expect(thread.member, isNull);
      expect(thread.messageCount, 0);
    });

    test('guildId getter covers the thread variant', () {
      final Channel channel = ThreadChannel.fromJson(publicThread);

      expect(channel.guildId, Snowflake.parse('1536791058510249984'));
    });

    test('toJson round-trips', () {
      final thread = ThreadChannel.fromJson(publicThread);
      final again = ThreadChannel.fromJson(thread.toJson());

      expect(again.id, thread.id);
      expect(again.name, thread.name);
      expect(again.metadata.createdAt, thread.metadata.createdAt);
      expect(again.member?.userId, thread.member?.userId);
    });
  });

  group('ThreadMember', () {
    test('own membership carries muted and both ids', () {
      final member = ThreadChannel.fromJson(publicThread).member!;

      expect(member.threadId, Snowflake.parse('1558481243627061250'));
      expect(member.userId, Snowflake.parse('1536790964075495424'));
      expect(member.muted, isFalse);
      expect(member.hasFlag(ThreadMemberFlag.hasInteracted), isTrue);
      expect(member.hasFlag(ThreadMemberFlag.allMessages), isFalse);
      expect(member.member, isNull);
    });

    test("another user's membership has no muted", () {
      final member = ThreadMember.fromJson({
        'id': '1558481243627061253',
        'user_id': '1536790890901667840',
        'join_timestamp': '2026-10-10T14:08:30.070Z',
        'flags': 0,
      });

      expect(member.muted, isNull);
      expect(member.joinedAt, DateTime.utc(2026, 10, 10, 14, 8, 30, 70));
    });

    test('the member of a thread listed at connect has no ids', () {
      final member = ThreadMember.fromJson({
        'flags': 1,
        'join_timestamp': '2026-10-10T14:08:16.657Z',
        'mute_config': null,
        'muted': false,
      });

      expect(member.threadId, isNull);
      expect(member.userId, isNull);
    });

    test('with_member embeds the guild member', () {
      final member = ThreadMember.fromJson({
        'id': '1558481243627061250',
        'user_id': '1536790964075495424',
        'join_timestamp': '2026-10-10T14:08:03.771Z',
        'flags': 1,
        'muted': false,
        'mute_config': null,
        'member': {
          'user': {
            'id': '1536790964075495424',
            'username': 'MarlinMammut',
            'discriminator': '9784',
            'global_name': null,
            'avatar': null,
            'avatar_color': null,
            'bot': true,
            'flags': 0,
          },
          'nick': null,
          'avatar': null,
          'banner': null,
          'accent_color': null,
          'roles': ['1546623715096133632'],
          'joined_at': '2026-08-12T06:10:10.527Z',
          'mute': false,
          'deaf': false,
          'communication_disabled_until': null,
        },
      });

      expect(member.member?.user.username, 'MarlinMammut');
    });
  });

  group('ThreadList', () {
    test('memberFor joins a membership to its thread', () {
      final list = ThreadList.fromJson({
        'threads': [
          publicThread,
          {...publicThread, 'id': '9'},
        ],
        'members': [publicThread['member']],
        'has_more': true,
      });

      expect(list.threads, hasLength(2));
      expect(list.hasMore, isTrue);
      expect(
        list.memberFor(Snowflake.parse('1558481243627061250'))?.userId,
        Snowflake.parse('1536790964075495424'),
      );
      expect(list.memberFor(const Snowflake(9)), isNull);
    });

    test('the active listing has no has_more', () {
      final list = ThreadList.fromJson({'threads': [], 'members': []});

      expect(list.hasMore, isFalse);
    });
  });

  group('forum channels', () {
    const forum = <String, dynamic>{
      'id': '1558481243627061256',
      'type': 15,
      'last_message_id': null,
      'last_pin_timestamp': null,
      'guild_id': '1536791058510249984',
      'name': 'probe-forum',
      'position': 2,
      'permission_overwrites': <dynamic>[],
      'parent_id': null,
      'topic': 'guidelines',
      'nsfw': false,
      'nsfw_override': null,
      'content_warning_level': 0,
      'content_warning_text': null,
      'rate_limit_per_user': 0,
      'flags': 16,
      'default_auto_archive_duration': null,
      'default_thread_rate_limit_per_user': 0,
      'available_tags': [
        {
          'id': '1558481293912571904',
          'name': 'Solved',
          'moderated': false,
          'emoji_id': null,
          'emoji_name': '✅',
        },
      ],
      'default_reaction_emoji': null,
      'default_sort_order': null,
      'default_tag_setting': 'match_some',
      'default_forum_layout': 0,
    };

    test('type 15 decodes to a forum channel with its tags', () {
      final channel = Channel.fromJson(forum);

      expect(channel, isA<GuildForumChannel>());
      final decoded = channel as GuildForumChannel;
      expect(decoded.isMedia, isFalse);
      expect(decoded.topic, 'guidelines');
      expect(decoded.requiresTag, isTrue);
      expect(decoded.lastPostId, isNull);
      expect(decoded.guildId, Snowflake.parse('1536791058510249984'));
      final tag = decoded.availableTags.single;
      expect(tag.name, 'Solved');
      expect(tag.emojiName, '✅');
      expect(tag.emojiId, isNull);
      expect(tag.moderated, isFalse);
    });

    test('type 16 decodes to the same variant, as media', () {
      final channel = Channel.fromJson({
        ...forum,
        'type': 16,
        'flags': 1 << 15,
      });

      expect(channel, isA<GuildForumChannel>());
      channel as GuildForumChannel;
      expect(channel.isMedia, isTrue);
      expect(channel.hasFlag(ChannelFlag.hideMediaDownloadOptions), isTrue);
      expect(channel.requiresTag, isFalse);
    });

    test('a forum post response decodes to thread plus first message', () {
      final post = ForumPost.fromJson({
        ...publicThread,
        'id': '1558481293912571907',
        'parent_id': '1558481243627061256',
        'applied_tags': ['1558481293912571904'],
        'message': {
          'id': '1558481293912571907',
          'channel_id': '1558481293912571907',
          'author': {
            'id': '1536790964075495424',
            'username': 'MarlinMammut',
            'discriminator': '9784',
            'global_name': null,
            'avatar': null,
            'avatar_color': null,
            'bot': true,
            'flags': 0,
          },
          'type': 0,
          'flags': 0,
          'content': 'first message',
          'timestamp': '2026-10-10T14:08:15.651Z',
          'edited_timestamp': null,
          'pinned': false,
          'mention_everyone': false,
          'tts': false,
          'mentions': <dynamic>[],
          'mention_roles': <dynamic>[],
          'embeds': <dynamic>[],
          'attachments': <dynamic>[],
          'stickers': <dynamic>[],
        },
      });

      expect(post.message.id, post.thread.id);
      expect(post.message.content, 'first message');
      expect(post.thread.parentId, Snowflake.parse('1558481243627061256'));
    });
  });

  group('messages and threads', () {
    Map<String, dynamic> message(Map<String, dynamic> overrides) => {
      'id': '1558481243262156800',
      'channel_id': '1536791058510249987',
      'author': {
        'id': '1536790964075495424',
        'username': 'MarlinMammut',
        'discriminator': '9784',
        'global_name': null,
        'avatar': null,
        'avatar_color': null,
        'bot': true,
        'flags': 0,
      },
      'type': 0,
      'flags': 0,
      'content': 'thread probe source',
      'timestamp': '2026-10-10T14:08:03.575Z',
      'edited_timestamp': null,
      'pinned': false,
      'mention_everyone': false,
      'tts': false,
      'mentions': <dynamic>[],
      'mention_roles': <dynamic>[],
      ...overrides,
    };

    test('a message that started a thread carries it and the flag', () {
      final decoded = Message.fromJson(
        message({
          'flags': 32,
          'thread': {...publicThread, 'id': '1558481243262156800'},
        }),
      );

      expect(decoded.hasFlag(MessageFlag.hasThread), isTrue);
      expect(decoded.thread?.id, decoded.id);
    });

    test('an ordinary message has no thread', () {
      expect(Message.fromJson(message({})).thread, isNull);
    });

    test('THREAD_CREATED references the thread as a channel', () {
      final decoded = Message.fromJson(
        message({
          'type': 18,
          'content': 'probe public',
          'message_reference': {
            'channel_id': '1558481243627061250',
            'guild_id': '1536791058510249984',
            'type': 0,
          },
        }),
      );

      expect(decoded.type, MessageType.threadCreated);
      expect(decoded.messageReference?.messageId, isNull);
      expect(
        decoded.messageReference?.channelId,
        Snowflake.parse('1558481243627061250'),
      );
    });

    test('THREAD_STARTER_MESSAGE has empty content and no stickers key', () {
      final decoded = Message.fromJson(
        message({
          'channel_id': '1558481243262156800',
          'webhook_id': null,
          'type': 21,
          'content': '',
          'embeds': <dynamic>[],
          'attachments': <dynamic>[],
          'message_reference': {
            'channel_id': '1536791058510249987',
            'message_id': '1558481243262156800',
            'guild_id': '1536791058510249984',
            'type': 0,
          },
          'referenced_message': message({'flags': 32}),
        }),
      );

      expect(decoded.type, MessageType.threadStarterMessage);
      expect(decoded.content, isEmpty);
      expect(decoded.referencedMessage?.content, 'thread probe source');
    });
  });

  group('thread permissions', () {
    test('the four thread bits sit at 34, 35, 36 and 38', () {
      expect(PermissionFlag.manageThreads.bit, 1 << 34);
      expect(PermissionFlag.createPublicThreads.bit, 1 << 35);
      expect(PermissionFlag.createPrivateThreads.bit, 1 << 36);
      expect(PermissionFlag.sendMessagesInThreads.bit, 1 << 38);
    });

    test('decode from the wire string', () {
      final permissions = Permissions.fromJson('395136991232');

      expect(permissions.toSet(), {
        PermissionFlag.manageThreads,
        PermissionFlag.createPublicThreads,
        PermissionFlag.createPrivateThreads,
        PermissionFlag.sendMessagesInThreads,
      });
    });
  });
}
