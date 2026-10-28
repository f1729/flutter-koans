import 'dart:js_interop';

import 'package:web/web.dart' as web;

const enabled = true;

/// Survives the page being closed, unlike a normal request.
void send(String url, String body) {
  web.window.navigator.sendBeacon(url, body.toJS);
}

void onPageHide(void Function() callback) {
  web.document.addEventListener(
    'visibilitychange',
    ((web.Event _) {
      if (web.document.visibilityState == 'hidden') callback();
    }).toJS,
  );
}
