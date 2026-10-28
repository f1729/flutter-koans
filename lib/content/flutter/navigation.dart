import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';

import '../../engine/koan.dart';
import 'preview_kit.dart';
import 'preview_kit_more.dart';
import 'registry.dart';

/// The learner's values, visible to every page of a [_MiniApp], so that
/// pages built long ago still act on what is typed now.
class _Values extends InheritedWidget {
  const _Values({required this.values, required super.child});

  final List<Object?> values;

  static List<Object?> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Values>()!.values;

  @override
  bool updateShouldNotify(_Values oldWidget) => true;
}

/// A tiny app with a Navigator of its own, drawn as a small screen.
class _MiniApp extends StatefulWidget {
  const _MiniApp({
    required this.values,
    required this.initial,
    this.routes = const {},
  });

  final List<Object?> values;

  /// The pages on the stack at the start, bottom first.
  final List<WidgetBuilder> initial;

  /// Pages that can be pushed by name.
  final Map<String, WidgetBuilder> routes;

  @override
  State<_MiniApp> createState() => _MiniAppState();
}

class _MiniAppState extends State<_MiniApp> {
  Key _navigator = UniqueKey();
  bool _empty = false;

  static _MiniAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MiniAppState>()!;

  /// What a real app shows once its last page is popped: nothing at all.
  void popLast() => setState(() => _empty = true);

  void _restart() => setState(() {
    _empty = false;
    _navigator = UniqueKey();
  });

  Route<Object?> _named(RouteSettings settings) => MaterialPageRoute(
    settings: settings,
    builder:
        widget.routes[settings.name] ?? (_) => _UnknownRoute(settings.name),
  );

  @override
  Widget build(BuildContext context) {
    return PreviewCanvas(
      child: Center(
        child: Container(
          width: 210,
          height: 176,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kInk.withValues(alpha: 0.25), width: 2),
          ),
          child: _empty
              ? _Emptiness(onRestart: _restart)
              : _Values(
                  values: widget.values,
                  child: Navigator(
                    key: _navigator,
                    onGenerateInitialRoutes: (navigator, name) => [
                      for (final page in widget.initial)
                        MaterialPageRoute(builder: page),
                    ],
                    onGenerateRoute: _named,
                  ),
                ),
        ),
      ),
    );
  }
}

class _Emptiness extends StatelessWidget {
  const _Emptiness({required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'no pages left',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        TextButton(onPressed: onRestart, child: const Text('restart')),
      ],
    ),
  );
}

class _UnknownRoute extends StatelessWidget {
  const _UnknownRoute(this.name);

  final String? name;

  @override
  Widget build(BuildContext context) => _Screen(
    title: '?',
    color: kRose,
    child: FittedBox(
      child: ErrorCard(
        "Could not find a generator for route '$name'.",
        title: 'Navigator',
      ),
    ),
  );
}

/// One page of a mini app.
class _Screen extends StatelessWidget {
  const _Screen({
    required this.title,
    required this.child,
    this.color = kSky,
    this.leading,
  });

  final String title;
  final Widget child;
  final Color color;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kMist,
    appBar: AppBar(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      leading: leading,
      toolbarHeight: 40,
      backgroundColor: color,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Padding(padding: const EdgeInsets.all(8), child: child),
    ),
  );
}

/// Does what [action], one of the Navigator methods, would do. Popping the
/// last page empties the app, as it would in a real one.
Future<Object?>? _go(
  BuildContext context,
  Object? action, {
  Route<Object?> Function()? route,
  Object? result,
}) {
  final navigator = Navigator.of(context);
  if (route != null) {
    if (action == Navigator.push) return navigator.push<Object?>(route());
    if (action == Navigator.pushReplacement) {
      return navigator.pushReplacement<Object?, Object?>(route());
    }
    if (action == Navigator.pushAndRemoveUntil) {
      return navigator.pushAndRemoveUntil<Object?>(route(), (_) => false);
    }
  }
  if (action == Navigator.pop) {
    navigator.canPop()
        ? navigator.pop(result)
        : _MiniAppState.of(context).popLast();
  } else if (action == Navigator.maybePop) {
    navigator.maybePop(result);
  }
  return null;
}

const _navigatorActions = [
  'Navigator.push',
  'Navigator.pushReplacement',
  'Navigator.pushAndRemoveUntil',
  'Navigator.pushNamed',
  'Navigator.pop',
  'Navigator.maybePop',
  'Navigator.popUntil',
  'Navigator.canPop',
];

/// Checks that [v] is one of the Navigator methods in the registry.
Object _action(Object? v) {
  if (!_navigatorActions.any((name) => flutterRegistry.symbols[name] == v)) {
    throw ArgumentError.value(v);
  }
  return v!;
}

Route<Object?> _page(String title, String body, {Color color = kSage}) =>
    MaterialPageRoute(
      builder: (context) => _Screen(
        title: title,
        color: color,
        child: Text(body, textAlign: TextAlign.center),
      ),
    );

class _OpenHome extends StatelessWidget {
  const _OpenHome();

  @override
  Widget build(BuildContext context) {
    final action = _Values.of(context)[0];
    return _Screen(
      title: 'Home',
      child: FilledButton(
        onPressed: () => _go(
          context,
          action,
          route: () => _page('Detail', 'A new page, on top'),
        ),
        child: const Text('Open'),
      ),
    );
  }
}

class _DoneDetail extends StatelessWidget {
  const _DoneDetail({this.depth = 1});

  final int depth;

  @override
  Widget build(BuildContext context) {
    final action = _Values.of(context)[0];
    return _Screen(
      title: 'Detail $depth',
      color: kSage,
      child: FilledButton(
        onPressed: () => _go(
          context,
          action,
          route: () =>
              MaterialPageRoute(builder: (_) => _DoneDetail(depth: depth + 1)),
        ),
        child: const Text('Done'),
      ),
    );
  }
}

class _PlainHome extends StatelessWidget {
  const _PlainHome();

  @override
  Widget build(BuildContext context) => _Screen(
    title: 'Home',
    child: OutlinedButton(
      onPressed: () =>
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const _DoneDetail())),
      child: const Text('Open'),
    ),
  );
}

class _RouteHome extends StatelessWidget {
  const _RouteHome();

  @override
  Widget build(BuildContext context) {
    final type = _Values.of(context)[0];
    Widget page(BuildContext context) =>
        const _Screen(title: 'Detail', color: kSage, child: Text('Arrived'));
    return _Screen(
      title: 'Home',
      child: FilledButton(
        onPressed: () => Navigator.of(context).push(switch (type) {
          const (CupertinoPageRoute) => CupertinoPageRoute<Object?>(
            builder: page,
          ),
          const (PageRouteBuilder) => PageRouteBuilder<Object?>(
            pageBuilder: (context, animation, secondary) => page(context),
          ),
          _ => MaterialPageRoute<Object?>(builder: page),
        }),
        child: const Text('Open'),
      ),
    );
  }
}

class _ComposeHome extends StatelessWidget {
  const _ComposeHome();

  @override
  Widget build(BuildContext context) {
    final dialog = _Values.of(context)[0] as bool;
    return _Screen(
      title: 'Letters',
      child: FilledButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: dialog,
            builder: (_) => const _Screen(
              title: 'Compose',
              color: kSand,
              child: Text('Dear friend,'),
            ),
          ),
        ),
        icon: const Icon(Icons.edit, size: 16),
        label: const Text('Write'),
      ),
    );
  }
}

class _SignIn extends StatelessWidget {
  const _SignIn();

  @override
  Widget build(BuildContext context) {
    final action = _Values.of(context)[0];
    return _Screen(
      title: 'Sign in',
      color: kSand,
      child: FilledButton(
        onPressed: () => _go(
          context,
          action,
          route: () => MaterialPageRoute(builder: (_) => const _Welcome()),
        ),
        child: const Text('Sign in'),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) => _Screen(
    title: 'Home',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Welcome'),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => const _SignIn())),
          child: const Text('Sign out'),
        ),
      ],
    ),
  );
}

String _shown(Object? v) => v is String ? "'$v'" : '$v';

class _MoodHome extends StatefulWidget {
  const _MoodHome();

  @override
  State<_MoodHome> createState() => _MoodHomeState();
}

class _MoodHomeState extends State<_MoodHome> {
  String _mood = '—';

  Future<void> _ask() async {
    final mood = await Navigator.of(context)
        .push<Object?>(MaterialPageRoute(builder: (_) => const _Ask()));
    if (mounted) setState(() => _mood = _shown(mood));
  }

  @override
  Widget build(BuildContext context) => _Screen(
    title: 'Home',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'mood: $_mood',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        FilledButton(onPressed: _ask, child: const Text('Ask')),
      ],
    ),
  );
}

class _Ask extends StatelessWidget {
  const _Ask();

  @override
  Widget build(BuildContext context) {
    final result = _Values.of(context)[0];
    return _Screen(
      title: 'How are you?',
      color: kSage,
      child: FilledButton(
        onPressed: () => Navigator.of(context).pop(result),
        child: const Text('Done'),
      ),
    );
  }
}

class _NamedHome extends StatelessWidget {
  const _NamedHome();

  @override
  Widget build(BuildContext context) {
    final name = _Values.of(context)[0];
    return _Screen(
      title: 'Home',
      child: FilledButton(
        onPressed: name is String
            ? () => Navigator.of(context).pushNamed(name)
            : null,
        child: const Text('Settings'),
      ),
    );
  }
}

class _BackHome extends StatelessWidget {
  const _BackHome({this.depth = 0});

  final int depth;

  @override
  Widget build(BuildContext context) {
    final action = _Values.of(context)[0];
    return _Screen(
      title: depth == 0 ? 'Home' : 'Page $depth',
      color: depth == 0 ? kSky : kSage,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _go(context, action),
      ),
      child: OutlinedButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => _BackHome(depth: depth + 1))),
        child: const Text('Open'),
      ),
    );
  }
}

const _swatches = [Colors.teal, Colors.amber, Colors.indigo, Colors.pink];

class _ColorHome extends StatefulWidget {
  const _ColorHome();

  @override
  State<_ColorHome> createState() => _ColorHomeState();
}

class _ColorHomeState extends State<_ColorHome> {
  Color? _color;

  Future<void> _pick(Object? action) async {
    final color = await _go(
      context,
      action,
      route: () => MaterialPageRoute(builder: (_) => const _Palette()),
    );
    if (mounted && color is Color) setState(() => _color = color);
  }

  @override
  Widget build(BuildContext context) {
    final action = _Values.of(context)[0];
    return _Screen(
      title: 'Home',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _color ?? Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: kFrame, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () => _pick(action),
            child: const Text('Pick'),
          ),
        ],
      ),
    );
  }
}

class _Palette extends StatelessWidget {
  const _Palette();

  @override
  Widget build(BuildContext context) {
    final action = _Values.of(context)[1];
    return _Screen(
      title: 'Palette',
      color: kInk,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final c in _swatches)
            GestureDetector(
              onTap: () => _go(context, action, result: c),
              child: CircleAvatar(radius: 18, backgroundColor: c),
            ),
        ],
      ),
    );
  }
}

final navigation = Category(
  id: 'navigation',
  title: const Tr('Navigation', 'Navigasi'),
  intro: const Tr(
    'Pages are stacked like stones: we push one on, and pop it off again.',
    'Halaman ditumpuk seperti batu: kita push satu ke atas, lalu pop untuk '
        'mengambilnya kembali.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'The Navigator keeps a stack of pages. Place a new one on top, then '
            'press Open',
        'Navigator menyimpan tumpukan halaman. Letakkan halaman baru di '
            'atasnya, lalu tekan Open',
      ),
      code: r'''
FilledButton(
  onPressed: () => __(
    context,
    MaterialPageRoute(builder: (context) => const DetailPage()),
  ),
  child: Text('Open'),
)''',
      answers: ['Navigator.push'],
      explanation: const Tr(
        'Navigator.push adds a route to the top of the stack and animates it '
            'in; the page below stays alive underneath, keeping its state. '
            'The AppBar notices there is a page below and offers a back '
            'arrow.',
        'Navigator.push menambahkan route ke puncak tumpukan dan '
            'menganimasikannya masuk; halaman di bawahnya tetap hidup dan '
            'menyimpan state-nya. AppBar menyadari ada halaman di bawah dan '
            'menampilkan panah kembali.',
      ),
      docs: 'https://docs.flutter.dev/cookbook/navigation/navigation-basics',
      mistakes: const [
        Mistake(
          ['Navigator.pushReplacement'],
          Tr(
            'That swaps the current page out, so there is nothing to come back '
                'to.',
            'Itu menukar halaman saat ini, jadi tidak ada tempat untuk kembali.',
          ),
        ),
        Mistake(
          ['Navigator.pop'],
          Tr(
            'pop takes a page off the stack; we want to add one.',
            'pop mengambil halaman dari tumpukan; kita ingin menambahkannya.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        _action(v[0]);
        return _MiniApp(values: v, initial: [(_) => const _OpenHome()]);
      },
    ),
    Koan(
      prompt: const Tr(
        'What was pushed may be popped. Step back down to the page below',
        'Apa yang di-push bisa di-pop. Turunlah kembali ke halaman di '
            'bawahnya',
      ),
      code: r'''
FilledButton(
  onPressed: () => __(context),
  child: Text('Done'),
)''',
      answers: ['Navigator.pop'],
      accept: (v) => v[0] == Navigator.pop || v[0] == Navigator.maybePop,
      explanation: const Tr(
        'Navigator.pop removes the top route and reveals the one below, just '
            'as the back arrow and the system back gesture do. The popped '
            'page is disposed once its exit animation ends.',
        'Navigator.pop menghapus route teratas dan memperlihatkan route di '
            'bawahnya, sama seperti panah kembali dan gestur kembali dari '
            'sistem. Halaman yang di-pop dibuang setelah animasi keluarnya '
            'selesai.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Navigator/pop.html',
      mistakes: const [
        Mistake(
          ['Navigator.push'],
          Tr(
            'push climbs higher, onto a new page. We want to step down.',
            'push naik lebih tinggi, ke halaman baru. Kita ingin turun.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        _action(v[0]);
        return _MiniApp(
          values: v,
          initial: [(_) => const _PlainHome(), (_) => const _DoneDetail()],
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'A page travels inside a route, and the route decides how it '
            'arrives. Send it in the Material way',
        'Sebuah halaman bepergian di dalam route, dan route-lah yang '
            'menentukan bagaimana ia tiba. Kirimkan dengan cara Material',
      ),
      code: r'''
Navigator.push(
  context,
  __(builder: (context) => const DetailPage()),
)''',
      answers: ['MaterialPageRoute'],
      explanation: const Tr(
        'MaterialPageRoute builds its page with builder and animates it in '
            'with the transition the theme chooses for the current platform. '
            'CupertinoPageRoute always slides in from the side and adds the '
            'iOS swipe from the edge to go back.',
        'MaterialPageRoute membangun halamannya dengan builder dan '
            'menganimasikannya masuk dengan transisi yang dipilih theme untuk '
            'platform saat ini. CupertinoPageRoute selalu bergeser masuk dari '
            'samping dan menambahkan gestur geser dari tepi ala iOS untuk '
            'kembali.',
      ),
      docs: 'https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html',
      mistakes: const [
        Mistake(
          ['Route'],
          Tr(
            'Route is the abstract idea of a page on the stack. We need one '
                'that knows how to build and animate a page.',
            'Route adalah gagasan abstrak tentang halaman di tumpukan. Kita '
                'butuh route yang tahu cara membangun dan menganimasikan '
                'halaman.',
          ),
        ),
        Mistake(
          ['CupertinoPageRoute'],
          Tr(
            'That is the iOS-style route. We asked for the Material one.',
            'Itu route bergaya iOS. Kita meminta yang Material.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        if (![
          MaterialPageRoute,
          CupertinoPageRoute,
          PageRouteBuilder,
        ].contains(v[0])) {
          throw ArgumentError.value(v[0]);
        }
        return _MiniApp(values: v, initial: [(_) => const _RouteHome()]);
      },
    ),
    Koan(
      prompt: const Tr(
        'Some pages are a task to finish, not a place to visit. Give this one '
            'a close button instead of a back arrow',
        'Ada halaman yang merupakan tugas untuk diselesaikan, bukan tempat '
            'untuk dikunjungi. Beri halaman ini tombol tutup, bukan panah '
            'kembali',
      ),
      code: r'''
Navigator.push(
  context,
  MaterialPageRoute(
    fullscreenDialog: __,
    builder: (context) => const ComposePage(),
  ),
)''',
      answers: ['true'],
      explanation: const Tr(
        'A fullscreen dialog route tells the AppBar to show a close button '
            'instead of a back arrow, and on iOS it rises from the bottom '
            'rather than sliding in from the side. It suits focused tasks '
            'such as writing a message.',
        'Route fullscreen dialog membuat AppBar menampilkan tombol tutup, '
            'bukan panah kembali, dan di iOS ia naik dari bawah, bukan '
            'bergeser dari samping. Cocok untuk tugas yang terfokus seperti '
            'menulis pesan.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/PageRoute/fullscreenDialog.html',
      mistakes: const [
        Mistake(
          ['false'],
          Tr(
            'That is the default: an ordinary page with a back arrow.',
            'Itu nilai bawaan: halaman biasa dengan panah kembali.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        if (v[0] is! bool) throw ArgumentError.value(v[0]);
        return _MiniApp(values: v, initial: [(_) => const _ComposeHome()]);
      },
    ),
    Koan(
      prompt: const Tr(
        'Once we are signed in, the door behind us should vanish. Replace '
            'this page instead of stacking on top of it',
        'Setelah kita masuk, pintu di belakang kita seharusnya lenyap. Ganti '
            'halaman ini, bukan menumpuk di atasnya',
      ),
      code: r'''
FilledButton(
  onPressed: () => __(
    context,
    MaterialPageRoute(builder: (context) => const HomePage()),
  ),
  child: Text('Sign in'),
)''',
      answers: ['Navigator.pushReplacement'],
      explanation: const Tr(
        'pushReplacement pushes the new route and removes the current one '
            'once the new one has arrived, so the stack keeps its height and '
            'there is no back arrow. pushAndRemoveUntil goes further and '
            'clears many pages at once.',
        'pushReplacement mem-push route baru dan menghapus route saat ini '
            'setelah yang baru tiba, jadi tinggi tumpukan tetap dan tidak ada '
            'panah kembali. pushAndRemoveUntil bertindak lebih jauh dan '
            'membersihkan banyak halaman sekaligus.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Navigator/pushReplacement.html',
      mistakes: const [
        Mistake(
          ['Navigator.push'],
          Tr(
            'Then the sign-in page stays below, and the back arrow leads right '
                'back to it.',
            'Maka halaman sign-in tetap di bawah, dan panah kembali membawa kita '
                'langsung ke sana.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        _action(v[0]);
        return _MiniApp(values: v, initial: [(_) => const _SignIn()]);
      },
    ),
    Koan(
      prompt: const Tr(
        'pop may carry a gift back down the stack. Return the word calm to '
            'the page that asked',
        'pop bisa membawa hadiah turun ke tumpukan di bawahnya. Kembalikan '
            'kata calm ke halaman yang bertanya',
      ),
      code: r'''
FilledButton(
  onPressed: () => Navigator.pop(context, __),
  child: Text('Done'),
)''',
      answers: ["'calm'"],
      hint: const Tr(
        'Press Ask, then Done. Try the back arrow too.',
        'Tekan Ask, lalu Done. Coba juga panah kembali.',
      ),
      explanation: const Tr(
        'Navigator.push returns a Future that completes with whatever the '
            'pushed route is popped with. If the user leaves by the back arrow '
            'instead, the result is null, so the page that awaits it must be '
            'ready for that.',
        'Navigator.push mengembalikan Future yang selesai dengan nilai apa '
            'pun yang dibawa saat route itu di-pop. Jika pengguna keluar lewat '
            'panah kembali, hasilnya null, jadi halaman yang menunggunya harus '
            'siap untuk itu.',
      ),
      docs: 'https://docs.flutter.dev/cookbook/navigation/returning-data',
      mistakes: const [
        Mistake(
          ['calm'],
          Tr(
            'Without quotes, calm is a name Dart would look up, not a word.',
            'Tanpa tanda kutip, calm adalah nama yang akan dicari Dart, bukan '
                'sebuah kata.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => _MiniApp(values: v, initial: [(_) => const _MoodHome()]),
    ),
    Koan(
      prompt: const Tr(
        'Pages may be called by name. Open the settings by the name it was '
            'given',
        'Halaman bisa dipanggil dengan namanya. Buka pengaturan dengan nama '
            'yang diberikan kepadanya',
      ),
      code: r'''
MaterialApp(
  routes: {
    '/': (context) => const HomePage(),
    '/settings': (context) => const SettingsPage(),
  },
);

Navigator.pushNamed(context, __);''',
      answers: ["'/settings'"],
      explanation: const Tr(
        'pushNamed looks the name up in MaterialApp.routes, then asks '
            'onGenerateRoute, and fails if neither knows it. Names keep pages '
            'decoupled; packages such as go_router grow the same idea into '
            'full URL paths.',
        'pushNamed mencari nama itu di MaterialApp.routes, lalu bertanya ke '
            'onGenerateRoute, dan gagal jika keduanya tidak mengenalnya. Nama '
            'membuat halaman tidak saling terikat; package seperti go_router '
            'mengembangkan gagasan yang sama menjadi path URL lengkap.',
      ),
      docs: 'https://docs.flutter.dev/cookbook/navigation/named-routes',
      mistakes: const [
        Mistake(
          ["'settings'"],
          Tr(
            'Route names are matched exactly, and these all begin with a slash.',
            'Nama route dicocokkan secara persis, dan semuanya diawali garis '
                'miring.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => _MiniApp(
        values: v,
        initial: [(_) => const _NamedHome()],
        routes: {
          '/': (_) => const _NamedHome(),
          '/settings': (_) => const _Screen(
            title: 'Settings',
            color: kSage,
            child: Text('Quiet mode: on'),
          ),
        },
      ),
    ),
    Koan(
      prompt: const Tr(
        'On the first page there is nothing beneath. Go back only if there '
            'is somewhere to go',
        'Di halaman pertama tidak ada apa-apa di bawahnya. Kembalilah hanya '
            'jika ada tempat untuk dituju',
      ),
      code: r'''
AppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => __(context),
  ),
)''',
      answers: ['Navigator.maybePop'],
      hint: const Tr(
        'Press the back arrow on Home, then open a page and try again.',
        'Tekan panah kembali di Home, lalu buka halaman lain dan coba lagi.',
      ),
      explanation: const Tr(
        'maybePop asks first: it does nothing on the last page, and it '
            'respects a PopScope that wants to stay, such as a form with '
            'unsaved changes. canPop asks the same question without acting.',
        'maybePop bertanya terlebih dahulu: ia tidak melakukan apa pun di '
            'halaman terakhir, dan menghormati PopScope yang ingin bertahan, '
            'seperti form dengan perubahan yang belum disimpan. canPop '
            'mengajukan pertanyaan yang sama tanpa bertindak.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Navigator/maybePop.html',
      mistakes: const [
        Mistake(
          ['Navigator.pop'],
          Tr(
            'pop removes the page whether or not one lies beneath. On the first '
                'page, that leaves an empty screen.',
            'pop menghapus halaman, ada atau tidak ada halaman di bawahnya. Di '
                'halaman pertama, itu menyisakan layar kosong.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        _action(v[0]);
        return _MiniApp(values: v, initial: [(_) => const _BackHome()]);
      },
    ),
    Koan(
      prompt: const Tr(
        'Gather it all: open the palette, and let the chosen color travel '
            'back to the page that waits for it',
        'Satukan semuanya: buka palet, dan biarkan warna yang dipilih '
            'kembali ke halaman yang menunggunya',
      ),
      code: r'''
final color = await __<Color>(
  context,
  MaterialPageRoute(builder: (context) => const Palette()),
);
if (color != null) setState(() => _color = color);

GestureDetector(
  onTap: () => __(context, Colors.teal),
  child: Dot(Colors.teal),
)''',
      answers: ['Navigator.push', 'Navigator.pop'],
      capstone: true,
      explanation: const Tr(
        'The page that asks awaits push; the page that answers passes its '
            'result to pop. The type argument, Color here, types the result, '
            'and it arrives nullable because the user may leave without '
            'choosing.',
        'Halaman yang bertanya menunggu push dengan await; halaman yang '
            'menjawab memberikan hasilnya ke pop. Argumen tipe, di sini Color, '
            'memberi tipe pada hasil itu, dan ia tiba sebagai nullable karena '
            'pengguna bisa pergi tanpa memilih.',
      ),
      docs: 'https://docs.flutter.dev/cookbook/navigation/returning-data',
      mistakes: const [
        Mistake(
          ['Navigator.pushReplacement', null],
          Tr(
            'The page that asks must still be there to hear the answer.',
            'Halaman yang bertanya harus tetap ada untuk mendengar jawabannya.',
          ),
        ),
        Mistake(
          ['Navigator.pop', 'Navigator.push'],
          Tr(
            'The two are swapped: one page climbs up to ask, the other steps '
                'down to answer.',
            'Keduanya tertukar: satu halaman naik untuk bertanya, yang lain '
                'turun untuk menjawab.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        _action(v[0]);
        _action(v[1]);
        return _MiniApp(values: v, initial: [(_) => const _ColorHome()]);
      },
    ),
  ],
);
