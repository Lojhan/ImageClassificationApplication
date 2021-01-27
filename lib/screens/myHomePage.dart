import 'dart:io';

import 'package:ImageClassificationApp/components/ResultDisplay.dart';
import 'package:ImageClassificationApp/services/AIService.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.cameras}) : super(key: key);

  final String title;
  final List<CameraDescription> cameras;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  CameraController controller;
  String imagePath;
  String title;
  Image image;

  @override
  void initState() {
    super.initState();
    controller =
        CameraController(widget.cameras[0], ResolutionPreset.ultraHigh);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container(child: Text('teste'));
    }
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          children: [
            CameraPreview(controller),
            Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.bottomCenter,
              child: Card(
                shape: CircleBorder(),
                child: IconButton(
                    color: Colors.blue,
                    icon: Icon(
                      Icons.camera,
                    ),
                    onPressed: () async => {
                          imagePath = await takePicture(),
                          title = await getPlantInfo(imagePath),
                          setState(() {}),
                          showMyImage(title, imagePath, context),
                        }),
              ),
            ),
          ],
        ));
  }
}
