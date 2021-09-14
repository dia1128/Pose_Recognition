import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String model;

  Camera(this.cameras, this.model, this.setRecognitions);

  @override
  _CameraState createState() => new _CameraState();
}

/// Holds values related to an action entry


class _CameraState extends State<Camera> {
  CameraController controller;
  bool isDetecting = false;
  List result = [];
  List<CameraDescription> cam;
  String filePath;

  /// for CSV
  File actionFile;

 ///
  ///
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
                  print(recognitions);
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
  /// Create the csv file used to store the action data. This
  /// function does not write to the file, only creates it
  /// Returns: A file that is created asynchronously
  ///
  Future<File> createActionTextFile() async {
    // reset the action table
    // get the app's storage directory
    final Directory extDir = await getApplicationDocumentsDirectory();
    // path in local files
    final String dirPath = '${extDir.path}/pose_recognition_app/text_action_files';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/' + DateTime.now().toString();
    //print("FILE PATH: " + filePath);
    // The file name
    File file = File(filePath);
    actionFile = file;
    return file;
  }

  ///Writing into file with buffer
  Future <void> writeActionFile(List rows) async {
    var buffer = new StringBuffer();
    buffer.write("Part,X,Y,Score");
    buffer.write("\n");
    for (var j = 0; j<rows.length; j++){
      String part = rows[j][0].toString();
      String x = rows[j][1].toString();
      String y = rows[j][2].toString();
      String score = rows[j][3].toString();

      //creating the  file
      //writeActionFile(part,x,y,score); //writing data into the file
      buffer.write(part);
      buffer.write(","+x);
      buffer.write(","+y);
      buffer.write(","+score);
      buffer.write("\n");

    }


    //print(data.toString());
    actionFile.writeAsString(buffer.toString());


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
              flex: 80,
              child: CameraPreview(controller)

          ),
          Expanded(
              flex: 10,
              child: FloatingActionButton(
                heroTag: "btn1",
                backgroundColor: const Color(0xff03dac6),
                foregroundColor: Colors.black,
                mini: true,
                 onPressed: () async {
                  if(result != null) {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (context) => HomePage(this.cam))
                    // );
                    print("Submit");
                    Map resultMap = Map<String, dynamic>.from(result[0]);
                    Map internal = Map<int, dynamic>.from(
                        resultMap.values.elementAt(1)); //keypoints only
                    List <List<dynamic>> rows = List<
                        List<dynamic>>(); //List to store data

                    for (var i = 0; i < internal.length; i ++) {
                      Map internalMap = Map<String, dynamic>.from(
                          internal[i]); // converting each keypoint to map type again
                      List<dynamic> row = List();

                      row.add(internalMap["part"]); //part
                      row.add(internalMap["x"]); //x
                      row.add(internalMap["y"]); //y
                      row.add(internalMap["score"]); //score
                      rows.add(row);
                    }
                    print(rows);
                    File txtUpload = await createActionTextFile();
                    writeActionFile(rows);

                    try {
                      final UploadFileResult result = await Amplify.Storage.uploadFile (

                        local: txtUpload,
                        key: 'Pose.csv',
                      );
                      print('Successfully uploaded file: ${result.key}');
                    } on StorageException catch (e) {
                      print('Error uploading file: $e');
                    }

                  }


                },
                child: Text("Submit"),
              )

          ),
          Expanded (
            flex:10,
              child: FloatingActionButton(
                heroTag: "btn2",
                //backgroundColor: const color(Colors.pink),
                foregroundColor: Colors.pink,
                onPressed: () {
                  print("stopped");
                  controller.stopImageStream();
                  setState(() {});



                },
                child: Text("Stop"),
              )
          )



        ],
      ),
    );
  }
}
