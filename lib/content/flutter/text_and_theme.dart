import 'package:flutter/material.dart';

import '../../engine/koan.dart';
import 'preview_kit.dart';
import 'registry.dart';

Widget _word(String text, TextStyle style) => PreviewCanvas(
  child: Center(child: Text(text, style: style)),
);

const _poem = 'The old pond\nA frog leaps in, the sound of water';
const _long =
    'The wind carries words far beyond the edge of the page, '
    'and still they keep on going';

final textAndTheme = Category(
  id: 'text-and-theme',
  title: const Tr('Text and Theme', 'Text dan Theme'),
  intro: const Tr(
    'Words take on size, weight and color, and a Theme lends them harmony.',
    'Kata-kata mendapat ukuran, ketebalan, dan warna, dan Theme memberinya '
        'keselarasan.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A word may whisper or speak aloud. Give this one a size of 32',
        'Sebuah kata bisa berbisik atau bersuara lantang. Beri kata ini '
            'ukuran 32',
      ),
      code: r'''
Text(
  'Calm',
  style: TextStyle(fontSize: __),
)''',
      answers: ['32'],
      accept: (v) => isNum(v[0], 32),
      explanation: const Tr(
        'fontSize is measured in logical pixels, and Text starts at 14 when '
            'nothing says otherwise. The user\'s text scaling setting is '
            'applied on top of it, so text can grow for those who need it.',
        'fontSize diukur dalam piksel logis, dan Text berukuran 14 jika tidak '
            'ada yang menentukan lain. Pengaturan skala teks milik pengguna '
            'diterapkan di atasnya, sehingga teks bisa membesar bagi yang '
            'membutuhkannya.',
      ),
      docs: 'https://api.flutter.dev/flutter/painting/TextStyle/fontSize.html',
      registry: flutterRegistry,
      preview: (v) =>
          _word('Calm', TextStyle(fontSize: px(v[0], min: 1, max: 72))),
    ),
    Koan(
      prompt: const Tr(
        'Some words carry more weight than others. Make yours match the goal',
        'Ada kata yang lebih berbobot daripada yang lain. Samakan dengan '
            'tujuan',
      ),
      code: r'''
Text(
  'Steady',
  style: TextStyle(
    fontSize: 28,
    fontWeight: __,
  ),
)''',
      answers: ['FontWeight.bold'],
      explanation: const Tr(
        'FontWeight.bold is another name for w700, and normal is w400; the '
            'weights run from w100 to w900. If the font has no file for a '
            'weight, the closest one is used, or bold is synthesized.',
        'FontWeight.bold adalah nama lain untuk w700, dan normal adalah w400; '
            'ketebalannya berkisar dari w100 hingga w900. Jika font tidak '
            'punya file untuk suatu ketebalan, yang terdekat akan dipakai, atau '
            'bold akan disintesis.',
      ),
      docs: 'https://api.flutter.dev/flutter/dart-ui/FontWeight-class.html',
      mistakes: const [
        Mistake(
          ['FontWeight.normal'],
          Tr(
            'That is the regular weight every Text starts with.',
            'Itu ketebalan biasa yang dimiliki setiap Text sejak awal.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => _word(
        'Steady',
        TextStyle(fontSize: 28, fontWeight: v[0] as FontWeight),
      ),
    ),
    Koan(
      prompt: const Tr(
        'A word may lean, like grass in the wind',
        'Sebuah kata bisa condong, seperti rumput yang tertiup angin',
      ),
      code: r'''
Text(
  'Breeze',
  style: TextStyle(
    fontSize: 28,
    fontStyle: __,
  ),
)''',
      answers: ['FontStyle.italic'],
      explanation: const Tr(
        'FontStyle.italic picks the italic face of the font, or slants the '
            'regular one if there is none. Style and weight are independent, '
            'so a word can be bold and italic at once.',
        'FontStyle.italic memilih versi miring dari font, atau memiringkan '
            'versi biasanya jika tidak tersedia. Gaya dan ketebalan tidak '
            'saling bergantung, sehingga sebuah kata bisa tebal sekaligus '
            'miring.',
      ),
      docs: 'https://api.flutter.dev/flutter/dart-ui/FontStyle.html',
      mistakes: const [
        Mistake(
          ['FontStyle.normal'],
          Tr(
            'That is the upright style every Text starts with.',
            'Itu gaya tegak yang dimiliki setiap Text sejak awal.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => _word(
        'Breeze',
        TextStyle(fontSize: 28, fontStyle: v[0] as FontStyle),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Lines of text may rest against either edge, or in between. Let '
            'these rest against the right',
        'Baris-baris teks bisa bersandar di salah satu tepi, atau di '
            'tengahnya. Sandarkan baris-baris ini di tepi kanan',
      ),
      code: r'''
Text(
  'The old pond\nA frog leaps in, the sound of water',
  textAlign: __,
)''',
      answers: ['TextAlign.right'],
      accept: (v) => v[0] == TextAlign.right || v[0] == TextAlign.end,
      hint: const Tr(
        'In a left-to-right language, the end is on the right.',
        'Dalam bahasa yang ditulis dari kiri ke kanan, ujung akhirnya ada di '
            'kanan.',
      ),
      explanation: const Tr(
        'textAlign arranges each line within the width of the Text itself, so '
            'it only shows when the Text is wider than its lines, as in this '
            '200-wide box. TextAlign.end follows the reading direction, which '
            'suits apps that also run right-to-left.',
        'textAlign mengatur setiap baris di dalam lebar Text itu sendiri, '
            'sehingga efeknya baru terlihat jika Text lebih lebar daripada '
            'baris-barisnya, seperti di kotak selebar 200 ini. TextAlign.end '
            'mengikuti arah baca, cocok untuk aplikasi yang juga berjalan dari '
            'kanan ke kiri.',
      ),
      docs: 'https://api.flutter.dev/flutter/dart-ui/TextAlign.html',
      mistakes: const [
        Mistake(
          ['TextAlign.start'],
          Tr(
            'start follows the reading direction, which in English begins on '
                'the left.',
            'start mengikuti arah baca, yang dalam bahasa Inggris dimulai dari '
                'kiri.',
          ),
        ),
        Mistake(
          ['TextAlign.justify'],
          Tr(
            'justify stretches full lines to touch both edges, and leaves the '
                'last line at the start.',
            'justify meregangkan baris penuh hingga menyentuh kedua tepi, dan '
                'membiarkan baris terakhir di awal.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Center(
          child: Frame(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                width: 200,
                child: Text(
                  _poem,
                  textAlign: v[0] as TextAlign,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'When words outgrow their place, let one line suffice and trail off '
            'softly',
        'Saat kata-kata melampaui tempatnya, cukupkan satu baris saja dan '
            'biarkan ia berakhir dengan titik-titik',
      ),
      code: r'''
Text(
  'The wind carries words far beyond the edge of the page...',
  maxLines: __,
  overflow: __,
)''',
      answers: ['1', 'TextOverflow.ellipsis'],
      explanation: const Tr(
        'maxLines caps how many lines the text may use, and overflow decides '
            'what happens to the rest: ellipsis ends with …, fade fades it '
            'out, and clip simply cuts it off. Without a limit, the text '
            'would just keep wrapping.',
        'maxLines membatasi berapa baris yang boleh dipakai teks, dan overflow '
            'menentukan apa yang terjadi pada sisanya: ellipsis diakhiri '
            'dengan …, fade memudarkannya, dan clip langsung memotongnya. '
            'Tanpa batas, teks akan terus berlanjut ke baris berikutnya.',
      ),
      docs: 'https://api.flutter.dev/flutter/painting/TextOverflow.html',
      mistakes: const [
        Mistake(
          [null, 'TextOverflow.clip'],
          Tr(
            'clip cuts the words off abruptly, with no soft trailing.',
            'clip memotong kata-kata secara tiba-tiba, tanpa akhiran yang '
                'lembut.',
          ),
        ),
        Mistake(
          [null, 'TextOverflow.fade'],
          Tr(
            'fade lets the last words dissolve, but leaves no trailing dots.',
            'fade membuat kata-kata terakhir memudar, tetapi tidak meninggalkan '
                'titik-titik.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final lines = v[0] as int?;
        final overflow = v[1] as TextOverflow?;
        return PreviewCanvas(
          child: Center(
            child: Frame(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: 200,
                  child: Text(
                    _long,
                    maxLines: lines?.clamp(1, 6),
                    overflow: overflow,
                    style: const TextStyle(fontSize: 15),
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
        'copyWith changes what we ask, and keeps everything else',
        'copyWith mengubah apa yang kita minta, dan mempertahankan sisanya',
      ),
      code: r'''
const base = TextStyle(fontSize: 20);
final bold = base.copyWith(fontWeight: FontWeight.bold);
expect(bold.fontSize, __);''',
      answers: ['20.0'],
      verify: () {
        const base = TextStyle(fontSize: 20);
        final bold = base.copyWith(fontWeight: FontWeight.bold);
        return [bold.fontSize];
      },
      accept: (v) => isNum(v[0], 20),
      explanation: const Tr(
        'TextStyle is immutable, so copyWith returns a new style with only the '
            'named fields replaced. The fontSize of 20 is kept, as a double, '
            'which is why Dart shows it as 20.0.',
        'TextStyle bersifat immutable, sehingga copyWith mengembalikan style '
            'baru dengan hanya field yang disebutkan yang diganti. fontSize 20 '
            'tetap dipertahankan sebagai double, karena itu Dart '
            'menampilkannya sebagai 20.0.',
      ),
      docs: 'https://api.flutter.dev/flutter/painting/TextStyle/copyWith.html',
      mistakes: const [
        Mistake(
          ['null'],
          Tr(
            'copyWith keeps every field we do not mention.',
            'copyWith mempertahankan setiap field yang tidak kita sebutkan.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'The Theme flows down the tree; any widget below may ask for it '
            'with of(context)',
        'Theme mengalir turun di sepanjang tree; widget mana pun di bawahnya '
            'bisa memintanya lewat of(context)',
      ),
      code: r'''
@override
Widget build(BuildContext context) {
  final theme = __.of(context);
  return Text(
    'koan',
    style: theme.textTheme.titleLarge,
  );
}''',
      answers: ['Theme'],
      explanation: const Tr(
        'Theme.of(context) walks up the tree to the nearest Theme and '
            'registers a dependency on it, so this widget rebuilds when the '
            'theme changes, for example when dark mode turns on. Without any '
            'Theme above, it returns a default ThemeData.',
        'Theme.of(context) menelusuri tree ke atas hingga Theme terdekat dan '
            'mendaftarkan ketergantungan padanya, sehingga widget ini build '
            'ulang saat theme berubah, misalnya saat mode gelap menyala. Jika '
            'tidak ada Theme di atasnya, ia mengembalikan ThemeData default.',
      ),
      docs: 'https://api.flutter.dev/flutter/material/Theme/of.html',
      mistakes: const [
        Mistake(
          ['ThemeData'],
          Tr(
            'ThemeData is the data itself. We ask the widget in the tree that '
                'hands it down.',
            'ThemeData adalah datanya sendiri. Kita bertanya kepada widget di '
                'tree yang mewariskannya.',
          ),
        ),
        Mistake(
          ['MediaQuery'],
          Tr(
            'MediaQuery knows about the screen, such as its size and text '
                'scaling, not about text styles.',
            'MediaQuery tahu tentang layar, seperti ukuran dan skala teksnya, '
                'bukan tentang text style.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'The colors of an app live together in its scheme',
        'Warna-warna sebuah aplikasi tinggal bersama di dalam skemanya',
      ),
      code: r'''
final theme = Theme.of(context);
return Container(
  color: theme.__.primary,
  child: Text('koan'),
);''',
      answers: ['colorScheme'],
      hint: const Tr('Its type is ColorScheme.', 'Tipenya adalah ColorScheme.'),
      explanation: const Tr(
        'ThemeData.colorScheme holds the Material color roles, such as '
            'primary, onPrimary and surface. Asking for a role instead of a '
            'fixed color lets the whole app follow a new seed or switch to '
            'dark mode.',
        'ThemeData.colorScheme menyimpan peran warna Material, seperti '
            'primary, onPrimary, dan surface. Meminta sebuah peran, bukan warna '
            'tetap, membuat seluruh aplikasi bisa mengikuti seed baru atau '
            'beralih ke mode gelap.',
      ),
      docs: 'https://api.flutter.dev/flutter/material/ColorScheme-class.html',
      mistakes: const [
        Mistake(
          ['textTheme'],
          Tr(
            'textTheme holds text styles, not colors.',
            'textTheme menyimpan text style, bukan warna.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'A Theme wraps a branch of the tree, and everything inside takes on '
            'its colors. Seed it with teal',
        'Theme membungkus satu cabang tree, dan semua yang ada di dalamnya '
            'ikut memakai warnanya. Beri benih warna teal',
      ),
      code: r'''
Theme(
  data: ThemeData(
    colorSchemeSeed: __,
  ),
  child: FilledButton(
    onPressed: () {},
    child: Text('Bow'),
  ),
)''',
      answers: ['Colors.teal'],
      explanation: const Tr(
        'colorSchemeSeed builds a whole ColorScheme from one color, with '
            'tones chosen to work together. The button\'s primary is a teal '
            'derived from the seed, not exactly Colors.teal.',
        'colorSchemeSeed membangun seluruh ColorScheme dari satu warna, dengan '
            'nada-nada yang dipilih agar serasi. Warna primary pada tombol '
            'adalah teal turunan dari seed tersebut, bukan persis Colors.teal.',
      ),
      docs: 'https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html',
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Theme(
          data: ThemeData(colorSchemeSeed: v[0] as Color),
          child: Center(
            child: FilledButton(onPressed: () {}, child: const Text('Bow')),
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'An article card: a bold title, the author leaning in the theme\'s '
            'color, and a summary that stops after two lines and trails off '
            'softly',
        'Sebuah kartu artikel: judul yang tebal, nama penulis yang condong '
            'dengan warna theme, dan ringkasan yang berhenti setelah dua baris '
            'lalu berakhir dengan titik-titik',
      ),
      code: r'''
final scheme = Theme.of(context).colorScheme;
return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('The Old Pond', style: TextStyle(fontSize: 20, fontWeight: __)),
    Text('Bashō', style: TextStyle(fontStyle: __, color: scheme.primary)),
    Text(summary, maxLines: __, overflow: __),
  ],
);''',
      answers: [
        'FontWeight.bold',
        'FontStyle.italic',
        '2',
        'TextOverflow.ellipsis',
      ],
      capstone: true,
      explanation: const Tr(
        'Each Text gets its own TextStyle for weight and style, and the '
            'author\'s color comes from the theme rather than a fixed value, so '
            'it follows the app\'s seed and dark mode. maxLines with an '
            'ellipsis keeps a long summary from pushing the layout around.',
        'Setiap Text punya TextStyle sendiri untuk ketebalan dan gayanya, dan '
            'warna nama penulis diambil dari theme, bukan nilai tetap, sehingga '
            'ikut mengikuti seed aplikasi dan mode gelap. maxLines dengan '
            'ellipsis mencegah ringkasan yang panjang mengacaukan tata letak.',
      ),
      docs: 'https://api.flutter.dev/flutter/painting/TextStyle-class.html',
      mistakes: const [
        Mistake(
          [null, null, null, 'TextOverflow.clip'],
          Tr(
            'clip cuts the summary off abruptly, with no soft trailing.',
            'clip memotong ringkasan secara tiba-tiba, tanpa akhiran yang '
                'lembut.',
          ),
        ),
        Mistake(
          [null, null, null, 'TextOverflow.fade'],
          Tr(
            'fade lets the last words dissolve, but leaves no trailing dots.',
            'fade membuat kata-kata terakhir memudar, tetapi tidak meninggalkan '
                'titik-titik.',
          ),
        ),
        Mistake(
          ['FontWeight.normal', null, null, null],
          Tr(
            'That is the regular weight every Text starts with; the title '
                'should stand out.',
            'Itu ketebalan biasa yang dimiliki setiap Text sejak awal; judulnya '
                'harus menonjol.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final weight = v[0] as FontWeight;
        final style = v[1] as FontStyle;
        final lines = (v[2] as int?)?.clamp(1, 6);
        final overflow = v[3] as TextOverflow;
        return PreviewCanvas(
          child: Center(
            child: Builder(
              builder: (context) {
                final scheme = Theme.of(context).colorScheme;
                return Container(
                  width: 236,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'The Old Pond',
                        style: TextStyle(fontSize: 20, fontWeight: weight),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bashō',
                        style: TextStyle(
                          fontStyle: style,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _summary,
                        maxLines: lines,
                        overflow: overflow,
                        style: const TextStyle(fontSize: 13, height: 1.35),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    ),
  ],
);

const _summary =
    'A frog leaps into an old pond, and for a moment the silence of the '
    'garden is broken by the sound of water, then the ripples fade and the '
    'stillness returns as if nothing had happened at all';
