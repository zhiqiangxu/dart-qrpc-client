// TODO: Put public facing types in this file.
import 'dart:io';
import 'dart:async';

import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'qrpc.dart';
import 'qrpc_frame_reader.dart';


typedef void SubFunc(QrpcConnection conn, QrpcFrame frame);

/// Checks if you are awesome. Spoiler: you are.
class QrpcConnection {
  QrpcConnection({this.addr, this.port, this.conf, this.sub}) {
    rng = new Random();
    reader = new QrpcFrameReader();
    respes = new Map<int, Completer<QrpcFrame>>();
  }

  final QrpcConnectionConfig conf;
  final String addr;
  final int port;
  Random rng;
  QrpcFrameReader reader;
  SubFunc sub;
  
  Map<int, Completer<QrpcFrame>> respes;
  Socket sock;

  bool get isAwesome => true;

  Future<bool> connect() async {
    
    if (this.sock != null) return true;

    try {
      Socket sock = await Socket.connect(this.addr, this.port, timeout: conf.dialTimeout);
      this.sock = sock;
      sock.listen((List<int> data) {
          // print('Got $data size ${data.length}');
          
          if (!this.reader.add(data)) {
            print("add fail, close");
            close();
            return;
          }
          while (true) {
            var frame = reader.take();
            if (frame == null) break;
            if (frame.isPushed) {
              if (sub != null) {
                sub(this, frame);
              } else {
                print("pushed msg ignored");
              }
              continue;
            }
            if (this.respes.containsKey(frame.requestID)) {
              this.respes[frame.requestID].complete(frame);
              this.respes.remove(frame.requestID);
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
    if (this.sock == null) return;
    this.sock.close();
    this.respes.forEach((requestID,c) {
      c.completeError("closed");
    });
    this.sock = null;
  }
  
  Future<QrpcFrame> request(int cmd, int flags, Uint8List payload) async {

    bool connected = await connect();
    if (!connected) throw("connection failed");

    bool ok = false;
    int requestID;
    final c = new Completer<QrpcFrame>();
    for (int i = 0; i < 3; i++) {
      requestID = this.rng.nextInt(1<<32);
      if (!this.respes.containsKey(requestID)) {
        ok = true;
        this.respes[requestID] = c;
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
    this.sock.add(sizeBytes);

    print("requestID $requestID");
    var requestIDBytes = new Uint8List(8);
    requestIDBytes[0] = requestID >> 56;
    requestIDBytes[1] = requestID >> 48;
    requestIDBytes[2] = requestID >> 40;
    requestIDBytes[3] = requestID >> 32;
    requestIDBytes[4] = requestID >> 24;
    requestIDBytes[5] = requestID >> 16;
    requestIDBytes[6] = requestID >> 8;
    requestIDBytes[7] = requestID;
    this.sock.add(requestIDBytes);

    var cmdBytes = new Uint8List(4);
    cmdBytes[0] = flags;
    cmdBytes[1] = cmd >> 16;
    cmdBytes[2] = cmd >> 8;
    cmdBytes[3] = cmd;
    this.sock.add(cmdBytes);

    
    this.sock.add(payload);

    await this.sock.flush();

    // new StreamTransformer.fromHandlers(handleData: null);
    // this.sock.transform().listen(null);
    return c.future;
  }
}


