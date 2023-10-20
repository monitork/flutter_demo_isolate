import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/base_isolate.dart';
import 'package:flutter_isolate/custom_slug.dart';
import 'package:flutter_isolate/image_rotate.dart';
import 'dart:isolate';

Future<int> _sum(int number) async {
  print("Start $number");
  var total = 0;
  for (var i = 0; i < number; i++) {
    total += i;
  }
  print("Finish $number");
  return total;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const ImageRotate(),
            Text(
              CustomSlug().makeSlug("Hà nội"),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // _sum(1000000000).then((value) => print("Data $value"));
          // final result = await createNewIsolate();
          createIsolate2();

          // final result = await floatClick();
          // print('[SHIN] ===> Main theart result $result');
          // print("OK...");
          // Nên sử dụng với Feature builder để fetch dữ liệu async
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<int> floatClick() => compute<int, int>(_sum, 1000000000);

  static void taskRunner(BaseIsolateSend<int> send) {
    // final receivePort = ReceivePort();
    // receivePort.listen((message) {
    //   print("[SHIN]: taskRunner $message");
    // });
    final total = _sum(1000000000);
    // print(receivePort.sendPort);
    // return total;
    send.sendPort.send([total, send.sendPort]);
  }

  static void taskRunner2<T>(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    receivePort.listen((message) async {
      print("[SHIN]: taskRunner $message");
      // final total = _sum(1000000000);
      if (message is Future<T>) {
        T result = await message;
        sendPort.send(result);
      }
    });
    // print(receivePort.sendPort);
    // return total;
  }

  Future<void> createIsolate2() async {
    ReceivePort receivePort = ReceivePort();
    late final Isolate newIsolate;
    try {
      newIsolate = await Isolate.spawn(taskRunner2<int>, receivePort.sendPort);
    } catch (e) {
      print(e.toString());
    }
    receivePort.listen((message) {
      print("message $message");
      if (message is SendPort) {
        message.send(_sum(1000000000));
      } else if (message is int) {
        newIsolate.kill(priority: Isolate.immediate);
        receivePort.close();
      }
    });
  }

  Future<int?> createNewIsolate() async {
    final Completer<int?> _completer = Completer<int?>();
    // ở đây vẫn là main isolate => vẫn print ra được
    // truyền vào top function hoặc static function
    // topFunction là function ngang cấp main
    // static function
    // message là giá trị truyền vào.

    // Để giao tiếp qua lại thì dùng Receive và sendPort
    late final Isolate newIsolate;
    ReceivePort receivePort = ReceivePort();
    try {
      newIsolate = await Isolate.spawn(taskRunner, BaseIsolateSend<int>(receivePort.sendPort, 1000000000));
    } catch (e) {
      print(e.toString());
      _completer.complete(null);
    }
    // Đây chính là 1 stream ==> đưa vào rxdart được
    receivePort.listen((message) {
      print("Result ${message[0]}");
      if (message[1] is SendPort) {
        message[1].send("Send to Main Thread");
        newIsolate.kill(priority: Isolate.immediate);
        receivePort.close();
        _completer.complete(message[0]);
      }
    });

    return _completer.future;
  }
}
