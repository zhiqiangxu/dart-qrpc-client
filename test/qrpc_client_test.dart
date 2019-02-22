import 'package:qrpc_client/qrpc_client.dart';
import 'package:test/test.dart';
import 'dart:convert';

void main() {
  group('A group of tests', () {
    QrpcConnection awesome;

    setUp(() {
      QrpcConnectionConfig conf = new QrpcConnectionConfig(dialTimeout: new Duration(seconds: 1));
      awesome = new QrpcConnection(addr:"localhost", port:8888, conf:conf);
    });

    test('First Test', () {
      expect(awesome.isAwesome, isTrue);
    });
    test('connect', () async {
      bool ok = await awesome.connect();
      expect(ok, isTrue);
    });

    test('binary', () async {
      String s = "中国人";
      var result = utf8.encode(s);
      for (int i = 0; i < result.length; i++) {
        print(result[i]);
      }
      print(result.length);
      expect(true, isTrue);
    });
  });
}
