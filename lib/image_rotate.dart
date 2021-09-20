import 'package:flutter/material.dart';

class ImageRotate extends StatefulWidget {
  const ImageRotate({Key? key}) : super(key: key);

  @override
  _ImageRotateState createState() => _ImageRotateState();
}

class _ImageRotateState extends State<ImageRotate>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    animationController.repeat();
  }

  stopRotation() {
    animationController.stop();
  }

  startRotation() {
    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: animationController,
                child: SizedBox(
                  height: 150.0,
                  width: 150.0,
                  child: Image.asset(
                    'assets/images/yin_yang.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                builder: (BuildContext context, Widget? _widget) {
                  return Transform.rotate(
                    angle: animationController.value * 6.3,
                    child: _widget,
                  );
                },
              )),
          Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: RaisedButton(
                onPressed: () => startRotation(),
                child: const Text(' Start Rotation '),
                textColor: Colors.white,
                color: Colors.green,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              )),
          Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: RaisedButton(
                onPressed: () => stopRotation(),
                child: const Text(' Stop Rotation '),
                textColor: Colors.white,
                color: Colors.green,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              )),
        ]);
  }
  @override
  void dispose() {
    animationController.stop();
    super.dispose();
  }
}
