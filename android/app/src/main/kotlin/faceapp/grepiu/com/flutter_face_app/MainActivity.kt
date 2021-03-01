package faceapp.grepiu.com.flutter_face_app

import android.os.Bundle
import com.tekartik.sqflite.Constant
import com.tekartik.sqflite.SqflitePlugin
import io.flutter.plugins.camera.CameraPlugin
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin
import io.flutter.plugins.pathprovider.PathProviderPlugin
import io.flutter.plugins.share.SharePlugin
import io.flutter.plugins.urllauncher.UrlLauncherPlugin

class MainActivity : io.flutter.app.FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState);
        FirebaseMessagingPlugin.registerWith(registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
        FirebaseAdMobPlugin.registerWith(registrarFor("plugins.flutter.io.firebase_admob"))
        CameraPlugin.registerWith(registrarFor("io.flutter.plugins.camera.CameraPlugin"));
        PathProviderPlugin.registerWith(registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
        SharePlugin.registerWith(registrarFor("io.flutter.plugins.share.SharePlugin"));
        SqflitePlugin.registerWith(registrarFor(Constant.PLUGIN_KEY));
        UrlLauncherPlugin.registerWith(registrarFor("io.flutter.plugins.url_launcher"))
    }
}