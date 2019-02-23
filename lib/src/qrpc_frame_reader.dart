import 'dart:typed_data';

import 'qrpc.dart';
import 'dart:collection';

class QrpcFrameReader {
  List<int> buffer;
  Queue<QrpcFrame> frames;
  QrpcFrameReader() {
    buffer = new List<int>();
    frames = new Queue<QrpcFrame>();
  }
  
  bool add(List<int> data) {
    buffer.addAll(data);

    // print('buffer length ${buffer.length}');
    while (buffer.length >= 16) {
      int size =  (buffer[0] << 24) + 
                  (buffer[1] << 16) + 
                  (buffer[2] << 8) + 
                  buffer[3];
      // print('size $size ${buffer[0]} ${buffer[1]} ${buffer[2]} ${buffer[3]}');
      if (size < 12) return false;

      if (this.buffer.length >= 4+size) {
        int requestID = (buffer[4] << 56) + 
                        (buffer[5] << 48) +
                        (buffer[6] << 40) +
                        (buffer[7] << 32) +
                        (buffer[8] << 24) +
                        (buffer[9] << 16) +
                        (buffer[10] << 8) +
                        buffer[11];
        // print("Got requestID $requestID");
        int flags = buffer[12];
        int cmd = (buffer[13] << 16) + 
                  (buffer[14] << 8) + 
                  buffer[15];
        Uint8List payload = Uint8List.fromList(buffer.sublist(16, 4+size));
        buffer = buffer.sublist(4+size);
        var frame = new QrpcFrame(requestID: requestID, flags: flags, cmd: cmd, payload: payload);
        frames.add(frame);
      }
    }
    return true;
  } 

  QrpcFrame take() {
    if (!frames.isEmpty) return frames.removeFirst();

    return null;
  }
}