import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../screens/auth/auth_screen.dart';
import '../screens/shell/app_shell.dart';
import 'app_controller.dart';
import 'app_scope.dart';
import 'app_theme.dart';

class SahalGasApp extends StatefulWidget {
  const SahalGasApp({super.key});

  @override
  State<SahalGasApp> createState() => _SahalGasAppState();
}

class _SahalGasAppState extends State<SahalGasApp> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    controller = AppController();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait<void>([
      controller.bootstrap(),
      Future<void>.delayed(const Duration(milliseconds: 2000)),
    ]);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Sahal Gas',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: switch (controller.appearance) {
              'Dark' => ThemeMode.dark,
              'System default' => ThemeMode.system,
              _ => ThemeMode.light,
            },
            locale: AppTheme.materialLocaleFor(controller.language),
            supportedLocales: AppTheme.supportedLocales.where(
              (locale) => locale.languageCode != 'so',
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const _RootGate(),
          );
        },
      ),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    if (controller.bootstrapping) {
      return const _SplashScreen();
    }
    if (controller.currentUser == null) {
      return const AuthScreen();
    }
    return const AppShell();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppTheme.orange,
      body: ClipRRect(
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(34)),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffff3517), Color(0xffff7516)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  right: -25,
                  top: 25,
                  child: Opacity(
                    opacity: .07,
                    child: Icon(Icons.local_fire_department_outlined, size: 210, color: Colors.white),
                  ),
                ),
                Positioned(
                  left: -35,
                  bottom: 160,
                  child: Opacity(
                    opacity: .06,
                    child: Icon(Icons.local_fire_department_outlined, size: 190, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 72, 26, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fast. Safe.\nReliable.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          height: 1.12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const SizedBox(
                        width: 190,
                        child: Text(
                          'Gas delivery to your\ndoorstep in minutes.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            'images/logo.png',
                            width: size.width < 380 ? 170 : 210,
                            height: size.width < 380 ? 170 : 210,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Get Started'),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white,
                            foregroundColor: AppTheme.orange,
                            disabledForegroundColor: AppTheme.orange,
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
