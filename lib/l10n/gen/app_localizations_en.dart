// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Koans';

  @override
  String get homeTagline =>
      'Fill in the blanks. Meditate on the result. Move on.';

  @override
  String get homeIntro =>
      'Each koan is a small truth about Dart or Flutter with a piece missing. Type what belongs in the blank and press Enter. When reality agrees with you, the next koan appears.';

  @override
  String get chooseYourWay => 'Choose your way';

  @override
  String get begin => 'Begin';

  @override
  String get continueWay => 'Continue';

  @override
  String get walkAgain => 'Walk again';

  @override
  String koanCount(int solved, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total koans',
      one: '1 koan',
    );
    return '$solved of $_temp0';
  }

  @override
  String categoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories',
      one: '1 category',
    );
    return '$_temp0';
  }

  @override
  String koanPosition(int current, int total) {
    return 'Koan $current of $total';
  }

  @override
  String get meditate => 'Meditate';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get showMe => 'Show me';

  @override
  String get hint => 'Hint';

  @override
  String get yours => 'Yours';

  @override
  String get goal => 'Goal';

  @override
  String get previewInvalid => 'Type a value to see it here';

  @override
  String get pressEnterToCheck => 'Press Enter to check your answer';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get suggestionsFooter => '↑↓ browse · Enter choose · Esc close';

  @override
  String get noSuggestions =>
      'No suggestions here: this blank wants a value, not a name.';

  @override
  String get solved => 'Reality agrees with you.';

  @override
  String get solvedNext => 'Press Enter to continue.';

  @override
  String get wrong => 'Not quite. Meditate on it a little longer.';

  @override
  String get wrongAgain =>
      'Still not quite. A hint may help, or you may ask to be shown.';

  @override
  String get answerRevealed =>
      'Here is the answer. Study it, then press Enter.';

  @override
  String get numberKind =>
      'So close: the number is right, but is it an int or a double?';

  @override
  String get errorEmpty => 'Every blank needs an answer.';

  @override
  String errorUnexpectedChar(String char) {
    return 'The character “$char” cannot be part of an answer.';
  }

  @override
  String get errorUnterminatedString => 'This string is never closed.';

  @override
  String get errorUnexpectedEnd =>
      'This answer ends too soon. Is a bracket missing?';

  @override
  String errorUnexpectedToken(String token) {
    return '“$token” was not expected here. Answers are values, not expressions.';
  }

  @override
  String errorUnknownName(String name) {
    return '“$name” is not something this koan knows.';
  }

  @override
  String categoryComplete(String category) {
    return 'You have completed $category.';
  }

  @override
  String get wayComplete => 'You have walked the whole way.';

  @override
  String wayCompleteBody(String way) {
    return 'Every koan in $way has been solved. Knowledge is a path, not a destination: return whenever you wish.';
  }

  @override
  String walkOtherWay(String way) {
    return 'Walk $way';
  }

  @override
  String get backHome => 'Back home';

  @override
  String get categories => 'Categories';

  @override
  String get language => 'Language';

  @override
  String get resetProgress => 'Reset progress';

  @override
  String get resetProgressConfirm =>
      'Forget every solved koan? This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get inspiredBy => 'Inspired by ClojureScript Koans';

  @override
  String get notFound => 'This path leads nowhere.';

  @override
  String get why => 'Why';

  @override
  String get readDocs => 'Read the docs';

  @override
  String get capstone => 'Final challenge';

  @override
  String get kindKeyword => 'keyword';

  @override
  String get kindType => 'type';

  @override
  String get kindMethod => 'method';

  @override
  String get kindProperty => 'property';

  @override
  String get kindValue => 'value';

  @override
  String get kindConstructor => 'constructor';

  @override
  String get wrongSuggest =>
      'Still not quite. Here is what can go in this blank: browse it and watch what changes.';

  @override
  String pressEnterOrShortcut(String shortcut) {
    return 'Press Enter to check your answer, or $shortcut for suggestions';
  }

  @override
  String get showLayout => 'Show layout';

  @override
  String get compareGoal => 'Compare with goal';

  @override
  String get review => 'Review';

  @override
  String reviewDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count koans to review',
      one: '1 koan to review',
    );
    return '$_temp0';
  }

  @override
  String reviewWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count koans waiting for a later review',
      one: '1 koan waiting for a later review',
    );
    return '$_temp0';
  }

  @override
  String get reviewIntro =>
      'Koans you struggled with, back for another look. Answer right the first time and they come back less often.';

  @override
  String reviewProgress(int current, int total) {
    return 'Review $current of $total';
  }

  @override
  String get reviewDone => 'All caught up.';

  @override
  String get reviewDoneBody =>
      'Koans you struggle with come back here after 10 minutes, then 1, 3, 7 and 21 days, until they feel easy.';

  @override
  String backToWay(String way) {
    return 'Back to $way';
  }

  @override
  String get privacyNote =>
      'Anonymous answers are counted to improve the koans.';
}
