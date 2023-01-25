import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

typedef void Callback(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription>? listCamera;
  final Callback? setRecognition;
  final String? model;
  const Camera({Key? key, this.listCamera, this.setRecognition, this.model})
      : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController? controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    if (widget.listCamera == null || widget.listCamera!.isEmpty) {
      print('No camera is found');
    } else {
      controller =
          CameraController(widget.listCamera![0], ResolutionPreset.high);
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        controller!.startImageStream((image) {
          if (!isDetecting) {
            isDetecting = true;
            int startTime = DateTime.now().microsecondsSinceEpoch;
            Tflite.runModelOnFrame(
              bytesList: image.planes.map((e) {
                return e.bytes;
              }).toList(),
              imageHeight: image.height,
              imageWidth: image.width,
              numResults: 2,
            ).then((value) {
              int endTime = DateTime.now().millisecondsSinceEpoch;
              print('Detection took ${endTime - startTime}');
              widget.setRecognition!(value!, image.height, image.width);
              isDetecting = false;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }
    var size = MediaQuery.of(context).size;
    var screenH = math.max(size.height, size.width);
    var screenW = math.min(size.height, size.width);
    size = controller!.value.previewSize!;
    var previewH = math.max(size.height, size.width);
    var previewW = math.min(size.height, size.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;
    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller!),
    );
  }
}
