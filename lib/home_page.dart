import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/base_isolate.dart';
import 'package:flutter_isolate/custom_slug.dart';
import 'package:flutter_isolate/image_rotate.dart';
import 'dart:isolate';

Future<int> _sum(int number) async {
  var total = 0;
  for (var i = 0; i < number; i++) {
    total += i;
  }
  print("Finish");
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

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
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              CustomSlug().makeSlug("Hà nội"),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // sum().then((value) => print("Data $value"));
          // createNewIsolate();
          floatClick();
          print("OK...");
          // Nên sử dụng với Feature builder để fetch dữ liệu async
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  floatClick() {
    return compute(_sum, 1000000000);
  }

  static void taskRunner(BaseIsolateSend<int> send) {
    var receivePort = ReceivePort();
    receivePort.listen((message) {
      print("$message");
    });
    int total = 0;
    for (var i = 0; i < send.message; i++) {
      total += i;
    }
    // print(receivePort.sendPort);
    // return total;
    send.sendPort.send([total, receivePort.sendPort]);
  }

  createNewIsolate() async {
    // ở đây vẫn là main isolate => vẫn print ra được
    // truyền vào top function hoặc static function
    // topFunction là function ngang cấp main
    // static function
    // message là giá trị truyền vào.

    // Để giao tiếp qua lại thì dùng Receive và sendPort

    ReceivePort receivePort = ReceivePort();
    try {
      Isolate newIsolate = await Isolate.spawn(
          taskRunner, BaseIsolateSend<int>(receivePort.sendPort, 10000));
      Future.delayed(const Duration(milliseconds: 300), () {
        print("Go to kill");
        newIsolate.kill(priority: Isolate.immediate);
      });
    } catch (e) {
      print(e.toString());
    }
    // Đây chính là 1 stream ==> đưa vào rxdart được
    receivePort.listen((message) {
      print("Result ${message[0]}");
      print(message[1] is SendPort);
      if (message[1] is SendPort) {
        message[1].send("Send from Main Thread");
      }
    });
  }
}
