import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'models.dart';
import 'home.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String model;

  Camera(this.cameras, this.model, this.setRecognitions);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController controller;
  bool isDetecting = false;
  List result = [];
  List<CameraDescription> cam;

  @override
  void initState() {
    super.initState();

    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;

            int startTime = new DateTime.now().millisecondsSinceEpoch;

           if (widget.model == posenet) {
              Tflite.runPoseNetOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                imageHeight: img.height,
                imageWidth: img.width,
                numResults: 2,
              ).then((recognitions) {

                int endTime = new DateTime.now().millisecondsSinceEpoch;

                ////

                if(recognitions.length>0){
                  print("Detection took ${endTime - startTime}");
                  for(var i =0; i<recognitions.length; i++){
                    result.add(recognitions[i]);
                  }
                  //print(result);
                }


                widget.setRecognitions(recognitions, img.height, img.width);

                isDetecting = false;
              });
            }
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
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
              flex: 90,
              child: CameraPreview(controller)

          ),
          Expanded(
              flex: 10,
              child: FloatingActionButton(
                backgroundColor: const Color(0xff03dac6),
                foregroundColor: Colors.black,
                mini: true,
                onPressed: () async {
                  if(result.isNotEmpty) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HomePage(this.cam)));
                    Map resultMap = Map<String, dynamic>.from(result[0]);
                    Map internal = Map<int, dynamic>.from(
                        resultMap.values.elementAt(1)); //keypoints only
                    List <List<dynamic>> rows = List<
                        List<dynamic>>(); //List to store data
                    print(internal);
                    for (var i = 0; i < internal.length; i ++) {
                      Map internalMap = Map<String, dynamic>.from(
                          internal[i]); // converting each keypoint to map type again
                      List<dynamic> row = List();
                      row.add(internalMap.values.elementAt(0)); //y
                      row.add(internalMap.values.elementAt(1)); //score
                      row.add(internalMap.values.elementAt(2)); //x
                      row.add(internalMap.values.elementAt(3)); //part
                      rows.add(row);
                    }
                    print(rows);
                    //generateCsv(rows);

                  }





                },
                child: Icon(Icons.navigate_before),
              )

          )
        ],
      ),
    );
  }
}
