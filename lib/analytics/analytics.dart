import 'dart:async';
import 'dart:convert';

import 'beacon_stub.dart' if (dart.library.js_interop) 'beacon_web.dart' as beacon;

/// Anonymous learning events (misses, reveals, solves), sent in small batches
/// to `/api/events` so we can see which koans people get stuck on. No user
/// ids, cookies or IPs; see `functions/api/events.js`.
abstract final class Analytics {
  static final _queue = <Map<String, Object?>>[];
  static Timer? _timer;
  static var _started = false;

  /// The interface language, sent along with each batch.
  static var locale = 'en';

  static void record(String koan, String outcome, {String? answer, int? attempts}) {
    if (!beacon.enabled) return;
    if (!_started) {
      _started = true;
      beacon.onPageHide(flush);
    }
    _queue.add({
      'koan': koan,
      'outcome': outcome,
      if (answer != null) 'answer': answer.length > 120 ? answer.substring(0, 120) : answer,
      'attempts': ?attempts,
    });
    if (_queue.length >= 20) {
      flush();
    } else {
      _timer ??= Timer(const Duration(seconds: 10), flush);
    }
  }

  static void flush() {
    _timer?.cancel();
    _timer = null;
    if (_queue.isEmpty) return;
    beacon.send('/api/events', jsonEncode({'locale': locale, 'events': _queue}));
    _queue.clear();
  }
}
