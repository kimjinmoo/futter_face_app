//package faceapp.grepiu.com.flutter_face_app
//
//import io.flutter.plugin.common.PluginRegistry;
//import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;
//
//class FirebaseCloudMessagingPluginRegistrant {
//    companion object {
//        fun registerWith(registry: PluginRegistry) {
//            if (alreadyRegisteredWith(registry)) {
//                return
//            }
//            FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
//        }
//
//        private fun alreadyRegisteredWith(registry: PluginRegistry): Boolean {
//            val key = FirebaseCloudMessagingPluginRegistrant::class.java.canonicalName
//            if (registry.hasPlugin(key)) {
//                return true
//            }
//            registry.registrarFor(key)
//            return false
//        }
//    }
//
//}
