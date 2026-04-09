// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

bool isStandalone() {
  return html.window.matchMedia('(display-mode: standalone)').matches ||
      (html.window.navigator as dynamic).standalone == true;
}
