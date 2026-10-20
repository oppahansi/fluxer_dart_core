import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

// Recorded from the local instance with a bot token. The bot token that
// `GET /applications/@me` returns has been removed from `_application`.
const _threadSearch = {
  'threads': [
    {
      'id': '1562169595744223238',
      'type': 11,
      'guild_id': '1536791058510249984',
      'parent_id': '1562169595744223236',
      'owner_id': '1536790964075495424',
      'name': 'findable post',
      'last_message_id': '1562169595744223238',
      'last_pin_timestamp': null,
      'rate_limit_per_user': 0,
      'flags': 0,
      'thread_metadata': {
        'archived': false,
        'auto_archive_duration': 4320,
        'archive_timestamp': '2026-10-20T18:24:15.584Z',
        'locked': false,
        'create_timestamp': '2026-10-20T18:24:15.584Z',
      },
      'message_count': 0,
      'total_message_sent': 0,
      'member_count': 1,
      'applied_tags': <dynamic>[],
      'member_ids_preview': ['1536790964075495424'],
    },
  ],
  'members': [
    {
      'id': '1562169595744223238',
      'user_id': '1536790964075495424',
      'join_timestamp': '2026-10-20T18:24:15.584Z',
      'flags': 0,
      'muted': false,
      'mute_config': null,
    },
  ],
  'has_more': false,
  'total_results': 1,
  'first_messages': [
    {
      'id': '1562169595744223238',
      'channel_id': '1562169595744223238',
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
      'content': 'body',
      'timestamp': '2026-10-20T18:24:15.333Z',
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
  ],
};

const _postData = {
  'threads': {
    '1562169595744223238': {
      'owner': {
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
      'first_message': {
        'id': '1562169595744223238',
        'channel_id': '1562169595744223238',
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
        'content': 'body',
        'timestamp': '2026-10-20T18:24:15.333Z',
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
    },
  },
};

const _categories = [
  {'id': 0, 'name': 'Gaming'},
  {'id': 1, 'name': 'Music'},
  {'id': 2, 'name': 'Entertainment'},
  {'id': 3, 'name': 'Education'},
  {'id': 4, 'name': 'Science & Technology'},
  {'id': 5, 'name': 'Content Creator'},
  {'id': 6, 'name': 'Anime & Manga'},
  {'id': 7, 'name': 'Movies & TV'},
  {'id': 8, 'name': 'Other'},
];

const _discoveryGuilds = {
  'guilds': <dynamic>[],
  'total': 0,
  'category_counts': <dynamic>[],
};

const _discoveryStatus = {
  'application': null,
  'eligible': true,
  'min_member_count': 1,
};

const _discoveryApplication = {
  'guild_id': '1536791058510249984',
  'status': 'pending',
  'description': 'test guild for an sdk',
  'category_type': 0,
  'primary_language': 'en-US',
  'custom_tags': <dynamic>[],
  'applied_at': '2026-10-20T18:24:18.985Z',
  'reviewed_at': null,
  'review_reason': null,
  'removed_at': null,
  'removal_reason': null,
};

const _profile = {
  'user': {
    'id': '1536790890901667840',
    'username': 'oppa',
    'discriminator': '3221',
    'global_name': 'Oppa',
    'avatar': null,
    'avatar_color': null,
    'flags': 0,
  },
  'user_profile': {
    'bio': null,
    'pronouns': null,
    'banner': null,
    'banner_color': null,
    'accent_color': null,
  },
  'guild_member': {
    'user': {
      'id': '1536790890901667840',
      'username': 'oppa',
      'discriminator': '3221',
      'global_name': 'Oppa',
      'avatar': null,
      'avatar_color': null,
      'flags': 0,
    },
    'nick': null,
    'avatar': null,
    'banner': null,
    'accent_color': null,
    'roles': <dynamic>[],
    'joined_at': '2026-08-11T17:39:00.546Z',
    'mute': false,
    'deaf': false,
    'communication_disabled_until': null,
  },
  'guild_member_profile': {
    'bio': null,
    'pronouns': null,
    'banner': null,
    'accent_color': null,
  },
  'mutual_guilds': [
    {'id': '1536791058510249984', 'nick': null},
  ],
  'connected_accounts': <dynamic>[],
  'timezone_offset': null,
};

const _stickerMetadata = {
  'id': '1562169595744223242',
  'guild_id': '1536791058510249984',
  'name': 'm12s',
  'animated': false,
  'allow_cloning': false,
};

const _stickerBulk = {
  'success': [
    {
      'id': '1562169595744223242',
      'name': 'm12s',
      'description': '',
      'tags': ['a'],
      'animated': false,
      'nsfw': false,
    },
  ],
  'failed': <dynamic>[],
};

const _searchEmpty = {
  'messages': <dynamic>[],
  'channels': <dynamic>[],
  'total': 0,
  'hits_per_page': 25,
  'page': 1,
};

const _application = {
  'id': '1536790964075495424',
  'name': 'fluxer.dart-bot example',
  'icon': null,
  'description': null,
  'bot_public': true,
  'bot_require_code_grant': false,
  'verify_key':
      '0000000000000000000000000000000000000000000000000000000000000000',
  'owner': {
    'id': '1536790890901667840',
    'username': 'oppa',
    'discriminator': '3221',
    'global_name': 'Oppa',
    'avatar': null,
    'avatar_color': null,
    'flags': 0,
  },
  'redirect_uris': <dynamic>[],
  'bot': {
    'id': '1536790964075495424',
    'username': 'MarlinMammut',
    'discriminator': '9784',
    'avatar': null,
    'banner': null,
    'bio': null,
    'mfa_enabled': false,
    'authenticator_types': <dynamic>[],
    'flags': 0,
  },
};

void main() {
  group('search', () {
    test('an indexing answer decodes to an empty, flagged result', () {
      final results = MessageSearchResults.fromJson({'indexing': true});

      expect(results.indexing, isTrue);
      expect(results.messages, isEmpty);
    });

    test('an empty result page', () {
      final results = MessageSearchResults.fromJson(_searchEmpty);

      expect(results.indexing, isFalse);
      expect(results.hitsPerPage, 25);
      expect(results.page, 1);
    });

    test('thread search with first messages', () {
      final results = ThreadSearchResults.fromJson(_threadSearch);

      expect(results.indexReady, isTrue);
      expect(results.threads.single.name, 'findable post');
      expect(results.totalResults, 1);
    });

    test('thread search answered with an index that is not ready', () {
      final results = ThreadSearchResults.fromJson({
        'code': 'SEARCH_INDEX_NOT_READY',
        'message': 'not ready',
        'documents_indexed': 0,
        'retry_after': 1.5,
      });

      expect(results.indexReady, isFalse);
      expect(results.retryAfter, const Duration(milliseconds: 1500));
    });

    test('forum post data', () {
      final threads = _postData['threads']! as Map<String, dynamic>;
      final data = ForumPostData.fromJson(
        threads.values.single as Map<String, dynamic>,
      );

      expect(data.owner!.user.username, 'MarlinMammut');
      expect(data.firstMessage!.content, 'body');
    });
  });

  group('discovery', () {
    test('categories', () {
      final categories = _categories
          .map((c) => DiscoveryCategory.fromJson(c as Map<String, dynamic>))
          .toList();

      expect(categories.first.name, 'Gaming');
      expect(categories, hasLength(9));
    });

    test('an empty guild page', () {
      final page = DiscoveryGuildPage.fromJson(_discoveryGuilds);

      expect(page.guilds, isEmpty);
      expect(page.categoryCounts, isEmpty);
    });

    test('status without an application, then the application', () {
      final status = DiscoveryStatus.fromJson(_discoveryStatus);
      expect(status.application, isNull);
      expect(status.eligible, isTrue);

      final application = DiscoveryApplication.fromJson(_discoveryApplication);
      expect(application.isPending, isTrue);
      expect(application.primaryLanguage, 'en-US');
      expect(application.reviewedAt, isNull);
    });
  });

  test('BotApplication ignores the bot token', () {
    final app = BotApplication.fromJson(_application);

    expect(app.name, 'fluxer.dart-bot example');
    expect(app.owner.username, 'oppa');
    expect(app.botPublic, isTrue);
  });

  test('UserProfile with a guild member', () {
    final profile = UserProfile.fromJson(_profile);

    expect(profile.user.username, 'oppa');
    expect(profile.guildMember, isNotNull);
    expect(profile.bio, isNull);
    expect(profile.timezoneOffset, isNull);
  });

  group('expressions', () {
    test('metadata', () {
      final metadata = ExpressionMetadata.fromJson(_stickerMetadata);

      expect(metadata.guildId, Snowflake.parse('1536791058510249984'));
      expect(metadata.allowCloning, isFalse);
    });

    test('bulk create result', () {
      final result = BulkCreateResult.fromJson(
        _stickerBulk,
        GuildSticker.fromJson,
      );

      expect(result.created.single.tags, ['a']);
      expect(result.failed, isEmpty);
    });
  });

  test('FluxerFieldError.listFromJson', () {
    // Recorded from a bulk emoji create with a one-character name.
    final errors = FluxerFieldError.listFromJson([
      {
        'path': 'emojis.1.name',
        'message': 'String length must be between 2 and 32 characters.',
        'code': 'STRING_LENGTH_INVALID',
      },
      'not an object',
    ]);

    expect(errors.single.path, 'emojis.1.name');
    expect(errors.single.code, 'STRING_LENGTH_INVALID');
  });

  test('a forum channel decodes its defaults', () {
    final channel =
        Channel.fromJson({
              'id': '1',
              'type': 15,
              'guild_id': '2',
              'name': 'f',
              'default_sort_order': 1,
              'default_forum_layout': 2,
              'default_tag_setting': 'match_all',
              'default_reaction_emoji': {'emoji_id': null, 'emoji_name': '👍'},
              'default_auto_archive_duration': 1440,
            })
            as GuildForumChannel;

    expect(channel.defaultSortOrder, ForumSortOrder.creationTime);
    expect(channel.defaultLayout, ForumLayout.grid);
    expect(channel.defaultTagSetting, ForumTagSetting.matchAll);
    expect(channel.defaultReaction!.emojiName, '👍');
    expect(
      channel.defaultAutoArchiveDuration,
      ThreadAutoArchiveDuration.oneDay,
    );
  });
}
