A library for Dart developers.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
SubFunc sub = (QrpcConnection conn, QrpcFrame frame) {
  print('pushed ${frame.payload}');
};
QrpcConnectionConfig conf = new QrpcConnectionConfig(dialTimeout: new Duration(seconds: 1));
var awesome = new QrpcConnection(addr:"localhost", port:8888, conf:conf, sub:sub);

var loginReq = {"app":"app", "device":"mac", "token":"cs1"};
var payloadStr = json.encode(loginReq);
Uint8List payload = utf8.encode(payloadStr);
var resp = await awesome.request(0, 0, payload);
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/zhiqiangxu/dart-qrpc-client/issues
