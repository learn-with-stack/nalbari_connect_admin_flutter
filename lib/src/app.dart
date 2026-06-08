import 'package:nalbari_connect_admin/src/imports/core_imports.dart';
import 'package:nalbari_connect_admin/src/imports/packages_imports.dart';
import 'package:nalbari_connect_admin/src/features/settings/presentation/providers/app_settings_provider.dart';

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
      title: 'Nalbari Admin',
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
        current = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: current,
        );
        current = SkeletonWrapper(child: current);
        current = SessionListenerWrapper(child: current);
        return current;
      },
    );
  }
}


