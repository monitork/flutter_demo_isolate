import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

class TimerIsolate extends StatefulWidget {
  const TimerIsolate({Key? key}) : super(key: key);

  @override
  _TimerIsolateState createState() => _TimerIsolateState();
}

class _TimerIsolateState extends State<TimerIsolate> {
  late Isolate _isolate;
  bool _running = false;
  static int _counter = 0;
  String notification = "";
  late ReceivePort _receivePort;

  void _start() async {
    _running = true;
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_checkTimer, _receivePort.sendPort);
    _receivePort.listen(_handleMessage, onDone:() {
      print("done!");
    });
  }

  static void _checkTimer(SendPort sendPort) async {
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _counter++;
      String msg = 'notification ' + _counter.toString();
      print('SEND: ' + msg);
      sendPort.send(msg);
    });
  }

  void _handleMessage(dynamic data) {
    print('RECEIVED: ' + data);
    setState(() {
      notification = data;
    });
  }

  void _stop() {
    setState(() {
      _running = false;
      notification = '';
    });
    _receivePort.close();
    _isolate.kill(priority: Isolate.immediate);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timer Isolate"),
      ),
      body: Center(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             Text(
              notification,
            ),
          ],
        ),
      ),
      floatingActionButton:  FloatingActionButton(
        onPressed: _running ? _stop : _start,
        tooltip: _running ? 'Timer stop' : 'Timer start',
        child: _running ?  const Icon(Icons.stop) :  const Icon(Icons.play_arrow),
      ),
    );
  }
}
