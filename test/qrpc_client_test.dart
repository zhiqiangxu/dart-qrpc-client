import 'dart:typed_data';

import 'package:qrpc_client/qrpc_client.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'package:socket_io/socket_io.dart';


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

    test('login qchat', () async {
      var loginReq = {"app":"qchat_client", "device":"mac", "token":"xu"};
      var payLoadStr = json.encode(loginReq);
      print(payLoadStr);
      print(payLoadStr.length);
      Uint8List payload = Uint8List.fromList(utf8.encode(payLoadStr));
      print(payload.length);
      var resp = await awesome.request(0, 0, payload);
      
      print(utf8.decode(resp.payload));
    });
  });
}
