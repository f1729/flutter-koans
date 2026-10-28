import '../../engine/koan.dart';

final lists = Category(
  id: 'lists',
  title: const Tr('Lists', 'List'),
  intro: const Tr(
    'A list is an ordered row of values, each in its place.',
    'List adalah deretan nilai yang berurutan, masing-masing di tempatnya.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A list remembers order, and counting starts at zero',
        'List mengingat urutan, dan hitungan dimulai dari nol',
      ),
      code: r'''
final fruits = ['apple', 'banana', 'cherry'];
expect(fruits[1], __);
expect(fruits.length, __);''',
      answers: ["'banana'", '3'],
      verify: () {
        final fruits = ['apple', 'banana', 'cherry'];
        return [fruits[1], fruits.length];
      },
      explanation: const Tr(
        'List indexes start at 0, so valid indexes run from 0 to length - 1, '
            'and anything outside that range throws a RangeError rather than '
            'returning null.',
        'Indeks list dimulai dari 0, jadi indeks yang sah adalah 0 sampai '
            'length - 1, dan indeks di luar rentang itu melempar RangeError, '
            'bukan mengembalikan null.',
      ),
      docs: 'https://api.dart.dev/dart-core/List-class.html',
      mistakes: const [
        Mistake(["'apple'", null], Tr(
          'Index 1 is not the first place. Where does counting start?',
          'Indeks 1 bukan tempat pertama. Dari mana hitungan dimulai?',
        )),
        Mistake([null, '2'], Tr(
          'length counts the elements; it is not the last index.',
          'length menghitung jumlah elemen; ia bukan indeks terakhir.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A growable list welcomes newcomers at either end',
        'List yang bisa tumbuh menyambut pendatang baru di ujung mana pun',
      ),
      code: r'''
final xs = [1, 2];
xs.add(3);
xs.insert(0, 0);
expect(xs, __);''',
      answers: ['[0, 1, 2, 3]'],
      verify: () {
        final xs = [1, 2];
        xs.add(3);
        xs.insert(0, 0);
        return [xs];
      },
      explanation: const Tr(
        'add appends at the end, while insert(index, value) shifts every later '
            'element one place to the right. Inserting at the front has to move '
            'the whole list, so add is the cheaper habit.',
        'add menambahkan di akhir, sedangkan insert(index, value) menggeser '
            'setiap elemen sesudahnya satu tempat ke kanan. Menyisipkan di '
            'depan harus memindahkan seluruh list, jadi add adalah kebiasaan '
            'yang lebih murah.',
      ),
      docs: 'https://api.dart.dev/dart-core/List/insert.html',
      mistakes: const [
        Mistake(['[1, 2, 3, 0]'], Tr(
          'insert places the value at the index it is given, not at the end.',
          'insert menaruh nilai di indeks yang diberikan, bukan di akhir.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'When two are alike, only one leaves',
        'Saat ada dua yang serupa, hanya satu yang pergi',
      ),
      code: r'''
final xs = ['a', 'b', 'c', 'b'];
xs.remove('b');
expect(xs, __);''',
      answers: ["['a', 'c', 'b']"],
      hint: const Tr(
        'remove searches from the front.',
        'remove mencari dari depan.',
      ),
      verify: () {
        final xs = ['a', 'b', 'c', 'b'];
        xs.remove('b');
        return [xs];
      },
      explanation: const Tr(
        'remove deletes only the first element equal to its argument and '
            'returns a bool saying whether it found one. To remove every match, '
            "use removeWhere((x) => x == 'b').",
        'remove hanya menghapus elemen pertama yang setara dengan argumennya '
            'dan mengembalikan bool yang menyatakan apakah ia menemukannya. '
            "Untuk menghapus semua yang cocok, gunakan removeWhere((x) => x == 'b').",
      ),
      docs: 'https://api.dart.dev/dart-core/List/remove.html',
      mistakes: const [
        Mistake(["['a', 'c']"], Tr(
          'remove stops after the first match it finds.',
          'remove berhenti setelah kecocokan pertama yang ditemukannya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Every list has a beginning and an end',
        'Setiap list punya awal dan akhir',
      ),
      code: r'''
final xs = [3, 1, 4];
expect(xs.first, __);
expect(xs.last, __);''',
      answers: ['3', '4'],
      verify: () {
        final xs = [3, 1, 4];
        return [xs.first, xs.last];
      },
      explanation: const Tr(
        'first and last are getters for xs[0] and xs[xs.length - 1], about '
            'position, not size. On an empty list they throw a StateError; '
            'firstOrNull and lastOrNull return null instead.',
        'first dan last adalah getter untuk xs[0] dan xs[xs.length - 1], '
            'tentang posisi, bukan ukuran. Pada list kosong keduanya melempar '
            'StateError; firstOrNull dan lastOrNull mengembalikan null sebagai '
            'gantinya.',
      ),
      docs: 'https://api.dart.dev/dart-core/List/first.html',
      mistakes: const [
        Mistake(['1', null], Tr(
          'first is about position in the list, not about the smallest value.',
          'first berkaitan dengan posisi di dalam list, bukan nilai terkecil.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Seeking what is absent brings back a quiet answer',
        'Mencari yang tidak ada membawa pulang jawaban yang tenang',
      ),
      code: r'''
final xs = ['a', 'b', 'c'];
expect(xs.contains('b'), __);
expect(xs.indexOf('z'), __);''',
      answers: ['true', '-1'],
      hint: const Tr(
        'indexOf always returns an int, never null.',
        'indexOf selalu mengembalikan int, tidak pernah null.',
      ),
      verify: () {
        final xs = ['a', 'b', 'c'];
        return [xs.contains('b'), xs.indexOf('z')];
      },
      explanation: const Tr(
        'indexOf returns -1 when nothing matches, a convention as old as C, '
            'so its type stays a plain int. When we only need a yes or no, '
            'contains says it more clearly.',
        'indexOf mengembalikan -1 jika tidak ada yang cocok, sebuah konvensi '
            'setua bahasa C, sehingga tipenya tetap int biasa. Jika kita hanya '
            'butuh jawaban ya atau tidak, contains menyatakannya dengan lebih '
            'jelas.',
      ),
      docs: 'https://api.dart.dev/dart-core/List/indexOf.html',
      mistakes: const [
        Mistake([null, 'null'], Tr(
          'indexOf is declared to return an int, so null is not an option.',
          'indexOf dideklarasikan mengembalikan int, jadi null bukan pilihan.',
        )),
        Mistake([null, '0'], Tr(
          '0 is a real index: the first element. How do we say "nowhere"?',
          '0 adalah indeks yang sah: elemen pertama. Bagaimana kita menyatakan '
              '"tidak di mana pun"?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A part can be taken while the whole stays intact',
        'Sebagian bisa diambil, sementara keseluruhannya tetap utuh',
      ),
      code: 'expect([0, 1, 2, 3, 4].sublist(1, 3), __);',
      answers: ['[1, 2]'],
      verify: () => [_list([0, 1, 2, 3, 4]).sublist(1, 3)],
      explanation: const Tr(
        'sublist(start, end) copies the elements from start up to, but not '
            'including, end into a new list, exactly like substring. The '
            'original list is not touched.',
        'sublist(start, end) menyalin elemen dari start sampai sebelum end ke '
            'dalam list baru, persis seperti substring. List aslinya tidak '
            'disentuh.',
      ),
      docs: 'https://api.dart.dev/dart-core/List/sublist.html',
      mistakes: const [
        Mistake(['[1, 2, 3]'], Tr(
          'The element at the end index is not included.',
          'Elemen pada indeks end tidak ikut diambil.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'sort rearranges the list itself, by the rule we give it',
        'sort menata ulang list itu sendiri, menurut aturan yang kita berikan',
      ),
      code: r'''
final xs = [3, 1, 2];
xs.sort((a, b) => b.compareTo(a));
expect(xs, __);''',
      answers: ['[3, 2, 1]'],
      hint: const Tr(
        'A negative result places a before b.',
        'Hasil negatif menempatkan a sebelum b.',
      ),
      verify: () {
        final xs = [3, 1, 2];
        xs.sort((a, b) => b.compareTo(a));
        return [xs];
      },
      explanation: const Tr(
        'sort works in place and returns void. The comparator returns a '
            'negative number when a should come first, so b.compareTo(a) '
            'reverses the natural ascending order.',
        'sort bekerja langsung pada list itu dan mengembalikan void. '
            'Comparator mengembalikan angka negatif jika a harus didahulukan, '
            'jadi b.compareTo(a) membalik urutan naik yang alami.',
      ),
      docs: 'https://api.dart.dev/dart-core/List/sort.html',
      mistakes: const [
        Mistake(['[1, 2, 3]'], Tr(
          'That is the natural order. Look at which side calls compareTo.',
          'Itu urutan alaminya. Perhatikan sisi mana yang memanggil compareTo.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Looking back is also a way of seeing',
        'Menengok ke belakang juga merupakan cara untuk melihat',
      ),
      code: 'expect([1, 2, 3].__.toList(), [3, 2, 1]);',
      answers: ['reversed'],
      explanation: const Tr(
        'reversed is a getter that returns a lazy Iterable walking the list '
            'backwards, which is why toList() follows. The original list keeps '
            'its order.',
        'reversed adalah getter yang mengembalikan Iterable malas yang '
            'menelusuri list dari belakang, itulah sebabnya diikuti toList(). '
            'List aslinya tetap dengan urutannya.',
      ),
      docs: 'https://api.dart.dev/dart-core/List/reversed.html',
      mistakes: const [
        Mistake(['reverse'], Tr(
          'List has no member by that name in Dart. Here we need a getter.',
          'List di Dart tidak punya member dengan nama itu. Di sini kita butuh '
              'sebuah getter.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Spreading into a new list leaves the original at peace',
        'Menyebarkan isi ke list baru membiarkan list aslinya tetap tenang',
      ),
      code: r'''
final a = [1, 2];
final b = [...a];
b.add(3);
expect(a, __);''',
      answers: ['[1, 2]'],
      verify: () {
        final a = [1, 2];
        final b = [...a];
        b.add(3);
        return [a];
      },
      explanation: const Tr(
        '[...a] builds a new list holding the same elements, so changing b '
            'leaves a alone. The copy is shallow: if the elements were '
            'themselves lists, both would still share them.',
        '[...a] membangun list baru yang berisi elemen yang sama, jadi '
            'mengubah b tidak mengusik a. Salinannya dangkal: jika elemennya '
            'sendiri berupa list, keduanya tetap berbagi elemen itu.',
      ),
      docs: 'https://dart.dev/language/collections#spread-operators',
      mistakes: const [
        Mistake(['[1, 2, 3]'], Tr(
          'b is a new list. Does adding to it touch a?',
          'b adalah list baru. Apakah menambahkan ke b ikut menyentuh a?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A const list cannot grow',
        'List const tidak bisa bertambah',
      ),
      code: r'''
const frozen = [1, 2];
expect(() => frozen.add(3), throwsA(isA<__>()));''',
      answers: ['UnsupportedError'],
      hint: const Tr(
        'The name of the error says the operation is not supported.',
        'Nama error-nya menyatakan bahwa operasi itu tidak didukung.',
      ),
      explanation: const Tr(
        'A const list is unmodifiable, so add, remove and sort throw an '
            'UnsupportedError at runtime; the analyzer cannot always catch it. '
            'List.unmodifiable gives the same protection to a list built at '
            'runtime.',
        'List const tidak bisa diubah, jadi add, remove, dan sort melempar '
            'UnsupportedError saat runtime; analyzer tidak selalu bisa '
            'menangkapnya. List.unmodifiable memberi perlindungan yang sama '
            'untuk list yang dibangun saat runtime.',
      ),
      docs: 'https://api.dart.dev/dart-core/UnsupportedError-class.html',
      mistakes: const [
        Mistake(['StateError'], Tr(
          'StateError means the right call at the wrong time, like first on an '
              'empty list. Here the operation is never allowed.',
          'StateError berarti pemanggilan yang benar pada waktu yang salah, '
              'seperti first pada list kosong. Di sini operasinya tidak pernah '
              'diizinkan.',
        )),
        Mistake(['UnimplementedError'], Tr(
          'That error means "not written yet". This list will never allow '
              'adding.',
          'Error itu berarti "belum ditulis". List ini tidak akan pernah '
              'mengizinkan penambahan.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A playlist is shuffled by hand, then put in order',
        'Sebuah playlist ditata dengan tangan, lalu diurutkan',
      ),
      code: r'''
final queue = ['jazz', 'lofi', 'rock', 'lofi'];
queue.remove('lofi');
queue.insert(0, 'ambient');
final top = queue.sublist(0, 2);
queue.sort();
expect(top, __);
expect(queue.indexOf('lofi'), __);
expect(queue.last, __);''',
      answers: ["['ambient', 'jazz']", '2', "'rock'"],
      capstone: true,
      verify: () {
        final queue = _words(['jazz', 'lofi', 'rock', 'lofi']);
        queue.remove('lofi');
        queue.insert(0, 'ambient');
        final top = queue.sublist(0, 2);
        queue.sort();
        return [top, queue.indexOf('lofi'), queue.last];
      },
      explanation: const Tr(
        'remove takes only the first lofi and insert pushes everything right. '
            'sublist copies, so top keeps its two songs even after sort '
            'rearranges the queue alphabetically in place.',
        'remove hanya mengambil lofi yang pertama dan insert mendorong semuanya '
            'ke kanan. sublist membuat salinan, jadi top tetap memegang dua '
            'lagunya bahkan setelah sort menata ulang queue secara alfabetis di '
            'tempatnya.',
      ),
      docs: 'https://api.dart.dev/dart-core/List-class.html',
      mistakes: const [
        Mistake(["['ambient', 'jazz', 'rock']", null, null], Tr(
          'Which index does sublist stop just before?',
          'Tepat sebelum indeks berapa sublist berhenti?',
        )),
        Mistake([null, '3', null], Tr(
          'sort has already rearranged the queue in place.',
          'sort sudah menata ulang queue itu di tempatnya.',
        )),
        Mistake([null, null, "'lofi'"], Tr(
          'sort has already rearranged the queue in place.',
          'sort sudah menata ulang queue itu di tempatnya.',
        )),
      ],
    ),
  ],
);

// Built at runtime so the analyzer does not fold it into a constant.
List<int> _list(List<int> values) => [...values];
List<String> _words(List<String> values) => [...values];
