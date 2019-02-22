import 'dart:typed_data';

const QrpcStreamFlag = 1;
const QrpcStreamEndFlag = 2;
const QrpcStreamRstFlag = 4;
const QrpcNBFlag = 8;
const QrpcPushFlag = 16;
const QrpcCompressFlag = 32;

class QrpcConnectionConfig  {
	final int writeTimeout;
	final int readTimeout;
	final Duration dialTimeout;

  const QrpcConnectionConfig({this.writeTimeout, this.readTimeout, this.dialTimeout});
}

class QrpcFrame {
	int requestID;
	int flags;  
	int cmd;
	Uint8List payload;

  QrpcFrame({this.requestID, this.flags, this.cmd, this.payload});
  
  bool get isPushed => flags & QrpcPushFlag != 0;
}

