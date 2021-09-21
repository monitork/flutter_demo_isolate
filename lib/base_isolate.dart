import 'dart:isolate';

class BaseIsolateSend<T> {
  SendPort sendPort;
  T message;

  BaseIsolateSend(this.sendPort, this.message);
}
