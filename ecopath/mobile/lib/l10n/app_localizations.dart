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

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.\nPlay games, recycle, or complete challenges to earn some!'**
  String get notificationsEmpty;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Setting'**
  String get accountTitle;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @accountSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Setting'**
  String get accountSettingTitle;

  /// No description provided for @accountYourInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Info'**
  String get accountYourInfoTitle;

  /// No description provided for @accountFieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get accountFieldUsername;

  /// No description provided for @accountFieldDob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth (yyyy/mm/dd)'**
  String get accountFieldDob;

  /// No description provided for @accountFieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get accountFieldAddress;

  /// No description provided for @accountEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get accountEdit;

  /// No description provided for @accountDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get accountDone;

  /// No description provided for @accountLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get accountLogout;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get accountDelete;

  /// No description provided for @accountConfirmSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save?'**
  String get accountConfirmSaveTitle;

  /// No description provided for @accountConfirmSaveCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get accountConfirmSaveCancel;

  /// No description provided for @accountConfirmSaveDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get accountConfirmSaveDone;

  /// No description provided for @accountSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Successfully Saved!'**
  String get accountSavedTitle;

  /// No description provided for @accountDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete your account?\nIt will disappear permanently.'**
  String get accountDeleteDialogTitle;

  /// No description provided for @accountDeleteNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get accountDeleteNo;

  /// No description provided for @accountDeleteYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get accountDeleteYes;

  /// No description provided for @accountAddressSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Address'**
  String get accountAddressSelectTitle;

  /// No description provided for @accountAddressSidoLabel.
  ///
  /// In en, this message translates to:
  /// **'Sido / Province'**
  String get accountAddressSidoLabel;

  /// No description provided for @accountAddressCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City / Gu / Gun'**
  String get accountAddressCityLabel;

  /// No description provided for @accountAddressDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Detail (optional)'**
  String get accountAddressDetailLabel;

  /// No description provided for @accountAddressDetailHint.
  ///
  /// In en, this message translates to:
  /// **'Building, room number, etc.'**
  String get accountAddressDetailHint;

  /// No description provided for @accountAddressApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get accountAddressApply;

  /// No description provided for @accountAddressTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select address'**
  String get accountAddressTapToSelect;

  /// No description provided for @accountUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'username is already taken'**
  String get accountUsernameTaken;

  /// No description provided for @accountUsernameValid.
  ///
  /// In en, this message translates to:
  /// **'username is valid to use'**
  String get accountUsernameValid;

  /// No description provided for @myBagsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Bags'**
  String get myBagsTitle;

  /// No description provided for @myBagsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any bags yet.\nExchange your points in the shop to get bags!'**
  String get myBagsEmptyMessage;

  /// No description provided for @myBagsTapToViewBarcode.
  ///
  /// In en, this message translates to:
  /// **'Tap to view barcode'**
  String get myBagsTapToViewBarcode;

  /// No description provided for @myBagsShowBarcodeInstruction.
  ///
  /// In en, this message translates to:
  /// **'Show this barcode when you use this bag.'**
  String get myBagsShowBarcodeInstruction;

  /// No description provided for @privacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Introduction'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Body.
  ///
  /// In en, this message translates to:
  /// **'EcoPath is committed to protecting your privacy. This Privacy Policy explains what data we collect, how we use it, and the choices you have. By using EcoPath, you agree to this Policy.'**
  String get privacySection1Body;

  /// No description provided for @privacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Information We Collect'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Body.
  ///
  /// In en, this message translates to:
  /// **'• Personal Information: such as your name, email address, or profile data (only if you provide them voluntarily).\n• App Activity: achievements, points, challenges joined, basic usage analytics.\n• Device Data: app version, OS, language, crash diagnostics.\n• Optional Inputs: feedback messages, images you upload within features.\n• Location (Optional): only if you enable features that require it.'**
  String get privacySection2Body;

  /// No description provided for @privacySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. How We Use Your Information'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Body.
  ///
  /// In en, this message translates to:
  /// **'• Provide and maintain core features (profiles, points).\n• Improve app performance, safety, and reliability.\n• Track and display your environmental progress, challenges, and achievements.\n• Personalize non-sensitive content such as streak reminders.\n• Communicate important updates, security notices, or policy changes.\n• Comply with legal obligations.'**
  String get privacySection3Body;

  /// No description provided for @privacySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Sharing & Transfers'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Body.
  ///
  /// In en, this message translates to:
  /// **'We do not sell your personal data. We may share limited data with service providers who help us operate the app (e.g., analytics, crash reporting) under confidentiality agreements. We may disclose information if required by law or to protect our rights, users, or the public.'**
  String get privacySection4Body;

  /// No description provided for @privacySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Data Retention'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Body.
  ///
  /// In en, this message translates to:
  /// **'We retain your data for as long as your account is active or as needed to provide services. You may request deletion; some records may be kept to meet legal or security requirements.'**
  String get privacySection5Body;

  /// No description provided for @privacySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Your Choices & Rights'**
  String get privacySection6Title;

  /// No description provided for @privacySection6Body.
  ///
  /// In en, this message translates to:
  /// **'• Access & Update: edit profile details in-app.\n• Delete: request account deletion from Settings or by contacting us.\n• Notifications: toggle reminders and notifications in Settings.\n• Permissions: manage device-level permissions (e.g., location, camera).'**
  String get privacySection6Body;

  /// No description provided for @privacySection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Children’s Privacy'**
  String get privacySection7Title;

  /// No description provided for @privacySection7Body.
  ///
  /// In en, this message translates to:
  /// **'EcoPath is not directed to children under the age where parental consent is required by local law. If we learn that we collected data from such a child without consent, we will delete it.'**
  String get privacySection7Body;

  /// No description provided for @privacySection8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Security'**
  String get privacySection8Title;

  /// No description provided for @privacySection8Body.
  ///
  /// In en, this message translates to:
  /// **'We use reasonable technical and organizational measures to protect your information. However, no method of transmission or storage is completely secure.'**
  String get privacySection8Body;

  /// No description provided for @privacySection9Title.
  ///
  /// In en, this message translates to:
  /// **'9. International Use'**
  String get privacySection9Title;

  /// No description provided for @privacySection9Body.
  ///
  /// In en, this message translates to:
  /// **'Your information may be processed in countries other than your own. We take steps to ensure appropriate safeguards in line with applicable laws.'**
  String get privacySection9Body;

  /// No description provided for @privacySection10Title.
  ///
  /// In en, this message translates to:
  /// **'10. Changes to This Policy'**
  String get privacySection10Title;

  /// No description provided for @privacySection10Body.
  ///
  /// In en, this message translates to:
  /// **'We may update this Policy from time to time. We will notify you of material changes by in-app notice or other means. Your continued use of EcoPath after changes indicates acceptance.'**
  String get privacySection10Body;

  /// No description provided for @privacySection11Title.
  ///
  /// In en, this message translates to:
  /// **'11. Contact Us'**
  String get privacySection11Title;

  /// No description provided for @privacySection11Body.
  ///
  /// In en, this message translates to:
  /// **'If you have questions or requests about this Policy or your data, please contact our team via the Feedback section in Settings or mail via info@ecopath.site.'**
  String get privacySection11Body;

  /// No description provided for @helpCenterSection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. What is EcoPath?'**
  String get helpCenterSection1Title;

  /// No description provided for @helpCenterSection1Body.
  ///
  /// In en, this message translates to:
  /// **'EcoPath is a gamified sustainability app. It helps you track your electricity, gas, and waste habits while playing mini games, completing eco-challenges, and earning points and XP.'**
  String get helpCenterSection1Body;

  /// No description provided for @helpCenterSection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Getting Started'**
  String get helpCenterSection2Title;

  /// No description provided for @helpCenterSection2Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Sign up with your basic information and create your account.'**
  String get helpCenterSection2Bullet1;

  /// No description provided for @helpCenterSection2Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Complete the Eco Survey to tell us about your home, energy usage, and eco goals.'**
  String get helpCenterSection2Bullet2;

  /// No description provided for @helpCenterSection2Bullet3.
  ///
  /// In en, this message translates to:
  /// **'After the survey, tap Start EcoPath to enter the main dashboard.'**
  String get helpCenterSection2Bullet3;

  /// No description provided for @helpCenterSection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Dashboard Overview'**
  String get helpCenterSection3Title;

  /// No description provided for @helpCenterSection3Body.
  ///
  /// In en, this message translates to:
  /// **'The dashboard shows your daily eco summary and quick access to main features.'**
  String get helpCenterSection3Body;

  /// No description provided for @helpCenterSection3Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Electricity & Gas cards – view your recent usage and trends (kWh / m³ and cost).'**
  String get helpCenterSection3Bullet1;

  /// No description provided for @helpCenterSection3Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Carbon footprint – see an estimate of your CO₂ impact based on your data.'**
  String get helpCenterSection3Bullet2;

  /// No description provided for @helpCenterSection3Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Daily goals – quick tasks to stay on track with your eco habits.'**
  String get helpCenterSection3Bullet3;

  /// No description provided for @helpCenterSection3Bullet4.
  ///
  /// In en, this message translates to:
  /// **'Energy bar – shows how much energy you have left to play games today.'**
  String get helpCenterSection3Bullet4;

  /// No description provided for @helpCenterSection3Bullet5.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts – open Games, Community, Shop, and My Plastic Bag.'**
  String get helpCenterSection3Bullet5;

  /// No description provided for @helpCenterSection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Energy, XP & Points'**
  String get helpCenterSection4Title;

  /// No description provided for @helpCenterSection4Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Energy is used when you play certain games or activities.'**
  String get helpCenterSection4Bullet1;

  /// No description provided for @helpCenterSection4Bullet2.
  ///
  /// In en, this message translates to:
  /// **'XP (experience points) helps you level up your EcoPath profile.'**
  String get helpCenterSection4Bullet2;

  /// No description provided for @helpCenterSection4Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Eco points can be used to unlock rewards in the Shop.'**
  String get helpCenterSection4Bullet3;

  /// No description provided for @helpCenterSection4Bullet4.
  ///
  /// In en, this message translates to:
  /// **'You can refill energy gradually over time or by completing specific daily missions (if enabled).'**
  String get helpCenterSection4Bullet4;

  /// No description provided for @helpCenterSection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Games & Activities'**
  String get helpCenterSection5Title;

  /// No description provided for @helpCenterSection5Body.
  ///
  /// In en, this message translates to:
  /// **'Games make sustainability more fun. You can access them from the Games tab or shortcuts.'**
  String get helpCenterSection5Body;

  /// No description provided for @helpCenterSection5Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Quiz – answer eco-questions and learn new tips. Correct answers give XP and points.'**
  String get helpCenterSection5Bullet1;

  /// No description provided for @helpCenterSection5Bullet2.
  ///
  /// In en, this message translates to:
  /// **'ScanTrash – use your camera to scan trash and identify the correct bin (where available).'**
  String get helpCenterSection5Bullet2;

  /// No description provided for @helpCenterSection5Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Recycle / Photo Proof – upload a photo of your recycling action to earn rewards (follow the rules shown on the screen).'**
  String get helpCenterSection5Bullet3;

  /// No description provided for @helpCenterSection5Bullet4.
  ///
  /// In en, this message translates to:
  /// **'Trash Sorting Game – move trash into the right bin. Great for kids and families.'**
  String get helpCenterSection5Bullet4;

  /// No description provided for @helpCenterSection5Bullet5.
  ///
  /// In en, this message translates to:
  /// **'To-Do / Daily Missions – complete small eco tasks to earn points and sometimes bonus chests.'**
  String get helpCenterSection5Bullet5;

  /// No description provided for @helpCenterSection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Community'**
  String get helpCenterSection6Title;

  /// No description provided for @helpCenterSection6Bullet1.
  ///
  /// In en, this message translates to:
  /// **'See posts and tips from other EcoPath users (if your region supports Community).'**
  String get helpCenterSection6Bullet1;

  /// No description provided for @helpCenterSection6Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Share your own eco actions with photos and short captions.'**
  String get helpCenterSection6Bullet2;

  /// No description provided for @helpCenterSection6Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Use respectful language. No spam, harmful content, or personal attacks.'**
  String get helpCenterSection6Bullet3;

  /// No description provided for @helpCenterSection6Bullet4.
  ///
  /// In en, this message translates to:
  /// **'Do not share sensitive personal information such as full address or phone number.'**
  String get helpCenterSection6Bullet4;

  /// No description provided for @helpCenterSection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Shop & My Plastic Bag'**
  String get helpCenterSection7Title;

  /// No description provided for @helpCenterSection7Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Use your eco points to redeem rewards such as local trash bags or other eco items (availability may differ by region).'**
  String get helpCenterSection7Bullet1;

  /// No description provided for @helpCenterSection7Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Check item details carefully: size (L), color, and district rules.'**
  String get helpCenterSection7Bullet2;

  /// No description provided for @helpCenterSection7Bullet3.
  ///
  /// In en, this message translates to:
  /// **'After you redeem a bag, it appears in My Plastic Bag (MyBags) with barcode and details so you can track what you own.'**
  String get helpCenterSection7Bullet3;

  /// No description provided for @helpCenterSection7Bullet4.
  ///
  /// In en, this message translates to:
  /// **'Always follow your city’s official trash sorting and bag rules.'**
  String get helpCenterSection7Bullet4;

  /// No description provided for @helpCenterSection8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Settings'**
  String get helpCenterSection8Title;

  /// No description provided for @helpCenterSection8Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Account – edit your profile, avatar, and basic info.'**
  String get helpCenterSection8Bullet1;

  /// No description provided for @helpCenterSection8Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Premium – view or manage extra features if your account supports them.'**
  String get helpCenterSection8Bullet2;

  /// No description provided for @helpCenterSection8Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Theme – switch between light and dark mode and other visual themes.'**
  String get helpCenterSection8Bullet3;

  /// No description provided for @helpCenterSection8Bullet4.
  ///
  /// In en, this message translates to:
  /// **'Language – choose your preferred language for the app.'**
  String get helpCenterSection8Bullet4;

  /// No description provided for @helpCenterSection8Bullet5.
  ///
  /// In en, this message translates to:
  /// **'My Plastic Bag – manage the bags you have redeemed or added.'**
  String get helpCenterSection8Bullet5;

  /// No description provided for @helpCenterSection9Title.
  ///
  /// In en, this message translates to:
  /// **'9. Notifications'**
  String get helpCenterSection9Title;

  /// No description provided for @helpCenterSection9Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Turn eco reminders on or off in Settings or during the survey.'**
  String get helpCenterSection9Bullet1;

  /// No description provided for @helpCenterSection9Bullet2.
  ///
  /// In en, this message translates to:
  /// **'EcoPath may send reminders about daily missions, streaks, and important updates.'**
  String get helpCenterSection9Bullet2;

  /// No description provided for @helpCenterSection9Bullet3.
  ///
  /// In en, this message translates to:
  /// **'You can also manage notification permissions from your device settings.'**
  String get helpCenterSection9Bullet3;

  /// No description provided for @helpCenterSection10Title.
  ///
  /// In en, this message translates to:
  /// **'10. Data & Privacy'**
  String get helpCenterSection10Title;

  /// No description provided for @helpCenterSection10Bullet1.
  ///
  /// In en, this message translates to:
  /// **'EcoPath only collects data needed to provide and improve the service (see Privacy Policy).'**
  String get helpCenterSection10Bullet1;

  /// No description provided for @helpCenterSection10Bullet2.
  ///
  /// In en, this message translates to:
  /// **'You can request account or data deletion from Settings or by contacting our team.'**
  String get helpCenterSection10Bullet2;

  /// No description provided for @helpCenterSection10Bullet3.
  ///
  /// In en, this message translates to:
  /// **'For full details, read the Privacy Policy and Terms of Service in the Help & Feedback section.'**
  String get helpCenterSection10Bullet3;

  /// No description provided for @helpCenterSection11Title.
  ///
  /// In en, this message translates to:
  /// **'11. Frequently Asked Questions'**
  String get helpCenterSection11Title;

  /// No description provided for @helpCenterSection11Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Why can’t I play a game? → You may not have enough energy or the feature might be unavailable in your region.'**
  String get helpCenterSection11Bullet1;

  /// No description provided for @helpCenterSection11Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Why is my data empty? → Make sure you finished the survey or connected your meter or entered your readings.'**
  String get helpCenterSection11Bullet2;

  /// No description provided for @helpCenterSection11Bullet3.
  ///
  /// In en, this message translates to:
  /// **'How do I change my language? → Go to Settings → Language.'**
  String get helpCenterSection11Bullet3;

  /// No description provided for @helpCenterSection11Bullet4.
  ///
  /// In en, this message translates to:
  /// **'How do I report a bug? → Use Feedback in Settings or contact us using the email shown there.'**
  String get helpCenterSection11Bullet4;

  /// No description provided for @helpCenterLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: 2025'**
  String get helpCenterLastUpdated;

  /// No description provided for @termsLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: Oct 14, 2025'**
  String get termsLastUpdated;

  /// No description provided for @termsSection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Agreement to Terms'**
  String get termsSection1Title;

  /// No description provided for @termsSection1Body.
  ///
  /// In en, this message translates to:
  /// **'By creating an account or using EcoPath, you agree to be bound by these Terms. If you do not agree, do not use the Service.'**
  String get termsSection1Body;

  /// No description provided for @termsSection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Who May Use EcoPath'**
  String get termsSection2Title;

  /// No description provided for @termsSection2Body.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 13 years old (or the minimum age required in your country) to use the Service. If you are under 18, you represent that you have parental consent.'**
  String get termsSection2Body;

  /// No description provided for @termsSection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Your Account & Security'**
  String get termsSection3Title;

  /// No description provided for @termsSection3Body.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your credentials and for all activities that occur under your account. Notify us of any unauthorized use.'**
  String get termsSection3Body;

  /// No description provided for @termsSection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Acceptable Use'**
  String get termsSection4Title;

  /// No description provided for @termsSection4Body.
  ///
  /// In en, this message translates to:
  /// **'Do not misuse EcoPath. For example, do not: (a) break the law; (b) reverse engineer, scrape, or overload our systems; (c) upload malware; (d) harass others; or (e) attempt to gain unauthorized access to any part of the Service.'**
  String get termsSection4Body;

  /// No description provided for @termsSection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Content & Licenses'**
  String get termsSection5Title;

  /// No description provided for @termsSection5Body.
  ///
  /// In en, this message translates to:
  /// **'You own the content you submit. You grant EcoPath a worldwide, non-exclusive, royalty-free license to host, store, process, and display your content solely to operate and improve the Service.'**
  String get termsSection5Body;

  /// No description provided for @termsSection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Virtual Points & Rewards'**
  String get termsSection6Title;

  /// No description provided for @termsSection6Body.
  ///
  /// In en, this message translates to:
  /// **'Points, badges, or rewards have no cash value and are not transferable. We may modify or terminate reward programs at any time.'**
  String get termsSection6Body;

  /// No description provided for @termsSection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Third-Party Services'**
  String get termsSection7Title;

  /// No description provided for @termsSection7Body.
  ///
  /// In en, this message translates to:
  /// **'EcoPath may link to or integrate third-party services (e.g., maps, payment, authentication). Those services are governed by their own terms and policies.'**
  String get termsSection7Body;

  /// No description provided for @termsSection8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Privacy'**
  String get termsSection8Title;

  /// No description provided for @termsSection8Body.
  ///
  /// In en, this message translates to:
  /// **'Please see our Privacy Policy to understand how we collect, use, and share information.'**
  String get termsSection8Body;

  /// No description provided for @termsSection9Title.
  ///
  /// In en, this message translates to:
  /// **'9. Disclaimers'**
  String get termsSection9Title;

  /// No description provided for @termsSection9Body.
  ///
  /// In en, this message translates to:
  /// **'EcoPath is provided “as is” and “as available.” We disclaim all warranties to the extent permitted by law, including implied warranties of merchantability, fitness for a particular purpose, and non-infringement.'**
  String get termsSection9Body;

  /// No description provided for @termsSection10Title.
  ///
  /// In en, this message translates to:
  /// **'10. Limitation of Liability'**
  String get termsSection10Title;

  /// No description provided for @termsSection10Body.
  ///
  /// In en, this message translates to:
  /// **'To the maximum extent permitted by law, EcoPath and its affiliates will not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenue.'**
  String get termsSection10Body;

  /// No description provided for @termsSection11Title.
  ///
  /// In en, this message translates to:
  /// **'11. Termination'**
  String get termsSection11Title;

  /// No description provided for @termsSection11Body.
  ///
  /// In en, this message translates to:
  /// **'We may suspend or terminate your access at any time if you breach these Terms or if required by law. You may stop using the Service at any time.'**
  String get termsSection11Body;

  /// No description provided for @termsSection12Title.
  ///
  /// In en, this message translates to:
  /// **'12. Changes to These Terms'**
  String get termsSection12Title;

  /// No description provided for @termsSection12Body.
  ///
  /// In en, this message translates to:
  /// **'We may update these Terms from time to time. We will post the updated version in the app. Your continued use after changes means you accept the new Terms.'**
  String get termsSection12Body;

  /// No description provided for @termsSection13Title.
  ///
  /// In en, this message translates to:
  /// **'13. Contact Us'**
  String get termsSection13Title;

  /// No description provided for @termsSection13Body.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about these Terms, contact the EcoPath team via the Feedback section in Settings or mail via info@ecopath.site.'**
  String get termsSection13Body;

  /// No description provided for @carbonTitle.
  ///
  /// In en, this message translates to:
  /// **'Carbon Footprint'**
  String get carbonTitle;

  /// No description provided for @carbonIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly footprint check'**
  String get carbonIntroTitle;

  /// No description provided for @carbonIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Pick how much trash you made this month.\nFor plastic, choose bag size:\n• Low  = 1L–5L\n• Medium = 10L / 20L\n• High = 30L+'**
  String get carbonIntroBody;

  /// No description provided for @carbonMonthlyTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Your monthly trash'**
  String get carbonMonthlyTrashTitle;

  /// No description provided for @carbonMonthlyTrashBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us how much you threw away this month.\nWe’ll turn that into CO₂.'**
  String get carbonMonthlyTrashBody;

  /// No description provided for @carbonGlassLabel.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get carbonGlassLabel;

  /// No description provided for @carbonGlassDesc.
  ///
  /// In en, this message translates to:
  /// **'Bottles, jars, broken glass containers.'**
  String get carbonGlassDesc;

  /// No description provided for @carbonPlasticLabel.
  ///
  /// In en, this message translates to:
  /// **'Plastic (bag volume)'**
  String get carbonPlasticLabel;

  /// No description provided for @carbonPlasticDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose based on bag size in liters.\nLow : 1L–5L\nMedium : 10L / 20L\nHigh : 30L+'**
  String get carbonPlasticDesc;

  /// No description provided for @carbonMetalLabel.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get carbonMetalLabel;

  /// No description provided for @carbonMetalDesc.
  ///
  /// In en, this message translates to:
  /// **'Cans, tins, aluminum packaging.'**
  String get carbonMetalDesc;

  /// No description provided for @carbonCardboardLabel.
  ///
  /// In en, this message translates to:
  /// **'Cardboard'**
  String get carbonCardboardLabel;

  /// No description provided for @carbonCardboardDesc.
  ///
  /// In en, this message translates to:
  /// **'Delivery boxes, packaging board.'**
  String get carbonCardboardDesc;

  /// No description provided for @carbonPaperLabel.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get carbonPaperLabel;

  /// No description provided for @carbonPaperDesc.
  ///
  /// In en, this message translates to:
  /// **'Receipts, tissues, office paper, etc.'**
  String get carbonPaperDesc;

  /// No description provided for @carbonGeneralLabel.
  ///
  /// In en, this message translates to:
  /// **'General Waste'**
  String get carbonGeneralLabel;

  /// No description provided for @carbonGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'Regular trash (municipal solid waste).\nStuff that can’t be recycled.'**
  String get carbonGeneralDesc;

  /// No description provided for @carbonBioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio / Organic'**
  String get carbonBioLabel;

  /// No description provided for @carbonBioDesc.
  ///
  /// In en, this message translates to:
  /// **'Food waste, peels, leftovers, compostable scraps.'**
  String get carbonBioDesc;

  /// No description provided for @carbonTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Trend'**
  String get carbonTrendTitle;

  /// No description provided for @carbonTrendRange4w.
  ///
  /// In en, this message translates to:
  /// **'Last 4 weeks'**
  String get carbonTrendRange4w;

  /// No description provided for @carbonTrendRange6m.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get carbonTrendRange6m;

  /// No description provided for @carbonTrendRange12m.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get carbonTrendRange12m;

  /// No description provided for @carbonSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your CO₂ estimate this month'**
  String get carbonSummaryTitle;

  /// No description provided for @carbonSummaryBody.
  ///
  /// In en, this message translates to:
  /// **'Lower number = lower impact. Try reducing general waste and plastic first 💚'**
  String get carbonSummaryBody;

  /// No description provided for @carbonSummaryValueSuffix.
  ///
  /// In en, this message translates to:
  /// **'kg CO₂e'**
  String get carbonSummaryValueSuffix;

  /// No description provided for @carbonServerPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Carbon Footprint'**
  String get carbonServerPanelTitle;

  /// No description provided for @carbonServerPanelErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get carbonServerPanelErrorPrefix;

  /// No description provided for @carbonServerElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get carbonServerElectricity;

  /// No description provided for @carbonServerGas.
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get carbonServerGas;

  /// No description provided for @carbonServerWaste.
  ///
  /// In en, this message translates to:
  /// **'Waste'**
  String get carbonServerWaste;

  /// No description provided for @carbonServerTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get carbonServerTotal;

  /// No description provided for @carbonServerFetchButton.
  ///
  /// In en, this message translates to:
  /// **'Fetch from server'**
  String get carbonServerFetchButton;

  /// No description provided for @carbonServerFetchingButton.
  ///
  /// In en, this message translates to:
  /// **'Fetching…'**
  String get carbonServerFetchingButton;

  /// No description provided for @carbonServerUnitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get carbonServerUnitKg;

  /// No description provided for @carbonLevelNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get carbonLevelNone;

  /// No description provided for @carbonLevelLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get carbonLevelLow;

  /// No description provided for @carbonLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get carbonLevelMedium;

  /// No description provided for @carbonLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get carbonLevelHigh;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// No description provided for @shopChooseAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your area'**
  String get shopChooseAreaTitle;

  /// No description provided for @shopRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'City / Province'**
  String get shopRegionLabel;

  /// No description provided for @shopDistrictLabel.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood / District'**
  String get shopDistrictLabel;

  /// No description provided for @shopWarningText.
  ///
  /// In en, this message translates to:
  /// **'Each Korean city/gu prints its own bag color. Pick your exact district first.'**
  String get shopWarningText;

  /// No description provided for @shopLoadingLocations.
  ///
  /// In en, this message translates to:
  /// **'Loading locations…'**
  String get shopLoadingLocations;

  /// No description provided for @shopSelectAreaHint.
  ///
  /// In en, this message translates to:
  /// **'Select your city / province and district.'**
  String get shopSelectAreaHint;

  /// No description provided for @shopNoBagInfo.
  ///
  /// In en, this message translates to:
  /// **'No bag info for this district yet.'**
  String get shopNoBagInfo;

  /// No description provided for @shopBagSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Bag Size'**
  String get shopBagSizeLabel;

  /// No description provided for @shopQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get shopQuantityLabel;

  /// No description provided for @shopBuyButton.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get shopBuyButton;

  /// No description provided for @shopConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get shopConfirmTitle;

  /// No description provided for @shopConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to buy this plastic bag?'**
  String get shopConfirmBody;

  /// No description provided for @shopConfirmNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get shopConfirmNo;

  /// No description provided for @shopConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get shopConfirmYes;

  /// No description provided for @shopNotEnoughTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough points'**
  String get shopNotEnoughTitle;

  /// No description provided for @shopNotEnoughBody.
  ///
  /// In en, this message translates to:
  /// **'You only have {points} pts.'**
  String shopNotEnoughBody(int points);

  /// No description provided for @shopPurchaseCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Complete'**
  String get shopPurchaseCompleteTitle;

  /// No description provided for @shopPurchaseCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'You bought the bag!\nCheck it in \'My Bags\'.'**
  String get shopPurchaseCompleteBody;

  /// No description provided for @ecoEducationTitle.
  ///
  /// In en, this message translates to:
  /// **'Eco Education'**
  String get ecoEducationTitle;

  /// No description provided for @ecoEducationTabBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get ecoEducationTabBeginner;

  /// No description provided for @ecoEducationTabIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get ecoEducationTabIntermediate;

  /// No description provided for @ecoEducationTabAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get ecoEducationTabAdvanced;

  /// No description provided for @ecoEducationLevelBeginnerHeading.
  ///
  /// In en, this message translates to:
  /// **'Start here: Learn the bins in Korea 🇰🇷'**
  String get ecoEducationLevelBeginnerHeading;

  /// No description provided for @ecoEducationLevelIntermediateHeading.
  ///
  /// In en, this message translates to:
  /// **'Go deeper: Learn rules & edge cases'**
  String get ecoEducationLevelIntermediateHeading;

  /// No description provided for @ecoEducationLevelAdvancedHeading.
  ///
  /// In en, this message translates to:
  /// **'Eco expert: Systems & lifestyle'**
  String get ecoEducationLevelAdvancedHeading;

  /// No description provided for @ecoEducationSectionInfographics.
  ///
  /// In en, this message translates to:
  /// **'Infographics'**
  String get ecoEducationSectionInfographics;

  /// No description provided for @ecoEducationSectionEcoTip.
  ///
  /// In en, this message translates to:
  /// **'Eco Tip of the Day'**
  String get ecoEducationSectionEcoTip;

  /// No description provided for @ecoEducationSectionMythFact.
  ///
  /// In en, this message translates to:
  /// **'Myth vs Fact'**
  String get ecoEducationSectionMythFact;

  /// No description provided for @ecoEducationHintTapCards.
  ///
  /// In en, this message translates to:
  /// **'Tap each card to reveal more.'**
  String get ecoEducationHintTapCards;

  /// No description provided for @ecoEducationBinSectionAllowed.
  ///
  /// In en, this message translates to:
  /// **'What belongs here'**
  String get ecoEducationBinSectionAllowed;

  /// No description provided for @ecoEducationBinSectionNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Do NOT put these here'**
  String get ecoEducationBinSectionNotAllowed;

  /// No description provided for @ecoEducationBinSectionTipsKorea.
  ///
  /// In en, this message translates to:
  /// **'Tips (Korea context)'**
  String get ecoEducationBinSectionTipsKorea;

  /// No description provided for @ecoEducationExtraKoreaNote.
  ///
  /// In en, this message translates to:
  /// **'Note: In Korea, food waste and general waste are usually separated into different bags or containers (e.g., food waste bin, pay-as-you-throw volume-rate plastic bags). Your apartment or neighborhood may post detailed rules on the notice board or recycling area.'**
  String get ecoEducationExtraKoreaNote;

  /// No description provided for @ecoEducationInfographicsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Infographics coming soon.'**
  String get ecoEducationInfographicsComingSoon;

  /// No description provided for @ecoEducationTipsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Tips coming soon.'**
  String get ecoEducationTipsComingSoon;

  /// No description provided for @ecoEducationMythsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Myths & facts coming soon.'**
  String get ecoEducationMythsComingSoon;

  /// No description provided for @ecoEducationTipShuffleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Shuffle tip'**
  String get ecoEducationTipShuffleTooltip;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackEmail.
  ///
  /// In en, this message translates to:
  /// **'Your email address'**
  String get feedbackEmail;

  /// No description provided for @feedbackSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get feedbackSubject;

  /// No description provided for @feedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get feedbackDescription;

  /// No description provided for @feedbackSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get feedbackSubmit;

  /// No description provided for @feedbackThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get feedbackThankYou;

  /// No description provided for @feedbackEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get feedbackEmailError;

  /// No description provided for @feedbackEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get feedbackEmailInvalid;

  /// No description provided for @feedbackSubjectError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject'**
  String get feedbackSubjectError;

  /// No description provided for @feedbackDescriptionError.
  ///
  /// In en, this message translates to:
  /// **'Please describe the issue or feedback'**
  String get feedbackDescriptionError;

  /// No description provided for @recycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Recycle'**
  String get recycleTitle;

  /// No description provided for @recycleHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Recycle to earn points'**
  String get recycleHeaderTitle;

  /// No description provided for @recycleHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload proof of your recycling. Each mission costs {energyCost} energy.'**
  String recycleHeaderSubtitle(int energyCost);

  /// No description provided for @recycleTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get recycleTakePhoto;

  /// No description provided for @recycleChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get recycleChooseFromGallery;

  /// No description provided for @recycleNotEnoughEnergyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough energy'**
  String get recycleNotEnoughEnergyTitle;

  /// No description provided for @recycleNotEnoughEnergyBody.
  ///
  /// In en, this message translates to:
  /// **'You need {required} energy to recycle.\nCurrent energy: {current}'**
  String recycleNotEnoughEnergyBody(int required, int current);

  /// No description provided for @recycleNotEnoughEnergyQuit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get recycleNotEnoughEnergyQuit;

  /// No description provided for @recycleValidationChooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Please choose what you recycled.'**
  String get recycleValidationChooseCategory;

  /// No description provided for @recycleValidationAddDescription.
  ///
  /// In en, this message translates to:
  /// **'Please add a short description.'**
  String get recycleValidationAddDescription;

  /// No description provided for @recycleValidationAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please upload a photo as proof.'**
  String get recycleValidationAddPhoto;

  /// No description provided for @recycleSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Nice job! ♻️'**
  String get recycleSuccessTitle;

  /// No description provided for @recycleSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'You earned {points} points for recycling.\nThis will show up in your Recycle History on the Profile page.'**
  String recycleSuccessBody(int points);

  /// No description provided for @recycleSuccessBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Games'**
  String get recycleSuccessBackButton;

  /// No description provided for @recycleInstructionsButton.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get recycleInstructionsButton;

  /// No description provided for @recycleCompleteMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your recycling mission'**
  String get recycleCompleteMissionTitle;

  /// No description provided for @recycleStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Step 1 • What did you recycle?'**
  String get recycleStep1Title;

  /// No description provided for @recycleStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Step 2 • Add a short note'**
  String get recycleStep2Title;

  /// No description provided for @recycleStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Step 3 • Upload a photo'**
  String get recycleStep3Title;

  /// No description provided for @recycleStep2Hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3 plastic bottles and 2 cans'**
  String get recycleStep2Hint;

  /// No description provided for @recycleStep3Hint.
  ///
  /// In en, this message translates to:
  /// **'Tap to take or choose a photo\nas proof of your recycling'**
  String get recycleStep3Hint;

  /// No description provided for @recycleQtyTitle.
  ///
  /// In en, this message translates to:
  /// **'How many items?'**
  String get recycleQtyTitle;

  /// No description provided for @recycleQtySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move the slider to estimate how many items you recycled.'**
  String get recycleQtySubtitle;

  /// No description provided for @recycleEstimatedRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated reward'**
  String get recycleEstimatedRewardTitle;

  /// No description provided for @recycleSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Recycle & claim points'**
  String get recycleSubmitButton;

  /// No description provided for @recycleCategoryPlastic.
  ///
  /// In en, this message translates to:
  /// **'Plastic'**
  String get recycleCategoryPlastic;

  /// No description provided for @recycleCategoryPaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get recycleCategoryPaper;

  /// No description provided for @recycleCategoryMetal.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get recycleCategoryMetal;

  /// No description provided for @recycleCategoryGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get recycleCategoryGlass;

  /// No description provided for @recycleCategoryEwaste.
  ///
  /// In en, this message translates to:
  /// **'E-waste'**
  String get recycleCategoryEwaste;

  /// No description provided for @recycleCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get recycleCategoryOther;

  /// No description provided for @recycleInstrTitle.
  ///
  /// In en, this message translates to:
  /// **'Disposal of recyclable items (Korea)'**
  String get recycleInstrTitle;

  /// No description provided for @recycleInstrIntro.
  ///
  /// In en, this message translates to:
  /// **'The main principle for recyclables is often described as the Four Keys: Empty, Rinse, Separate, Don\'t mix.'**
  String get recycleInstrIntro;

  /// No description provided for @recycleInstrRule1.
  ///
  /// In en, this message translates to:
  /// **'Empty contents and make items as clean as possible.'**
  String get recycleInstrRule1;

  /// No description provided for @recycleInstrRule2.
  ///
  /// In en, this message translates to:
  /// **'Rinse and dry bottles, cans and containers.'**
  String get recycleInstrRule2;

  /// No description provided for @recycleInstrRule3.
  ///
  /// In en, this message translates to:
  /// **'Separate by material such as paper, cans and metals, glass, plastics, vinyl and styrofoam.'**
  String get recycleInstrRule3;

  /// No description provided for @recycleInstrRule4.
  ///
  /// In en, this message translates to:
  /// **'Do not mix food waste or non-recyclable items into recycling bins.'**
  String get recycleInstrRule4;

  /// No description provided for @recycleInstrWhatGoesWhere.
  ///
  /// In en, this message translates to:
  /// **'What goes where?'**
  String get recycleInstrWhatGoesWhere;

  /// No description provided for @recyclePaperTitle.
  ///
  /// In en, this message translates to:
  /// **'Paper (종이)'**
  String get recyclePaperTitle;

  /// No description provided for @recyclePaperPrep.
  ///
  /// In en, this message translates to:
  /// **'Flatten and stack newspapers, cardboard boxes and magazines. Remove tape, labels and plastic wrap.'**
  String get recyclePaperPrep;

  /// No description provided for @recyclePaperDisposal.
  ///
  /// In en, this message translates to:
  /// **'Tie them with string or place neatly in a paper/cardboard box or paper recycling bin.'**
  String get recyclePaperDisposal;

  /// No description provided for @recyclePaperPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Paper packs / cups (종이팩, 종이컵)'**
  String get recyclePaperPackTitle;

  /// No description provided for @recyclePaperPackPrep.
  ///
  /// In en, this message translates to:
  /// **'Empty contents, rinse them clean and flatten. Keep them separate from normal paper.'**
  String get recyclePaperPackPrep;

  /// No description provided for @recyclePaperPackDisposal.
  ///
  /// In en, this message translates to:
  /// **'Place them in a separate pack or cup collection box or bin if provided.'**
  String get recyclePaperPackDisposal;

  /// No description provided for @recycleCansMetalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cans & metals (캔/고철)'**
  String get recycleCansMetalsTitle;

  /// No description provided for @recycleCansMetalsPrep.
  ///
  /// In en, this message translates to:
  /// **'Empty and rinse. Puncture spray cans or butane canisters in a well-ventilated area. Remove lids and labels and flatten if possible.'**
  String get recycleCansMetalsPrep;

  /// No description provided for @recycleCansMetalsDisposal.
  ///
  /// In en, this message translates to:
  /// **'Place them in the designated metal or can recycling bin.'**
  String get recycleCansMetalsDisposal;

  /// No description provided for @recycleGlassTitle.
  ///
  /// In en, this message translates to:
  /// **'Glass bottles (병)'**
  String get recycleGlassTitle;

  /// No description provided for @recycleGlassPrep.
  ///
  /// In en, this message translates to:
  /// **'Empty and rinse glass bottles. Remove metal or plastic caps and dispose of caps by their own material. Broken glass is usually not recyclable.'**
  String get recycleGlassPrep;

  /// No description provided for @recycleGlassDisposal.
  ///
  /// In en, this message translates to:
  /// **'Place whole bottles in the designated glass bin. Wrap broken glass safely and follow your district rules for non-flammable or general waste.'**
  String get recycleGlassDisposal;

  /// No description provided for @recyclePlasticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Plastics (플라스틱)'**
  String get recyclePlasticsTitle;

  /// No description provided for @recyclePlasticsPrep.
  ///
  /// In en, this message translates to:
  /// **'Empty, rinse clean and remove all labels, stickers and caps. Compress bottles to reduce volume.'**
  String get recyclePlasticsPrep;

  /// No description provided for @recyclePlasticsDisposal.
  ///
  /// In en, this message translates to:
  /// **'Place in the designated plastics bin, which may be divided into PET bottles and other plastics.'**
  String get recyclePlasticsDisposal;

  /// No description provided for @recycleVinylTitle.
  ///
  /// In en, this message translates to:
  /// **'Vinyl / plastic film (비닐류)'**
  String get recycleVinylTitle;

  /// No description provided for @recycleVinylPrep.
  ///
  /// In en, this message translates to:
  /// **'Only clean and dry items such as plastic bags, snack wrappers and bubble wrap. If they are dirty or have food that cannot be washed off, treat them as general waste.'**
  String get recycleVinylPrep;

  /// No description provided for @recycleVinylDisposal.
  ///
  /// In en, this message translates to:
  /// **'Collect them in a transparent or semi-transparent plastic bag or place them in the vinyl or film bin if available.'**
  String get recycleVinylDisposal;

  /// No description provided for @recycleStyrofoamTitle.
  ///
  /// In en, this message translates to:
  /// **'Styrofoam (스티로폼)'**
  String get recycleStyrofoamTitle;

  /// No description provided for @recycleStyrofoamPrep.
  ///
  /// In en, this message translates to:
  /// **'Remove tape, labels and stickers. Styrofoam must be clean and dry. Food-stained or very dirty styrofoam should go to general waste.'**
  String get recycleStyrofoamPrep;

  /// No description provided for @recycleStyrofoamDisposal.
  ///
  /// In en, this message translates to:
  /// **'Place in the designated styrofoam bin or a transparent or semi-transparent plastic bag if your building uses one.'**
  String get recycleStyrofoamDisposal;

  /// No description provided for @recycleInstrBagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Standard bags for non-recyclable waste'**
  String get recycleInstrBagsTitle;

  /// No description provided for @recycleBagGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General waste (일반 쓰레기 봉투)'**
  String get recycleBagGeneralTitle;

  /// No description provided for @recycleBagGeneralPrep.
  ///
  /// In en, this message translates to:
  /// **'Used for items that cannot be recycled or are too dirty to clean.'**
  String get recycleBagGeneralPrep;

  /// No description provided for @recycleBagGeneralDisposal.
  ///
  /// In en, this message translates to:
  /// **'Bag color varies by district, such as white, light blue or yellow/orange. Use the standard general-waste bag required in your area.'**
  String get recycleBagGeneralDisposal;

  /// No description provided for @recycleBagFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Food waste (음식물 쓰레기 봉투)'**
  String get recycleBagFoodTitle;

  /// No description provided for @recycleBagFoodPrep.
  ///
  /// In en, this message translates to:
  /// **'Used only for food scraps and liquids that count as food waste.'**
  String get recycleBagFoodPrep;

  /// No description provided for @recycleBagFoodDisposal.
  ///
  /// In en, this message translates to:
  /// **'Often collected in special food-waste bags, which can be yellow, pink or light green depending on the district.'**
  String get recycleBagFoodDisposal;

  /// No description provided for @recycleInstrGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get recycleInstrGotIt;
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
