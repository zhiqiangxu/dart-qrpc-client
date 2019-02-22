// TODO: Put public facing types in this file.
import 'dart:io';
import 'dart:async';

import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'qrpc.dart';




/// Checks if you are awesome. Spoiler: you are.
class QrpcConnection {
  QrpcConnection({this.addr, this.port, this.conf}) {
    this.rng = new Random();
  }

  final QrpcConnectionConfig conf;
  final String addr;
  final int port;
  Random rng;
  
  Map<int, QrpcResponse> respes;
  Socket sock;

  bool get isAwesome => true;

  Future<bool> connect() async {
    try {
      Socket sock = await Socket.connect(this.addr, this.port, timeout: conf.dialTimeout);
      this.sock = sock;
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  
  Future<QrpcResponse> request(int cmd, int flags, Uint8List payload) async {

    bool ok = false;
    QrpcResponse resp;
    for (int i = 0; i < 3; i++) {
      int requestID = this.rng.nextInt(2^64-1);
      if (!this.respes.containsKey(requestID)) {
        ok = true;
        resp = new QrpcResponse(requestID:requestID);
        this.respes[requestID] = resp;
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

    int requestID = resp.requestID;
    var requestIDBytes = new Uint8List(8);
    sizeBytes[0] = requestID >> 56;
    sizeBytes[1] = requestID >> 48;
    sizeBytes[2] = requestID >> 40;
    sizeBytes[3] = requestID >> 32;
    sizeBytes[4] = requestID >> 24;
    sizeBytes[5] = requestID >> 16;
    sizeBytes[6] = requestID >> 8;
    sizeBytes[7] = requestID;
    this.sock.add(requestIDBytes);

    
    this.sock.add(payload);

    await this.sock.flush();

    return resp;
  }
}


