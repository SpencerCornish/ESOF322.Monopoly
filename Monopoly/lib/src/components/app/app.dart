import 'dart:html';
import 'dart:async';

void main() {
  Timer tempLoadingTimeout = new Timer(new Duration(seconds: 4), _changeStuff);
}

void _changeStuff() {
  querySelector('#output').text = 'Your Dart app is running.';
}
