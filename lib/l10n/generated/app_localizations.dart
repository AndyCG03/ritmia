import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your subscriptions. Your rhythm.'**
  String get tagline;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get home;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add subscription'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit subscription'**
  String get edit;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Your subscriptions'**
  String get subscriptions;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Make room for what matters.'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first subscription. See what it costs and when it renews.'**
  String get emptyBody;

  /// No description provided for @monthCharges.
  ///
  /// In en, this message translates to:
  /// **'Expected charges this month'**
  String get monthCharges;

  /// No description provided for @noCharges.
  ///
  /// In en, this message translates to:
  /// **'No expected charges'**
  String get noCharges;

  /// No description provided for @localMode.
  ///
  /// In en, this message translates to:
  /// **'Local mode · data on this device'**
  String get localMode;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search name or notes'**
  String get search;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount per cycle'**
  String get amount;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @billingCycle.
  ///
  /// In en, this message translates to:
  /// **'Billing cycle'**
  String get billingCycle;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @quarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get quarterly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @anchorDate.
  ///
  /// In en, this message translates to:
  /// **'First renewal / anchor date'**
  String get anchorDate;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @logo.
  ///
  /// In en, this message translates to:
  /// **'Custom logo'**
  String get logo;

  /// No description provided for @uploadLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get uploadLogo;

  /// No description provided for @removeLogo.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get removeLogo;

  /// No description provided for @logoHelp.
  ///
  /// In en, this message translates to:
  /// **'PNG/JPG/WebP · optimized to 256 px and up to 128 KB.'**
  String get logoHelp;

  /// No description provided for @catalog.
  ///
  /// In en, this message translates to:
  /// **'Choose a service'**
  String get catalog;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this subscription?'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes the Ritmia record. Your contract with the provider stays active.'**
  String get deleteBody;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Subscription saved'**
  String get saved;

  /// No description provided for @invalidName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name of up to 80 characters.'**
  String get invalidName;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than zero, with no thousands separators.'**
  String get invalidAmount;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Use a valid https address.'**
  String get invalidUrl;

  /// No description provided for @dateOrder.
  ///
  /// In en, this message translates to:
  /// **'The end date cannot be before the start date.'**
  String get dateOrder;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @productivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivity;

  /// No description provided for @storageCategory.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageCategory;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @utilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get utilities;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @reminderHelp.
  ///
  /// In en, this message translates to:
  /// **'Notify at 09:00 before renewal, trial end or plan end.'**
  String get reminderHelp;

  /// No description provided for @daysOne.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get daysOne;

  /// No description provided for @daysThree.
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get daysThree;

  /// No description provided for @daysSeven.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get daysSeven;

  /// No description provided for @daysFourteen.
  ///
  /// In en, this message translates to:
  /// **'14 days'**
  String get daysFourteen;

  /// No description provided for @endsOn.
  ///
  /// In en, this message translates to:
  /// **'Plan ends (optional)'**
  String get endsOn;

  /// No description provided for @trialEndsOn.
  ///
  /// In en, this message translates to:
  /// **'Trial ends (optional)'**
  String get trialEndsOn;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @cancelUrl.
  ///
  /// In en, this message translates to:
  /// **'Manage / cancel URL'**
  String get cancelUrl;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage with provider'**
  String get manage;

  /// No description provided for @manageHelp.
  ///
  /// In en, this message translates to:
  /// **'Opens the provider website. Ritmia does not cancel contracts or process charges.'**
  String get manageHelp;

  /// No description provided for @nextRenewal.
  ///
  /// In en, this message translates to:
  /// **'Next renewal'**
  String get nextRenewal;

  /// No description provided for @noRenewal.
  ///
  /// In en, this message translates to:
  /// **'No upcoming renewal'**
  String get noRenewal;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Renewals on this day'**
  String get events;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'A day with no renewals.'**
  String get noEvents;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get system;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get plan;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Ritmia Free'**
  String get freePlan;

  /// No description provided for @freeFeatures.
  ///
  /// In en, this message translates to:
  /// **'5 subscriptions in total, calendar, logos, reminders and all currencies.'**
  String get freeFeatures;

  /// No description provided for @proPlan.
  ///
  /// In en, this message translates to:
  /// **'Ritmia Pro'**
  String get proPlan;

  /// No description provided for @proFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlimited subscriptions. Activation through a server-verified purchase.'**
  String get proFeatures;

  /// No description provided for @proPending.
  ///
  /// In en, this message translates to:
  /// **'Purchases are not enabled yet.'**
  String get proPending;

  /// No description provided for @limitMessage.
  ///
  /// In en, this message translates to:
  /// **'You reached the free limit of 5 subscriptions. Delete one to add another.'**
  String get limitMessage;

  /// No description provided for @quotaHelp.
  ///
  /// In en, this message translates to:
  /// **'Paused and archived records also occupy a slot.'**
  String get quotaHelp;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get export;

  /// No description provided for @exportHelp.
  ///
  /// In en, this message translates to:
  /// **'Export your records. Logos are not included.'**
  String get exportHelp;

  /// No description provided for @notificationToggle.
  ///
  /// In en, this message translates to:
  /// **'Alerts on this device'**
  String get notificationToggle;

  /// No description provided for @notificationHelp.
  ///
  /// In en, this message translates to:
  /// **'Schedules the next 60 days (up to 60 alerts). Open the app to refresh the schedule.'**
  String get notificationHelp;

  /// No description provided for @webNotificationHelp.
  ///
  /// In en, this message translates to:
  /// **'On web, closed-app alerts use email once Firebase and the email provider are configured.'**
  String get webNotificationHelp;

  /// No description provided for @emailToggle.
  ///
  /// In en, this message translates to:
  /// **'Email reminders'**
  String get emailToggle;

  /// No description provided for @emailHelp.
  ///
  /// In en, this message translates to:
  /// **'Requires a verified email account. Sends at 09:00 in your time zone.'**
  String get emailHelp;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications in your device settings.'**
  String get permissionDenied;

  /// No description provided for @notificationError.
  ///
  /// In en, this message translates to:
  /// **'Could not update alerts. Check permissions and reopen the app.'**
  String get notificationError;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHelp.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters.'**
  String get passwordHelp;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPassword;

  /// No description provided for @resetSent.
  ///
  /// In en, this message translates to:
  /// **'If the account exists, you will receive a password reset email.'**
  String get resetSent;

  /// No description provided for @verificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent. Check your inbox.'**
  String get verificationSent;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verifyEmail;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get verified;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Use a password with at least 8 characters.'**
  String get weakPassword;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'That email already has an account.'**
  String get emailInUse;

  /// No description provided for @credentialsError.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with those credentials.'**
  String get credentialsError;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait.'**
  String get tooManyRequests;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'No connection. Try again.'**
  String get networkError;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the action. Try again.'**
  String get genericError;

  /// No description provided for @conflictMessage.
  ///
  /// In en, this message translates to:
  /// **'This record changed on another device. Close and reopen the editor.'**
  String get conflictMessage;

  /// No description provided for @imageError.
  ///
  /// In en, this message translates to:
  /// **'Use a PNG/JPG/WebP image that can be reduced to 128 KB.'**
  String get imageError;

  /// No description provided for @preconditionError.
  ///
  /// In en, this message translates to:
  /// **'Verify your email or check your Firebase configuration.'**
  String get preconditionError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @logoPartialError.
  ///
  /// In en, this message translates to:
  /// **'Record saved, but logo upload failed. Open it to retry.'**
  String get logoPartialError;

  /// No description provided for @reminderRenewal.
  ///
  /// In en, this message translates to:
  /// **'A renewal is coming'**
  String get reminderRenewal;

  /// No description provided for @reminderTrial.
  ///
  /// In en, this message translates to:
  /// **'Your trial is ending'**
  String get reminderTrial;

  /// No description provided for @reminderEnding.
  ///
  /// In en, this message translates to:
  /// **'Your plan is ending'**
  String get reminderEnding;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'Review your subscription before the indicated date.'**
  String get reminderBody;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Your data is used to manage your subscriptions and the alerts you enable.'**
  String get privacy;

  /// No description provided for @cloudSetupError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to Firebase. Check docs/FIREBASE.md and startup configuration.'**
  String get cloudSetupError;

  /// No description provided for @searchBrands.
  ///
  /// In en, this message translates to:
  /// **'Search all service brands'**
  String get searchBrands;

  /// No description provided for @catalogHelp.
  ///
  /// In en, this message translates to:
  /// **'Showing up to 12 matches. Search any brand in the catalog.'**
  String get catalogHelp;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Find my rhythm'**
  String get getStarted;

  /// No description provided for @onboardEyebrowOne.
  ///
  /// In en, this message translates to:
  /// **'Less noise. More clarity.'**
  String get onboardEyebrowOne;

  /// No description provided for @onboardTitleOne.
  ///
  /// In en, this message translates to:
  /// **'Everything recurring,\none calm place.'**
  String get onboardTitleOne;

  /// No description provided for @onboardBodyOne.
  ///
  /// In en, this message translates to:
  /// **'Bring your free and paid subscriptions together. Give each its color, logo and a place of its own.'**
  String get onboardBodyOne;

  /// No description provided for @onboardEyebrowTwo.
  ///
  /// In en, this message translates to:
  /// **'Your month, at a glance'**
  String get onboardEyebrowTwo;

  /// No description provided for @onboardTitleTwo.
  ///
  /// In en, this message translates to:
  /// **'No more surprise\nrenewals.'**
  String get onboardTitleTwo;

  /// No description provided for @onboardBodyTwo.
  ///
  /// In en, this message translates to:
  /// **'See renewals on the calendar and expected charges in each currency. No mental arithmetic.'**
  String get onboardBodyTwo;

  /// No description provided for @onboardEyebrowThree.
  ///
  /// In en, this message translates to:
  /// **'You decide what stays'**
  String get onboardEyebrowThree;

  /// No description provided for @onboardTitleThree.
  ///
  /// In en, this message translates to:
  /// **'A timely reminder.\nA calmer decision.'**
  String get onboardTitleThree;

  /// No description provided for @onboardBodyThree.
  ///
  /// In en, this message translates to:
  /// **'Choose alerts before renewals or trial endings. When you want to cancel, open your provider\'s link.'**
  String get onboardBodyThree;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @subscriptionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 subscriptions} =1{1 subscription} other{{count} subscriptions}}'**
  String subscriptionCount(int count);

  /// No description provided for @subscriptionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptionsHeading;

  /// No description provided for @perWeek.
  ///
  /// In en, this message translates to:
  /// **'/ week'**
  String get perWeek;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get perMonth;

  /// No description provided for @perQuarter.
  ///
  /// In en, this message translates to:
  /// **'/ quarter'**
  String get perQuarter;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get perYear;

  /// No description provided for @renewalLabel.
  ///
  /// In en, this message translates to:
  /// **'{cycle} renewal'**
  String renewalLabel(String cycle);

  /// No description provided for @tapDateHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a date to see its renewals'**
  String get tapDateHint;

  /// No description provided for @openCalendar.
  ///
  /// In en, this message translates to:
  /// **'Open calendar'**
  String get openCalendar;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @searchService.
  ///
  /// In en, this message translates to:
  /// **'Search a service'**
  String get searchService;

  /// No description provided for @tabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabAll;

  /// No description provided for @tabAi.
  ///
  /// In en, this message translates to:
  /// **'Artificial intelligence'**
  String get tabAi;

  /// No description provided for @addCustom.
  ///
  /// In en, this message translates to:
  /// **'Add custom service'**
  String get addCustom;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No services match your search.'**
  String get noResults;

  /// No description provided for @daysBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysBefore(int count);

  /// No description provided for @remindersBefore.
  ///
  /// In en, this message translates to:
  /// **'{list} before'**
  String remindersBefore(String list);

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders'**
  String get noReminders;

  /// No description provided for @colorAndIcon.
  ///
  /// In en, this message translates to:
  /// **'Color and icon'**
  String get colorAndIcon;

  /// No description provided for @providerHelp.
  ///
  /// In en, this message translates to:
  /// **'Cancel your plan on the {name} website.'**
  String providerHelp(String name);

  /// No description provided for @noProviderLink.
  ///
  /// In en, this message translates to:
  /// **'Add the provider link when editing.'**
  String get noProviderLink;

  /// No description provided for @pauseTracking.
  ///
  /// In en, this message translates to:
  /// **'Pause tracking'**
  String get pauseTracking;

  /// No description provided for @resumeTracking.
  ///
  /// In en, this message translates to:
  /// **'Resume tracking'**
  String get resumeTracking;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get deleteRecord;

  /// No description provided for @notCancelHelp.
  ///
  /// In en, this message translates to:
  /// **'This does not cancel your plan with the provider.'**
  String get notCancelHelp;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @renewsToday.
  ///
  /// In en, this message translates to:
  /// **'Renews today'**
  String get renewsToday;

  /// No description provided for @notifChannel.
  ///
  /// In en, this message translates to:
  /// **'Renewal reminders'**
  String get notifChannel;

  /// No description provided for @notifChannelHelp.
  ///
  /// In en, this message translates to:
  /// **'Heads-up before renewals, trial ends and plan ends.'**
  String get notifChannelHelp;

  /// No description provided for @notifToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get notifToday;

  /// No description provided for @notifTomorrow.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get notifTomorrow;

  /// No description provided for @notifInDays.
  ///
  /// In en, this message translates to:
  /// **'in {count} days'**
  String notifInDays(int count);

  /// No description provided for @notifRenewalTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} renews {when}'**
  String notifRenewalTitle(String name, String when);

  /// No description provided for @notifTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} trial ends {when}'**
  String notifTrialTitle(String name, String when);

  /// No description provided for @notifEndingTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} plan ends {when}'**
  String notifEndingTitle(String name, String when);

  /// No description provided for @notifRenewalBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} · {day}. Still using it? There\'s time to decide calmly.'**
  String notifRenewalBody(String amount, String day);

  /// No description provided for @notifOtherBody.
  ///
  /// In en, this message translates to:
  /// **'{day}. Check whether you want to continue.'**
  String notifOtherBody(String day);

  /// No description provided for @permTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders, right on time'**
  String get permTitle;

  /// No description provided for @permBody.
  ///
  /// In en, this message translates to:
  /// **'Ritmia lets you know at 9:00 before a renewal, a trial end or a plan end. Only your reminders — never ads.'**
  String get permBody;

  /// No description provided for @permPointOne.
  ///
  /// In en, this message translates to:
  /// **'You choose 1, 3, 7 or 14 days before'**
  String get permPointOne;

  /// No description provided for @permPointTwo.
  ///
  /// In en, this message translates to:
  /// **'Works offline, on this device'**
  String get permPointTwo;

  /// No description provided for @permPointThree.
  ///
  /// In en, this message translates to:
  /// **'Turn them off any time in Settings'**
  String get permPointThree;

  /// No description provided for @permAllow.
  ///
  /// In en, this message translates to:
  /// **'Turn on reminders'**
  String get permAllow;

  /// No description provided for @permLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permLater;

  /// No description provided for @permGranted.
  ///
  /// In en, this message translates to:
  /// **'Reminders are on.'**
  String get permGranted;

  /// No description provided for @permDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked'**
  String get permDeniedTitle;

  /// No description provided for @permDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Android is blocking Ritmia\'s notifications. Turn them on in Phone settings › Apps › Ritmia › Notifications, then come back.'**
  String get permDeniedBody;

  /// No description provided for @permBlockedBanner.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked in phone settings.'**
  String get permBlockedBanner;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get understood;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @priceSection.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceSection;

  /// No description provided for @paidOption.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidOption;

  /// No description provided for @freeOption.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeOption;

  /// No description provided for @becomesPaid.
  ///
  /// In en, this message translates to:
  /// **'Becomes paid later'**
  String get becomesPaid;

  /// No description provided for @becomesPaidHelp.
  ///
  /// In en, this message translates to:
  /// **'Set the day charges start and how much they will be.'**
  String get becomesPaidHelp;

  /// No description provided for @paidFrom.
  ///
  /// In en, this message translates to:
  /// **'Charges start on'**
  String get paidFrom;

  /// No description provided for @amountAfter.
  ///
  /// In en, this message translates to:
  /// **'Amount after that'**
  String get amountAfter;

  /// No description provided for @purchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase date'**
  String get purchaseDate;

  /// No description provided for @purchaseHelp.
  ///
  /// In en, this message translates to:
  /// **'It renews every cycle from this day. Renewals appear in the calendar.'**
  String get purchaseHelp;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @nextRenewalPreview.
  ///
  /// In en, this message translates to:
  /// **'Next renewal: {date}'**
  String nextRenewalPreview(String date);

  /// No description provided for @freeUntilPreview.
  ///
  /// In en, this message translates to:
  /// **'Free until {date}, then {amount}'**
  String freeUntilPreview(String date, String amount);

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @searchCurrency.
  ///
  /// In en, this message translates to:
  /// **'Search currency'**
  String get searchCurrency;

  /// No description provided for @customLook.
  ///
  /// In en, this message translates to:
  /// **'Color and logo'**
  String get customLook;

  /// No description provided for @serviceName.
  ///
  /// In en, this message translates to:
  /// **'Service name'**
  String get serviceName;

  /// No description provided for @chooseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get chooseCurrency;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get dataSection;

  /// No description provided for @openPhoneSettings.
  ///
  /// In en, this message translates to:
  /// **'Open phone settings'**
  String get openPhoneSettings;

  /// No description provided for @notifOnSummary.
  ///
  /// In en, this message translates to:
  /// **'On · 9:00 before each renewal'**
  String get notifOnSummary;

  /// No description provided for @notifOffSummary.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get notifOffSummary;

  /// No description provided for @notifBlockedSummary.
  ///
  /// In en, this message translates to:
  /// **'Blocked in phone settings'**
  String get notifBlockedSummary;

  /// No description provided for @appearanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSummary;

  /// No description provided for @languageSummary.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSummary;

  /// No description provided for @autoRenew.
  ///
  /// In en, this message translates to:
  /// **'Renewal'**
  String get autoRenew;

  /// No description provided for @willRenew.
  ///
  /// In en, this message translates to:
  /// **'Renews'**
  String get willRenew;

  /// No description provided for @stopRenewing.
  ///
  /// In en, this message translates to:
  /// **'Don\'t renew'**
  String get stopRenewing;

  /// No description provided for @resumeRenewing.
  ///
  /// In en, this message translates to:
  /// **'Renew again'**
  String get resumeRenewing;

  /// No description provided for @notRenewing.
  ///
  /// In en, this message translates to:
  /// **'Won\'t renew'**
  String get notRenewing;

  /// No description provided for @cancelBefore.
  ///
  /// In en, this message translates to:
  /// **'Cancel before {date}'**
  String cancelBefore(String date);

  /// No description provided for @rowNotRenewing.
  ///
  /// In en, this message translates to:
  /// **'Don\'t renew · {date}'**
  String rowNotRenewing(String date);

  /// No description provided for @stopRenewHelp.
  ///
  /// In en, this message translates to:
  /// **'Ritmia marks the deadline to cancel with the provider before the next charge.'**
  String get stopRenewHelp;

  /// No description provided for @stopRenewTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop renewing {name}?'**
  String stopRenewTitle(String name);

  /// No description provided for @stopRenewBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see {date} as your deadline to cancel, with reminders before it. Ritmia doesn\'t cancel the plan for you.'**
  String stopRenewBody(String date);

  /// No description provided for @endsHere.
  ///
  /// In en, this message translates to:
  /// **'Last day · don\'t renew'**
  String get endsHere;

  /// No description provided for @chooseIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get chooseIcon;

  /// No description provided for @uploadOwn.
  ///
  /// In en, this message translates to:
  /// **'Upload your own image'**
  String get uploadOwn;

  /// No description provided for @purchasedHere.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchasedHere;

  /// No description provided for @widgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Home screen widget'**
  String get widgetTitle;

  /// No description provided for @widgetHelp.
  ///
  /// In en, this message translates to:
  /// **'Your next three plans, with cancellation deadlines first.'**
  String get widgetHelp;

  /// No description provided for @widgetCompactTitle.
  ///
  /// In en, this message translates to:
  /// **'Compact row widget'**
  String get widgetCompactTitle;

  /// No description provided for @widgetCompactHelp.
  ///
  /// In en, this message translates to:
  /// **'Single row (3 to 4 columns) with your next plans.'**
  String get widgetCompactHelp;

  /// No description provided for @widgetManual.
  ///
  /// In en, this message translates to:
  /// **'Long-press an empty area on your home screen → Widgets → Ritmia.'**
  String get widgetManual;

  /// No description provided for @notifCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel {name} {when}'**
  String notifCancelTitle(String name, String when);

  /// No description provided for @notifCancelBody.
  ///
  /// In en, this message translates to:
  /// **'Avoid the next {amount} charge. Deadline: {date}. Open Ritmia to review this plan.'**
  String notifCancelBody(String amount, String date);

  /// No description provided for @notifScheduleError.
  ///
  /// In en, this message translates to:
  /// **'Reminders are enabled, but scheduling failed. Try again.'**
  String get notifScheduleError;

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to device calendar'**
  String get addToCalendar;

  /// No description provided for @calendarAddHelp.
  ///
  /// In en, this message translates to:
  /// **'Review and save this date in your calendar app.'**
  String get calendarAddHelp;

  /// No description provided for @calendarExport.
  ///
  /// In en, this message translates to:
  /// **'Export to calendar'**
  String get calendarExport;

  /// No description provided for @calendarExportHelp.
  ///
  /// In en, this message translates to:
  /// **'Next 12 months · up to 1,000 dates · .ics file'**
  String get calendarExportHelp;

  /// No description provided for @calendarNoDates.
  ///
  /// In en, this message translates to:
  /// **'No upcoming dates to add.'**
  String get calendarNoDates;

  /// No description provided for @calendarOpened.
  ///
  /// In en, this message translates to:
  /// **'Review the event and save it in your calendar.'**
  String get calendarOpened;

  /// No description provided for @calendarRenewalTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} renewal'**
  String calendarRenewalTitle(String name);

  /// No description provided for @calendarTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} trial ends'**
  String calendarTrialTitle(String name);

  /// No description provided for @calendarCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel {name}'**
  String calendarCancelTitle(String name);

  /// No description provided for @calendarEventHelp.
  ///
  /// In en, this message translates to:
  /// **'Tracked in Ritmia. Changing this event does not change your subscription or cancel your plan.'**
  String get calendarEventHelp;

  /// No description provided for @notificationTest.
  ///
  /// In en, this message translates to:
  /// **'Send a test alert'**
  String get notificationTest;

  /// No description provided for @notificationTestSent.
  ///
  /// In en, this message translates to:
  /// **'Test alert sent. Check your notification panel.'**
  String get notificationTestSent;

  /// No description provided for @notifTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Ritmia reminders are ready'**
  String get notifTestTitle;

  /// No description provided for @notifTestBody.
  ///
  /// In en, this message translates to:
  /// **'This is a test alert. Your subscription reminders will appear here.'**
  String get notifTestBody;

  /// No description provided for @guidedTour.
  ///
  /// In en, this message translates to:
  /// **'Create a subscription step by step'**
  String get guidedTour;

  /// No description provided for @guidedTourHelp.
  ///
  /// In en, this message translates to:
  /// **'A guided tour that highlights the controls as you use the app.'**
  String get guidedTourHelp;

  /// No description provided for @tourProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String tourProgress(int current, int total);

  /// No description provided for @tourSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip tour'**
  String get tourSkip;

  /// No description provided for @tourNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get tourNext;

  /// No description provided for @tourBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tourBack;

  /// No description provided for @tourFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get tourFinish;

  /// No description provided for @tourAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first subscription'**
  String get tourAddTitle;

  /// No description provided for @tourAddBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the highlighted button. You’ll create a real record; you can skip this tour at any time.'**
  String get tourAddBody;

  /// No description provided for @tourBrandTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a brand'**
  String get tourBrandTitle;

  /// No description provided for @tourBrandBody.
  ///
  /// In en, this message translates to:
  /// **'Search for your service and tap its name. You can also create a custom one. Logos are already in the app.'**
  String get tourBrandBody;

  /// No description provided for @tourNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Give it a name'**
  String get tourNameTitle;

  /// No description provided for @tourNameBody.
  ///
  /// In en, this message translates to:
  /// **'The brand fills in the name and logo. Change the name to distinguish a plan or account.'**
  String get tourNameBody;

  /// No description provided for @tourPriceTitle.
  ///
  /// In en, this message translates to:
  /// **'Free or paid?'**
  String get tourPriceTitle;

  /// No description provided for @tourPriceBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the plan type. For paid plans, enter the amount, choose the currency and how often you are charged.'**
  String get tourPriceBody;

  /// No description provided for @tourDateTitle.
  ///
  /// In en, this message translates to:
  /// **'When did you buy it?'**
  String get tourDateTitle;

  /// No description provided for @tourDateBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the purchase date. Ritmia calculates the next renewal from that day and your billing cycle.'**
  String get tourDateBody;

  /// No description provided for @tourRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your reminders'**
  String get tourRemindersTitle;

  /// No description provided for @tourRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Select how many days before to be reminded. You can choose several. Alerts need your phone’s permission.'**
  String get tourRemindersBody;

  /// No description provided for @tourSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your subscription'**
  String get tourSaveTitle;

  /// No description provided for @tourSaveBody.
  ///
  /// In en, this message translates to:
  /// **'Tap Save to create the record. If a detail is missing, go back to the previous step to complete it.'**
  String get tourSaveBody;

  /// No description provided for @tourRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Here’s your plan'**
  String get tourRecordTitle;

  /// No description provided for @tourRecordBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the subscription for its details. You can mark Don’t renew there; those plans appear first.'**
  String get tourRecordBody;

  /// No description provided for @tourCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'See your dates'**
  String get tourCalendarTitle;

  /// No description provided for @tourCalendarBody.
  ///
  /// In en, this message translates to:
  /// **'Open the calendar to review renewals. You can add a date to your phone’s calendar from the plan details.'**
  String get tourCalendarBody;

  /// No description provided for @tourFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Find what you need'**
  String get tourFilterTitle;

  /// No description provided for @tourFilterBody.
  ///
  /// In en, this message translates to:
  /// **'Filter by Renews or Don’t renew. Combine it with a search by name or notes.'**
  String get tourFilterBody;

  /// No description provided for @tourSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get tourSettingsTitle;

  /// No description provided for @tourSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on and test alerts, choose a language or theme, add the widget and export dates to your calendar here.'**
  String get tourSettingsBody;

  /// No description provided for @notificationSetupError.
  ///
  /// In en, this message translates to:
  /// **'Could not start reminders. Update Ritmia or try again.'**
  String get notificationSetupError;

  /// No description provided for @proBadge.
  ///
  /// In en, this message translates to:
  /// **'ONE-TIME PURCHASE · FOREVER'**
  String get proBadge;

  /// No description provided for @proSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock everything in Ritmia with a single payment, without adding another subscription to your month.'**
  String get proSubtitle;

  /// No description provided for @proBenefitUnlimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited subscriptions'**
  String get proBenefitUnlimitedTitle;

  /// No description provided for @proBenefitUnlimitedBody.
  ///
  /// In en, this message translates to:
  /// **'Track all your active, paused and archived services without the 5-slot limit.'**
  String get proBenefitUnlimitedBody;

  /// No description provided for @proBenefitNoAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get proBenefitNoAdsTitle;

  /// No description provided for @proBenefitNoAdsBody.
  ///
  /// In en, this message translates to:
  /// **'Remove occasional ads for a clean, uninterrupted experience.'**
  String get proBenefitNoAdsBody;

  /// No description provided for @proBenefitOneTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'One-time lifetime payment'**
  String get proBenefitOneTimeTitle;

  /// No description provided for @proBenefitOneTimeBody.
  ///
  /// In en, this message translates to:
  /// **'Pay once and keep Ritmia Pro forever.'**
  String get proBenefitOneTimeBody;

  /// No description provided for @proUnlockCta.
  ///
  /// In en, this message translates to:
  /// **'Unlock Ritmia Pro'**
  String get proUnlockCta;

  /// No description provided for @proRestoreCta.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get proRestoreCta;

  /// No description provided for @proActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Active · One-time purchase'**
  String get proActiveBadge;

  /// No description provided for @proRestoreEmpty.
  ///
  /// In en, this message translates to:
  /// **'No previous Ritmia Pro purchase was found.'**
  String get proRestoreEmpty;

  /// No description provided for @adInterstitialLabel.
  ///
  /// In en, this message translates to:
  /// **'SPONSORED'**
  String get adInterstitialLabel;

  /// No description provided for @adInterstitialTitle.
  ///
  /// In en, this message translates to:
  /// **'Go ad-free with Ritmia Pro'**
  String get adInterstitialTitle;

  /// No description provided for @adInterstitialBody.
  ///
  /// In en, this message translates to:
  /// **'With a one-time payment you remove occasional ads and unlock unlimited subscriptions forever.'**
  String get adInterstitialBody;

  /// No description provided for @adContinueFree.
  ///
  /// In en, this message translates to:
  /// **'Continue with Ritmia Free'**
  String get adContinueFree;
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
      <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
