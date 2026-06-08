import 'package:nalbari_connect/src/imports/core_imports.dart';
import 'package:nalbari_connect/src/imports/packages_imports.dart';
import 'package:nalbari_connect/src/features/settings/presentation/providers/app_settings_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = _buildMaterialApp(context, ref);
    return ScreenUtilWrapper(child: current);
  }

  Widget _buildMaterialApp(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp.router(
      title: 'Nalbari Connect',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(primaryColorHex: '#FF9933'),
      darkTheme: buildDarkTheme(primaryColorHex: '#FF9933'),
      themeMode: settings.themeMode,
      routerConfig: ref.watch(appRouterProvider),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        Widget current = child!;
        current = SkeletonWrapper(child: current);
        current = SessionListenerWrapper(child: current);
        return current;
      },
    );
  }
}
