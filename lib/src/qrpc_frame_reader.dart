import 'dart:typed_data';

import 'qrpc.dart';
import 'dart:collection';

class QrpcFrameReader {
  List<int> buffer;
  Queue<QrpcFrame> frames;
  QrpcFrameReader() {
    this.buffer = new List<int>();
    this.frames = new Queue<QrpcFrame>();
  }
  
  bool add(List<int> data) {
    this.buffer.addAll(data);

  
    while (this.buffer.length >= 16) {
      int size =  this.buffer[0] << 24 + 
                  this.buffer[1] << 16 + 
                  this.buffer[2] << 8 + 
                  this.buffer[3];

      if (size < 12) return false;

      if (this.buffer.length >= 4+size) {
        int requestID = this.buffer[4] << 56 + 
                        this.buffer[5] << 48 +
                        this.buffer[6] << 40 +
                        this.buffer[7] << 32 +
                        this.buffer[8] << 24 +
                        this.buffer[9] << 16 +
                        this.buffer[10] << 8 +
                        this.buffer[11];
        int flags = this.buffer[12];
        int cmd = this.buffer[13] << 16 + 
                  this.buffer[14] << 8 + 
                  this.buffer[15];
        Uint8List payload = Uint8List.fromList(this.buffer.sublist(16, 4+size));
        this.buffer = this.buffer.sublist(4+size);
        var frame = new QrpcFrame(requestID: requestID, flags: flags, cmd: cmd, payload: payload);
        this.frames.add(frame);
      }
    }
  } 

  QrpcFrame get() {
    if (!frames.isEmpty) return frames.removeFirst();

    return null;
  }
}