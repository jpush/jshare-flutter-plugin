import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jshare_flutter_plugin/jshare_flutter_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('jshare_flutter_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });


}
