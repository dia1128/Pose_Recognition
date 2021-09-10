import 'dart:async';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
//import 'package:flutter_realtime_detection/amplifyconfiguration.dart';
import 'home.dart';
import 'package:amplify_flutter/amplify.dart';
import 'amplifyconfiguration.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';





List<CameraDescription> cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();


}

class _MyAppState extends State<MyApp> {

  bool _amplifyConfigured = false;

  // Instantiate Amplify


  @override
  void initState() {
    super.initState();

    //amplify is configured on startup
    _configureAmplify();
  }

  void _configureAmplify() async {
    if (!mounted) return;

    // Add this line, to include Auth and Storage plugins.
    await Amplify.addPlugins([AmplifyAuthCognito(), AmplifyStorageS3()]);
// ... add other plugins, if any
    await Amplify.configure(amplifyconfig);

    try {
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e);
    }
  }
  // Future<void> amplify() async {
  //
  //   await Amplify.configure(amplifyconfig);
  //   try {
  //     setState(() {
  //       _amplifyConfigured = true;
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  //
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tflite real-time detection',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: HomePage(cameras),
    );
  }
}

///Test run to see if amplify configured
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Scaffold(
//             appBar: AppBar(
//               title: const Text('Amplify Core example app'),
//             ),
//             body: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
//               Center(
//                 child: Column(children: [
//                   const Padding(padding: EdgeInsets.all(5.0)),
//                   Text(_amplifyConfigured ? "configured" : "not configured"),
//                 ]),
//               )
//             ])));
//   }
// }
