import '../../engine/koan.dart';

final iterables = Category(
  id: 'iterables',
  title: const Tr('Iterables', 'Iterable'),
  intro: const Tr(
    'An iterable is a promise of values, kept only when asked.',
    'Iterable adalah janji akan nilai-nilai, yang ditepati hanya saat '
        'diminta.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'Each element can be transformed into another',
        'Setiap elemen bisa diubah menjadi elemen lain',
      ),
      code: 'expect([1, 2, 3].__((x) => x * 2).toList(), [2, 4, 6]);',
      answers: ['map'],
      explanation: const Tr(
        'map transforms every element with a function and returns a lazy '
            'Iterable, not a List, which is why toList() follows. The result '
            'may even hold a different type, such as strings made from numbers.',
        'map mengubah setiap elemen dengan sebuah fungsi dan mengembalikan '
            'Iterable yang malas, bukan List, itulah sebabnya diikuti toList(). '
            'Hasilnya bahkan boleh bertipe lain, misalnya string yang dibuat '
            'dari angka.',
      ),
      docs: 'https://api.dart.dev/dart-core/Iterable/map.html',
      mistakes: const [
        Mistake(['where'], Tr(
          'where keeps or drops elements; it never changes them.',
          'where menyimpan atau membuang elemen; ia tidak pernah mengubahnya.',
        )),
        Mistake(['forEach'], Tr(
          'forEach returns void, so there would be nothing to call toList on.',
          'forEach mengembalikan void, jadi tidak ada yang bisa dipanggil '
              'toList.',
        )),
        Mistake(['expand'], Tr(
          'expand expects each element to become a whole iterable.',
          'expand mengharapkan setiap elemen menjadi satu iterable utuh.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Keep only what passes the test',
        'Simpan hanya yang lolos ujian',
      ),
      code: 'expect([1, 2, 3, 4].where((x) => x.isOdd).toList(), __);',
      answers: ['[1, 3]'],
      verify: () => [
        [1, 2, 3, 4].where((x) => x.isOdd).toList(),
      ],
      explanation: const Tr(
        'where keeps the elements for which the test returns true, lazily and '
            'in their original order. To filter by type instead, whereType<T>() '
            'also gives the result the narrower type.',
        'where menyimpan elemen yang membuat ujiannya mengembalikan true, '
            'secara malas dan dengan urutan aslinya. Untuk menyaring '
            'berdasarkan tipe, whereType<T>() juga memberi hasilnya tipe yang '
            'lebih sempit.',
      ),
      docs: 'https://api.dart.dev/dart-core/Iterable/where.html',
    ),
    Koan(
      prompt: const Tr(
        'fold carries one value through every element',
        'fold membawa satu nilai melewati setiap elemen',
      ),
      code: 'expect([1, 2, 3].fold(10, (sum, x) => sum + x), __);',
      answers: ['16'],
      hint: const Tr(
        'Notice where the journey starts.',
        'Perhatikan dari mana perjalanan dimulai.',
      ),
      verify: () {
        final total = [1, 2, 3].fold(10, (sum, x) => sum + x);
        return [total];
      },
      explanation: const Tr(
        'fold starts from the initial value we give it and combines it with '
            'each element in turn. Unlike reduce, it works on an empty '
            'iterable, and its result may have a different type than the '
            'elements.',
        'fold dimulai dari nilai awal yang kita berikan lalu menggabungkannya '
            'dengan setiap elemen secara bergiliran. Berbeda dengan reduce, ia '
            'tetap bekerja pada iterable kosong, dan hasilnya boleh bertipe '
            'lain dari elemennya.',
      ),
      docs: 'https://api.dart.dev/dart-core/Iterable/fold.html',
      mistakes: const [
        Mistake(['6'], Tr(
          'The journey does not start at zero. Look at the first argument.',
          'Perjalanannya tidak dimulai dari nol. Perhatikan argumen pertama.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'reduce lets the elements meet, two by two',
        'reduce mempertemukan elemen-elemen, dua demi dua',
      ),
      code: 'expect([3, 7, 2].reduce((a, b) => a > b ? a : b), __);',
      answers: ['7'],
      verify: () => [
        [3, 7, 2].reduce((a, b) => a > b ? a : b),
      ],
      explanation: const Tr(
        'reduce starts from the first element and combines it with each next '
            'one, so this function carries the larger value along. It throws '
            'a StateError on an empty iterable; dart:math max does the same job '
            'for two numbers.',
        'reduce dimulai dari elemen pertama lalu menggabungkannya dengan '
            'setiap elemen berikutnya, jadi fungsi ini membawa nilai yang lebih '
            'besar. Ia melempar StateError pada iterable kosong; max dari '
            'dart:math melakukan hal yang sama untuk dua angka.',
      ),
      docs: 'https://api.dart.dev/dart-core/Iterable/reduce.html',
      mistakes: const [
        Mistake(['12'], Tr(
          'reduce does not add unless we tell it to. What does this function '
              'keep?',
          'reduce tidak menjumlahkan kecuali kita memintanya. Apa yang '
              'disimpan oleh fungsi ini?',
        )),
        Mistake(['2'], Tr(
          'The answer is not simply the last element. Follow the larger one '
              'through each step.',
          'Jawabannya bukan sekadar elemen terakhir. Ikuti nilai yang lebih '
              'besar di setiap langkah.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Is there one? Are they all?',
        'Adakah satu? Apakah semuanya?',
      ),
      code: r'''
final odds = [1, 3, 5];
expect(odds.any((x) => x.isEven), __);
expect(odds.every((x) => x.isOdd), __);''',
      answers: ['false', 'true'],
      verify: () {
        final odds = [1, 3, 5];
        return [odds.any((x) => x.isEven), odds.every((x) => x.isOdd)];
      },
      explanation: const Tr(
        'any stops at the first element that passes, and every stops at the '
            'first that fails. On an empty iterable, any is false and every is '
            'true, since no element breaks the rule.',
        'any berhenti pada elemen pertama yang lolos, dan every berhenti pada '
            'elemen pertama yang gagal. Pada iterable kosong, any bernilai '
            'false dan every bernilai true, karena tidak ada elemen yang '
            'melanggar aturannya.',
      ),
      docs: 'https://dart.dev/libraries/collections/iterables#checking-conditions',
    ),
    Koan(
      prompt: const Tr(
        'Skip a little, take a little',
        'Lewati sedikit, ambil sedikit',
      ),
      code: 'expect([1, 2, 3, 4, 5].skip(1).take(2).toList(), __);',
      answers: ['[2, 3]'],
      verify: () => [
        [1, 2, 3, 4, 5].skip(1).take(2).toList(),
      ],
      explanation: const Tr(
        'skip(n) drops the first n elements and take(n) keeps at most n, both '
            'lazily and in order. Together they make a simple pager: '
            'skip(page * size).take(size).',
        'skip(n) membuang n elemen pertama dan take(n) menyimpan paling banyak '
            'n, keduanya secara malas dan berurutan. Bersama-sama keduanya '
            'membentuk pager sederhana: skip(page * size).take(size).',
      ),
      docs: 'https://api.dart.dev/dart-core/Iterable/skip.html',
      mistakes: const [
        Mistake(['[1, 2]'], Tr(
          'skip runs first, so the first element is already gone.',
          'skip berjalan lebih dulu, jadi elemen pertama sudah hilang.',
        )),
        Mistake(['[3, 4]'], Tr(
          'skip(1) drops only one element.',
          'skip(1) hanya membuang satu elemen.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'One element can become many',
        'Satu elemen bisa menjadi banyak',
      ),
      code: 'expect([1, 2].expand((x) => [x, x * 10]).toList(), __);',
      answers: ['[1, 10, 2, 20]'],
      verify: () => [
        [1, 2].expand((x) => [x, x * 10]).toList(),
      ],
      explanation: const Tr(
        'expand turns each element into an iterable and flattens the results '
            'into one sequence, what other languages call flatMap.',
        'expand mengubah setiap elemen menjadi iterable lalu meratakan '
            'hasilnya menjadi satu urutan, yang di bahasa lain disebut flatMap.',
      ),
      docs: 'https://api.dart.dev/dart-core/Iterable/expand.html',
      mistakes: const [
        Mistake(['[[1, 10], [2, 20]]'], Tr(
          'That is what map would give. expand flattens what the function '
              'returns.',
          'Itu hasil dari map. expand meratakan apa yang dikembalikan fungsinya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Seek the first that fits, and know what to do if none does',
        'Carilah yang pertama cocok, dan ketahui apa yang harus dilakukan '
            'jika tidak ada',
      ),
      code: r'''
final xs = [1, 2, 3];
expect(xs.firstWhere((x) => x > 1), __);
expect(xs.firstWhere((x) => x > 5, orElse: () => -1), __);''',
      answers: ['2', '-1'],
      verify: () {
        final xs = [1, 2, 3];
        return [
          xs.firstWhere((x) => x > 1),
          xs.firstWhere((x) => x > 5, orElse: () => -1),
        ];
      },
      explanation: const Tr(
        'firstWhere returns the first element that passes the test. With no '
            'match it throws a StateError, unless orElse supplies a value; '
            'where(test).firstOrNull is the nullable alternative.',
        'firstWhere mengembalikan elemen pertama yang lolos ujian. Jika tidak '
            'ada yang cocok, ia melempar StateError, kecuali orElse menyediakan '
            'sebuah nilai; where(test).firstOrNull adalah alternatif yang '
            'nullable.',
      ),
      docs: 'https://api.dart.dev/dart-core/Iterable/firstWhere.html',
      mistakes: const [
        Mistake(['3', null], Tr(
          'Elements are checked in order. Which is the first to pass?',
          'Elemen diperiksa secara berurutan. Mana yang pertama lolos?',
        )),
        Mistake([null, 'null'], Tr(
          'firstWhere does not give back null on its own. Who decides here?',
          'firstWhere tidak mengembalikan null dengan sendirinya. Siapa yang '
              'menentukan di sini?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'An iterable does nothing until it is asked',
        'Iterable tidak melakukan apa-apa sampai diminta',
      ),
      code: r'''
var calls = 0;
final doubled = [1, 2, 3].map((x) {
  calls++;
  return x * 2;
});
expect(calls, __);
doubled.toList();
expect(calls, __);''',
      answers: ['0', '3'],
      hint: const Tr(
        'map only describes the work; toList does it.',
        'map hanya menggambarkan pekerjaannya; toList yang mengerjakannya.',
      ),
      verify: () {
        var calls = 0;
        final doubled = [1, 2, 3].map((x) {
          calls++;
          return x * 2;
        });
        final before = calls;
        doubled.toList();
        return [before, calls];
      },
      explanation: const Tr(
        'map only describes the work; the function runs when something '
            'iterates, such as toList or a for loop. That is why side effects '
            'inside map are a trap.',
        'map hanya menggambarkan pekerjaannya; fungsinya baru berjalan ketika '
            'ada yang beriterasi, seperti toList atau loop for. Karena itulah '
            'efek samping di dalam map adalah jebakan.',
      ),
      docs: 'https://api.dart.dev/dart-core/Iterable/map.html',
      mistakes: const [
        Mistake(['3', null], Tr(
          'Creating doubled does not run the function yet.',
          'Membuat doubled belum menjalankan fungsinya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'And it does not remember what it was asked before',
        'Dan ia tidak mengingat apa yang pernah ditanyakan sebelumnya',
      ),
      code: r'''
var calls = 0;
final doubled = [1, 2, 3].map((x) {
  calls++;
  return x * 2;
});
expect(doubled.first, 2);
expect(doubled.first, 2);
expect(calls, __);''',
      answers: ['2'],
      hint: const Tr(
        'first needs only one element, and it computes that element anew '
            'each time.',
        'first hanya butuh satu elemen, dan elemen itu dihitung ulang setiap '
            'kali.',
      ),
      verify: () {
        var calls = 0;
        final doubled = [1, 2, 3].map((x) {
          calls++;
          return x * 2;
        });
        final a = doubled.first;
        final b = doubled.first;
        return [a == 2 && b == 2 ? calls : -1];
      },
      explanation: const Tr(
        'A lazy iterable recomputes its elements every time it is iterated, '
            'and first needs only the first one. When results are read more '
            'than once, call toList() once and reuse the list.',
        'Iterable yang malas menghitung ulang elemennya setiap kali '
            'diiterasi, dan first hanya butuh elemen pertama. Jika hasilnya '
            'dibaca lebih dari sekali, panggil toList() sekali lalu pakai '
            'ulang list-nya.',
      ),
      docs: 'https://api.dart.dev/dart-core/Iterable-class.html',
      mistakes: const [
        Mistake(['6'], Tr(
          'first does not need the whole list.',
          'first tidak membutuhkan seluruh list.',
        )),
        Mistake(['1'], Tr(
          'Nothing is cached between the two reads.',
          'Tidak ada yang disimpan di antara kedua pembacaan itu.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Many questions asked of the same few words',
        'Banyak pertanyaan diajukan kepada beberapa kata yang sama',
      ),
      code: r'''
final words = ['zen', 'Koan', 'calm', 'Breath', 'sea'];
final capitals = words.where((w) => w[0] == w[0].toUpperCase());
final letters = words.map((w) => w.length).fold(0, (a, b) => a + b);
expect(capitals.toList(), __);
expect(letters, __);
expect(words.skip(1).take(2).every((w) => w.length == 4), __);
expect(words.firstWhere((w) => w.length > 6, orElse: () => 'none'), __);''',
      answers: ["['Koan', 'Breath']", '20', 'true', "'none'"],
      capstone: true,
      verify: () {
        final words = [_text('zen'), 'Koan', 'calm', 'Breath', 'sea'];
        final capitals = words.where((w) => w[0] == w[0].toUpperCase());
        final letters = words.map((w) => w.length).fold(0, (a, b) => a + b);
        return [
          capitals.toList(),
          letters,
          words.skip(1).take(2).every((w) => w.length == 4),
          words.firstWhere((w) => w.length > 6, orElse: () => 'none'),
        ];
      },
      explanation: const Tr(
        'Each question is a short chain: where filters, map then fold turns '
            'words into a total, skip and take pick a window that every checks, '
            'and orElse answers when firstWhere finds nothing. None of them '
            'changes words itself.',
        'Setiap pertanyaan adalah rantai pendek: where menyaring, map lalu fold '
            'mengubah kata-kata menjadi total, skip dan take memilih jendela '
            'yang diperiksa every, dan orElse menjawab ketika firstWhere tidak '
            'menemukan apa-apa. Tidak satu pun dari mereka mengubah words.',
      ),
      docs: 'https://dart.dev/libraries/collections/iterables',
      mistakes: const [
        Mistake([null, '5', null, null], Tr(
          'fold adds up the lengths; it does not count the words.',
          'fold menjumlahkan panjangnya; ia tidak menghitung jumlah kata.',
        )),
        Mistake([null, null, 'false', null], Tr(
          'After skip(1), which two words does take(2) keep?',
          'Setelah skip(1), dua kata mana yang disimpan take(2)?',
        )),
        Mistake([null, null, null, "'Breath'"], Tr(
          'Count the letters of the longest word again, and note that > is '
              'strict.',
          'Hitung lagi huruf dari kata terpanjang, dan ingat bahwa > itu '
              'ketat.',
        )),
      ],
    ),
  ],
);

// Built at runtime so the analyzer does not fold it into a constant.
String _text(String value) => value;
