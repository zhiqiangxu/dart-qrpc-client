import 'dart:convert';
import 'dart:typed_data';

import 'package:qrpc_client/qrpc_client.dart';

main() async {
  SubFunc sub = (QrpcConnection conn, QrpcFrame frame) {
    print('pushed ${frame.payload}');
  };
  QrpcConnectionConfig conf = new QrpcConnectionConfig(dialTimeout: new Duration(seconds: 1));
  var awesome = new QrpcConnection(addr:"localhost", port:8888, conf:conf, sub:sub);

  var loginReq = {"app":"app", "device":"mac", "token":"cs1"};
  var payloadStr = json.encode(loginReq);
  Uint8List payload = utf8.encode(payloadStr);
  var resp = await awesome.request(0, 0, payload);
  
  print(resp.payload);
  
}
