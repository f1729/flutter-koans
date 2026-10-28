import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'analytics/analytics.dart';
import 'app_state.dart';
import 'content/ways.dart';
import 'l10n/gen/app_localizations.dart';
import 'theme.dart';
import 'ui/home_screen.dart';
import 'ui/koan_screen.dart';
import 'ui/review_screen.dart';
import 'ui/way_complete_screen.dart';
import 'ui/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  ErrorWidget.builder = (details) => const PreviewPlaceholder();
  final state = await AppState.load();
  runApp(KoansApp(state: state));
}

class KoansApp extends StatefulWidget {
  const KoansApp({super.key, required this.state});

  final AppState state;

  @override
  State<KoansApp> createState() => _KoansAppState();
}

class _KoansAppState extends State<KoansApp> {
  late final _router = GoRouter(
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/:way',
        redirect: (context, state) {
          if (state.uri.pathSegments.length != 1) return null;
          final way = wayById(state.pathParameters['way']!);
          return way == null ? '/' : wayStartPath(widget.state, way);
        },
        routes: [
          GoRoute(
            path: 'review',
            builder: (context, state) =>
                ReviewScreen(way: wayById(state.pathParameters['way']!)!),
          ),
          GoRoute(
            path: 'done',
            builder: (context, state) =>
                WayCompleteScreen(way: wayById(state.pathParameters['way']!)!),
          ),
          GoRoute(
            path: ':category',
            redirect: (context, state) => state.uri.pathSegments.length == 2
                ? '${state.uri.path}/1'
                : null,
            routes: [
              GoRoute(
                path: ':n',
                redirect: (context, state) {
                  final way = wayById(state.pathParameters['way']!);
                  final category = way?.category(
                    state.pathParameters['category']!,
                  );
                  final n = int.tryParse(state.pathParameters['n']!);
                  if (way == null) return '/';
                  if (category == null ||
                      n == null ||
                      n < 1 ||
                      n > category.koans.length) {
                    return '/${way.id}';
                  }
                  return null;
                },
                pageBuilder: (context, state) {
                  final way = wayById(state.pathParameters['way']!)!;
                  final category = way.category(
                    state.pathParameters['category']!,
                  )!;
                  final index = int.parse(state.pathParameters['n']!) - 1;
                  return NoTransitionPage(
                    child: KoanScreen(
                      way: way,
                      category: category,
                      index: index,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: widget.state,
      child: ListenableBuilder(
        listenable: widget.state,
        builder: (context, _) {
          Analytics.locale = widget.state.locale.languageCode;
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
            locale: widget.state.locale,
            supportedLocales: supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
