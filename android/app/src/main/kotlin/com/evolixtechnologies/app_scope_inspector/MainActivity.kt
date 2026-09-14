package com.evolixtechnologies.appScopeInspector

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors
import java.util.zip.ZipEntry
import java.util.zip.ZipFile

class MainActivity : FlutterActivity() {
    private val channelName = "app_scope_inspector/native_app_info"
    private val backgroundExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppInfo" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName.isNullOrBlank()) {
                        result.error(
                            "INVALID_PACKAGE",
                            "A packageName argument is required.",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    backgroundExecutor.execute {
                        try {
                            val appInfo = readAppInfo(packageName, includeIcon = true)
                            mainHandler.post { result.success(appInfo) }
                        } catch (error: PackageManager.NameNotFoundException) {
                            mainHandler.post {
                                result.error(
                                    "APP_NOT_FOUND",
                                    "No installed application was found for $packageName.",
                                    null,
                                )
                            }
                        } catch (error: Exception) {
                            mainHandler.post {
                                result.error(
                                    "APP_INFO_FAILED",
                                    error.message ?: "Unable to inspect installed application.",
                                    null,
                                )
                            }
                        }
                    }
                }

                "getInstalledApps" -> {
                    val excludeSystemApps = call.argument<Boolean>("excludeSystemApps") ?: false
                    val excludeNonLaunchableApps =
                        call.argument<Boolean>("excludeNonLaunchableApps") ?: false
                    val withIcon = call.argument<Boolean>("withIcon") ?: true
                    val packageNamePrefix = call.argument<String>("packageNamePrefix")

                    backgroundExecutor.execute {
                        try {
                            val apps = readInstalledApps(
                                excludeSystemApps = excludeSystemApps,
                                excludeNonLaunchableApps = excludeNonLaunchableApps,
                                withIcon = withIcon,
                                packageNamePrefix = packageNamePrefix,
                            )
                            mainHandler.post { result.success(apps) }
                        } catch (error: Exception) {
                            mainHandler.post {
                                result.error(
                                    "APPS_LIST_FAILED",
                                    error.message ?: "Unable to read installed applications.",
                                    null,
                                )
                            }
                        }
                    }
                }

                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName.isNullOrBlank()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }

                    backgroundExecutor.execute {
                        val icon = try {
                            val appInfo = getApplicationInfo(packageName)
                            iconBytes(appInfo)
                        } catch (_: Exception) {
                            null
                        }
                        mainHandler.post { result.success(icon) }
                    }
                }

                "startApp" -> {
                    val packageName = call.argument<String>("packageName")
                    result.success(packageName?.let { startApp(it) } ?: false)
                }

                "openSettings" -> {
                    val packageName = call.argument<String>("packageName")
                    if (!packageName.isNullOrBlank()) {
                        openAppSettings(packageName)
                    }
                    result.success(null)
                }

                "uninstallApp" -> {
                    val packageName = call.argument<String>("packageName")
                    result.success(packageName?.let { uninstallApp(it) } ?: false)
                }

                "isSystemApp" -> {
                    val packageName = call.argument<String>("packageName")
                    result.success(packageName?.let { isSystemApp(it) })
                }

                "isAppInstalled" -> {
                    val packageName = call.argument<String>("packageName")
                    result.success(packageName?.let { isAppInstalled(it) } ?: false)
                }

                "toast" -> {
                    val message = call.argument<String>("message").orEmpty()
                    val isShortLength = call.argument<Boolean>("isShortLength") ?: true
                    Toast.makeText(
                        this,
                        message,
                        if (isShortLength) Toast.LENGTH_SHORT else Toast.LENGTH_LONG,
                    ).show()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun readInstalledApps(
        excludeSystemApps: Boolean,
        excludeNonLaunchableApps: Boolean,
        withIcon: Boolean,
        packageNamePrefix: String?,
    ): List<Map<String, Any?>> {
        val applications = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getInstalledApplications(
                PackageManager.ApplicationInfoFlags.of(0L),
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        }

        return applications
            .asSequence()
            .filter { appInfo ->
                !excludeSystemApps || !appInfo.isSystemApplication()
            }
            .filter { appInfo ->
                packageNamePrefix.isNullOrBlank() ||
                    appInfo.packageName.startsWith(packageNamePrefix)
            }
            .mapNotNull { appInfo ->
                val launchable = packageManager.getLaunchIntentForPackage(appInfo.packageName) != null
                if (excludeNonLaunchableApps && !launchable) return@mapNotNull null

                val packageInfo = try {
                    getPackageInfo(appInfo.packageName)
                } catch (_: PackageManager.NameNotFoundException) {
                    null
                }

                appInfoToMap(
                    packageInfo = packageInfo,
                    applicationInfo = appInfo,
                    includeIcon = withIcon,
                    includeFrameworkDetails = false,
                )
            }
            .sortedBy { row ->
                row["name"]?.toString()?.lowercase().orEmpty()
            }
            .toList()
    }

    private fun readAppInfo(
        packageName: String,
        includeIcon: Boolean,
    ): Map<String, Any?> {
        val packageInfo = getPackageInfo(packageName)
        val applicationInfo = packageInfo.applicationInfo
            ?: return unavailableAppInfo(packageInfo, packageName)

        return appInfoToMap(
            packageInfo = packageInfo,
            applicationInfo = applicationInfo,
            includeIcon = includeIcon,
            includeFrameworkDetails = true,
        )
    }

    private fun appInfoToMap(
        packageInfo: PackageInfo?,
        applicationInfo: ApplicationInfo,
        includeIcon: Boolean,
        includeFrameworkDetails: Boolean,
    ): Map<String, Any?> {
        val frameworkInfo = inspectFramework(
            sourceDir = applicationInfo.sourceDir,
            includeVersionScan = includeFrameworkDetails,
        )
        val packageName = applicationInfo.packageName

        return mapOf(
            "name" to applicationInfo.loadLabel(packageManager).toString(),
            "packageName" to packageName,
            "versionName" to packageInfo?.versionName,
            "versionCode" to packageInfo?.let { versionCode(it) },
            "installedTimestamp" to (packageInfo?.firstInstallTime ?: 0L),
            "firstInstallTime" to (packageInfo?.firstInstallTime ?: 0L),
            "lastUpdateTime" to (packageInfo?.lastUpdateTime ?: 0L),
            "minSdkVersion" to minSdkVersion(applicationInfo),
            "targetSdkVersion" to applicationInfo.targetSdkVersion,
            "compileSdkVersion" to compileSdkVersion(applicationInfo),
            "compileSdkVersionCodename" to compileSdkVersionCodename(applicationInfo),
            "installerPackageName" to installerPackageName(packageName),
            "sourceDir" to applicationInfo.sourceDir,
            "publicSourceDir" to applicationInfo.publicSourceDir,
            "nativeLibraryDir" to applicationInfo.nativeLibraryDir,
            "dataDir" to applicationInfo.dataDir,
            "processName" to applicationInfo.processName,
            "taskAffinity" to applicationInfo.taskAffinity,
            "uid" to applicationInfo.uid,
            "debuggable" to applicationInfo.isDebuggable(),
            "isSystemApp" to applicationInfo.isSystemApplication(),
            "isLaunchableApp" to (packageManager.getLaunchIntentForPackage(packageName) != null),
            "category" to categoryName(applicationInfo),
            "platformType" to frameworkInfo.framework,
            "icon" to if (includeIcon) iconBytes(applicationInfo) else null,
            "hasNativeCode" to frameworkInfo.hasNativeCode,
            "detectedFramework" to frameworkInfo.framework,
            "frameworkVersion" to frameworkInfo.frameworkVersion,
            "language" to frameworkInfo.language,
            "runtime" to frameworkInfo.runtime,
            "sdkVersion" to frameworkInfo.sdkVersion,
            "frameworkVersionAvailable" to frameworkInfo.frameworkVersionAvailable,
            "frameworkEvidence" to frameworkInfo.evidence,
            "requestedPermissions" to packageInfo?.let { requestedPermissions(it) }.orEmpty(),
            "requestedFeatures" to packageInfo?.let { requestedFeatures(it) }.orEmpty(),
        )
    }

    private fun unavailableAppInfo(
        packageInfo: PackageInfo,
        packageName: String,
    ): Map<String, Any?> {
        return mapOf(
            "packageName" to packageInfo.packageName,
            "versionName" to packageInfo.versionName,
            "versionCode" to versionCode(packageInfo),
            "firstInstallTime" to packageInfo.firstInstallTime,
            "lastUpdateTime" to packageInfo.lastUpdateTime,
            "installerPackageName" to installerPackageName(packageName),
            "detectedFramework" to "Unknown",
            "language" to "Unknown",
            "runtime" to "Unknown",
            "frameworkVersionAvailable" to false,
            "frameworkEvidence" to emptyList<String>(),
            "requestedPermissions" to requestedPermissions(packageInfo),
            "requestedFeatures" to requestedFeatures(packageInfo),
        )
    }

    private fun getPackageInfo(packageName: String): PackageInfo {
        val flags = PackageManager.GET_PERMISSIONS or
            PackageManager.GET_CONFIGURATIONS or
            PackageManager.GET_META_DATA

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getPackageInfo(
                packageName,
                PackageManager.PackageInfoFlags.of(flags.toLong()),
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.getPackageInfo(packageName, flags)
        }
    }

    private fun getApplicationInfo(packageName: String): ApplicationInfo {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getApplicationInfo(
                packageName,
                PackageManager.ApplicationInfoFlags.of(0L),
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.getApplicationInfo(packageName, 0)
        }
    }

    private fun ApplicationInfo.isDebuggable(): Boolean {
        return (flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
    }

    private fun ApplicationInfo.isSystemApplication(): Boolean {
        return (flags and ApplicationInfo.FLAG_SYSTEM) != 0 ||
            (flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
    }

    private fun versionCode(packageInfo: PackageInfo): Long {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageInfo.longVersionCode
        } else {
            @Suppress("DEPRECATION")
            packageInfo.versionCode.toLong()
        }
    }

    private fun minSdkVersion(applicationInfo: ApplicationInfo): Int? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            applicationInfo.minSdkVersion
        } else {
            null
        }
    }

    private fun compileSdkVersion(applicationInfo: ApplicationInfo): Int? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            applicationInfo.compileSdkVersion
        } else {
            null
        }
    }

    private fun compileSdkVersionCodename(applicationInfo: ApplicationInfo): String? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            applicationInfo.compileSdkVersionCodename
        } else {
            null
        }
    }

    private fun installerPackageName(packageName: String): String? {
        return try {
            @Suppress("DEPRECATION")
            packageManager.getInstallerPackageName(packageName)
        } catch (_: IllegalArgumentException) {
            null
        }
    }

    private fun requestedPermissions(packageInfo: PackageInfo): List<String> {
        return packageInfo.requestedPermissions?.toList().orEmpty()
    }

    private fun requestedFeatures(packageInfo: PackageInfo): List<String> {
        return packageInfo.reqFeatures
            ?.mapNotNull { featureInfo -> featureInfo.name }
            .orEmpty()
    }

    private fun startApp(packageName: String): Boolean {
        return try {
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName) ?: return false
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(launchIntent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun openAppSettings(packageName: String) {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        } catch (_: Exception) {
        }
    }

    private fun uninstallApp(packageName: String): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_DELETE).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun isSystemApp(packageName: String): Boolean? {
        return try {
            getApplicationInfo(packageName).isSystemApplication()
        } catch (_: PackageManager.NameNotFoundException) {
            null
        }
    }

    private fun isAppInstalled(packageName: String): Boolean {
        return try {
            getPackageInfo(packageName)
            true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun categoryName(applicationInfo: ApplicationInfo): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return "Undefined"

        return when (applicationInfo.category) {
            ApplicationInfo.CATEGORY_GAME -> "Game"
            ApplicationInfo.CATEGORY_AUDIO -> "Audio"
            ApplicationInfo.CATEGORY_VIDEO -> "Video"
            ApplicationInfo.CATEGORY_IMAGE -> "Image"
            ApplicationInfo.CATEGORY_SOCIAL -> "Social"
            ApplicationInfo.CATEGORY_NEWS -> "News"
            ApplicationInfo.CATEGORY_MAPS -> "Maps"
            ApplicationInfo.CATEGORY_PRODUCTIVITY -> "Productivity"
            else -> "Undefined"
        }
    }

    private fun iconBytes(applicationInfo: ApplicationInfo): ByteArray? {
        return try {
            val drawable = applicationInfo.loadIcon(packageManager)
            val size = 96
            val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888).also { bitmap ->
                val canvas = Canvas(bitmap)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
            }

            ByteArrayOutputStream().use { output ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, output)
                output.toByteArray()
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun inspectFramework(
        sourceDir: String?,
        includeVersionScan: Boolean,
    ): FrameworkInfo {
        if (sourceDir.isNullOrBlank()) {
            return FrameworkInfo(
                framework = "Unknown",
                language = "Unknown",
                runtime = "Unknown",
                sdkVersion = null,
                frameworkVersion = null,
                frameworkVersionAvailable = false,
                hasNativeCode = false,
                evidence = emptyList(),
            )
        }

        val evidence = linkedSetOf<String>()
        var hasNativeCode = false
        var hasFlutter = false
        var hasReactNative = false
        var hasHermes = false
        var hasXamarin = false
        var hasIonic = false
        var hasCapacitor = false
        var hasCordova = false
        var flutterSdkVersion: String? = null
        var dartSdkVersion: String? = null
        var flutterEngineRevision: String? = null

        ZipFile(sourceDir).use { zip ->
            val entries = zip.entries()
            while (entries.hasMoreElements()) {
                val entry = entries.nextElement()
                val entryName = entry.name
                val normalized = entryName.lowercase()

                if (normalized.startsWith("lib/") && normalized.endsWith(".so")) {
                    hasNativeCode = true
                }

                if (normalized.endsWith("/libflutter.so") ||
                    normalized.startsWith("assets/flutter_assets/")
                ) {
                    hasFlutter = true
                    addEvidence(evidence, entryName)
                }

                if (includeVersionScan && isFlutterVersionCandidate(normalized)) {
                    val versionInfo = extractFlutterVersionInfo(zip, entry)
                    flutterSdkVersion = flutterSdkVersion ?: versionInfo.flutterVersion
                    dartSdkVersion = dartSdkVersion ?: versionInfo.dartVersion
                    flutterEngineRevision = flutterEngineRevision ?: versionInfo.engineRevision

                    if (versionInfo.hasAnyValue) {
                        addEvidence(evidence, "version strings from $entryName")
                    }
                }

                if (normalized.endsWith("/libreactnativejni.so") ||
                    normalized.endsWith("/libfbjni.so") ||
                    normalized == "assets/index.android.bundle" ||
                    normalized.endsWith("/index.android.bundle")
                ) {
                    hasReactNative = true
                    addEvidence(evidence, entryName)
                }

                if (normalized.endsWith("/libhermes.so") ||
                    normalized.endsWith("/libjsc.so")
                ) {
                    hasReactNative = true
                    hasHermes = normalized.endsWith("/libhermes.so")
                    addEvidence(evidence, entryName)
                }

                if (normalized.endsWith("/libmonodroid.so") ||
                    normalized.startsWith("assemblies/") ||
                    normalized.endsWith(".dll") && normalized.contains("assembl")
                ) {
                    hasXamarin = true
                    addEvidence(evidence, entryName)
                }

                if (normalized.startsWith("assets/www/")) {
                    hasIonic = true
                    addEvidence(evidence, entryName)
                }

                if (normalized.contains("capacitor.config") ||
                    normalized.contains("@capacitor")
                ) {
                    hasCapacitor = true
                    hasIonic = true
                    addEvidence(evidence, entryName)
                }

                if (normalized.endsWith("cordova.js") ||
                    normalized.contains("cordova_plugins.js")
                ) {
                    hasCordova = true
                    hasIonic = true
                    addEvidence(evidence, entryName)
                }
            }
        }

        return when {
            hasFlutter -> FrameworkInfo(
                framework = "Flutter",
                language = "Dart",
                runtime = flutterEngineRevision?.let {
                    "Flutter engine / Dart AOT ($it)"
                } ?: "Flutter engine / Dart AOT",
                sdkVersion = dartSdkVersion ?: unavailableVersion(),
                frameworkVersion = flutterSdkVersion ?: unavailableVersion(),
                frameworkVersionAvailable =
                    flutterSdkVersion != null || dartSdkVersion != null,
                hasNativeCode = hasNativeCode,
                evidence = evidence.toList(),
            )

            hasReactNative -> FrameworkInfo(
                framework = "React Native",
                language = "JavaScript / TypeScript",
                runtime = if (hasHermes) "Hermes JavaScript engine" else "JavaScript runtime",
                sdkVersion = unavailableVersion(),
                frameworkVersion = unavailableVersion(),
                frameworkVersionAvailable = false,
                hasNativeCode = hasNativeCode,
                evidence = evidence.toList(),
            )

            hasXamarin -> FrameworkInfo(
                framework = "Xamarin / .NET for Android",
                language = "C#",
                runtime = "Mono / .NET Android runtime",
                sdkVersion = unavailableVersion(),
                frameworkVersion = unavailableVersion(),
                frameworkVersionAvailable = false,
                hasNativeCode = hasNativeCode,
                evidence = evidence.toList(),
            )

            hasIonic -> FrameworkInfo(
                framework = when {
                    hasCapacitor -> "Ionic / Capacitor"
                    hasCordova -> "Ionic / Cordova"
                    else -> "Ionic / WebView"
                },
                language = "JavaScript / TypeScript",
                runtime = "Android WebView",
                sdkVersion = unavailableVersion(),
                frameworkVersion = unavailableVersion(),
                frameworkVersionAvailable = false,
                hasNativeCode = hasNativeCode,
                evidence = evidence.toList(),
            )

            else -> FrameworkInfo(
                framework = "Native or Others",
                language = "Kotlin / Java / C++",
                runtime = "Android Runtime",
                sdkVersion = null,
                frameworkVersion = null,
                frameworkVersionAvailable = false,
                hasNativeCode = hasNativeCode,
                evidence = evidence.toList(),
            )
        }
    }

    private fun addEvidence(evidence: MutableSet<String>, value: String) {
        if (evidence.size < 8) {
            evidence.add(value)
        }
    }

    private fun isFlutterVersionCandidate(entryName: String): Boolean {
        return entryName.endsWith("/libapp.so") ||
            entryName.endsWith("/libflutter.so") ||
            entryName.endsWith("assets/flutter_assets/kernel_blob.bin") ||
            entryName.endsWith("assets/flutter_assets/vm_snapshot_data") ||
            entryName.endsWith("assets/flutter_assets/isolate_snapshot_data") ||
            entryName.endsWith("assets/flutter_assets/assetmanifest.json") ||
            entryName.endsWith("assets/flutter_assets/assetmanifest.bin") ||
            entryName.endsWith("assets/flutter_assets/fontmanifest.json")
    }

    private fun extractFlutterVersionInfo(
        zip: ZipFile,
        entry: ZipEntry,
    ): FlutterVersionInfo {
        if (entry.isDirectory) return FlutterVersionInfo()

        return try {
            val text = readEntryText(zip, entry)
            FlutterVersionInfo(
                flutterVersion = findFlutterVersion(text),
                dartVersion = findDartVersion(text),
                engineRevision = findFlutterEngineRevision(text),
            )
        } catch (_: Exception) {
            FlutterVersionInfo()
        }
    }

    private fun readEntryText(zip: ZipFile, entry: ZipEntry): String {
        val maxBytes = 32 * 1024 * 1024
        val size = entry.size
        if (size < 0 || size > maxBytes) return ""

        return zip.getInputStream(entry).use { input ->
            val bytes = input.readBytes()
            bytes
                .map { byte ->
                    val code = byte.toInt()
                    if (code in 32..126 || code == 9 || code == 10 || code == 13) {
                        byte
                    } else {
                        32.toByte()
                    }
                }
                .toByteArray()
                .toString(Charsets.UTF_8)
        }
    }

    private fun findFlutterVersion(text: String): String? {
        val patterns = listOf(
            Regex("""Flutter(?: SDK)?(?: version)?:?\s+([0-9]+\.[0-9]+\.[0-9]+(?:[-+.\w]*)?)""", RegexOption.IGNORE_CASE),
            Regex("""flutter[_ -]?version["':=\s]+([0-9]+\.[0-9]+\.[0-9]+(?:[-+.\w]*)?)""", RegexOption.IGNORE_CASE),
        )

        return firstMatch(text, patterns)
    }

    private fun findDartVersion(text: String): String? {
        val patterns = listOf(
            Regex("""Dart (?:SDK|VM) version:?\s+([0-9]+\.[0-9]+\.[0-9]+(?:[-+.\w]*)?)""", RegexOption.IGNORE_CASE),
            Regex("""dart[_ -]?sdk[_ -]?version["':=\s]+([0-9]+\.[0-9]+\.[0-9]+(?:[-+.\w]*)?)""", RegexOption.IGNORE_CASE),
        )

        return firstMatch(text, patterns)
    }

    private fun findFlutterEngineRevision(text: String): String? {
        val patterns = listOf(
            Regex("""Flutter Engine(?: revision)?:?\s+([a-f0-9]{7,40})""", RegexOption.IGNORE_CASE),
            Regex("""engine[_ -]?revision["':=\s]+([a-f0-9]{7,40})""", RegexOption.IGNORE_CASE),
        )

        return firstMatch(text, patterns)
    }

    private fun firstMatch(text: String, patterns: List<Regex>): String? {
        for (pattern in patterns) {
            val match = pattern.find(text)
            val value = match?.groups?.get(1)?.value?.trim()
            if (!value.isNullOrBlank()) return value
        }
        return null
    }

    private fun unavailableVersion(): String {
        return "Not found in APK version strings"
    }

    private data class FlutterVersionInfo(
        val flutterVersion: String? = null,
        val dartVersion: String? = null,
        val engineRevision: String? = null,
    ) {
        val hasAnyValue: Boolean
            get() = flutterVersion != null || dartVersion != null || engineRevision != null
    }

    private data class FrameworkInfo(
        val framework: String,
        val language: String,
        val runtime: String,
        val sdkVersion: String?,
        val frameworkVersion: String?,
        val frameworkVersionAvailable: Boolean,
        val hasNativeCode: Boolean,
        val evidence: List<String>,
    )
}
