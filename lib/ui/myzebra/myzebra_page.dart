import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import '../../main.dart';
import '../camera/camera.dart';

class MyZebraPage extends StatefulWidget {
  const MyZebraPage({Key? key}) : super(key: key);

  @override
  _MyZebraPageState createState() => _MyZebraPageState();
}

class _MyZebraPageState extends State<MyZebraPage> {
  List<dynamic>? _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String status = "";

  loadModel() async {
    String? val;
    val = await Tflite.loadModel(
        model: "assets/tflite/mobilenet_v1_1.0_224.tflite",
        labels: "assets/tflite/mobilenet_v1_1.0_224.txt");
    if (val == 'success') {
      status = val!;
    }
    setState(() {});
  }

  setRecognitions(recognitions, imageHeight, imageWidth) async {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: status == ""
            ? const SizedBox()
            : Stack(
                children: [
                  Camera(
                    listCamera: cameras!,
                    setRecognition: setRecognitions,
                    model: status,
                  )
                ],
              ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status == ""
                  ? 'please wait..'
                  : _recognitions == null || _recognitions!.isEmpty
                      ? 'Bukan Zebra'
                      : _recognitions!.first["label"]
                              .toString()
                              .toLowerCase()
                              .contains('zebra')
                          ? 'Zebra'
                          : 'Bukan Zebra',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            status == ""
                ? const SizedBox()
                : _recognitions == null || _recognitions!.isEmpty
                    ? const Icon(
                        Icons.close,
                        color: Colors.red,
                      )
                    : _recognitions!.first["label"]
                            .toString()
                            .toLowerCase()
                            .contains('zebra')
                        ? const Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.close,
                            color: Colors.red,
                          )
          ],
        ),
      ),
    );
  }
}
