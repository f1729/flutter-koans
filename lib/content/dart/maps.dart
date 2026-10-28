import '../../engine/koan.dart';

final maps = Category(
  id: 'maps',
  title: const Tr('Maps', 'Map'),
  intro: const Tr(
    'In a map, every key opens exactly one door.',
    'Di dalam map, setiap key membuka tepat satu pintu.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A key leads straight to its value',
        'Sebuah key langsung mengantar ke nilainya',
      ),
      code: r'''
final ages = {'ratu': 7, 'budi': 9};
expect(ages['ratu'], __);''',
      answers: ['7'],
      verify: () {
        final ages = {'ratu': 7, 'budi': 9};
        return [ages['ratu']];
      },
      explanation: const Tr(
        "map[key] finds a value by hashing the key, so a lookup stays fast in "
            'large maps. Its static type is int?, even when the key happens to '
            'be there.',
        'map[key] menemukan nilai dengan meng-hash key-nya, sehingga pencarian '
            'tetap cepat di map yang besar. Tipe statisnya int?, bahkan ketika '
            'key itu kebetulan ada.',
      ),
      docs: 'https://api.dart.dev/dart-core/Map/operator_get.html',
      mistakes: const [
        Mistake(["'ratu'"], Tr(
          'The key opens the door. What is behind it?',
          'Key membuka pintunya. Apa yang ada di baliknya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A missing key leads to nothing',
        'Key yang tidak ada mengantar ke ketiadaan',
      ),
      code: r'''
final ages = {'ratu': 7, 'budi': 9};
expect(ages['sari'], __);''',
      answers: ['null'],
      verify: () {
        final ages = {'ratu': 7, 'budi': 9};
        return [ages['sari']];
      },
      explanation: const Tr(
        'Looking up a missing key returns null instead of throwing, unlike a '
            "KeyError in Python. That is exactly why a map's [] has a nullable "
            'type.',
        'Mencari key yang tidak ada mengembalikan null alih-alih melempar '
            'error, berbeda dengan KeyError di Python. Justru karena itulah '
            'operator [] pada map punya tipe nullable.',
      ),
      docs: 'https://dart.dev/null-safety/understanding-null-safety#the-map-index-operator-is-nullable',
      mistakes: const [
        Mistake(['0'], Tr(
          'A map does not invent a default value for a key it lacks.',
          'Map tidak mengarang nilai default untuk key yang tidak dimilikinya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Finding nothing is not the same as nothing being there',
        'Tidak menemukan apa-apa tidak sama dengan tidak ada apa-apa',
      ),
      code: r'''
final notes = {'silence': null};
expect(notes['silence'], __);
expect(notes.containsKey('silence'), __);''',
      answers: ['null', 'true'],
      hint: const Tr(
        'Square brackets cannot tell a missing key from a key holding null; '
            'containsKey can.',
        'Kurung siku tidak bisa membedakan key yang tidak ada dengan key yang '
            'bernilai null; containsKey bisa.',
      ),
      verify: () {
        final notes = <String, int?>{'silence': null};
        return [notes['silence'], notes.containsKey('silence')];
      },
      explanation: const Tr(
        'When values may be null, [] cannot tell "absent" from "present but '
            'null"; containsKey can. Most maps avoid the question by never '
            'storing null values.',
        'Ketika nilainya boleh null, [] tidak bisa membedakan "tidak ada" '
            'dengan "ada tetapi null"; containsKey bisa. Kebanyakan map '
            'menghindari pertanyaan ini dengan tidak pernah menyimpan nilai '
            'null.',
      ),
      docs: 'https://api.dart.dev/dart-core/Map/containsKey.html',
      mistakes: const [
        Mistake([null, 'false'], Tr(
          'The key is there, even though its value is null.',
          'Key-nya ada, walaupun nilainya null.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Assigning to a key adds it, or replaces what was there',
        'Mengisi sebuah key berarti menambahkannya, atau mengganti isinya',
      ),
      code: r'''
final scores = {'a': 1};
scores['b'] = 2;
scores['a'] = 3;
expect(scores, __);''',
      answers: ["{'a': 3, 'b': 2}"],
      verify: () {
        final scores = {'a': 1};
        scores['b'] = 2;
        scores['a'] = 3;
        return [scores];
      },
      explanation: const Tr(
        'map[key] = value inserts a new key or overwrites an existing one, '
            'since each key appears only once. Overwriting keeps the key in its '
            'original place in the iteration order.',
        'map[key] = value menyisipkan key baru atau menimpa key yang sudah '
            'ada, karena setiap key hanya muncul sekali. Menimpa tetap menjaga '
            'key itu di tempat asalnya dalam urutan iterasi.',
      ),
      docs: 'https://api.dart.dev/dart-core/Map/operator_put.html',
      mistakes: const [
        Mistake(["{'a': 1, 'b': 2, 'a': 3}"], Tr(
          'A key can appear only once in a map.',
          'Sebuah key hanya boleh muncul sekali di dalam map.',
        )),
        Mistake(["{'a': 1, 'b': 2}"], Tr(
          'The last line assigns to a key that already exists. What happens to '
              'the old value?',
          'Baris terakhir mengisi key yang sudah ada. Apa yang terjadi pada '
              'nilai lamanya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'putIfAbsent only fills an empty place',
        'putIfAbsent hanya mengisi tempat yang kosong',
      ),
      code: r'''
final cache = {'pi': 3};
cache.putIfAbsent('pi', () => 4);
cache.putIfAbsent('e', () => 2);
expect(cache, __);''',
      answers: ["{'pi': 3, 'e': 2}"],
      verify: () {
        final cache = {'pi': 3};
        cache.putIfAbsent('pi', () => 4);
        cache.putIfAbsent('e', () => 2);
        return [cache];
      },
      explanation: const Tr(
        'putIfAbsent calls its function only when the key is missing, and '
            'never overwrites. Because the function is not even run for an '
            'existing key, it is a good fit for caches of expensive values.',
        'putIfAbsent hanya memanggil fungsinya jika key-nya belum ada, dan '
            'tidak pernah menimpa. Karena fungsinya bahkan tidak dijalankan '
            'untuk key yang sudah ada, ia cocok untuk cache nilai yang mahal.',
      ),
      docs: 'https://api.dart.dev/dart-core/Map/putIfAbsent.html',
      mistakes: const [
        Mistake(["{'pi': 4, 'e': 2}"], Tr(
          'Was pi absent when the first putIfAbsent ran?',
          'Apakah pi tidak ada ketika putIfAbsent pertama dijalankan?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'update changes what exists; ifAbsent tends to what does not',
        'update mengubah yang sudah ada; ifAbsent mengurus yang belum ada',
      ),
      code: r'''
final counts = {'zen': 1};
counts.update('zen', (n) => n + 1);
counts.update('koan', (n) => n + 1, ifAbsent: () => 10);
expect(counts, __);''',
      answers: ["{'zen': 2, 'koan': 10}"],
      hint: const Tr(
        'The value from ifAbsent is stored as it is; the update function '
            'does not touch it.',
        'Nilai dari ifAbsent disimpan apa adanya; fungsi update tidak '
            'menyentuhnya.',
      ),
      verify: () {
        final counts = {'zen': 1};
        counts.update('zen', (n) => n + 1);
        counts.update('koan', (n) => n + 1, ifAbsent: () => 10);
        return [counts];
      },
      explanation: const Tr(
        'update transforms the value of an existing key; for a missing key it '
            'stores the result of ifAbsent as it is. Without ifAbsent, updating '
            'a missing key throws an ArgumentError.',
        'update mengubah nilai dari key yang sudah ada; untuk key yang belum '
            'ada, ia menyimpan hasil ifAbsent apa adanya. Tanpa ifAbsent, '
            'meng-update key yang tidak ada akan melempar ArgumentError.',
      ),
      docs: 'https://api.dart.dev/dart-core/Map/update.html',
      mistakes: const [
        Mistake(["{'zen': 2, 'koan': 11}"], Tr(
          'For a missing key, the update function is not called at all.',
          'Untuk key yang belum ada, fungsi update sama sekali tidak '
              'dipanggil.',
        )),
        Mistake(["{'zen': 2}"], Tr(
          'ifAbsent tells update what to store when the key is missing.',
          'ifAbsent memberi tahu update apa yang harus disimpan saat key-nya '
              'tidak ada.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A map can show its keys and its values apart',
        'Map dapat menunjukkan key dan value-nya secara terpisah',
      ),
      code: r'''
final sky = {'sun': 1, 'moon': 2};
expect(sky.keys.toList(), __);
expect(sky.values.toList(), __);''',
      answers: ["['sun', 'moon']", '[1, 2]'],
      verify: () {
        final sky = {'sun': 1, 'moon': 2};
        return [sky.keys.toList(), sky.values.toList()];
      },
      explanation: const Tr(
        'keys and values are lazy iterables that follow the same insertion '
            'order, so the nth key belongs to the nth value. A map literal '
            'creates a LinkedHashMap; it is not sorted.',
        'keys dan values adalah iterable malas yang mengikuti urutan '
            'penyisipan yang sama, jadi key ke-n adalah milik value ke-n. '
            'Literal map membuat LinkedHashMap; ia tidak terurut.',
      ),
      docs: 'https://api.dart.dev/dart-core/Map/keys.html',
      mistakes: const [
        Mistake(["['moon', 'sun']", null], Tr(
          'The default map is not sorted. Which order does it keep?',
          'Map bawaan tidak terurut. Urutan apa yang dijaganya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Each entry pairs a key with its value',
        'Setiap entry memasangkan sebuah key dengan value-nya',
      ),
      code: r'''
final sky = {'sun': 1, 'moon': 2};
final entry = sky.entries.last;
expect(entry.key, __);
expect(entry.value, __);''',
      answers: ["'moon'", '2'],
      verify: () {
        final entry = {'sun': 1, 'moon': 2}.entries.last;
        return [entry.key, entry.value];
      },
      explanation: const Tr(
        'entries yields MapEntry objects in insertion order, handy when we '
            'need key and value together. A pattern can unpack them directly: '
            'for (final MapEntry(:key, :value) in sky.entries).',
        'entries menghasilkan objek MapEntry sesuai urutan penyisipan, berguna '
            'saat kita butuh key dan value bersamaan. Pattern bisa langsung '
            'membongkarnya: for (final MapEntry(:key, :value) in sky.entries).',
      ),
      docs: 'https://api.dart.dev/dart-core/Map/entries.html',
      mistakes: const [
        Mistake(["'sun'", null], Tr(
          'last follows the order in which the entries were added.',
          'last mengikuti urutan saat entry-entry itu ditambahkan.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Removing a key hands back what it held',
        'Menghapus sebuah key mengembalikan apa yang dipegangnya',
      ),
      code: r'''
final m = {'a': 1, 'b': 2};
expect(m.remove('a'), __);
expect(m, __);''',
      answers: ['1', "{'b': 2}"],
      verify: () {
        final m = {'a': 1, 'b': 2};
        final removed = m.remove('a');
        return [removed, m];
      },
      explanation: const Tr(
        'Map.remove returns the value that was stored, or null if the key was '
            'absent, so its type is int?. That differs from List.remove and '
            'Set.remove, which return a bool.',
        'Map.remove mengembalikan nilai yang tadinya tersimpan, atau null jika '
            'key-nya tidak ada, jadi tipenya int?. Ini berbeda dengan '
            'List.remove dan Set.remove, yang mengembalikan bool.',
      ),
      docs: 'https://api.dart.dev/dart-core/Map/remove.html',
      mistakes: const [
        Mistake(['true', null], Tr(
          'List.remove answers with a bool, but Map.remove hands back '
              'something else.',
          'List.remove menjawab dengan bool, tetapi Map.remove mengembalikan '
              'hal lain.',
        )),
        Mistake(["'a'", null], Tr(
          'We already know the key. What did it hold?',
          'Kita sudah tahu key-nya. Apa yang dipegangnya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A map may hold whole lists, gathered one by one',
        'Map bisa menyimpan list utuh, yang dikumpulkan satu per satu',
      ),
      code: r'''
final groups = <String, List<int>>{};
groups.putIfAbsent('odd', () => []).add(1);
groups.putIfAbsent('odd', () => []).add(3);
groups.putIfAbsent('even', () => []).add(2);
expect(groups, __);''',
      answers: ["{'odd': [1, 3], 'even': [2]}"],
      hint: const Tr(
        'putIfAbsent returns the value now stored under the key.',
        'putIfAbsent mengembalikan nilai yang sekarang tersimpan di key '
            'tersebut.',
      ),
      verify: () {
        final groups = <String, List<int>>{};
        groups.putIfAbsent('odd', () => []).add(1);
        groups.putIfAbsent('odd', () => []).add(3);
        groups.putIfAbsent('even', () => []).add(2);
        return [groups];
      },
      explanation: const Tr(
        'putIfAbsent returns the value stored under the key, whether it just '
            'created it or found it already there. That makes create-or-get '
            'plus add a one-line grouping idiom.',
        'putIfAbsent mengembalikan nilai yang tersimpan di key itu, baik yang '
            'baru saja dibuatnya maupun yang sudah ada. Itu membuat pola '
            'buat-atau-ambil lalu add menjadi idiom pengelompokan satu baris.',
      ),
      docs: 'https://api.dart.dev/dart-core/Map/putIfAbsent.html',
      mistakes: const [
        Mistake(["{'odd': [3], 'even': [2]}"], Tr(
          'The second putIfAbsent finds the odd list already there. Does it '
              'replace it?',
          'putIfAbsent yang kedua mendapati list odd sudah ada. Apakah ia '
              'menggantinya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Counting words, each into its own place',
        'Menghitung kata, masing-masing ke tempatnya sendiri',
      ),
      code: r'''
final counts = <String, int>{};
for (final word in 'the cat saw the dog'.split(' ')) {
  counts.update(word, (n) => n + 1, ifAbsent: () => 1);
}
expect(counts['the'], __);
expect(counts['bird'] ?? 0, __);
expect(counts.keys.take(3).toList(), __);
expect(counts.remove('cat'), __);''',
      answers: ['2', '0', "['the', 'cat', 'saw']", '1'],
      capstone: true,
      verify: () {
        final counts = <String, int>{};
        for (final word in _text('the cat saw the dog').split(' ')) {
          counts.update(word, (n) => n + 1, ifAbsent: () => 1);
        }
        return [
          counts['the'],
          counts['bird'] ?? 0,
          counts.keys.take(3).toList(),
          counts.remove('cat'),
        ];
      },
      explanation: const Tr(
        'update with ifAbsent is the classic counting idiom: the first sighting '
            'stores 1 and later ones add to it. A missing key reads as null, '
            'which ?? turns into 0, keys keep first-insertion order, and remove '
            'hands back the count it held.',
        'update dengan ifAbsent adalah idiom klasik untuk menghitung: '
            'kemunculan pertama menyimpan 1 dan kemunculan berikutnya '
            'menambahkannya. Key yang tidak ada terbaca sebagai null, yang '
            'diubah ?? menjadi 0, keys menjaga urutan penyisipan pertama, dan '
            'remove mengembalikan hitungan yang dipegangnya.',
      ),
      docs: 'https://api.dart.dev/dart-core/Map-class.html',
      mistakes: const [
        Mistake(['1', null, null, null], Tr(
          'The second "the" finds its key already present.',
          'Kata "the" yang kedua mendapati key-nya sudah ada.',
        )),
        Mistake([null, 'null', null, null], Tr(
          '?? supplies a value whenever the lookup gives null.',
          '?? menyediakan nilai setiap kali pencarian menghasilkan null.',
        )),
        Mistake([null, null, null, 'true'], Tr(
          'Map.remove hands back what was stored, not a bool.',
          'Map.remove mengembalikan apa yang tadinya tersimpan, bukan bool.',
        )),
      ],
    ),
  ],
);

// Built at runtime so the analyzer does not fold it into a constant.
String _text(String value) => value;
