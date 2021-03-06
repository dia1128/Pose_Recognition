package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    flutterEngine.getPlugins().add(new com.amazonaws.amplify.amplify_auth_cognito.AuthCognito());
    flutterEngine.getPlugins().add(new com.amazonaws.amplify.amplify_core.AmplifyCorePlugin());
    flutterEngine.getPlugins().add(new com.amazonaws.amplify.Amplify());
    flutterEngine.getPlugins().add(new com.amazonaws.amplify.amplify_storage_s3.AmplifyStorageS3Plugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.camera.CameraPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
      sq.flutter.tflite.TflitePlugin.registerWith(shimPluginRegistry.registrarFor("sq.flutter.tflite.TflitePlugin"));
  }
}
