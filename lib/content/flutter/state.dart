import '../../engine/koan.dart';
import 'preview_kit.dart';
import 'registry.dart';

final state = Category(
  id: 'state',
  title: const Tr('State', 'State'),
  intro: const Tr(
    'Some widgets must remember, and their memory lives in a State.',
    'Sebagian widget perlu mengingat, dan ingatannya tersimpan di dalam '
        'sebuah State.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A widget that must remember is stateful; it creates the State that '
            'remembers for it',
        'Widget yang perlu mengingat bersifat stateful; ia membuat State '
            'yang mengingat untuknya',
      ),
      code: r'''
class Counter extends __ {
  const Counter({super.key});

  @override
  State<Counter> __() => _CounterState();
}''',
      answers: ['StatefulWidget', 'createState'],
      explanation: const Tr(
        'A StatefulWidget is still immutable. When it is inserted into the '
            'tree, Flutter calls createState once, and the State it returns '
            'holds the changing data and survives every rebuild.',
        'StatefulWidget tetap immutable. Saat ia dipasang di tree, Flutter '
            'memanggil createState sekali, dan State yang dikembalikannya '
            'menyimpan data yang berubah serta bertahan di setiap build ulang.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html',
      mistakes: const [
        Mistake(
          ['StatelessWidget', null],
          Tr(
            'A StatelessWidget has no State to create; it only builds.',
            'StatelessWidget tidak punya State untuk dibuat; ia hanya '
                'melakukan build.',
          ),
        ),
        Mistake(
          [null, 'build'],
          Tr(
            'In a stateful widget, build lives in the State. The widget\'s own '
                'job is to bring that State into being.',
            'Pada widget stateful, build berada di dalam State. Tugas widget '
                'itu sendiri adalah menghadirkan State tersebut.',
          ),
        ),
        Mistake(
          [null, 'initState'],
          Tr(
            'initState runs inside the State once it exists; something has to '
                'make the State first.',
            'initState berjalan di dalam State setelah State itu ada; harus '
                'ada yang membuat State-nya lebih dulu.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'The widget is the seed; the State is the tree that grows from it',
        'Widget adalah benihnya; State adalah pohon yang tumbuh darinya',
      ),
      code: r'''
class _CounterState extends __<Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Text('$_count');
  }
}''',
      answers: ['State'],
      explanation: const Tr(
        'State<Counter> is generic over its widget, so inside it widget is '
            'typed as Counter. Its mutable fields, like _count, outlive every '
            'rebuild; the class is usually private, since only its widget '
            'creates it.',
        'State<Counter> generik terhadap widget-nya, sehingga di dalamnya '
            'widget bertipe Counter. Field yang bisa berubah, seperti _count, '
            'bertahan melewati setiap build ulang; class-nya biasanya private, '
            'karena hanya widget-nya yang membuatnya.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/State-class.html',
      mistakes: const [
        Mistake(
          ['StatefulWidget'],
          Tr(
            'The StatefulWidget is the immutable half, already written as '
                'Counter. This class is the half that remembers.',
            'StatefulWidget adalah separuh yang immutable, yang sudah ditulis '
                'sebagai Counter. Class ini adalah separuh yang mengingat.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'Changing a field is silent; to be heard, the change must be '
            'announced',
        'Mengubah sebuah field tidak bersuara; agar terdengar, perubahan itu '
            'harus diumumkan',
      ),
      code: r'''
void _increment() {
  __(() {
    _count += 1;
  });
}''',
      answers: ['setState'],
      hint: const Tr(
        'It asks Flutter to run build again.',
        'Method ini meminta Flutter menjalankan build sekali lagi.',
      ),
      explanation: const Tr(
        'setState runs the callback right away, then marks the State as dirty '
            'so build runs again in the next frame. Changing _count without it '
            'updates the field, but the screen keeps showing the old number.',
        'setState langsung menjalankan callback-nya, lalu menandai State '
            'sebagai kotor sehingga build berjalan lagi di frame berikutnya. '
            'Mengubah _count tanpanya memang memperbarui field, tetapi layar '
            'tetap menampilkan angka lama.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/State/setState.html',
      mistakes: const [
        Mistake(
          ['build'],
          Tr(
            'Calling build ourselves only returns a new widget, which nobody '
                'puts on screen. Flutter must be asked to rebuild.',
            'Memanggil build sendiri hanya mengembalikan widget baru, yang '
                'tidak ditampilkan siapa pun. Flutter harus diminta untuk '
                'build ulang.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'Change the state inside setState and build runs again. Make each '
            'tap add 5, then tap both counters',
        'Ubah state di dalam setState, maka build berjalan lagi. Buat setiap '
            'ketukan menambah 5, lalu ketuk kedua counter',
      ),
      code: r'''
void _increment() {
  setState(() {
    _count += __;
  });
}''',
      answers: ['5'],
      explanation: const Tr(
        'Each tap runs setState, which changes _count and schedules a new '
            'build. The two counters in the preview are separate widgets, each '
            'with its own State, so tapping one never changes the other.',
        'Setiap ketukan menjalankan setState, yang mengubah _count dan '
            'menjadwalkan build baru. Kedua counter di pratinjau adalah widget '
            'terpisah, masing-masing dengan State-nya sendiri, sehingga '
            'mengetuk yang satu tidak pernah mengubah yang lain.',
      ),
      docs: 'https://docs.flutter.dev/ui/interactivity',
      registry: flutterRegistry,
      preview: (v) {
        final step = v[0] as int;
        return PreviewCanvas(child: TapCounter(step: step));
      },
    ),
    Koan(
      prompt: const Tr(
        'What is born with the State is created once, before the first build',
        'Apa yang lahir bersama State dibuat sekali saja, sebelum build '
            'pertama',
      ),
      code: r'''
@override
void __() {
  super.__();
  _controller = AnimationController(vsync: this);
}''',
      answers: ['initState', 'initState'],
      explanation: const Tr(
        'initState runs exactly once, after the State joins the tree and '
            'before the first build, which makes it the place for one-time '
            'setup such as controllers and subscriptions. super.initState() '
            'comes first.',
        'initState berjalan tepat sekali, setelah State bergabung dengan tree '
            'dan sebelum build pertama, sehingga cocok untuk persiapan sekali '
            'jalan seperti controller dan subscription. super.initState() '
            'dipanggil paling awal.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/State/initState.html',
      mistakes: const [
        Mistake(
          ['build', 'build'],
          Tr(
            'build may run many times, so a controller made there would be '
                'created again on every rebuild.',
            'build bisa berjalan berkali-kali, sehingga controller yang dibuat '
                'di sana akan dibuat ulang di setiap build ulang.',
          ),
        ),
        Mistake(
          ['didChangeDependencies', 'didChangeDependencies'],
          Tr(
            'That runs after the State is born, and again whenever an '
                'inherited widget it depends on changes, so possibly more than '
                'once.',
            'Method itu berjalan setelah State lahir, dan berjalan lagi setiap '
                'kali inherited widget yang ia andalkan berubah, jadi bisa lebih '
                'dari sekali.',
          ),
        ),
        Mistake(
          ['createState', 'createState'],
          Tr(
            'createState belongs to the widget and returns the State; setup '
                'inside the State happens afterwards.',
            'createState milik widget dan mengembalikan State; persiapan di '
                'dalam State terjadi sesudahnya.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'What we create, we must also release, when the State leaves the '
            'tree for good',
        'Apa yang kita buat juga harus kita lepaskan, saat State '
            'meninggalkan tree untuk selamanya',
      ),
      code: r'''
@override
void __() {
  _controller.dispose();
  super.__();
}''',
      answers: ['dispose', 'dispose'],
      explanation: const Tr(
        'dispose is called when the State leaves the tree for good. It is the '
            'place to release controllers, timers and subscriptions, calling '
            'super.dispose() last, the mirror image of initState. Afterwards '
            'mounted is false and setState is no longer allowed.',
        'dispose dipanggil saat State meninggalkan tree untuk selamanya. Di '
            'sinilah kita melepaskan controller, timer, dan subscription, lalu '
            'memanggil super.dispose() paling akhir, kebalikan dari initState. '
            'Setelah itu mounted bernilai false dan setState tidak boleh lagi '
            'dipanggil.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/State/dispose.html',
      mistakes: const [
        Mistake(
          ['deactivate', 'deactivate'],
          Tr(
            'After deactivate, a State may still be put back elsewhere in the '
                'tree, so it is not the end.',
            'Setelah deactivate, State masih bisa dipasang kembali di tempat '
                'lain dalam tree, jadi itu belum akhir.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'The State outlives its widgets. When the parent sends a new one, '
            'the State may compare it with the old',
        'State hidup lebih lama daripada widget-nya. Saat parent mengirim '
            'widget baru, State bisa membandingkannya dengan yang lama',
      ),
      code: r'''
@override
void __(Counter oldWidget) {
  super.__(oldWidget);
  if (widget.step != oldWidget.step) {
    _count = 0;
  }
}''',
      answers: ['didUpdateWidget', 'didUpdateWidget'],
      explanation: const Tr(
        'When the parent rebuilds with a widget of the same type and key, '
            'Flutter keeps the State, updates widget, and calls '
            'didUpdateWidget with the old one so we can react to the change. '
            'build always follows, so there is no need for setState here.',
        'Saat parent build ulang dengan widget bertipe dan ber-key sama, '
            'Flutter mempertahankan State, memperbarui widget, lalu memanggil '
            'didUpdateWidget dengan widget lama agar kita bisa menanggapi '
            'perubahannya. build selalu menyusul, jadi setState tidak '
            'diperlukan di sini.',
      ),
      docs:
          'https://api.flutter.dev/flutter/widgets/State/didUpdateWidget.html',
      mistakes: const [
        Mistake(
          ['didChangeDependencies', 'didChangeDependencies'],
          Tr(
            'That reacts to inherited widgets such as Theme changing, not to '
                'a new configuration from the parent. It takes no old widget.',
            'Method itu menanggapi perubahan inherited widget seperti Theme, '
                'bukan konfigurasi baru dari parent. Ia tidak menerima widget '
                'lama.',
          ),
        ),
        Mistake(
          ['initState', 'initState'],
          Tr(
            'initState runs only once; the State is not born again when the '
                'parent sends a new widget.',
            'initState hanya berjalan sekali; State tidak lahir kembali saat '
                'parent mengirim widget baru.',
          ),
        ),
      ],
      hint: const Tr(
        'Its name says that the widget has been updated.',
        'Namanya menyatakan bahwa widget telah diperbarui.',
      ),
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'The State reaches its current configuration through a single '
            'getter',
        'State menjangkau konfigurasinya saat ini melalui satu getter',
      ),
      code: r'''
class _GreetingState extends State<Greeting> {
  @override
  Widget build(BuildContext context) {
    return Text('Hello, ${__.name}');
  }
}''',
      answers: ['widget'],
      explanation: const Tr(
        'State.widget always points to the latest configuration, and is '
            'swapped whenever the parent rebuilds. Reading widget.name in build '
            'keeps it fresh; copying it into a field in initState would go '
            'stale.',
        'State.widget selalu menunjuk ke konfigurasi terbaru, dan diganti '
            'setiap kali parent build ulang. Membaca widget.name di dalam build '
            'membuatnya selalu segar; menyalinnya ke field di initState akan '
            'membuatnya basi.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/State/widget.html',
      mistakes: const [
        Mistake(
          ['context'],
          Tr(
            'context is the State\'s place in the tree; it does not hold the '
                'widget\'s fields.',
            'context adalah posisi State di dalam tree; ia tidak menyimpan '
                'field milik widget.',
          ),
        ),
        Mistake(
          ['this'],
          Tr(
            'this is the State itself, and name is not one of its fields.',
            'this adalah State itu sendiri, dan name bukan salah satu '
                'field-nya.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'After a long wait, first ask whether you are still part of the tree',
        'Setelah menunggu lama, tanyakan dulu apakah kita masih menjadi '
            'bagian dari tree',
      ),
      code: r'''
Future<void> _load() async {
  final data = await fetchQuote();
  if (!__) return;
  setState(() => _quote = data);
}''',
      answers: ['mounted'],
      hint: const Tr(
        'A State is attached to the tree between initState and dispose.',
        'Sebuah State terpasang di tree antara initState dan dispose.',
      ),
      explanation: const Tr(
        'While we await, the user may leave the screen and the State may be '
            'disposed, and calling setState then is an error. mounted is true '
            'only while the State is in the tree; outside a State, '
            'context.mounted asks the same question.',
        'Selama kita menunggu, pengguna bisa meninggalkan layar dan State bisa '
            'saja sudah di-dispose, dan memanggil setState saat itu adalah '
            'error. mounted bernilai true hanya selama State berada di tree; '
            'di luar State, context.mounted menanyakan hal yang sama.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/State/mounted.html',
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'A like button: it starts unliked at 12, each tap toggles our like, '
            'and the count follows. Make yours behave like the goal, then tap '
            'both hearts',
        'Sebuah tombol suka: awalnya belum disukai dengan angka 12, setiap '
            'ketukan membalik suka kita, dan angkanya mengikuti. Buat milik '
            'kita berperilaku seperti tujuan, lalu ketuk kedua hati',
      ),
      code: r'''
bool _liked = __;
int _likes = 12;

void _toggle() {
  setState(() {
    _liked = !_liked;
    _likes += _liked ? __ : __;
  });
}''',
      answers: ['false', '1', '-1'],
      capstone: true,
      explanation: const Tr(
        'The State remembers two things, and setState changes them together '
            'so build shows a heart and a count that always agree. Liking adds '
            'one and unliking takes it back, so tapping twice returns to 12. '
            'Each heart in the preview has its own State, so they count '
            'separately.',
        'State mengingat dua hal, dan setState mengubah keduanya bersamaan '
            'sehingga build menampilkan hati dan angka yang selalu selaras. '
            'Menyukai menambah satu dan membatalkannya mengambilnya kembali, '
            'sehingga dua kali ketukan kembali ke 12. Setiap hati di pratinjau '
            'punya State sendiri, sehingga hitungannya terpisah.',
      ),
      docs: 'https://docs.flutter.dev/ui/interactivity',
      mistakes: const [
        Mistake(
          ['true', null, null],
          Tr(
            'Then the heart starts out filled, before anyone has tapped it.',
            'Kalau begitu hatinya sudah terisi sejak awal, sebelum ada yang '
                'mengetuknya.',
          ),
        ),
        Mistake(
          [null, '1', '1'],
          Tr(
            'Taking back a like should lower the count. Tap twice and watch '
                'it climb instead.',
            'Membatalkan suka seharusnya menurunkan angkanya. Ketuk dua kali '
                'dan lihat angkanya malah terus naik.',
          ),
        ),
        Mistake(
          [null, '-1', '1'],
          Tr(
            'Swapped: the first tap likes the post, yet the count goes down.',
            'Tertukar: ketukan pertama menyukai postingan, tetapi angkanya '
                'malah turun.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: LikeButton(
          liked: v[0] as bool,
          likes: 12,
          onLike: (v[1] as int).clamp(-99, 99),
          onUnlike: (v[2] as int).clamp(-99, 99),
        ),
      ),
    ),
  ],
);
