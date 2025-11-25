import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EcoPath'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageOption.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageOption;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageKorean;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @myPlasticBag.
  ///
  /// In en, this message translates to:
  /// **'My Plastic Bag'**
  String get myPlasticBag;

  /// No description provided for @helpAndFeedback.
  ///
  /// In en, this message translates to:
  /// **'Help & Feedback'**
  String get helpAndFeedback;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @gamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Play & Earn'**
  String get gamesTitle;

  /// No description provided for @scanTrash.
  ///
  /// In en, this message translates to:
  /// **'Scan Trash'**
  String get scanTrash;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @recycle.
  ///
  /// In en, this message translates to:
  /// **'Recycle'**
  String get recycle;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Stella'**
  String get profileName;

  /// No description provided for @currentRankPrefix.
  ///
  /// In en, this message translates to:
  /// **'Current Rank :'**
  String get currentRankPrefix;

  /// No description provided for @pointsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Points :'**
  String get pointsPrefix;

  /// No description provided for @impactThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Your Impact This Week:'**
  String get impactThisWeek;

  /// No description provided for @electricityChange.
  ///
  /// In en, this message translates to:
  /// **'Electricity ↓ 12%'**
  String get electricityChange;

  /// No description provided for @gasChange.
  ///
  /// In en, this message translates to:
  /// **'Gas ↑ 4%'**
  String get gasChange;

  /// No description provided for @overallScore.
  ///
  /// In en, this message translates to:
  /// **'Overall Score: 78'**
  String get overallScore;

  /// No description provided for @recycleTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you recycle item today?'**
  String get recycleTileTitle;

  /// No description provided for @recycleTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go & Recycle!'**
  String get recycleTileSubtitle;

  /// No description provided for @quizTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you want to challenge?'**
  String get quizTileTitle;

  /// No description provided for @quizTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take the quiz and get full marks!'**
  String get quizTileSubtitle;

  /// No description provided for @educateSmallTitle.
  ///
  /// In en, this message translates to:
  /// **'Educate yourself'**
  String get educateSmallTitle;

  /// No description provided for @educateSmallAnd.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get educateSmallAnd;

  /// No description provided for @educateSmallMain.
  ///
  /// In en, this message translates to:
  /// **'“Protect” the environment'**
  String get educateSmallMain;

  /// No description provided for @recycleDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Recycle item'**
  String get recycleDialogTitle;

  /// No description provided for @recycleDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to recycle an item?'**
  String get recycleDialogMessage;

  /// No description provided for @quizDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge yourself'**
  String get quizDialogTitle;

  /// No description provided for @quizDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to take a quiz now?'**
  String get quizDialogMessage;

  /// No description provided for @educationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Educate yourself'**
  String get educationDialogTitle;

  /// No description provided for @educationDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to learn more eco tips and lessons now?'**
  String get educationDialogMessage;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @ecoPointsTrend.
  ///
  /// In en, this message translates to:
  /// **'Eco Points Trend'**
  String get ecoPointsTrend;

  /// No description provided for @avgPointsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Avg:'**
  String get avgPointsPrefix;

  /// No description provided for @featuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get featuresTitle;

  /// No description provided for @chooseEcoMission.
  ///
  /// In en, this message translates to:
  /// **'Choose your eco-mission'**
  String get chooseEcoMission;

  /// No description provided for @featureElectricityTitle.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get featureElectricityTitle;

  /// No description provided for @featureElectricitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track weekly / monthly / yearly usage'**
  String get featureElectricitySubtitle;

  /// No description provided for @featureGasTitle.
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get featureGasTitle;

  /// No description provided for @featureGasSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor and set save goals'**
  String get featureGasSubtitle;

  /// No description provided for @featureCarbonTitle.
  ///
  /// In en, this message translates to:
  /// **'Carbon\nFootprint'**
  String get featureCarbonTitle;

  /// No description provided for @featureCarbonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See your CO₂ footprint'**
  String get featureCarbonSubtitle;

  /// No description provided for @featureTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Trash &\nRecycling'**
  String get featureTrashTitle;

  /// No description provided for @featureTrashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan, sort, and track'**
  String get featureTrashSubtitle;

  /// No description provided for @featureShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get featureShopTitle;

  /// No description provided for @featureShopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange points for goods'**
  String get featureShopSubtitle;

  /// No description provided for @featureEducationTitle.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get featureEducationTitle;

  /// No description provided for @featureEducationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick eco lessons & quizzes'**
  String get featureEducationSubtitle;

  /// No description provided for @featureNotiTruckTitle.
  ///
  /// In en, this message translates to:
  /// **'Notify Truck'**
  String get featureNotiTruckTitle;

  /// No description provided for @featureNotiTruckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alert to collect trash'**
  String get featureNotiTruckSubtitle;

  /// No description provided for @trashRecyclingTitle.
  ///
  /// In en, this message translates to:
  /// **'Trash & Recycling'**
  String get trashRecyclingTitle;

  /// No description provided for @trashRecyclingLine1.
  ///
  /// In en, this message translates to:
  /// **'• Scan items & sort correctly'**
  String get trashRecyclingLine1;

  /// No description provided for @trashRecyclingLine2.
  ///
  /// In en, this message translates to:
  /// **'• Track recycling streaks'**
  String get trashRecyclingLine2;

  /// No description provided for @trashRecyclingLine3.
  ///
  /// In en, this message translates to:
  /// **'• Leaderboard boosts'**
  String get trashRecyclingLine3;

  /// No description provided for @trashRecyclingHint.
  ///
  /// In en, this message translates to:
  /// **'Complete actions here to earn EcoPath points & badges.'**
  String get trashRecyclingHint;

  /// No description provided for @communityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityTitle;

  /// No description provided for @tabQuests.
  ///
  /// In en, this message translates to:
  /// **'Quests'**
  String get tabQuests;

  /// No description provided for @tabFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get tabFeed;

  /// No description provided for @tabEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get tabEvents;

  /// No description provided for @fabAddEcoTip.
  ///
  /// In en, this message translates to:
  /// **'Add eco tip'**
  String get fabAddEcoTip;

  /// No description provided for @streakPrefix.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakPrefix;

  /// No description provided for @joinedQuestToast.
  ///
  /// In en, this message translates to:
  /// **'Joined quest'**
  String get joinedQuestToast;

  /// No description provided for @leftQuestToast.
  ///
  /// In en, this message translates to:
  /// **'Left quest'**
  String get leftQuestToast;

  /// No description provided for @leaderboardThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard • This Week'**
  String get leaderboardThisWeek;

  /// No description provided for @filterShowingPrefix.
  ///
  /// In en, this message translates to:
  /// **'Showing'**
  String get filterShowingPrefix;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// No description provided for @commentsHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get commentsHint;

  /// No description provided for @registerByPrefix.
  ///
  /// In en, this message translates to:
  /// **'Register by'**
  String get registerByPrefix;

  /// No description provided for @joinedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joinedPrefix;

  /// No description provided for @leftPrefix.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get leftPrefix;

  /// No description provided for @levelPrefix.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelPrefix;

  /// No description provided for @isYouSuffix.
  ///
  /// In en, this message translates to:
  /// **'(You)'**
  String get isYouSuffix;

  /// No description provided for @hashtagsHint.
  ///
  /// In en, this message translates to:
  /// **'#hashtag #separated'**
  String get hashtagsHint;

  /// No description provided for @newPostTitle.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get newPostTitle;

  /// No description provided for @shareEcoTipHint.
  ///
  /// In en, this message translates to:
  /// **'Share your eco tip...'**
  String get shareEcoTipHint;

  /// No description provided for @hashtagHint.
  ///
  /// In en, this message translates to:
  /// **'#hashtag #separated'**
  String get hashtagHint;

  /// No description provided for @hashtagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Hashtags'**
  String get hashtagsLabel;

  /// No description provided for @addPhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhotoButton;

  /// No description provided for @postButton.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postButton;

  /// No description provided for @pointsSuffix.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get pointsSuffix;

  /// No description provided for @gameQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get gameQuiz;

  /// No description provided for @gameScanTrash.
  ///
  /// In en, this message translates to:
  /// **'Scan Trash'**
  String get gameScanTrash;

  /// No description provided for @gameRecycle.
  ///
  /// In en, this message translates to:
  /// **'Recycle'**
  String get gameRecycle;

  /// No description provided for @gameDailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get gameDailyChallenge;

  /// No description provided for @gameCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get gameCommunity;

  /// No description provided for @gameTrashSorting.
  ///
  /// In en, this message translates to:
  /// **'Trash Sorting'**
  String get gameTrashSorting;

  /// No description provided for @energyDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough energy'**
  String get energyDialogTitle;

  /// No description provided for @energyDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Your energy is empty. Wait until it refills to play again.'**
  String get energyDialogMessage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @changeAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get changeAvatarTitle;

  /// No description provided for @changeAvatarTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get changeAvatarTakePhoto;

  /// No description provided for @changeAvatarChooseAlbum.
  ///
  /// In en, this message translates to:
  /// **'Choose from album'**
  String get changeAvatarChooseAlbum;

  /// No description provided for @changeAvatarChooseCharacter.
  ///
  /// In en, this message translates to:
  /// **'Choose from character'**
  String get changeAvatarChooseCharacter;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @recycleInfoText.
  ///
  /// In en, this message translates to:
  /// **'Track your eco journey! Each time you recycle and earn points, your activity appears here. Check your streaks and see how consistent your recycling habits are!'**
  String get recycleInfoText;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @dayPointsMessagePrefix.
  ///
  /// In en, this message translates to:
  /// **'You earned'**
  String get dayPointsMessagePrefix;

  /// No description provided for @dayPointsMessageSuffix.
  ///
  /// In en, this message translates to:
  /// **'points on this day!'**
  String get dayPointsMessageSuffix;

  /// No description provided for @pointsEarnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Points earned'**
  String get pointsEarnedLabel;

  /// No description provided for @progressDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress done'**
  String get progressDoneLabel;

  /// No description provided for @recycleHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recycle History'**
  String get recycleHistoryTitle;

  /// No description provided for @weekdayShortSun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdayShortSun;

  /// No description provided for @weekdayShortMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekdayShortWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdayShortSat;

  /// No description provided for @electricityTitle.
  ///
  /// In en, this message translates to:
  /// **'Electricity Usage'**
  String get electricityTitle;

  /// No description provided for @electricityThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get electricityThisWeek;

  /// No description provided for @electricityThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get electricityThisMonth;

  /// No description provided for @electricityThisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get electricityThisYear;

  /// No description provided for @electricityUsageKpiTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get electricityUsageKpiTitle;

  /// No description provided for @electricityUsageKpiSub.
  ///
  /// In en, this message translates to:
  /// **'Estimate only'**
  String get electricityUsageKpiSub;

  /// No description provided for @electricityBillKpiTitle.
  ///
  /// In en, this message translates to:
  /// **'Est. Bill'**
  String get electricityBillKpiTitle;

  /// No description provided for @electricityBillKpiSubYear.
  ///
  /// In en, this message translates to:
  /// **'avg/month'**
  String get electricityBillKpiSubYear;

  /// No description provided for @electricityBillKpiSubOther.
  ///
  /// In en, this message translates to:
  /// **'estimate'**
  String get electricityBillKpiSubOther;

  /// No description provided for @electricityTrendUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get electricityTrendUp;

  /// No description provided for @electricityTrendDown.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get electricityTrendDown;

  /// No description provided for @electricityVsLastPeriod.
  ///
  /// In en, this message translates to:
  /// **'vs last period'**
  String get electricityVsLastPeriod;

  /// No description provided for @electricityBackendLoading.
  ///
  /// In en, this message translates to:
  /// **'Fetching backend average for Jan 2025…'**
  String get electricityBackendLoading;

  /// No description provided for @electricityBackendNone.
  ///
  /// In en, this message translates to:
  /// **'No backend average available.'**
  String get electricityBackendNone;

  /// No description provided for @electricityBackendLabel.
  ///
  /// In en, this message translates to:
  /// **'Backend Avg (Jan 2025):'**
  String get electricityBackendLabel;

  /// No description provided for @electricityRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get electricityRefresh;

  /// No description provided for @electricityRangeWeekButton.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get electricityRangeWeekButton;

  /// No description provided for @electricityRangeMonthButton.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get electricityRangeMonthButton;

  /// No description provided for @electricityRangeYearButton.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get electricityRangeYearButton;

  /// No description provided for @electricityUsageChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage Chart'**
  String get electricityUsageChartTitle;

  /// No description provided for @electricityProjectionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Projection:'**
  String get electricityProjectionPrefix;

  /// No description provided for @gasTitle.
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get gasTitle;

  /// No description provided for @gasIntro.
  ///
  /// In en, this message translates to:
  /// **'Track your monthly gas usage\nand estimate your carbon impact.'**
  String get gasIntro;

  /// No description provided for @gasQuickConverterTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Converter'**
  String get gasQuickConverterTitle;

  /// No description provided for @gasQuickConverterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your latest reading to convert to CO₂e'**
  String get gasQuickConverterSubtitle;

  /// No description provided for @gasReadingLabelM3.
  ///
  /// In en, this message translates to:
  /// **'Gas used (m³)'**
  String get gasReadingLabelM3;

  /// No description provided for @gasReadingLabelKwh.
  ///
  /// In en, this message translates to:
  /// **'Gas used (kWh)'**
  String get gasReadingLabelKwh;

  /// No description provided for @gasReadingHintM3.
  ///
  /// In en, this message translates to:
  /// **'e.g. 42.5'**
  String get gasReadingHintM3;

  /// No description provided for @gasReadingHintKwh.
  ///
  /// In en, this message translates to:
  /// **'e.g. 120.0'**
  String get gasReadingHintKwh;

  /// No description provided for @gasRateLabelM3.
  ///
  /// In en, this message translates to:
  /// **'Optional: Rate per m³ (₩)'**
  String get gasRateLabelM3;

  /// No description provided for @gasRateLabelKwh.
  ///
  /// In en, this message translates to:
  /// **'Optional: Rate per kWh (₩)'**
  String get gasRateLabelKwh;

  /// No description provided for @gasRateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 92.5'**
  String get gasRateHint;

  /// No description provided for @gasRateHelper.
  ///
  /// In en, this message translates to:
  /// **'If set, we’ll also estimate this month’s bill.'**
  String get gasRateHelper;

  /// No description provided for @gasConvertButton.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get gasConvertButton;

  /// No description provided for @gasResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get gasResultTitle;

  /// No description provided for @gasResultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your estimated carbon footprint and optional bill estimate'**
  String get gasResultSubtitle;

  /// No description provided for @gasResultEmpty.
  ///
  /// In en, this message translates to:
  /// **'No result yet. Enter a reading above and tap Convert.'**
  String get gasResultEmpty;

  /// No description provided for @gasResultCo2Label.
  ///
  /// In en, this message translates to:
  /// **'CO₂e'**
  String get gasResultCo2Label;

  /// No description provided for @gasResultCo2HelperM3.
  ///
  /// In en, this message translates to:
  /// **'Based on your input in m³.'**
  String get gasResultCo2HelperM3;

  /// No description provided for @gasResultCo2HelperKwh.
  ///
  /// In en, this message translates to:
  /// **'Based on your input in kWh.'**
  String get gasResultCo2HelperKwh;

  /// No description provided for @gasResultBillLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated Bill'**
  String get gasResultBillLabel;

  /// No description provided for @gasResultBillHelper.
  ///
  /// In en, this message translates to:
  /// **'Set your rate to see a bill estimate.'**
  String get gasResultBillHelper;

  /// No description provided for @gasUsageTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage Trend'**
  String get gasUsageTrendTitle;

  /// No description provided for @gasUsageTrendSubtitle4w.
  ///
  /// In en, this message translates to:
  /// **'Last 4 weeks'**
  String get gasUsageTrendSubtitle4w;

  /// No description provided for @gasUsageTrendSubtitle6m.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get gasUsageTrendSubtitle6m;

  /// No description provided for @gasUsageTrendSubtitle12m.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get gasUsageTrendSubtitle12m;

  /// No description provided for @gasTipText.
  ///
  /// In en, this message translates to:
  /// **'Tip: Switch units to match your bill. Trends update automatically.'**
  String get gasTipText;

  /// No description provided for @gasRange1M.
  ///
  /// In en, this message translates to:
  /// **'1M'**
  String get gasRange1M;

  /// No description provided for @gasRange6M.
  ///
  /// In en, this message translates to:
  /// **'6M'**
  String get gasRange6M;

  /// No description provided for @gasRange1Y.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get gasRange1Y;

  /// No description provided for @notiTruckTitle.
  ///
  /// In en, this message translates to:
  /// **'Notify Truck'**
  String get notiTruckTitle;

  /// No description provided for @notiTruckHeader.
  ///
  /// In en, this message translates to:
  /// **'Report Mass Trash Situation'**
  String get notiTruckHeader;

  /// No description provided for @notiTruckDescription.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details so the truck team can come and clean the area.'**
  String get notiTruckDescription;

  /// No description provided for @notiTruckLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get notiTruckLocationLabel;

  /// No description provided for @notiTruckLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sejong Univ back gate, near CU store'**
  String get notiTruckLocationHint;

  /// No description provided for @notiTruckPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo (optional)'**
  String get notiTruckPhotoLabel;

  /// No description provided for @notiTruckPhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get notiTruckPhotoCamera;

  /// No description provided for @notiTruckPhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get notiTruckPhotoGallery;

  /// No description provided for @notiTruckNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get notiTruckNoteLabel;

  /// No description provided for @notiTruckNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Smell is very bad, trash is scattered all over the street…'**
  String get notiTruckNoteHint;

  /// No description provided for @notiTruckRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get notiTruckRegisterButton;

  /// No description provided for @notiTruckSnackLocationMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter a location.'**
  String get notiTruckSnackLocationMissing;

  /// No description provided for @notiTruckDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Successfully notified!'**
  String get notiTruckDialogTitle;

  /// No description provided for @notiTruckDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Your report has been sent. Thank you for helping keep your area clean!'**
  String get notiTruckDialogMessage;

  /// No description provided for @notiTruckDialogDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notiTruckDialogDone;

  /// No description provided for @bagWhite.
  ///
  /// In en, this message translates to:
  /// **'White Bag'**
  String get bagWhite;

  /// No description provided for @bagGreen.
  ///
  /// In en, this message translates to:
  /// **'Green Bag'**
  String get bagGreen;

  /// No description provided for @bagBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue Bag'**
  String get bagBlue;

  /// No description provided for @bagPink.
  ///
  /// In en, this message translates to:
  /// **'Pink Bag'**
  String get bagPink;

  /// No description provided for @bagYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow Bag'**
  String get bagYellow;

  /// No description provided for @bagPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple Bag'**
  String get bagPurple;

  /// No description provided for @bagOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange Bag'**
  String get bagOrange;

  /// No description provided for @wasteGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Waste'**
  String get wasteGeneral;

  /// No description provided for @wasteFood.
  ///
  /// In en, this message translates to:
  /// **'Food Waste'**
  String get wasteFood;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ko': return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
