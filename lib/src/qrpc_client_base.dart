import 'dart:io';
import 'dart:async';

import 'dart:typed_data';
import 'dart:math';
import 'qrpc.dart';
import 'qrpc_frame_reader.dart';


typedef void SubFunc(QrpcConnection conn, QrpcFrame frame);
typedef void CloseFunc(QrpcConnection conn);

/// Checks if you are awesome. Spoiler: you are.
class QrpcConnection {
  QrpcConnection({this.addr, this.port, this.conf, this.sub, this.closecb}) {
    _rng = new Random();
    _reader = new QrpcFrameReader();
    _respes = new Map<int, Completer<QrpcFrame>>();
  }

  final QrpcConnectionConfig conf;
  final String addr;
  final int port;
  Random _rng;
  QrpcFrameReader _reader;
  SubFunc sub;
  CloseFunc closecb;
  
  Map<int, Completer<QrpcFrame>> _respes;
  Socket _sock;

  bool get isAwesome => true;

  Future<bool> connect() async {
    
    if (this._sock != null) return true;

    try {
      Socket sock = await Socket.connect(this.addr, this.port, timeout: conf.dialTimeout);
      this._sock = sock;
      sock.listen((List<int> data) {
          // print('Got $data size ${data.length}');
          
          if (!this._reader.add(data)) {
            print("add fail, close");
            close();
            return;
          }
          while (true) {
            var frame = _reader.take();
            if (frame == null) break;
            if (frame.isPushed) {
              if (sub != null) {
                sub(this, frame);
              } else {
                print("pushed msg ignored");
              }
              continue;
            }
            if (this._respes.containsKey(frame.requestID)) {
              this._respes[frame.requestID].complete(frame);
              this._respes.remove(frame.requestID);
            }
          }
          
          
        }, 
        onError: (e) { print('Got error $e');this.close(); },
        onDone: () { print('Done');this.close(); }
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void close() {
    if (this._sock == null) return;
    this._sock.close();
    this._respes.forEach((requestID,c) {
      c.completeError("closed");
    });
    this._sock = null;
    if (this.closecb != null) this.closecb(this);
  }
  
  Future<QrpcFrame> request(int cmd, int flags, Uint8List payload) async {

    if (_sock == null) throw("not connected");

    bool ok = false;
    int requestID;
    final c = new Completer<QrpcFrame>();
    for (int i = 0; i < 3; i++) {
      requestID = this._rng.nextInt(1<<32);
      if (!this._respes.containsKey(requestID)) {
        ok = true;
        this._respes[requestID] = c;
        break;
      }
    }

    if (!ok) {
      throw("out of requestID!");
    }
    
    int size = 12 + payload.length;
    var sizeBytes = new Uint8List(4);
    sizeBytes[0] = size >> 24;
    sizeBytes[1] = size >> 16;
    sizeBytes[2] = size >> 8;
    sizeBytes[3] = size;
    this._sock.add(sizeBytes);

    // print("requestID $requestID");
    var requestIDBytes = new Uint8List(8);
    requestIDBytes[0] = requestID >> 56;
    requestIDBytes[1] = requestID >> 48;
    requestIDBytes[2] = requestID >> 40;
    requestIDBytes[3] = requestID >> 32;
    requestIDBytes[4] = requestID >> 24;
    requestIDBytes[5] = requestID >> 16;
    requestIDBytes[6] = requestID >> 8;
    requestIDBytes[7] = requestID;
    this._sock.add(requestIDBytes);

    var cmdBytes = new Uint8List(4);
    cmdBytes[0] = flags;
    cmdBytes[1] = cmd >> 16;
    cmdBytes[2] = cmd >> 8;
    cmdBytes[3] = cmd;
    this._sock.add(cmdBytes);

    
    this._sock.add(payload);

    await this._sock.flush();

    // new StreamTransformer.fromHandlers(handleData: null);
    // this.sock.transform().listen(null);
    return c.future;
  }
}


