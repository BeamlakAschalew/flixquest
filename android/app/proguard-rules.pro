## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**

# The download bridge is called from Flutter/Android framework entry points,
# and Better Player opens the Media3 cache through StreamDownloadStore using
# reflection. Keep this small native package intact so R8 cannot rename the
# reflected class/methods or optimize the foreground-service callbacks only in
# release builds.
-keep class dev.beamlak.flixquest_v2.downloads.** { *; }
