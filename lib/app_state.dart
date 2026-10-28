import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'engine/koan.dart';
import 'review.dart';

const supportedLocales = [Locale('en'), Locale('id')];

/// The learner's language, which koans they have solved, what needs review,
/// and preview preferences, kept in localStorage on the web.
class AppState extends ChangeNotifier {
  AppState._(this._prefs, this._locale, this._solved, this.reviews, this._showLayout, this._compareGoal);

  static const _localeKey = 'locale';
  static const _solvedKey = 'solved';
  static const _reviewKey = 'review';
  static const _layoutKey = 'showLayout';
  static const _compareKey = 'compareGoal';

  final SharedPreferences _prefs;
  Locale _locale;
  final Set<String> _solved;
  final ReviewQueue reviews;
  bool _showLayout;
  bool _compareGoal;

  /// Overridable for tests.
  static DateTime Function() clock = DateTime.now;

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey) ??
        PlatformDispatcher.instance.locale.languageCode;
    final solved = prefs.getString(_solvedKey);
    final review = prefs.getString(_reviewKey);
    return AppState._(
      prefs,
      Locale(code == 'id' ? 'id' : 'en'),
      {if (solved != null) ...(jsonDecode(solved) as List).cast<String>()},
      review == null ? ReviewQueue() : ReviewQueue.fromJson((jsonDecode(review) as Map).cast<String, Object?>()),
      prefs.getBool(_layoutKey) ?? false,
      prefs.getBool(_compareKey) ?? false,
    );
  }

  Locale get locale => _locale;

  set locale(Locale value) {
    if (value == _locale) return;
    _locale = value;
    _prefs.setString(_localeKey, value.languageCode);
    notifyListeners();
  }

  bool isSolved(String key) => _solved.contains(key);

  /// Draw box outlines and sizes over Flutter previews.
  bool get showLayout => _showLayout;
  set showLayout(bool value) {
    _showLayout = value;
    _prefs.setBool(_layoutKey, value);
    notifyListeners();
  }

  /// Lay the goal faintly over the learner's preview.
  bool get compareGoal => _compareGoal;
  set compareGoal(bool value) {
    _compareGoal = value;
    _prefs.setBool(_compareKey, value);
    notifyListeners();
  }

  /// Records how solving [key] went: a struggle sends it to review.
  void recordSolve(String key, {required int misses, required bool revealed}) {
    if (revealed || misses >= ReviewQueue.struggleThreshold) {
      reviews.struggled(key, clock());
      _saveReviews();
    }
  }

  /// Records a review of [key].
  void recordReview(String key, {required bool firstTry}) {
    reviews.reviewed(key, firstTry: firstTry, now: clock());
    _saveReviews();
  }

  List<String> dueReviews(Way way) => reviews.due('${way.id}/', clock());

  void _saveReviews() {
    _prefs.setString(_reviewKey, jsonEncode(reviews.toJson()));
    notifyListeners();
  }

  void markSolved(String key) {
    if (_solved.add(key)) _save();
  }

  void reset() {
    _solved.clear();
    reviews.cards.clear();
    _prefs.remove(_reviewKey);
    _save();
  }

  void _save() {
    _prefs.setString(_solvedKey, jsonEncode(_solved.toList()));
    notifyListeners();
  }

  int solvedIn(Way way, [Category? category]) {
    var n = 0;
    for (final c in category == null ? way.categories : [category]) {
      for (var i = 0; i < c.koans.length; i++) {
        if (isSolved(koanKey(way, c, i))) n++;
      }
    }
    return n;
  }

  /// The first koan not yet solved, or null if the whole way is done.
  (Category, int)? firstUnsolved(Way way) {
    for (final c in way.categories) {
      for (var i = 0; i < c.koans.length; i++) {
        if (!isSolved(koanKey(way, c, i))) return (c, i);
      }
    }
    return null;
  }

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Reads the state without rebuilding when it changes.
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);
}

String koanPath(Way way, Category category, int index) =>
    '/${way.id}/${category.id}/${index + 1}';

String wayStartPath(AppState state, Way way) {
  final next = state.firstUnsolved(way);
  if (next == null) return '/${way.id}/done';
  return koanPath(way, next.$1, next.$2);
}
