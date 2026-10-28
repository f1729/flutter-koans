import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../engine/koan.dart';
import 'preview_kit.dart';
import 'preview_kit_more.dart';
import 'registry.dart';

const _week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _tints = [kRose, kSky, kSage, kSand];

/// One row of a list: a quiet, rounded strip with a label.
class _Item extends StatelessWidget {
  const _Item(this.label, {this.index = 0});

  final String label;
  final int index;

  @override
  Widget build(BuildContext context) => Container(
    height: 32,
    margin: const EdgeInsets.symmetric(vertical: 3),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border(left: BorderSide(color: _tints[index % 4], width: 4)),
    ),
    child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
  );
}

/// The area a list scrolls within, drawn as a frame.
Widget _window(Widget child) => PreviewCanvas(
  child: Frame(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: child,
      ),
    ),
  ),
);

/// A builder list that counts how many items it has actually built.
class _LazyList extends StatefulWidget {
  const _LazyList({required this.eager});

  final bool eager;

  @override
  State<_LazyList> createState() => _LazyListState();
}

class _LazyListState extends State<_LazyList> {
  static const _total = 1000;
  final _built = <int>{};
  final _count = ValueNotifier(0);
  bool _scheduled = false;

  void _note(int i) {
    if (!_built.add(i) || _scheduled) return;
    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (mounted) _count.value = _built.length;
    });
  }

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }

  Widget _item(int i) {
    _note(i);
    return _Item('Koan ${i + 1}', index: i);
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.eager
        ? ListView(children: [for (var i = 0; i < _total; i++) _item(i)])
        : ListView.builder(
            itemCount: _total,
            itemBuilder: (context, i) => _item(i),
          );
    return Column(
      children: [
        Expanded(child: list),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ValueListenableBuilder(
            valueListenable: _count,
            builder: (context, n, _) => Caption('built $n of $_total'),
          ),
        ),
      ],
    );
  }
}

const _poem = [
  'The old pond.',
  'A frog leaps in.',
  'The sound of water.',
  'Then silence again, wider than before.',
  'Ripples reach the reeds and fade.',
  'The moon settles back onto the surface.',
  'Nothing moved, and everything did.',
];

Widget _poemColumn() => Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        'Basho, retold',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
      const SizedBox(height: 6),
      for (final line in _poem)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(line, style: const TextStyle(fontSize: 15)),
        ),
    ],
  ),
);

final listsScrolling = Category(
  id: 'lists-scrolling',
  title: const Tr('Lists and Scrolling', 'List dan Scrolling'),
  intro: const Tr(
    'When there is more than fits, let it flow past the window.',
    'Saat isinya lebih banyak daripada ruangnya, biarkan ia mengalir '
        'melewati jendela.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A Column holds only what fits, and overflows the rest. Let the week '
            'scroll instead',
        'Column hanya menampung yang muat, dan sisanya overflow. Biarkan '
            'minggu ini di-scroll saja',
      ),
      code: r'''
__(
  children: [
    for (final day in week) ListTile(title: Text(day)),
  ],
)''',
      answers: ['ListView'],
      explanation: const Tr(
        'ListView is a scrollable Column: it lays its children out along the '
            'scroll axis and shows a window onto them. Its children are '
            'offered unbounded height, so each takes the height it needs and '
            'the list simply grows longer.',
        'ListView adalah Column yang bisa di-scroll: ia menata child-nya di '
            'sepanjang sumbu scroll dan menampilkan jendela ke arah mereka. '
            'Child-nya ditawari tinggi tak terbatas, jadi masing-masing '
            'mengambil tinggi yang dibutuhkan dan list-nya tinggal memanjang.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/ListView-class.html',
      mistakes: const [
        Mistake(
          ['Column'],
          Tr(
            'A Column lays out every child at once and never scrolls; whatever '
                'does not fit overflows.',
            'Column menata semua child sekaligus dan tidak pernah scroll; apa '
                'pun yang tidak muat akan overflow.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final items = [
          for (final (i, d) in [..._week, ..._week].indexed) _Item(d, index: i),
        ];
        return _window(switch (v[0]) {
          const (ListView) => ListView(children: items),
          const (Column) => FakeOverflow(child: Column(children: items)),
          _ => throw ArgumentError.value(v[0]),
        });
      },
    ),
    Koan(
      prompt: const Tr(
        'A thousand koans, yet only a handful fit on screen. Build each one '
            'only when it is about to be seen, then scroll',
        'Seribu koan, tetapi hanya segelintir yang muat di layar. Bangun '
            'masing-masing hanya saat akan terlihat, lalu scroll',
      ),
      code: r'''
__(
  itemCount: 1000,
  itemBuilder: (context, index) => Text('Koan ${index + 1}'),
)''',
      answers: ['ListView.builder'],
      explanation: const Tr(
        'ListView.builder calls itemBuilder lazily, only for the items in '
            'view plus a small margin, and lets go of those that scroll far '
            'away. The plain ListView constructor needs every child built up '
            'front, which is fine for a few and wasteful for a thousand.',
        'ListView.builder memanggil itemBuilder secara lazy, hanya untuk item '
            'yang terlihat ditambah sedikit cadangan, dan melepaskan yang '
            'sudah ter-scroll jauh. Constructor ListView biasa membutuhkan '
            'semua child dibuat di awal, tidak masalah untuk beberapa item, '
            'tetapi boros untuk seribu.',
      ),
      docs: 'https://docs.flutter.dev/cookbook/lists/long-lists',
      mistakes: const [
        Mistake(
          ['ListView'],
          Tr(
            'The plain constructor takes a ready-made list of children, all '
                'created before the first frame.',
            'Constructor biasa menerima list children yang sudah jadi, semuanya '
                'dibuat sebelum frame pertama.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final value = v[0];
        if (value == ListView) return _window(const _LazyList(eager: true));
        if (value == ListView.builder) {
          return _window(const _LazyList(eager: false));
        }
        throw ArgumentError.value(value);
      },
    ),
    Koan(
      prompt: const Tr(
        'A string of prayer beads holds 108. Tell the builder where to stop',
        'Seuntai tasbih berisi 108 butir. Beri tahu builder kapan harus '
            'berhenti',
      ),
      code: r'''
ListView.builder(
  itemCount: __,
  itemBuilder: (context, index) => Text('Bead ${index + 1}'),
)''',
      answers: ['108'],
      hint: const Tr(
        'Scroll to the end of the goal to see where it stops.',
        'Scroll sampai ujung tujuan untuk melihat di mana ia berhenti.',
      ),
      explanation: const Tr(
        'itemCount is how many times itemBuilder may be called, with index '
            'running from 0 to itemCount - 1. Leave it null and the list never '
            'ends, which suits a feed that loads more as we scroll.',
        'itemCount adalah berapa kali itemBuilder boleh dipanggil, dengan '
            'index dari 0 sampai itemCount - 1. Biarkan null maka list tidak '
            'pernah berakhir, cocok untuk feed yang memuat lebih banyak saat '
            'di-scroll.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html',
      mistakes: const [
        Mistake(
          ['107'],
          Tr(
            'itemCount is a count, not the last index. The last bead has '
                'index 107.',
            'itemCount adalah jumlah, bukan index terakhir. Butir terakhir '
                'ber-index 107.',
          ),
        ),
        Mistake(
          ['null'],
          Tr(
            'Without a count the builder never stops, and the beads go on '
                'forever.',
            'Tanpa jumlah, builder tidak pernah berhenti, dan butirnya terus '
                'berlanjut tanpa akhir.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final count = (v[0] as int?)?.clamp(0, 100000);
        return _window(
          ListView.builder(
            itemCount: count,
            itemBuilder: (context, i) => _Item('Bead ${i + 1}', index: i),
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'Not every list falls downward. Lay the colors side by side',
        'Tidak semua list jatuh ke bawah. Susun warna-warna ini '
            'berdampingan',
      ),
      code: r'''
SizedBox(
  height: 96,
  child: ListView(
    scrollDirection: __,
    children: [
      for (final c in colors) Container(width: 80, color: c),
    ],
  ),
)''',
      answers: ['Axis.horizontal'],
      explanation: const Tr(
        'scrollDirection turns the main axis of the list. Children are then '
            'offered unbounded width, so each must choose how wide to be, '
            'while their height is stretched to the list. That is why a '
            'horizontal list needs a height from its parent.',
        'scrollDirection memutar main axis dari list. Child-nya lalu ditawari '
            'lebar tak terbatas, jadi masing-masing harus memilih selebar '
            'apa, sementara tingginya diregangkan setinggi list. Itulah '
            'sebabnya list horizontal membutuhkan tinggi dari parent-nya.',
      ),
      docs: 'https://docs.flutter.dev/cookbook/lists/horizontal-list',
      mistakes: const [
        Mistake(
          ['Axis.vertical'],
          Tr(
            'That is the default: the list still runs down the page.',
            'Itu nilai bawaan: list-nya tetap mengalir ke bawah halaman.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final axis = v[0] as Axis;
        return PreviewCanvas(
          child: Center(
            child: Frame(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: SizedBox(
                  height: 96,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ListView(
                      scrollDirection: axis,
                      children: [
                        for (var i = 0; i < 12; i++)
                          Container(
                            width: 80,
                            height: 40,
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: _tints[i % 4],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'Five steps on a path. How many lines are drawn between them?',
        'Lima langkah di sebuah jalan. Berapa garis yang digambar di antara '
            'mereka?',
      ),
      code: r'''
final list = ListView.separated(
  itemCount: 5,
  itemBuilder: (context, i) => Text('Step ${i + 1}'),
  separatorBuilder: (context, i) => const Divider(),
);
await tester.pumpWidget(MaterialApp(home: list));
expect(find.byType(Divider), findsNWidgets(__));''',
      answers: ['4'],
      verify: () {
        final list = ListView.separated(
          itemCount: 5,
          itemBuilder: (context, i) => Text('Step ${i + 1}'),
          separatorBuilder: (context, i) => const Divider(),
        );
        final delegate = list.childrenDelegate as SliverChildBuilderDelegate;
        return [delegate.childCount! - 5];
      },
      explanation: const Tr(
        'ListView.separated builds a separator only between two items, '
            'never before the first or after the last, so n items get n - 1 '
            'separators. Like the builder, it builds both lazily.',
        'ListView.separated membuat separator hanya di antara dua item, '
            'tidak pernah sebelum yang pertama atau setelah yang terakhir, '
            'jadi n item mendapat n - 1 separator. Seperti builder, keduanya '
            'dibuat secara lazy.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/ListView/ListView.separated.html',
      mistakes: const [
        Mistake(
          ['5'],
          Tr(
            'A separator lives between two items. Is there anything after the '
                'last step?',
            'Separator berada di antara dua item. Apakah ada sesuatu setelah '
                'langkah terakhir?',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'Not a list of many, but one tall thing that does not fit. Let it '
            'scroll as a whole',
        'Bukan list berisi banyak item, melainkan satu hal tinggi yang tidak '
            'muat. Biarkan ia di-scroll sebagai satu kesatuan',
      ),
      code: r'''
__(
  child: Column(
    children: [
      Text('Basho, retold'),
      for (final line in poem) Text(line),
    ],
  ),
)''',
      answers: ['SingleChildScrollView'],
      explanation: const Tr(
        'SingleChildScrollView offers its one child unbounded height and '
            'shows a scrollable window onto it. It builds the whole child at '
            'once, so it suits a form or an article; for many similar items, '
            'ListView.builder builds only what is seen.',
        'SingleChildScrollView menawarkan tinggi tak terbatas kepada satu '
            'child-nya dan menampilkan jendela yang bisa di-scroll. Ia '
            'membangun seluruh child sekaligus, jadi cocok untuk form atau '
            'artikel; untuk banyak item serupa, ListView.builder hanya '
            'membangun yang terlihat.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html',
      mistakes: const [
        Mistake(
          ['ListView'],
          Tr(
            'A ListView takes many children, not one child. Which scroll view '
                'wraps a single widget?',
            'ListView menerima banyak children, bukan satu child. Scroll view '
                'mana yang membungkus satu widget saja?',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => _window(switch (v[0]) {
        const (SingleChildScrollView) => SingleChildScrollView(
          child: _poemColumn(),
        ),
        _ => FakeOverflow(child: _poemColumn()),
      }),
    ),
    Koan(
      prompt: const Tr(
        'A list inside a Column is offered endless height, and a window '
            'cannot be endless. Let the list be only as tall as its items',
        'List di dalam Column ditawari tinggi tanpa batas, dan sebuah jendela '
            'tidak bisa tanpa batas. Biarkan list setinggi item-nya saja',
      ),
      code: r'''
Column(
  children: [
    Text('Today'),
    ListView(
      shrinkWrap: __,
      children: [Text('Sit'), Text('Breathe'), Text('Rest')],
    ),
  ],
)''',
      answers: ['true'],
      explanation: const Tr(
        'With shrinkWrap the list measures its children and becomes exactly '
            'as tall as they are. That works here, but it builds every child '
            'to find out; often an Expanded around the ListView is the better '
            'fix, giving it a bounded height while keeping it lazy.',
        'Dengan shrinkWrap, list mengukur child-nya dan menjadi tepat '
            'setinggi mereka. Itu berhasil di sini, tetapi ia harus membangun '
            'semua child untuk mengetahuinya; sering kali Expanded di sekitar '
            'ListView adalah solusi yang lebih baik, memberinya tinggi yang '
            'terbatas sambil tetap lazy.',
      ),
      docs:
          'https://api.flutter.dev/flutter/widgets/ScrollView/shrinkWrap.html',
      mistakes: const [
        Mistake(
          ['false'],
          Tr(
            'Then the list wants to be as tall as the endless height it is '
                'offered, and Flutter stops with an error.',
            'Maka list ingin setinggi tinggi tanpa batas yang ditawarkan '
                'kepadanya, dan Flutter berhenti dengan error.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final shrink = v[0] as bool;
        return PreviewCanvas(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 6),
              if (shrink)
                ListView(
                  shrinkWrap: true,
                  children: const [
                    _Item('Sit'),
                    _Item('Breathe', index: 1),
                    _Item('Rest', index: 2),
                  ],
                )
              else
                const ErrorCard(
                  'Vertical viewport was given unbounded height.',
                  title: 'RenderViewport',
                ),
            ],
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'Some lists should hold still, perhaps because something around them '
            'already scrolls. Forbid this one to move',
        'Ada list yang seharusnya diam, mungkin karena sesuatu di sekitarnya '
            'sudah bisa di-scroll. Larang list ini bergerak',
      ),
      code: r'''
ListView(
  physics: const __(),
  children: [
    for (final rule in rules) Text(rule),
  ],
)''',
      answers: ['NeverScrollableScrollPhysics'],
      explanation: const Tr(
        'NeverScrollableScrollPhysics ignores drags, so an outer scroll view '
            'can move the whole page instead. Physics also gives scrolling its '
            'feel: BouncingScrollPhysics springs past the edge as on iOS, '
            'ClampingScrollPhysics stops hard at it.',
        'NeverScrollableScrollPhysics mengabaikan seretan, sehingga scroll '
            'view di luarnya yang menggerakkan seluruh halaman. Physics juga '
            'memberi rasa pada scrolling: BouncingScrollPhysics memantul '
            'melewati tepi seperti di iOS, ClampingScrollPhysics berhenti '
            'tegas di tepi.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/NeverScrollableScrollPhysics-class.html',
      mistakes: const [
        Mistake(
          ['ClampingScrollPhysics'],
          Tr(
            'That still scrolls; it only stops hard at the edges.',
            'Itu masih bisa di-scroll; ia hanya berhenti tegas di tepi.',
          ),
        ),
        Mistake(
          ['BouncingScrollPhysics'],
          Tr(
            'That still scrolls; it only springs back at the edges.',
            'Itu masih bisa di-scroll; ia hanya memantul kembali di tepi.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final ScrollPhysics physics = switch (v[0]) {
          const (NeverScrollableScrollPhysics) =>
            const NeverScrollableScrollPhysics(),
          const (BouncingScrollPhysics) => const BouncingScrollPhysics(),
          const (ClampingScrollPhysics) => const ClampingScrollPhysics(),
          const (AlwaysScrollableScrollPhysics) =>
            const AlwaysScrollableScrollPhysics(),
          const (PageScrollPhysics) => const PageScrollPhysics(),
          _ => throw ArgumentError.value(v[0]),
        };
        const rules = [
          'Sit still',
          'Breathe in',
          'Breathe out',
          'Let thoughts pass',
          'Return to the breath',
          'Rest',
          'Begin again',
          'Bow',
        ];
        return _window(
          ListView(
            physics: physics,
            children: [for (final (i, r) in rules.indexed) _Item(r, index: i)],
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'Gather it all: the seven days of a week side by side, scrolling '
            'sideways, with 8 pixels of quiet between each day',
        'Satukan semuanya: tujuh hari dalam seminggu berdampingan, di-scroll '
            'ke samping, dengan jeda 8 piksel di antara setiap hari',
      ),
      code: r'''
SizedBox(
  height: 72,
  child: ListView.separated(
    scrollDirection: __,
    itemCount: __,
    itemBuilder: (context, i) => Chip(label: Text(week[i])),
    separatorBuilder: (context, i) => SizedBox(width: __),
  ),
)''',
      answers: ['Axis.horizontal', '7', '8'],
      accept: (v) => v[0] == Axis.horizontal && v[1] == 7 && isNum(v[2], 8),
      capstone: true,
      explanation: const Tr(
        'A horizontal list needs a bounded height, given here by the '
            'SizedBox, and each chip picks its own width. The separators sit '
            'only between days, so the strip begins and ends flush with its '
            'first and last day.',
        'List horizontal membutuhkan tinggi yang terbatas, yang di sini '
            'diberikan oleh SizedBox, dan setiap chip memilih lebarnya '
            'sendiri. Separator hanya ada di antara hari, jadi deretan ini '
            'dimulai dan diakhiri rapat dengan hari pertama dan terakhirnya.',
      ),
      docs: 'https://docs.flutter.dev/ui/layout/scrolling',
      mistakes: const [
        Mistake(
          ['Axis.vertical', null, null],
          Tr(
            'Then the days fall down the page instead of lying side by side.',
            'Maka hari-hari jatuh ke bawah halaman, bukan berdampingan.',
          ),
        ),
        Mistake(
          [null, '6', null],
          Tr(
            'itemCount counts the days; it is not the last index.',
            'itemCount menghitung jumlah hari; itu bukan index terakhir.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final axis = v[0] as Axis;
        final count = (v[1] as int).clamp(0, 1000);
        final gap = px(v[2], max: 120);
        return PreviewCanvas(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This week',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Frame(
                child: SizedBox(
                  height: 72,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ListView.separated(
                      scrollDirection: axis,
                      padding: const EdgeInsets.all(6),
                      itemCount: count,
                      itemBuilder: (context, i) => Center(
                        child: Chip(
                          label: Text(_week[i % 7]),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: _tints[i % 4], width: 2),
                        ),
                      ),
                      separatorBuilder: (context, i) => SizedBox(width: gap),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  ],
);
