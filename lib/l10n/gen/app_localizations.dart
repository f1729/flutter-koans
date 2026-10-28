import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Koans'**
  String get appTitle;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blanks. Meditate on the result. Move on.'**
  String get homeTagline;

  /// No description provided for @homeIntro.
  ///
  /// In en, this message translates to:
  /// **'Each koan is a small truth about Dart or Flutter with a piece missing. Type what belongs in the blank and press Enter. When reality agrees with you, the next koan appears.'**
  String get homeIntro;

  /// No description provided for @chooseYourWay.
  ///
  /// In en, this message translates to:
  /// **'Choose your way'**
  String get chooseYourWay;

  /// No description provided for @begin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get begin;

  /// No description provided for @continueWay.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueWay;

  /// No description provided for @walkAgain.
  ///
  /// In en, this message translates to:
  /// **'Walk again'**
  String get walkAgain;

  /// No description provided for @koanCount.
  ///
  /// In en, this message translates to:
  /// **'{solved} of {total, plural, =1{1 koan} other{{total} koans}}'**
  String koanCount(int solved, int total);

  /// No description provided for @categoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 category} other{{count} categories}}'**
  String categoryCount(int count);

  /// No description provided for @koanPosition.
  ///
  /// In en, this message translates to:
  /// **'Koan {current} of {total}'**
  String koanPosition(int current, int total);

  /// No description provided for @meditate.
  ///
  /// In en, this message translates to:
  /// **'Meditate'**
  String get meditate;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @showMe.
  ///
  /// In en, this message translates to:
  /// **'Show me'**
  String get showMe;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @yours.
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get yours;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @previewInvalid.
  ///
  /// In en, this message translates to:
  /// **'Type a value to see it here'**
  String get previewInvalid;

  /// No description provided for @pressEnterToCheck.
  ///
  /// In en, this message translates to:
  /// **'Press Enter to check your answer'**
  String get pressEnterToCheck;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @suggestionsFooter.
  ///
  /// In en, this message translates to:
  /// **'↑↓ browse · Enter choose · Esc close'**
  String get suggestionsFooter;

  /// No description provided for @noSuggestions.
  ///
  /// In en, this message translates to:
  /// **'No suggestions here: this blank wants a value, not a name.'**
  String get noSuggestions;

  /// No description provided for @solved.
  ///
  /// In en, this message translates to:
  /// **'Reality agrees with you.'**
  String get solved;

  /// No description provided for @solvedNext.
  ///
  /// In en, this message translates to:
  /// **'Press Enter to continue.'**
  String get solvedNext;

  /// No description provided for @wrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Meditate on it a little longer.'**
  String get wrong;

  /// No description provided for @wrongAgain.
  ///
  /// In en, this message translates to:
  /// **'Still not quite. A hint may help, or you may ask to be shown.'**
  String get wrongAgain;

  /// No description provided for @answerRevealed.
  ///
  /// In en, this message translates to:
  /// **'Here is the answer. Study it, then press Enter.'**
  String get answerRevealed;

  /// No description provided for @numberKind.
  ///
  /// In en, this message translates to:
  /// **'So close: the number is right, but is it an int or a double?'**
  String get numberKind;

  /// No description provided for @errorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Every blank needs an answer.'**
  String get errorEmpty;

  /// No description provided for @errorUnexpectedChar.
  ///
  /// In en, this message translates to:
  /// **'The character “{char}” cannot be part of an answer.'**
  String errorUnexpectedChar(String char);

  /// No description provided for @errorUnterminatedString.
  ///
  /// In en, this message translates to:
  /// **'This string is never closed.'**
  String get errorUnterminatedString;

  /// No description provided for @errorUnexpectedEnd.
  ///
  /// In en, this message translates to:
  /// **'This answer ends too soon. Is a bracket missing?'**
  String get errorUnexpectedEnd;

  /// No description provided for @errorUnexpectedToken.
  ///
  /// In en, this message translates to:
  /// **'“{token}” was not expected here. Answers are values, not expressions.'**
  String errorUnexpectedToken(String token);

  /// No description provided for @errorUnknownName.
  ///
  /// In en, this message translates to:
  /// **'“{name}” is not something this koan knows.'**
  String errorUnknownName(String name);

  /// No description provided for @categoryComplete.
  ///
  /// In en, this message translates to:
  /// **'You have completed {category}.'**
  String categoryComplete(String category);

  /// No description provided for @wayComplete.
  ///
  /// In en, this message translates to:
  /// **'You have walked the whole way.'**
  String get wayComplete;

  /// No description provided for @wayCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Every koan in {way} has been solved. Knowledge is a path, not a destination: return whenever you wish.'**
  String wayCompleteBody(String way);

  /// No description provided for @walkOtherWay.
  ///
  /// In en, this message translates to:
  /// **'Walk {way}'**
  String walkOtherWay(String way);

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back home'**
  String get backHome;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get resetProgress;

  /// No description provided for @resetProgressConfirm.
  ///
  /// In en, this message translates to:
  /// **'Forget every solved koan? This cannot be undone.'**
  String get resetProgressConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @inspiredBy.
  ///
  /// In en, this message translates to:
  /// **'Inspired by ClojureScript Koans'**
  String get inspiredBy;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'This path leads nowhere.'**
  String get notFound;

  /// No description provided for @why.
  ///
  /// In en, this message translates to:
  /// **'Why'**
  String get why;

  /// No description provided for @readDocs.
  ///
  /// In en, this message translates to:
  /// **'Read the docs'**
  String get readDocs;

  /// No description provided for @capstone.
  ///
  /// In en, this message translates to:
  /// **'Final challenge'**
  String get capstone;

  /// No description provided for @kindKeyword.
  ///
  /// In en, this message translates to:
  /// **'keyword'**
  String get kindKeyword;

  /// No description provided for @kindType.
  ///
  /// In en, this message translates to:
  /// **'type'**
  String get kindType;

  /// No description provided for @kindMethod.
  ///
  /// In en, this message translates to:
  /// **'method'**
  String get kindMethod;

  /// No description provided for @kindProperty.
  ///
  /// In en, this message translates to:
  /// **'property'**
  String get kindProperty;

  /// No description provided for @kindValue.
  ///
  /// In en, this message translates to:
  /// **'value'**
  String get kindValue;

  /// No description provided for @kindConstructor.
  ///
  /// In en, this message translates to:
  /// **'constructor'**
  String get kindConstructor;

  /// No description provided for @wrongSuggest.
  ///
  /// In en, this message translates to:
  /// **'Still not quite. Here is what can go in this blank: browse it and watch what changes.'**
  String get wrongSuggest;

  /// No description provided for @pressEnterOrShortcut.
  ///
  /// In en, this message translates to:
  /// **'Press Enter to check your answer, or {shortcut} for suggestions'**
  String pressEnterOrShortcut(String shortcut);

  /// No description provided for @showLayout.
  ///
  /// In en, this message translates to:
  /// **'Show layout'**
  String get showLayout;

  /// No description provided for @compareGoal.
  ///
  /// In en, this message translates to:
  /// **'Compare with goal'**
  String get compareGoal;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @reviewDue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 koan to review} other{{count} koans to review}}'**
  String reviewDue(int count);

  /// No description provided for @reviewWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 koan waiting for a later review} other{{count} koans waiting for a later review}}'**
  String reviewWaiting(int count);

  /// No description provided for @reviewIntro.
  ///
  /// In en, this message translates to:
  /// **'Koans you struggled with, back for another look. Answer right the first time and they come back less often.'**
  String get reviewIntro;

  /// No description provided for @reviewProgress.
  ///
  /// In en, this message translates to:
  /// **'Review {current} of {total}'**
  String reviewProgress(int current, int total);

  /// No description provided for @reviewDone.
  ///
  /// In en, this message translates to:
  /// **'All caught up.'**
  String get reviewDone;

  /// No description provided for @reviewDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Koans you struggle with come back here after 10 minutes, then 1, 3, 7 and 21 days, until they feel easy.'**
  String get reviewDoneBody;

  /// No description provided for @backToWay.
  ///
  /// In en, this message translates to:
  /// **'Back to {way}'**
  String backToWay(String way);

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Anonymous answers are counted to improve the koans.'**
  String get privacyNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
