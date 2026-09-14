# AGENT.md — AppScope Flutter Project Rules

## 1. Purpose

This file defines the mandatory development rules for the **AppScope** Flutter application.

All AI coding agents, contributors, and generated code must follow these rules unless the user explicitly overrides a rule for a specific task.

The project must use:

- Flutter
- Dart null safety
- Material 3
- Provider for state management
- Clean Architecture
- Feature-first project organization
- Repository abstraction
- Light and dark themes
- Centralized colors, typography, spacing, radius, gradients, and reusable UI styles
- Responsive mobile-first UI
- The `installed_apps` package for installed application functionality

The application should remain maintainable, testable, modular, and easy to extend.

---

# 2. General Development Rules

## 2.1 Mandatory principles

Always:

- Write production-quality Dart code.
- Keep widgets small and focused.
- Separate UI, business logic, and data access.
- Follow dependency inversion.
- Use interfaces/abstract classes between layers.
- Keep feature-specific code inside its feature.
- Prefer composition over inheritance.
- Use immutable models/entities wherever practical.
- Use `const` constructors whenever possible.
- Use null-safe APIs.
- Handle loading, success, empty, and error states.
- Keep navigation logic out of reusable widgets.
- Avoid unnecessary rebuilds.
- Avoid duplicated code.
- Extract repeated UI into reusable widgets.
- Extract repeated logic into services/use cases/helpers.
- Give classes, methods, variables, and files descriptive names.

Never:

- Put API/plugin calls directly inside UI widgets.
- Put business logic inside `build()`.
- Access repositories directly from presentation widgets.
- Hardcode reusable colors, font sizes, spacing, radii, gradients, or shadows in pages.
- Create large "god" classes.
- Create one global provider containing unrelated application state.
- Use `setState` for feature/business state that belongs in Provider.
- Use static mutable global state.
- Swallow exceptions silently.
- Use force unwrap (`!`) unless safety is guaranteed and documented.
- Mix presentation models with data DTOs.
- Couple domain code to Flutter UI classes.

---

# 3. Command Execution Rule for Coding Agents

Unless the user explicitly requests command execution, the coding agent must **not run**:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `dart analyze`
- `dart fix`
- `dart format`
- Gradle commands
- build commands
- emulator/device commands
- package installation commands
- shell scripts
- code generators

The agent should make code changes only.

The user will run analyzer, formatter, dependency, test, and build commands manually unless explicitly requested otherwise.

Do not consume time/tokens repeatedly running validation commands after every code change.

---

# 4. Clean Architecture

The application must follow these layers:

```text
Presentation
    ↓
Domain
    ↓
Data
```

Dependency direction must point inward.

The Domain layer must not depend on Presentation or Data.

---

# 5. Recommended Project Structure

Use a feature-first Clean Architecture structure.

```text
lib/
├── app/
│   ├── app.dart
│   ├── app_bootstrap.dart
│   ├── navigation/
│   │   ├── app_router.dart
│   │   └── app_routes.dart
│   └── providers/
│       └── app_providers.dart
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── asset_paths.dart
│   │
│   ├── errors/
│   │   ├── app_exception.dart
│   │   ├── failure.dart
│   │   └── error_mapper.dart
│   │
│   ├── extensions/
│   │   ├── context_extensions.dart
│   │   └── string_extensions.dart
│   │
│   ├── services/
│   │   ├── app_launcher_service.dart
│   │   ├── app_settings_service.dart
│   │   └── share_service.dart
│   │
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_gradients.dart
│   │   ├── app_radius.dart
│   │   ├── app_shadows.dart
│   │   ├── app_spacing.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   │
│   ├── utils/
│   │   └── ...
│   │
│   └── widgets/
│       ├── app_error_view.dart
│       ├── app_loading_view.dart
│       ├── app_empty_view.dart
│       └── ...
│
├── features/
│   ├── splash/
│   │   └── presentation/
│   │       └── pages/
│   │
│   ├── home/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── apps/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── tools/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── statistics/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── developer/
│   │   └── presentation/
│   │
│   └── settings/
│       └── presentation/
│
└── main.dart
```

Do not create unnecessary folders for a feature that has no need for them.

For example, a static About page may only need a presentation layer.

---

# 6. Layer Responsibilities

## 6.1 Presentation layer

Contains:

- Pages
- Widgets
- Providers
- View models/state classes where needed
- UI-specific enums
- UI formatting

Presentation may depend on Domain.

Presentation must not directly depend on plugin implementations or data sources.

Example:

```text
InstalledAppsPage
    ↓
InstalledAppsProvider
    ↓
GetInstalledAppsUseCase
```

---

## 6.2 Domain layer

Contains:

- Entities
- Repository contracts
- Use cases
- Domain rules

Domain must be pure Dart whenever possible.

Do not import:

```dart
package:flutter/material.dart
```

inside domain entities, repositories, or use cases unless there is an unavoidable reason.

Example:

```dart
abstract interface class InstalledAppsRepository {
  Future<List<DeviceApp>> getInstalledApps();
}
```

---

## 6.3 Data layer

Contains:

- Plugin/data-source implementation
- DTO/models
- Repository implementations
- Data mapping

Example:

```text
InstalledAppsPluginDataSource
        ↓
InstalledAppsRepositoryImpl
        ↓
DeviceApp entity
```

Only the Data layer should know the concrete `installed_apps` package API.

---

# 7. Provider State Management Rules

Use the `provider` package.

Preferred provider types:

- `ChangeNotifierProvider`
- `MultiProvider`
- `ProxyProvider` only when dependency composition genuinely requires it
- `Selector` for optimized rebuilds
- `Consumer` when only a small subtree needs rebuilding
- `context.read<T>()` for actions
- `context.watch<T>()` for state needed by the whole widget
- `context.select<T, R>()` for a specific property

---

# 8. Provider Responsibilities

One provider should represent one cohesive feature/state responsibility.

Good examples:

```text
InstalledAppsProvider
AppDetailsProvider
AppFilterProvider
StatisticsProvider
ThemeProvider
```

Avoid:

```text
AppProvider
GlobalProvider
MainProvider
EverythingProvider
```

when they hold unrelated state.

---

# 9. Provider State Pattern

Prefer explicit state properties.

Example:

```dart
enum LoadStatus {
  initial,
  loading,
  success,
  empty,
  failure,
}
```

Example provider:

```dart
class InstalledAppsProvider extends ChangeNotifier {
  InstalledAppsProvider({
    required GetInstalledAppsUseCase getInstalledApps,
  }) : _getInstalledApps = getInstalledApps;

  final GetInstalledAppsUseCase _getInstalledApps;

  LoadStatus _status = LoadStatus.initial;
  LoadStatus get status => _status;

  List<DeviceApp> _apps = const [];
  List<DeviceApp> get apps => List.unmodifiable(_apps);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadApps() async {
    if (_status == LoadStatus.loading) return;

    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _getInstalledApps();

      _apps = result;
      _status = result.isEmpty
          ? LoadStatus.empty
          : LoadStatus.success;
    } catch (error) {
      _status = LoadStatus.failure;
      _errorMessage = error.toString();
    }

    notifyListeners();
  }
}
```

Do not expose mutable lists publicly.

---

# 10. Provider Creation

Top-level application providers belong in:

```text
lib/app/providers/app_providers.dart
```

Example:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
    ),
  ],
  child: const AppScopeApp(),
);
```

Feature providers should be created as close as possible to the feature route/page.

Do not register every feature provider globally.

---

# 11. Installed Apps Package Integration

The `installed_apps` plugin must be isolated behind a data source.

Never write package calls directly in:

```text
Page
Widget
Provider
```

Preferred architecture:

```text
installed_apps plugin
      ↓
InstalledAppsDataSource
      ↓
InstalledAppsRepositoryImpl
      ↓
InstalledAppsRepository
      ↓
UseCase
      ↓
Provider
      ↓
UI
```

---

# 12. Installed Apps Domain Entity

Create a project-owned entity rather than exposing plugin models throughout the app.

Example concept:

```dart
class DeviceApp {
  const DeviceApp({
    required this.name,
    required this.packageName,
    this.icon,
    this.versionName,
    this.versionCode,
    this.installedAt,
    this.updatedAt,
    this.isSystemApp = false,
    this.isLaunchable = false,
    this.category,
    this.platformType,
  });

  final String name;
  final String packageName;
  final Uint8List? icon;
  final String? versionName;
  final String? versionCode;
  final DateTime? installedAt;
  final DateTime? updatedAt;
  final bool isSystemApp;
  final bool isLaunchable;
  final String? category;
  final String? platformType;
}
```

Adapt fields according to the actual supported package API.

---

# 13. Use Cases

Each business action should be represented cleanly.

Examples:

```text
GetInstalledAppsUseCase
GetSystemAppsUseCase
GetNonLaunchableAppsUseCase
GetAppInfoUseCase
CheckAppInstalledUseCase
CheckSystemAppUseCase
LaunchAppUseCase
OpenAppSettingsUseCase
UninstallAppUseCase
FilterAppsUseCase
GetAppStatisticsUseCase
```

Do not create meaningless one-line use cases when no abstraction/value is gained.

For package/plugin actions, use cases are encouraged because they make the presentation independent from the plugin.

---

# 14. UI Architecture

Pages should mainly:

- compose widgets
- watch provider state
- trigger provider actions
- handle navigation
- display dialogs/bottom sheets

Pages must not contain heavy data transformation or plugin logic.

Extract substantial sections into widgets.

Example:

```text
HomePage
├── HomeHeader
├── AppSummaryGrid
├── QuickToolsSection
├── EvolixBrandCard
└── AppBottomNavigation
```

---

# 15. Theme Rules

The application must support:

- Light mode
- Dark mode
- System mode

Use:

```dart
theme: AppTheme.light,
darkTheme: AppTheme.dark,
themeMode: selectedThemeMode,
```

Theme selection must be controlled through a dedicated `ThemeProvider`.

---

# 16. Font Rules

Primary font family:

```text
Inter
```

Required font assets:

```text
Inter-Regular.ttf      400
Inter-Medium.ttf       500
Inter-SemiBold.ttf     600
Inter-Bold.ttf         700
Inter-ExtraBold.ttf    800
```

Do not introduce another font without explicit approval.

---

# 17. Typography Scale

Use the centralized typography system.

Approved font sizes:

```text
10
11
12
13
14
15
16
18
20
22
24
28
32
34
40
42
48
```

Typical mapping:

| Purpose | Size | Weight |
|---|---:|---:|
| Tiny label | 10 | 500 |
| Metadata | 11 | 400/500 |
| Caption | 12 | 400/500 |
| Small body | 13 | 400 |
| Body | 14 | 400/500 |
| Button | 15 | 600 |
| List title | 16 | 600 |
| Section title | 18 | 700 |
| App title | 20 | 700 |
| Page title | 22 | 700 |
| Headline | 24 | 700 |
| Dashboard headline | 28 | 700/800 |
| Brand title | 32 | 800 |
| Statistics | 34 | 700/800 |
| Splash title | 40 | 800 |
| Hero statistic | 42 | 800 |
| Large hero | 48 | 800 |

Prefer:

```dart
Theme.of(context).textTheme.titleMedium
```

or centralized `AppTextStyles`.

Do not repeatedly write:

```dart
TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
)
```

inside pages.

---

# 18. Brand Colors

Primary brand palette:

```text
Deep Navy        #07195A
Primary Blue     #175CFF
Royal Blue       #3044F5
Bright Blue      #248BFF
Purple           #6B3DF5
Soft Purple      #8B5CF6
```

Semantic colors:

```text
Success Green    #16C784
Warning Orange   #FF8A1F
Error Red        #FF4D5E
Cyan             #15B8A6
```

---

# 19. Light Theme Colors

```text
Background          #F7F9FF
Surface             #FFFFFF
Secondary Surface   #F2F5FD
Card                #FFFFFF

Primary Text        #07195A
Secondary Text      #64719B
Tertiary Text       #8F9ABC

Border              #E3E9F6
Divider             #E8EDF7
Icon                #65739E
```

---

# 20. Dark Theme Colors

```text
Background          #050A1D
Surface             #0D1530
Secondary Surface   #121B38
Card                #121B38

Primary Text        #F5F7FF
Secondary Text      #AAB4D0
Tertiary Text       #7883A5

Border              #202B4A
Divider             #1C2745
Icon                #9AA7CB
```

---

# 21. Color Usage Rules

Do not hardcode colors in feature UI.

Bad:

```dart
Container(
  color: const Color(0xFFF7F9FF),
)
```

Good:

```dart
Container(
  color: Theme.of(context).scaffoldBackgroundColor,
)
```

Or:

```dart
color: AppColors.primary
```

Use `Theme.of(context).colorScheme` for semantic theme-aware colors where practical.

Use `AppColors` for fixed brand colors.

---

# 22. Gradients

Approved gradients belong in:

```text
app_gradients.dart
```

Primary:

```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF248BFF),
    Color(0xFF3044F5),
    Color(0xFF6B3DF5),
  ],
)
```

Splash:

```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF07195A),
    Color(0xFF09237E),
    Color(0xFF173DD7),
  ],
)
```

Do not define duplicate gradients inside widgets.

---

# 23. Spacing Scale

Approved spacing:

```dart
4
6
8
12
16
20
24
32
40
```

Centralize as:

```dart
abstract class AppSpacing {
  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}
```

Avoid arbitrary values such as:

```dart
padding: EdgeInsets.all(17.3)
```

unless visually necessary and documented.

---

# 24. Radius Scale

Use:

```dart
abstract class AppRadius {
  static const double small = 10;
  static const double medium = 14;
  static const double large = 18;
  static const double card = 20;
  static const double bottomSheet = 28;
  static const double pill = 100;
}
```

Do not repeat `BorderRadius.circular(...)` values throughout pages.

---

# 25. Shadows

Light theme may use subtle shadows.

Recommended:

```dart
BoxShadow(
  color: AppColors.deepNavy.withValues(alpha: 0.06),
  blurRadius: 24,
  offset: const Offset(0, 8),
)
```

Dark mode should primarily use borders rather than large shadows.

---

# 26. Dark Mode Rules

Dark mode is not an inverted light theme.

Use:

- Deep navy/near-black background
- Slightly lighter elevated surfaces
- Soft borders
- White/blue-gray typography
- Bright blue primary actions
- Controlled purple accents

Avoid:

- pure `Colors.black` for every surface
- excessive glow
- heavy shadows
- low-contrast gray text
- bright gradients on every card

---

# 27. App Logo and Evolix Assets

SVG assets should be used through `flutter_svg`.

Store assets under:

```text
assets/
├── images/
├── icons/
└── fonts/
```

Create centralized paths:

```dart
abstract class AssetPaths {
  static const String appLogo =
      'assets/images/evolix_logo.png';

  static const String evolixLogo =
      'assets/images/evolix_logo.png';
}
```

Do not type asset strings directly throughout the codebase.

---

# 28. Installed App Icons

Third-party installed application icons must be loaded dynamically from the plugin/device.

Do not add static copies of:

- WhatsApp
- YouTube
- Instagram
- Gmail
- Chrome
- Maps
- Photos
- other installed app logos

as project assets.

---

# 29. Responsive Design

The product is mobile-first.

UI must adapt to different Android screen sizes.

Avoid fixed screen widths/heights.

Prefer:

- `LayoutBuilder`
- `MediaQuery`
- `Expanded`
- `Flexible`
- `Wrap`
- responsive grid logic

Do not size major UI using a single reference device only.

Respect:

```dart
SafeArea
```

where appropriate.

---

# 30. Screen Width Guidelines

For horizontal page padding, start with:

```text
16–20 px on normal phones
24 px on larger phones
```

Cards should stretch naturally to the available width.

Two-column cards may become one-column if space is insufficient.

---

# 31. Navigation

Main bottom navigation:

```text
Home
Apps
Tools
Developer
```

Pages such as:

```text
App Details
Filters & Sort
Statistics
About Evolix
Settings
Privacy Policy
Terms & Conditions
Licenses
```

should be pushed as subroutes.

Avoid duplicating a bottom navigation bar on routes where it harms expected Android navigation behavior.

---

# 32. Main Screens

The project should support at least:

```text
Splash
Home
Installed Apps
App Details
Quick Tools
Filters & Sort
App Statistics
Developer
About Evolix
Settings
```

Additional screens/dialogs can be introduced when functionality requires them.

---

# 33. Splash Screen

Splash screen rules:

- Use AppScope logo.
- Use primary/splash brand gradient.
- Show AppScope product name.
- Show tagline.
- Show "Powered by Evolix Technologies".
- Keep animation subtle.
- Avoid long artificial splash delays.
- Continue immediately after required initialization finishes.

---

# 34. Home Screen

Home should provide high-level entry points:

```text
Installed Apps
User Apps
System Apps
App Details / Search
```

Quick tools may include:

```text
Launch App
Check Installed
Sort & Filter
App Statistics
```

Home must remain visually clean and not expose every feature at once.

---

# 35. Installed Apps Screen

Must support:

- All apps
- User apps
- System apps
- Search
- Filtering
- Sorting
- App detail navigation

Each item may show:

```text
Icon
App name
Package name
App classification
Optional metadata
Overflow actions
```

Do not perform expensive filtering directly inside `build()`.

Filtering should happen through provider/domain logic.

---

# 36. Search Rules

Search should:

- debounce when appropriate
- be case-insensitive
- search app name
- search package name
- avoid repeated plugin calls for every keystroke if data is already loaded

Keep full app data cached within the feature provider and derive filtered results from it.

---

# 37. Filters

Filters can include:

```text
All Apps
User Apps
System Apps
Non-launchable Apps
Package Prefix
Platform Type
App Category
```

Keep filter state in a dedicated provider/model if it becomes complex.

Do not mix filter widget state throughout multiple pages.

---

# 38. App Details

App details should use the selected app entity.

Actions can include:

```text
Launch
Open Settings
Uninstall
Check if Installed
Check if System App
View in Play Store
```

Destructive actions such as uninstall must require confirmation when appropriate.

---

# 39. Destructive Actions

Always visually distinguish destructive actions.

Use:

```text
Error red
Clear warning text
Confirmation dialog
```

Do not place destructive actions directly beside safe actions without visual distinction.

---

# 40. Quick Tools

Quick tools should demonstrate package capabilities without becoming tightly coupled to the plugin.

Possible features:

```text
Get Installed Apps
Get System Apps
Get Non-launchable Apps
Filter by Package Prefix
Filter by Platform Type
Check Is Installed
Check Is System App
Get App Info
Launch App
Open App Settings
Uninstall App
Show Toast Message
```

Each tool should call domain/provider logic.

---

# 41. Statistics

Statistics are derived from loaded application data.

Possible statistics:

```text
Total Apps
User Apps
System Apps
Launchable Apps
Non-launchable Apps
Apps by Category
Apps by Platform Type
```

Only show storage size statistics if the required data is accurately available.

Never display fake/estimated values as factual production data.

---

# 42. Developer Screen

Developer screen must clearly display:

```text
AppScope
Version
Evolix branding
Developed by Evolix Technologies
```

Possible items:

```text
About Evolix Technologies
Visit Website
Contact Us
Rate on Play Store
Share App
Privacy Policy
Terms & Conditions
Open Source Licenses
```

Keep company information centralized in constants/configuration.

---

# 43. Loading States

Do not use only a centered spinner for every screen.

Use the best state per context:

- skeleton/shimmer for app lists/cards if desired
- compact progress indicator for small actions
- button progress for action-specific loading

Never allow the user to trigger the same asynchronous action repeatedly while it is already running.

---

# 44. Empty States

Every list/search/filter should have an intentional empty state.

Example:

```text
No apps found
Try changing your search or filters.
```

Empty state widgets should be reusable.

---

# 45. Error Handling

Do not expose raw stack traces or plugin exceptions to end users.

Data layer:

```text
plugin exception
    ↓
AppException
```

Repository/domain:

```text
AppException
    ↓
Failure
```

Presentation:

```text
Failure
    ↓
Friendly message
```

Log technical details only when a logging strategy is present.

---

# 46. Async Logic

Always:

- prevent duplicate actions
- handle exceptions
- verify provider is still relevant before UI callbacks when necessary
- avoid blocking UI
- use `Future` correctly
- keep async plugin calls outside widget `build()`

Do not call async data loading repeatedly due to rebuilds.

Initialize via:

- provider creation
- controlled `initState`
- explicit refresh

---

# 47. Context After Await

When using `BuildContext` after `await`, ensure safety.

Example:

```dart
await provider.launchApp();

if (!context.mounted) return;

ScaffoldMessenger.of(context).showSnackBar(...);
```

---

# 48. Performance

Use:

```dart
const
Selector
context.select
ListView.builder
SliverList
RepaintBoundary
```

when appropriate.

Avoid:

- rebuilding full screens for one changing boolean
- mapping thousands of widgets eagerly
- decoding the same app icon repeatedly
- expensive sorting in `build`
- repeated plugin queries when cached data is sufficient

---

# 49. Lists

Installed apps must use lazy lists:

```dart
ListView.builder
```

or slivers.

Do not use:

```dart
SingleChildScrollView(
  child: Column(
    children: apps.map(...).toList(),
  ),
)
```

for a large app list.

---

# 50. Refresh

If app data can change while the application is running, provide a refresh mechanism.

A refresh should:

- reload installed apps
- update counts
- update filters/search results
- update statistics

Avoid silently refreshing constantly in the background without need.

---

# 51. Models and Mapping

Data DTOs must map to Domain entities.

Example:

```dart
extension InstalledAppModelMapper on InstalledAppModel {
  DeviceApp toEntity() {
    return DeviceApp(
      name: name,
      packageName: packageName,
    );
  }
}
```

Do not expose plugin models to the entire application.

---

# 52. Repository Interfaces

Repository contracts belong in:

```text
domain/repositories/
```

Implementations belong in:

```text
data/repositories/
```

Example:

```dart
abstract interface class InstalledAppsRepository {
  Future<List<DeviceApp>> getInstalledApps();

  Future<bool> isAppInstalled(String packageName);

  Future<void> launchApp(String packageName);

  Future<void> openAppSettings(String packageName);

  Future<void> uninstallApp(String packageName);
}
```

Adapt signatures to actual package capabilities.

---

# 53. Dependency Injection

Provider can be used to provide dependencies.

Do not manually instantiate repositories repeatedly inside pages.

Dependencies should be created once at the appropriate scope.

Example concept:

```text
DataSource
   ↓
Repository
   ↓
UseCase
   ↓
ChangeNotifierProvider
```

---

# 54. Theme Provider

Use a dedicated provider.

Example:

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();
  }
}
```

Persist theme preference if persistence is implemented.

---

# 55. App Configuration

Do not scatter company/product strings across widgets.

Centralize:

```dart
abstract class AppConstants {
  static const String appName = 'AppScope - Inspector';

  static const String companyName =
      'Evolix Technologies';

  static const String tagline =
      'Explore • Inspect • Manage';
}
```

---

# 56. Widget Naming

Use clear names:

Good:

```text
InstalledAppTile
AppSummaryCard
QuickToolCard
DeveloperMenuTile
StatisticsSummaryCard
AppSearchField
FilterChipGroup
```

Avoid:

```text
CustomCard
MyWidget
ItemWidget
BoxWidget
CommonWidget
```

unless genuinely generic.

---

# 57. File Naming

Use snake_case:

```text
installed_apps_page.dart
installed_apps_provider.dart
installed_apps_repository.dart
installed_apps_repository_impl.dart
get_installed_apps_use_case.dart
```

One primary public class per file where practical.

---

# 58. Dart Naming

Use:

```text
PascalCase     classes/enums
camelCase      variables/functions
snake_case     files
SCREAMING_CASE only where conventional and necessary
```

Prefer descriptive names over abbreviations.

---

# 59. Methods

Methods should do one thing.

Prefer:

```dart
Future<void> loadInstalledApps()
Future<void> launchSelectedApp()
void updateSearchQuery(String value)
void clearFilters()
```

Avoid extremely generic names:

```dart
doIt()
process()
handle()
run()
```

without context.

---

# 60. Comments

Comments should explain **why**, not restate obvious code.

Good:

```dart
// Keep the complete list cached so search does not query
// PackageManager again for every keystroke.
```

Bad:

```dart
// Set loading to true.
isLoading = true;
```

---

# 61. TODO Rules

TODO comments must be actionable.

Good:

```dart
// TODO(permissions): Handle Play Store QUERY_ALL_PACKAGES
// policy before production release.
```

Avoid:

```dart
// TODO: fix
```

---

# 62. Platform Restrictions

The application is Android-focused because `installed_apps` is Android-specific.

Do not pretend unsupported functionality exists on iOS.

Platform-specific logic must be guarded appropriately if the project later targets additional platforms.

---

# 63. Android Permissions

Any permission required for installed app visibility must be handled carefully.

Do not automatically introduce sensitive Android permissions without documenting why they are required.

In particular, package visibility and Play Store policy requirements must be considered before production release.

---

# 64. Accessibility

All interactive UI must:

- have adequate touch target size
- maintain text contrast
- support text scaling reasonably
- use semantic labels for icon-only actions where helpful

Example:

```dart
Tooltip(
  message: 'Filter apps',
  child: IconButton(...),
)
```

---

# 65. Icons

Prefer:

1. AppScope SVG assets for branded/feature icons.
2. Material icons for standard platform actions.
3. Dynamic installed-app icons from the device.

Do not mix many unrelated icon styles.

Keep icon visual weight consistent.

---

# 66. SVG Usage

Use `flutter_svg`.

Prefer:

```dart
SvgPicture.asset(
  AssetPaths.appLogo,
)
```

Avoid embedding large SVG XML strings directly in Dart files.

---

# 67. Dialogs and Bottom Sheets

Use dialogs for:

- destructive confirmation
- critical decisions

Use bottom sheets for:

- filters
- sorting
- quick action menus
- non-destructive options

Keep bottom sheets rounded and consistent with `AppRadius.bottomSheet`.

---

# 68. Snackbar and Toast

Use package toast functionality only when demonstrating/testing the package feature.

For regular application feedback, prefer Flutter UI feedback such as:

```text
SnackBar
Inline status
Dialog
```

depending on context.

Do not overuse toast messages.

---

# 69. Search and Filter Data Flow

Preferred data flow:

```text
Plugin results
     ↓
Repository
     ↓
Provider stores full list
     ↓
Provider derives visible list
     ↓
UI renders visible list
```

Do not query the native installed-app API for every filter toggle if the complete required data is already in memory.

---

# 70. UI State Separation

Separate:

```text
Source data
Search query
Filter configuration
Sort configuration
Selected app
Loading/error state
```

Do not mutate the original app list destructively during search/filtering.

---

# 71. Immutability

Use immutable values where practical.

Expose:

```dart
UnmodifiableListView
List.unmodifiable
final
const
```

Avoid allowing widgets to mutate provider collections directly.

---

# 72. Equality

For domain state/value objects, implement reliable equality.

Use standard Dart equality or a suitable lightweight package only if already approved.

Do not add dependencies casually for trivial functionality.

---

# 73. Dependencies

Before adding a new package:

- verify the functionality cannot reasonably be done using current dependencies
- keep dependencies minimal
- use actively maintained packages
- avoid overlapping packages
- do not add a package just for a trivial helper

The coding agent must not modify `pubspec.yaml` unnecessarily.

---

# 74. Material 3

Use:

```dart
useMaterial3: true
```

Favor modern Material 3 components where they fit the provided AppScope design.

Do not blindly accept default Material 3 appearance when it conflicts with the established AppScope design system.

---

# 75. Theme Access

Preferred:

```dart
final theme = Theme.of(context);
final colors = theme.colorScheme;
final textTheme = theme.textTheme;
```

Then reuse these variables throughout a widget.

Avoid repeated long calls when readability suffers.

---

# 76. Theme-Aware Components

Reusable components must work in both light and dark mode automatically.

Bad reusable component:

```dart
Container(
  color: Colors.white,
)
```

Good:

```dart
Container(
  color: Theme.of(context).cardColor,
)
```

---

# 77. Opacity

For modern Flutter, prefer:

```dart
color.withValues(alpha: 0.10)
```

If the project's Flutter SDK does not support it, use:

```dart
color.withOpacity(0.10)
```

Stay consistent with the SDK version in use.

---

# 78. Code Formatting Style

Keep code readable and idiomatic.

Use trailing commas in multiline Flutter widgets.

Example:

```dart
Padding(
  padding: const EdgeInsets.all(
    AppSpacing.base,
  ),
  child: Text(
    title,
    style: Theme.of(context).textTheme.titleMedium,
  ),
)
```

Do not intentionally compress Flutter widget trees into unreadable single lines.

---

# 79. Build Method Size

If `build()` becomes difficult to scan, extract meaningful widgets.

Do not extract every 3-line widget into a method solely to reduce line count.

Extract based on:

- reuse
- conceptual responsibility
- readability
- rebuild optimization

---

# 80. Private Widget Classes

Prefer private widget classes for substantial page sections:

```dart
class _SummarySection extends StatelessWidget
```

rather than large `_buildSummarySection()` methods when the section has its own UI responsibility.

---

# 81. Provider Consumers

Do not wrap an entire page in `Consumer` if only one small section changes.

Prefer:

```dart
Selector<InstalledAppsProvider, int>(
  selector: (_, provider) => provider.apps.length,
  builder: (_, count, __) {
    ...
  },
)
```

when only the count is needed.

---

# 82. Side Effects

Do not trigger:

```text
navigation
dialogs
snackbars
plugin calls
provider mutations
```

directly during `build()`.

Side effects must happen in event handlers or controlled lifecycle logic.

---

# 83. Initialization

Do not write:

```dart
Future.microtask(
  () => context.read<MyProvider>().load(),
);
```

inside every build.

Initialize state once at the appropriate lifecycle point or provider creation scope.

---

# 84. App Refresh Lifecycle

If installed apps should refresh after returning from Android settings/uninstall flow, handle lifecycle intentionally.

Do not constantly poll the installed-app list.

Possible strategy:

```text
App resumed
    ↓
check whether refresh is needed
    ↓
reload apps once
```

---

# 85. Tests

Architecture should remain testable even when tests are not requested.

Business logic should be testable without rendering Flutter UI.

Repository contracts should make plugin implementations replaceable with fakes/mocks.

The coding agent must not generate large test suites unless asked.

---

# 86. Security and Privacy

Do not collect installed app information remotely unless the product explicitly requires it and appropriate user disclosure/consent exists.

Treat installed application data as user/device information.

Keep app analysis local by default.

---

# 87. Play Store Compliance

Do not claim unsupported functionality.

Do not misrepresent installed app visibility.

Any broad package visibility permission must be reviewed against current Google Play policy before production release.

---

# 88. App Naming

Current preferred product naming:

```text
AppScope - Inspector
```

Short UI branding:

```text
AppScope
INSPECTOR
```

Company:

```text
Evolix Technologies
```

Do not rename the product throughout the codebase unless the user explicitly requests it.

---

# 89. UX Copy Style

Use short, clear, professional copy.

Preferred:

```text
Installed Apps
View all apps on your device
```

Avoid overly technical language in primary UI unless the screen is specifically designed for developers.

---

# 90. Tooltips

Icon-only actions should use tooltips where the meaning is not obvious.

Examples:

```text
Search
Filter
More options
Refresh
Open settings
```

---

# 91. Confirmation Messages

Confirmation messages must clearly name the action.

Example:

```text
Uninstall WhatsApp?

Android will open the system uninstall screen for this application.
```

Avoid:

```text
Are you sure?
```

without context.

---

# 92. Reusable Result Pattern

Where useful, repository/domain operations may return a consistent result abstraction.

Do not overengineer this if standard exceptions/failures are already sufficient.

The project should have one error-handling pattern, not several.

---

# 93. No Fake Production Data

Mock/sample app names and statistics are allowed for UI previews only.

Production pages must derive data from actual device results.

Do not hardcode:

```text
142 apps
97 user apps
45 system apps
12.4 GB
```

as real application values.

---

# 94. App Statistics Accuracy

Only calculate a metric if source data supports it accurately.

If installed app size is not reliably available from the package/platform, do not fabricate total storage usage.

Hide unsupported statistics or clearly label estimates.

---

# 95. Native System Actions

For actions such as:

```text
Launch app
Open settings
Uninstall
Open Play Store
```

expect that Android may:

- reject the action
- show a native screen
- have no matching activity
- return to the app later

Handle these outcomes gracefully.

---

# 96. Strings

If localization is planned, structure UI strings so migration to localization is easy.

At minimum, avoid repeating important text constants across multiple screens.

Do not prematurely build a complex localization system unless requested.

---

# 97. Date Formatting

Do not manually assemble date strings throughout UI.

Use one formatter/helper.

Example display:

```text
Sep 02, 2026
```

Use the device locale where practical if localization is enabled.

---

# 98. Package Name Display

Package names are technical identifiers.

Use a secondary text style:

```text
com.example.application
```

Allow long names to wrap or ellipsize appropriately.

Do not let package text break layout.

---

# 99. Image/Icon Memory

Installed app icons may be byte data.

Avoid unnecessary transformations or repeated decoding.

Use appropriately sized widgets and caching where practical.

---

# 100. Final Rule

When implementing or changing a feature, always preserve:

1. Clean Architecture boundaries.
2. Provider-based state management.
3. Centralized AppScope design system.
4. Light/dark theme support.
5. Responsive mobile UI.
6. Error/loading/empty handling.
7. Plugin isolation behind data/repository abstractions.
8. Maintainable and readable Dart code.
9. Accurate functionality based on real package capabilities.
10. Existing project conventions unless the user explicitly requests a change.

If a requested change conflicts with this file, follow the user's explicit instruction for that task and keep all unaffected rules intact.
