# Flutter embedding and plugin entry points are invoked by Android/Flutter
# framework code and should stay stable after R8 shrinking.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep the Activity class name referenced from AndroidManifest.xml.
-keep class com.evolixtechnologies.appScopeInspector.MainActivity { *; }

# Keep Kotlin metadata used by Kotlin reflection and tooling.
-keep class kotlin.Metadata { *; }
-keepattributes *Annotation*,InnerClasses,EnclosingMethod,Signature

# Keep common model/enum names readable in crash reports while still allowing
# method bodies in the rest of the app to be optimized by R8.
-keepnames class com.evolixtechnologies.appScopeInspector.** {
    *;
}

# Flutter/Android Gradle plugin may reference optional Play Core split-install
# APIs for dynamic feature compatibility. They are not required by this app.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
