import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

void main() {
  group('Guild.badgeIds', () {
    final base = {
      'id': '1',
      'name': 'g',
      'icon': null,
      'owner_id': '2',
      'roles': <dynamic>[],
    };

    test('decodes the ids as snowflakes', () {
      final guild = Guild.fromJson({
        ...base,
        'badge_ids': ['10', '11'],
      });
      expect(guild.badgeIds, [Snowflake.parse('10'), Snowflake.parse('11')]);
    });

    test('is empty when absent or empty', () {
      expect(Guild.fromJson(base).badgeIds, isEmpty);
      expect(Guild.fromJson({...base, 'badge_ids': <dynamic>[]}).badgeIds, []);
    });

    test('is read from the properties of a GUILD_CREATE payload', () {
      final guild = Guild.fromGuildCreateJson({
        'id': '1',
        'properties': {
          'name': 'g',
          'icon': null,
          'owner_id': '2',
          'badge_ids': ['10'],
        },
        'roles': <dynamic>[],
      });
      expect(guild.badgeIds, [Snowflake.parse('10')]);
    });
  });

  group('Invite.guildBadgeIds', () {
    Map<String, dynamic> invite(Map<String, dynamic>? guild) => {
      'code': 'abc',
      'guild': guild,
      'channel': {'id': '2', 'name': 'general', 'type': 0},
      'member_count': 1,
      'presence_count': 1,
      'expires_at': null,
      'temporary': false,
    };

    test('reads the badge ids of the guild', () {
      final decoded = Invite.fromJson(
        invite({
          'id': '1',
          'name': 'g',
          'badge_ids': ['10'],
        }),
      );
      expect(decoded.guildBadgeIds, [Snowflake.parse('10')]);
    });

    test('is empty with no guild', () {
      expect(Invite.fromJson(invite(null)).guildBadgeIds, isEmpty);
    });
  });

  test('DiscoveryGuild.badgeIds decodes and defaults to empty', () {
    Map<String, dynamic> guild(Map<String, dynamic> extra) => {
      'id': '1',
      'name': 'g',
      'icon': null,
      'description': null,
      'category_type': 0,
      'primary_language': null,
      'custom_tags': <dynamic>[],
      'member_count': 3,
      'online_count': 1,
      'features': <dynamic>[],
      ...extra,
    };

    expect(
      DiscoveryGuild.fromJson(
        guild({
          'badge_ids': ['10'],
        }),
      ).badgeIds,
      [Snowflake.parse('10')],
    );
    expect(DiscoveryGuild.fromJson(guild({})).badgeIds, isEmpty);
  });

  group('ProfileBadge', () {
    test('decodes a custom badge with an image URL', () {
      final badge = ProfileBadge.fromJson({
        'key': 'custom:10',
        'kind': 'custom',
        'label': 'Early supporter',
        'asset': null,
        'asset_url': 'https://media.example.com/custom-badges/10/a.webp',
        'aspect_ratio': null,
        'caption': null,
        'href': null,
      });
      expect(badge.key, 'custom:10');
      expect(badge.kind, 'custom');
      expect(badge.assetUrl, endsWith('a.webp'));
      expect(badge.asset, isNull);
      expect(badge.aspectRatio, isNull);
      expect(badge.count, isNull);
      expect(badge.details, isNull);
    });

    test('decodes the optional fields of a built-in badge', () {
      final badge = ProfileBadge.fromJson({
        'key': 'operator_pass',
        'kind': 'operator_pass',
        'label': 'Operator Pass',
        'asset': '0123456789abcdef',
        'asset_url': null,
        'small_asset': 'fedcba9876543210',
        'aspect_ratio': 1.5,
        'caption': '#42',
        'href': 'https://fluxer.app/operators',
        'count': 3,
        'accessible_label': 'Operator Pass, 3 passes',
        'details': {
          'title': 'Operator Pass',
          'lines': ['Since 2026', 'Three passes'],
        },
      });
      expect(badge.smallAsset, 'fedcba9876543210');
      expect(badge.aspectRatio, 1.5);
      expect(badge.caption, '#42');
      expect(badge.count, 3);
      expect(badge.accessibleLabel, 'Operator Pass, 3 passes');
      expect(badge.details!.title, 'Operator Pass');
      expect(badge.details!.lines, ['Since 2026', 'Three passes']);
    });

    test('decodes an integral aspect ratio sent as a JSON integer', () {
      final badge = ProfileBadge.fromJson({
        'key': 'staff',
        'kind': 'staff',
        'label': 'Staff',
        'asset': '0123456789abcdef',
        'asset_url': null,
        'aspect_ratio': 2,
        'caption': null,
        'href': null,
      });
      expect(badge.aspectRatio, 2.0);
    });
  });

  group('UserProfile badges', () {
    Map<String, dynamic> profile(Map<String, dynamic> extra) => {
      'user': {
        'id': '1',
        'username': 'u',
        'discriminator': '0',
        'global_name': null,
        'avatar': null,
        'avatar_color': null,
        'bot': false,
        'system': false,
      },
      'user_profile': <String, dynamic>{},
      ...extra,
    };

    test('defaults to none', () {
      final decoded = UserProfile.fromJson(
        profile({'profile_badges': <dynamic>[], 'operator_pass_since': null}),
      );
      expect(decoded.badges, isEmpty);
      expect(decoded.operatorPassSince, isNull);
      expect(decoded.hiddenBadgeCount, isNull);
    });

    test('decodes badges, the pass date and the hidden count', () {
      final decoded = UserProfile.fromJson(
        profile({
          'profile_badges': [
            {
              'key': 'staff',
              'kind': 'staff',
              'label': 'Staff',
              'asset': '0123456789abcdef',
              'asset_url': null,
              'aspect_ratio': null,
              'caption': null,
              'href': null,
            },
          ],
          'operator_pass_since': '2026-10-01T00:00:00.000Z',
          'hidden_profile_badge_count': 2,
        }),
      );
      expect(decoded.badges.single.kind, 'staff');
      expect(decoded.operatorPassSince, DateTime.utc(2026, 10));
      expect(decoded.hiddenBadgeCount, 2);
    });
  });

  group('InstanceDiscovery', () {
    test('defaults to no badges and no notice', () {
      final discovery = InstanceDiscovery.fromJson({
        'guild_badges': <dynamic>[],
        'notice': null,
      });
      expect(discovery.guildBadges, isEmpty);
      expect(discovery.notice, isNull);
    });

    test('decodes guild badges and a notice', () {
      final discovery = InstanceDiscovery.fromJson({
        'guild_badges': [
          {
            'id': '10',
            'name': 'Friends',
            'description': null,
            'asset_url': 'https://media.example.com/custom-badges/10/a.webp',
            'href': 'https://example.com',
          },
        ],
        'notice': {
          'id': 'n1',
          'message': 'Maintenance tonight',
          'url': null,
          'starts_at': '2026-11-01T20:00:00.000Z',
          'ends_at': null,
        },
      });
      final badge = discovery.guildBadges.single;
      expect(badge.id, Snowflake.parse('10'));
      expect(badge.description, isNull);
      expect(badge.assetUrl.host, 'media.example.com');
      expect(badge.href, Uri.parse('https://example.com'));
      expect(discovery.notice!.message, 'Maintenance tonight');
      expect(discovery.notice!.startsAt, DateTime.utc(2026, 11, 1, 20));
      expect(discovery.notice!.endsAt, isNull);
    });

    test('resolves badge ids in the order given and skips unknown ones', () {
      Map<String, dynamic> badge(String id) => {
        'id': id,
        'name': 'badge $id',
        'description': null,
        'asset_url': 'https://media.example.com/$id.webp',
        'href': null,
      };
      final discovery = InstanceDiscovery.fromJson({
        'guild_badges': [badge('10'), badge('11')],
      });

      final resolved = discovery.resolveGuildBadges([
        Snowflake.parse('11'),
        Snowflake.parse('99'),
        Snowflake.parse('10'),
      ]);
      expect(resolved.map((b) => b.name), ['badge 11', 'badge 10']);
    });
  });
}
