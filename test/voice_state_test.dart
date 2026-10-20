import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

void main() {
  // Not yet observed live: a bot joining voice receives only
  // VOICE_SERVER_UPDATE until a client connects to the media server.
  // Shaped from the reference's voice state object.
  group('VoiceState.fromJson', () {
    test('decodes a guild voice connection', () {
      final state = VoiceState.fromJson({
        'guild_id': '1',
        'channel_id': '2',
        'user_id': '3',
        'connection_id': 'chausie-eagle',
        'session_id': 'ABC',
        'member': null,
        'mute': false,
        'deaf': true,
        'self_mute': true,
        'self_deaf': false,
        'self_video': false,
        'self_stream': true,
        'is_mobile': false,
        'suppress': false,
        'viewer_stream_keys': ['k1'],
        'e2ee_capable': true,
        'p2p': false,
        'version': 7,
      });

      expect(state.guildId, const Snowflake(1));
      expect(state.channelId, const Snowflake(2));
      expect(state.connectionId, 'chausie-eagle');
      expect(state.deaf, isTrue);
      expect(state.selfMute, isTrue);
      expect(state.selfStream, isTrue);
      expect(state.viewerStreamKeys, ['k1']);
      expect(state.version, 7);
    });

    test('a null channel_id means the connection left', () {
      final state = VoiceState.fromJson({
        'guild_id': null,
        'channel_id': null,
        'user_id': '3',
        'connection_id': 'x',
      });

      expect(state.channelId, isNull);
      expect(state.guildId, isNull);
      expect(state.mute, isFalse);
      expect(state.viewerStreamKeys, isEmpty);
    });
  });
}
