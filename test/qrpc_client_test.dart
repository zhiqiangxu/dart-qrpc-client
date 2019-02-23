import 'dart:typed_data';

import 'package:qrpc_client/qrpc_client.dart';
import 'package:test/test.dart';
import 'dart:convert';


void main() {
  group('A group of tests', () {
    QrpcConnection awesome;

    setUp(() {
      SubFunc sub = (QrpcConnection conn, QrpcFrame frame) {
        print('pushed ${utf8.decode(frame.payload)}');
      };
      QrpcConnectionConfig conf = new QrpcConnectionConfig(dialTimeout: new Duration(seconds: 1));
      awesome = new QrpcConnection(addr:"localhost", port:8888, conf:conf, sub:sub);
    });

    test('First Test', () {
      expect(awesome.isAwesome, isTrue);
    });
    test('connect', () async {
      bool ok = await awesome.connect();
      expect(ok, isTrue);
    });

    test('login qchat', () async {
      var loginReq = {"app":"app", "device":"mac", "token":"cs1"};
      var payloadStr = json.encode(loginReq);
      print(payloadStr);
      print(payloadStr.length);
      Uint8List payload = Uint8List.fromList(utf8.encode(payloadStr));
      print(payload.length);
      var resp = await awesome.request(0, 0, payload);
      
      print(utf8.decode(resp.payload));
      
      await new Future.delayed(const Duration(seconds: 10), () => "1");
    });

    test('math Test', () {
      int size =  (0 << 24) + 
                  (0 << 16) + 
                  (0 << 8) + 
                  154;
      bool ok = size == 154;
      print('size $size');
      expect(ok, isTrue);
    });

  });
}
