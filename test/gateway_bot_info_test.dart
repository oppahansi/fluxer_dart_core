import 'package:fluxer_core/fluxer_core.dart';
import 'package:test/test.dart';

void main() {
  test('GatewayBotInfo.fromJson decodes the gateway/bot response shape', () {
    final info = GatewayBotInfo.fromJson({
      'url': 'wss://gateway.fluxer.app',
      'shards': 1,
      'session_start_limit': {
        'total': 1000,
        'remaining': 999,
        'reset_after': 86400000,
        'max_concurrency': 1,
      },
    });

    expect(info.url, 'wss://gateway.fluxer.app');
    expect(info.shards, 1);
    expect(info.sessionStartLimit.total, 1000);
    expect(info.sessionStartLimit.remaining, 999);
    expect(
      info.sessionStartLimit.resetAfter,
      const Duration(milliseconds: 86400000),
    );
    expect(info.sessionStartLimit.maxConcurrency, 1);
  });
}
