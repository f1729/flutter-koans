import '../../engine/koan.dart';

final sets = Category(
  id: 'sets',
  title: const Tr('Sets', 'Set'),
  intro: const Tr(
    'A set holds each value only once.',
    'Set hanya menyimpan setiap nilai satu kali.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'An echo adds nothing new',
        'Gema tidak menambahkan sesuatu yang baru',
      ),
      code: 'expect({1, 2, 2, 3}.length, __);',
      answers: ['3'],
      verify: () => [_set([1, 2, 2, 3]).length],
      explanation: const Tr(
        'A set stores each distinct value once, so the repeated 2 adds '
            'nothing and the analyzer even flags it. Sets are the natural tool '
            'for removing duplicates.',
        'Set menyimpan setiap nilai yang berbeda satu kali saja, jadi angka 2 '
            'yang berulang tidak menambahkan apa-apa, dan analyzer bahkan '
            'menandainya. Set adalah alat yang wajar untuk membuang duplikat.',
      ),
      docs: 'https://dart.dev/language/collections#sets',
      mistakes: const [
        Mistake(['4'], Tr(
          'The second 2 is only an echo. Does a set keep it?',
          'Angka 2 yang kedua hanyalah gema. Apakah set menyimpannya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A set knows at once whether it holds something',
        'Set langsung tahu apakah ia menyimpan sesuatu',
      ),
      code: "expect({'lotus', 'bamboo'}.contains('pine'), __);",
      answers: ['false'],
      verify: () => [_set(['lotus', 'bamboo']).contains('pine')],
      explanation: const Tr(
        'Set.contains is a hash lookup that takes about the same time however '
            'large the set is, while List.contains scans every element. When '
            'membership is the main question, a set is the right shape.',
        'Set.contains adalah pencarian hash yang memakan waktu kurang lebih '
            'sama sebesar apa pun set-nya, sedangkan List.contains memindai '
            'setiap elemen. Jika pertanyaan utamanya adalah keanggotaan, set '
            'adalah bentuk yang tepat.',
      ),
      docs: 'https://api.dart.dev/dart-core/Set-class.html',
    ),
    Koan(
      prompt: const Tr(
        'Adding tells us whether something new arrived',
        'Menambahkan memberi tahu kita apakah ada sesuatu yang baru tiba',
      ),
      code: r'''
final seen = {'lotus'};
expect(seen.add('lotus'), __);
expect(seen.add('bamboo'), __);''',
      answers: ['false', 'true'],
      verify: () {
        final seen = {'lotus'};
        return [seen.add('lotus'), seen.add('bamboo')];
      },
      explanation: const Tr(
        'Set.add returns true only when the value was not there before. That '
            'lets us check "is this the first time?" and record it in one '
            'step, without a separate contains.',
        'Set.add mengembalikan true hanya jika nilai itu belum ada sebelumnya. '
            'Dengan begitu kita bisa memeriksa "apakah ini pertama kali?" '
            'sekaligus mencatatnya dalam satu langkah, tanpa contains '
            'tersendiri.',
      ),
      docs: 'https://api.dart.dev/dart-core/Set/add.html',
      mistakes: const [
        Mistake(['true', null], Tr(
          'add reports whether the set changed. Was lotus new?',
          'add melaporkan apakah set-nya berubah. Apakah lotus itu baru?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A list becomes a set, and its echoes fade',
        'List menjadi set, dan gema-gemanya memudar',
      ),
      code: 'expect([1, 1, 2, 3, 3].toSet(), __);',
      answers: ['{1, 2, 3}'],
      verify: () => [_list([1, 1, 2, 3, 3]).toSet()],
      explanation: const Tr(
        'toSet keeps the first occurrence of each value, in the order they '
            'appeared. list.toSet().toList() is the everyday way to remove '
            'duplicates while keeping order.',
        'toSet menyimpan kemunculan pertama dari setiap nilai, sesuai urutan '
            'kemunculannya. list.toSet().toList() adalah cara sehari-hari untuk '
            'membuang duplikat sambil menjaga urutan.',
      ),
      docs: 'https://api.dart.dev/dart-core/Iterable/toSet.html',
      mistakes: const [
        Mistake(['[1, 2, 3]'], Tr(
          'The echoes are gone, but what kind of collection did toSet return?',
          'Gemanya sudah hilang, tetapi koleksi jenis apa yang dikembalikan '
              'toSet?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A union gathers everything from both',
        'Union mengumpulkan semuanya dari keduanya',
      ),
      code: 'expect({1, 2}.union({2, 3}), __);',
      answers: ['{1, 2, 3}'],
      verify: () => [_set([1, 2]).union({2, 3})],
      explanation: const Tr(
        'union returns a new set with every element of both, and the shared 2 '
            'still appears once. A set literal with two spreads, {...a, ...b}, '
            'says the same thing.',
        'union mengembalikan set baru berisi setiap elemen dari keduanya, dan '
            'angka 2 yang dimiliki bersama tetap muncul sekali. Literal set '
            'dengan dua spread, {...a, ...b}, menyatakan hal yang sama.',
      ),
      docs: 'https://api.dart.dev/dart-core/Set/union.html',
      mistakes: const [
        Mistake(['{1, 2, 2, 3}'], Tr(
          'Even after a union, a set holds each value only once.',
          'Bahkan setelah union, set tetap menyimpan setiap nilai sekali saja.',
        )),
        Mistake(['{2}'], Tr(
          'That is only what they share. union gathers more.',
          'Itu hanya yang dimiliki bersama. union mengumpulkan lebih banyak.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'What two sets hold in common',
        'Apa yang dimiliki bersama oleh dua set',
      ),
      code: 'expect({1, 2, 3}.__({2, 3, 4}), {2, 3});',
      answers: ['intersection'],
      explanation: const Tr(
        'intersection returns a new set with only the elements found in both. '
            'Together with union and difference it gives sets their algebra, '
            'useful for comparing permissions, tags or selections.',
        'intersection mengembalikan set baru yang hanya berisi elemen yang ada '
            'di keduanya. Bersama union dan difference, ia memberi set '
            'aljabarnya, berguna untuk membandingkan izin, tag, atau pilihan.',
      ),
      docs: 'https://api.dart.dev/dart-core/Set/intersection.html',
      mistakes: const [
        Mistake(['union'], Tr(
          'union gathers everything, including 1 and 4.',
          'union mengumpulkan semuanya, termasuk 1 dan 4.',
        )),
        Mistake(['difference'], Tr(
          'difference keeps what the other set lacks, which would be {1}.',
          'difference menyisakan apa yang tidak dimiliki set lain, yaitu {1}.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Difference keeps what the other lacks',
        'Difference menyisakan apa yang tidak dimiliki yang lain',
      ),
      code: 'expect({1, 2, 3}.difference({2}), __);',
      answers: ['{1, 3}'],
      verify: () => [_set([1, 2, 3]).difference({2})],
      explanation: const Tr(
        'a.difference(b) keeps the elements of a that b lacks, like a minus b. '
            'It is not symmetric: {2}.difference({1, 2, 3}) would be empty.',
        'a.difference(b) menyisakan elemen a yang tidak dimiliki b, seperti a '
            'dikurangi b. Ia tidak simetris: {2}.difference({1, 2, 3}) akan '
            'kosong.',
      ),
      docs: 'https://api.dart.dev/dart-core/Set/difference.html',
      mistakes: const [
        Mistake(['{2}'], Tr(
          'That is what the two have in common, the very part difference takes '
              'away.',
          'Itu yang dimiliki keduanya, justru bagian yang dibuang oleh '
              'difference.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Yet a Dart set remembers the order of arrival',
        'Namun set di Dart mengingat urutan kedatangan',
      ),
      code: 'expect({3, 1, 2}.first, __);',
      answers: ['3'],
      hint: const Tr(
        'The default Set in Dart is a LinkedHashSet.',
        'Set bawaan Dart adalah LinkedHashSet.',
      ),
      verify: () => [_set([3, 1, 2]).first],
      explanation: const Tr(
        'A set literal creates a LinkedHashSet, which iterates in insertion '
            'order. A HashSet promises no order at all, and a SplayTreeSet '
            'keeps its elements sorted.',
        'Literal set membuat LinkedHashSet, yang beriterasi sesuai urutan '
            'penyisipan. HashSet sama sekali tidak menjanjikan urutan, dan '
            'SplayTreeSet menjaga elemennya tetap terurut.',
      ),
      docs: 'https://api.dart.dev/dart-collection/LinkedHashSet-class.html',
      mistakes: const [
        Mistake(['1'], Tr(
          'The default set is not sorted. What order does it remember?',
          'Set bawaan tidak terurut. Urutan apa yang diingatnya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'To a set, two lists that look alike are still two',
        'Bagi set, dua list yang tampak sama tetaplah dua',
      ),
      code: 'expect({[1], [1]}.length, __);',
      answers: ['2'],
      hint: const Tr(
        'A set decides sameness with ==. Recall how lists answer ==.',
        'Set menentukan kesamaan dengan ==. Ingat bagaimana list menjawab ==.',
      ),
      verify: () => [_set([_one(), _one()]).length],
      explanation: const Tr(
        'A set finds duplicates with == and hashCode, and lists inherit both '
            'from Object, which means identity. For values that compare by '
            'content, use records such as (1, 2) or a class that overrides == '
            'and hashCode.',
        'Set menemukan duplikat dengan == dan hashCode, dan list mewarisi '
            'keduanya dari Object, yang berarti identitas. Untuk nilai yang '
            'dibandingkan berdasarkan isinya, gunakan record seperti (1, 2) '
            'atau kelas yang meng-override == dan hashCode.',
      ),
      docs: 'https://api.dart.dev/dart-core/Object/hashCode.html',
      mistakes: const [
        Mistake(['1'], Tr(
          'The two lists look alike, but do they compare equal with ==?',
          'Kedua list itu tampak sama, tetapi apakah keduanya setara menurut ==?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Who came twice, and who came only once',
        'Siapa yang datang dua kali, dan siapa yang datang sekali saja',
      ),
      code: r'''
final morning = {'ratu', 'budi', 'sari'};
final evening = <String>{};
var repeats = 0;
for (final name in ['budi', 'dewi', 'budi']) {
  if (!evening.add(name)) repeats++;
}
expect(morning.intersection(evening), __);
expect(evening.difference(morning), __);
expect(repeats, __);''',
      answers: ["{'budi'}", "{'dewi'}", '1'],
      capstone: true,
      verify: () {
        final morning = _set(['ratu', 'budi', 'sari']);
        final evening = <String>{};
        var repeats = 0;
        for (final name in ['budi', 'dewi', 'budi']) {
          if (!evening.add(name)) repeats++;
        }
        return [
          morning.intersection(evening),
          evening.difference(morning),
          repeats,
        ];
      },
      explanation: const Tr(
        'The bool from add counts the repeat visit without a separate '
            'contains, and the set quietly keeps budi once. intersection and '
            'difference then answer "who came to both?" and "who came only in '
            'the evening?" in one call each.',
        'Nilai bool dari add menghitung kunjungan berulang tanpa contains '
            'tersendiri, dan set diam-diam menyimpan budi sekali saja. '
            'intersection dan difference lalu menjawab "siapa yang datang ke '
            'keduanya?" dan "siapa yang hanya datang sore hari?" masing-masing '
            'dalam satu pemanggilan.',
      ),
      docs: 'https://api.dart.dev/dart-core/Set-class.html',
      mistakes: const [
        Mistake([null, "{'ratu', 'sari'}", null], Tr(
          'difference is not symmetric. Whose elements does it keep?',
          'difference tidak simetris. Elemen milik siapa yang disisakannya?',
        )),
        Mistake([null, null, '0'], Tr(
          'Look at what add returns the second time it sees budi.',
          'Perhatikan apa yang dikembalikan add saat kedua kalinya melihat '
              'budi.',
        )),
        Mistake([null, null, '2'], Tr(
          'The first budi is a newcomer, not a repeat.',
          'budi yang pertama adalah pendatang baru, bukan kunjungan ulang.',
        )),
      ],
    ),
  ],
);

// Built at runtime so the analyzer does not fold them into constants.
Set<T> _set<T>(List<T> values) => values.toSet();
List<int> _list(List<int> values) => [...values];
List<int> _one() => [1];
