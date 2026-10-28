// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Flutter Koans';

  @override
  String get homeTagline =>
      'Isi bagian yang kosong. Renungkan hasilnya. Lanjutkan.';

  @override
  String get homeIntro =>
      'Setiap koan adalah kebenaran kecil tentang Dart atau Flutter yang kehilangan satu bagian. Ketik apa yang seharusnya mengisi bagian kosong, lalu tekan Enter. Ketika kenyataan setuju denganmu, koan berikutnya akan muncul.';

  @override
  String get chooseYourWay => 'Pilih jalanmu';

  @override
  String get begin => 'Mulai';

  @override
  String get continueWay => 'Lanjutkan';

  @override
  String get walkAgain => 'Tempuh lagi';

  @override
  String koanCount(int solved, int total) {
    return '$solved dari $total koan';
  }

  @override
  String categoryCount(int count) {
    return '$count kategori';
  }

  @override
  String koanPosition(int current, int total) {
    return 'Koan $current dari $total';
  }

  @override
  String get meditate => 'Renungkan';

  @override
  String get next => 'Berikutnya';

  @override
  String get previous => 'Sebelumnya';

  @override
  String get showMe => 'Tunjukkan';

  @override
  String get hint => 'Petunjuk';

  @override
  String get yours => 'Milikmu';

  @override
  String get goal => 'Tujuan';

  @override
  String get previewInvalid => 'Ketik sebuah nilai untuk melihatnya di sini';

  @override
  String get pressEnterToCheck => 'Tekan Enter untuk memeriksa jawabanmu';

  @override
  String get suggestions => 'Saran';

  @override
  String get suggestionsFooter => '↑↓ telusuri · Enter pilih · Esc tutup';

  @override
  String get noSuggestions =>
      'Tidak ada saran di sini: bagian kosong ini meminta sebuah nilai, bukan nama.';

  @override
  String get solved => 'Kenyataan setuju denganmu.';

  @override
  String get solvedNext => 'Tekan Enter untuk melanjutkan.';

  @override
  String get wrong => 'Belum tepat. Renungkan sedikit lebih lama.';

  @override
  String get wrongAgain =>
      'Masih belum tepat. Petunjuk mungkin membantu, atau minta untuk ditunjukkan.';

  @override
  String get answerRevealed => 'Inilah jawabannya. Pelajari, lalu tekan Enter.';

  @override
  String get numberKind =>
      'Hampir: angkanya benar, tapi apakah ini int atau double?';

  @override
  String get errorEmpty => 'Setiap bagian kosong perlu diisi.';

  @override
  String errorUnexpectedChar(String char) {
    return 'Karakter “$char” tidak bisa menjadi bagian dari jawaban.';
  }

  @override
  String get errorUnterminatedString => 'String ini tidak pernah ditutup.';

  @override
  String get errorUnexpectedEnd =>
      'Jawaban ini berakhir terlalu cepat. Apakah ada kurung yang hilang?';

  @override
  String errorUnexpectedToken(String token) {
    return '“$token” tidak diharapkan di sini. Jawaban berupa nilai, bukan ekspresi.';
  }

  @override
  String errorUnknownName(String name) {
    return '“$name” tidak dikenal oleh koan ini.';
  }

  @override
  String categoryComplete(String category) {
    return 'Kamu telah menyelesaikan $category.';
  }

  @override
  String get wayComplete => 'Kamu telah menempuh seluruh jalan.';

  @override
  String wayCompleteBody(String way) {
    return 'Semua koan di $way telah terpecahkan. Pengetahuan adalah perjalanan, bukan tujuan: kembalilah kapan pun kamu mau.';
  }

  @override
  String walkOtherWay(String way) {
    return 'Tempuh $way';
  }

  @override
  String get backHome => 'Kembali ke beranda';

  @override
  String get categories => 'Kategori';

  @override
  String get language => 'Bahasa';

  @override
  String get resetProgress => 'Atur ulang kemajuan';

  @override
  String get resetProgressConfirm =>
      'Lupakan semua koan yang sudah terpecahkan? Tindakan ini tidak bisa dibatalkan.';

  @override
  String get cancel => 'Batal';

  @override
  String get reset => 'Atur ulang';

  @override
  String get inspiredBy => 'Terinspirasi dari ClojureScript Koans';

  @override
  String get notFound => 'Jalan ini tidak menuju ke mana pun.';

  @override
  String get why => 'Mengapa';

  @override
  String get readDocs => 'Baca dokumentasi';

  @override
  String get capstone => 'Tantangan akhir';

  @override
  String get kindKeyword => 'kata kunci';

  @override
  String get kindType => 'tipe';

  @override
  String get kindMethod => 'method';

  @override
  String get kindProperty => 'properti';

  @override
  String get kindValue => 'nilai';

  @override
  String get kindConstructor => 'konstruktor';

  @override
  String get wrongSuggest =>
      'Masih belum tepat. Inilah pilihan yang bisa mengisi bagian kosong ini: telusuri dan perhatikan perubahannya.';

  @override
  String pressEnterOrShortcut(String shortcut) {
    return 'Tekan Enter untuk memeriksa jawabanmu, atau $shortcut untuk melihat saran';
  }

  @override
  String get showLayout => 'Tampilkan layout';

  @override
  String get compareGoal => 'Bandingkan dengan tujuan';

  @override
  String get review => 'Ulas';

  @override
  String reviewDue(int count) {
    return '$count koan untuk diulas';
  }

  @override
  String reviewWaiting(int count) {
    return '$count koan menunggu ulasan berikutnya';
  }

  @override
  String get reviewIntro =>
      'Koan yang dulu terasa sulit, kembali untuk dilihat lagi. Jawab benar pada percobaan pertama, dan koan itu akan makin jarang muncul.';

  @override
  String reviewProgress(int current, int total) {
    return 'Ulasan $current dari $total';
  }

  @override
  String get reviewDone => 'Semua sudah diulas.';

  @override
  String get reviewDoneBody =>
      'Koan yang sulit akan kembali ke sini setelah 10 menit, lalu 1, 3, 7, dan 21 hari, sampai terasa mudah.';

  @override
  String backToWay(String way) {
    return 'Kembali ke $way';
  }

  @override
  String get privacyNote => 'Jawaban anonim dihitung untuk memperbaiki koan.';
}
