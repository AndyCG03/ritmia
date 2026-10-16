// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tagline => 'Your subscriptions. Your rhythm.';

  @override
  String get home => 'Overview';

  @override
  String get calendar => 'Calendar';

  @override
  String get settings => 'Settings';

  @override
  String get add => 'Add subscription';

  @override
  String get edit => 'Edit subscription';

  @override
  String get subscriptions => 'Your subscriptions';

  @override
  String get emptyTitle => 'Make room for what matters.';

  @override
  String get emptyBody =>
      'Add your first subscription. See what it costs and when it renews.';

  @override
  String get monthCharges => 'Expected charges this month';

  @override
  String get noCharges => 'No expected charges';

  @override
  String get localMode => 'Local mode · data on this device';

  @override
  String get all => 'All';

  @override
  String get paid => 'Paid';

  @override
  String get free => 'Free';

  @override
  String get active => 'Active';

  @override
  String get paused => 'Paused';

  @override
  String get archived => 'Archived';

  @override
  String get search => 'Search name or notes';

  @override
  String get name => 'Name';

  @override
  String get amount => 'Amount per cycle';

  @override
  String get currency => 'Currency';

  @override
  String get billingCycle => 'Billing cycle';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get quarterly => 'Quarterly';

  @override
  String get yearly => 'Yearly';

  @override
  String get anchorDate => 'First renewal / anchor date';

  @override
  String get color => 'Color';

  @override
  String get logo => 'Custom logo';

  @override
  String get uploadLogo => 'Upload image';

  @override
  String get removeLogo => 'Remove image';

  @override
  String get logoHelp => 'PNG/JPG/WebP · optimized to 256 px and up to 128 KB.';

  @override
  String get catalog => 'Choose a service';

  @override
  String get notes => 'Notes';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Back';

  @override
  String get delete => 'Delete';

  @override
  String get deleteTitle => 'Delete this subscription?';

  @override
  String get deleteBody =>
      'This deletes the Ritmia record. Your contract with the provider stays active.';

  @override
  String get saved => 'Subscription saved';

  @override
  String get invalidName => 'Enter a name of up to 80 characters.';

  @override
  String get invalidAmount =>
      'Enter a valid amount greater than zero, with no thousands separators.';

  @override
  String get invalidUrl => 'Use a valid https address.';

  @override
  String get dateOrder => 'The end date must follow the anchor date.';

  @override
  String get status => 'Status';

  @override
  String get category => 'Category';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get productivity => 'Productivity';

  @override
  String get storageCategory => 'Storage';

  @override
  String get education => 'Education';

  @override
  String get health => 'Health';

  @override
  String get utilities => 'Utilities';

  @override
  String get other => 'Other';

  @override
  String get reminders => 'Reminders';

  @override
  String get reminderHelp =>
      'Notify at 09:00 before renewal, trial end or plan end.';

  @override
  String get daysOne => '1 day';

  @override
  String get daysThree => '3 days';

  @override
  String get daysSeven => '7 days';

  @override
  String get daysFourteen => '14 days';

  @override
  String get endsOn => 'Plan ends (optional)';

  @override
  String get trialEndsOn => 'Trial ends (optional)';

  @override
  String get clear => 'Clear';

  @override
  String get cancelUrl => 'Manage / cancel URL';

  @override
  String get manage => 'Manage with provider';

  @override
  String get manageHelp =>
      'Opens the provider website. Ritmia does not cancel contracts or process charges.';

  @override
  String get nextRenewal => 'Next renewal';

  @override
  String get noRenewal => 'No upcoming renewal';

  @override
  String get events => 'Renewals on this day';

  @override
  String get noEvents => 'A day with no renewals.';

  @override
  String get today => 'Today';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get language => 'Language';

  @override
  String get system => 'System default';

  @override
  String get plan => 'Your plan';

  @override
  String get freePlan => 'Ritmia Free';

  @override
  String get freeFeatures =>
      '5 subscriptions in total, calendar, logos, reminders and all currencies.';

  @override
  String get proPlan => 'Ritmia Pro';

  @override
  String get proFeatures =>
      'Unlimited subscriptions. Activation through a server-verified purchase.';

  @override
  String get proPending => 'Purchases are not enabled yet.';

  @override
  String get limitMessage =>
      'You reached the free limit of 5 subscriptions. Delete one to add another.';

  @override
  String get quotaHelp => 'Paused and archived records also occupy a slot.';

  @override
  String get export => 'Export CSV';

  @override
  String get exportHelp => 'Export your records. Logos are not included.';

  @override
  String get notificationToggle => 'Alerts on this device';

  @override
  String get notificationHelp =>
      'Schedules the next 60 days (up to 60 alerts). Open the app to refresh the schedule.';

  @override
  String get webNotificationHelp =>
      'On web, closed-app alerts use email once Firebase and the email provider are configured.';

  @override
  String get emailToggle => 'Email reminders';

  @override
  String get emailHelp =>
      'Requires a verified email account. Sends at 09:00 in your time zone.';

  @override
  String get permissionDenied => 'Allow notifications in your device settings.';

  @override
  String get notificationError =>
      'Could not update alerts. Check permissions and reopen the app.';

  @override
  String get account => 'Account';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get passwordHelp => 'At least 8 characters.';

  @override
  String get forgotPassword => 'Reset password';

  @override
  String get resetSent =>
      'If the account exists, you will receive a password reset email.';

  @override
  String get verificationSent => 'Verification email sent. Check your inbox.';

  @override
  String get verifyEmail => 'Verify email';

  @override
  String get signOut => 'Sign out';

  @override
  String get verified => 'Email verified';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get weakPassword => 'Use a password with at least 8 characters.';

  @override
  String get emailInUse => 'That email already has an account.';

  @override
  String get credentialsError => 'Could not sign in with those credentials.';

  @override
  String get tooManyRequests => 'Too many attempts. Please wait.';

  @override
  String get networkError => 'No connection. Try again.';

  @override
  String get genericError => 'Could not complete the action. Try again.';

  @override
  String get conflictMessage =>
      'This record changed on another device. Close and reopen the editor.';

  @override
  String get imageError =>
      'Use a PNG/JPG/WebP image that can be reduced to 128 KB.';

  @override
  String get preconditionError =>
      'Verify your email or check your Firebase configuration.';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading';

  @override
  String get logoPartialError =>
      'Record saved, but logo upload failed. Open it to retry.';

  @override
  String get reminderRenewal => 'A renewal is coming';

  @override
  String get reminderTrial => 'Your trial is ending';

  @override
  String get reminderEnding => 'Your plan is ending';

  @override
  String get reminderBody =>
      'Review your subscription before the indicated date.';

  @override
  String get privacy =>
      'Your data is used to manage your subscriptions and the alerts you enable.';

  @override
  String get cloudSetupError =>
      'Could not connect to Firebase. Check docs/FIREBASE.md and startup configuration.';

  @override
  String get searchBrands => 'Search all service brands';

  @override
  String get catalogHelp =>
      'Showing up to 12 matches. Search any brand in the catalog.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Find my rhythm';

  @override
  String get onboardEyebrowOne => 'Less noise. More clarity.';

  @override
  String get onboardTitleOne => 'Everything recurring,\none calm place.';

  @override
  String get onboardBodyOne =>
      'Bring your free and paid subscriptions together. Give each its color, logo and a place of its own.';

  @override
  String get onboardEyebrowTwo => 'Your month, at a glance';

  @override
  String get onboardTitleTwo => 'No more surprise\nrenewals.';

  @override
  String get onboardBodyTwo =>
      'See renewals on the calendar and expected charges in each currency. No mental arithmetic.';

  @override
  String get onboardEyebrowThree => 'You decide what stays';

  @override
  String get onboardTitleThree => 'A timely reminder.\nA calmer decision.';

  @override
  String get onboardBodyThree =>
      'Choose alerts before renewals or trial endings. When you want to cancel, open your provider\'s link.';

  @override
  String get thisMonth => 'This month';

  @override
  String subscriptionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions',
      one: '1 subscription',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionsHeading => 'Subscriptions';

  @override
  String get perWeek => '/ week';

  @override
  String get perMonth => '/ month';

  @override
  String get perQuarter => '/ quarter';

  @override
  String get perYear => '/ year';

  @override
  String renewalLabel(String cycle) {
    return '$cycle renewal';
  }

  @override
  String get tapDateHint => 'Tap a date to see its renewals';

  @override
  String get openCalendar => 'Open calendar';

  @override
  String get close => 'Close';

  @override
  String get filter => 'Filter';

  @override
  String get searchService => 'Search a service';

  @override
  String get tabAll => 'All';

  @override
  String get tabAi => 'Artificial intelligence';

  @override
  String get addCustom => 'Add custom service';

  @override
  String get noResults => 'No services match your search.';

  @override
  String daysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String remindersBefore(String list) {
    return '$list before';
  }

  @override
  String get and => 'and';

  @override
  String get noReminders => 'No reminders';

  @override
  String get colorAndIcon => 'Color and icon';

  @override
  String providerHelp(String name) {
    return 'Cancel your plan on the $name website.';
  }

  @override
  String get noProviderLink => 'Add the provider link when editing.';

  @override
  String get pauseTracking => 'Pause tracking';

  @override
  String get resumeTracking => 'Resume tracking';

  @override
  String get deleteRecord => 'Delete record';

  @override
  String get notCancelHelp =>
      'This does not cancel your plan with the provider.';

  @override
  String get theme => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get renewsToday => 'Renews today';

  @override
  String get notifChannel => 'Renewal reminders';

  @override
  String get notifChannelHelp =>
      'Heads-up before renewals, trial ends and plan ends.';

  @override
  String get notifToday => 'today';

  @override
  String get notifTomorrow => 'tomorrow';

  @override
  String notifInDays(int count) {
    return 'in $count days';
  }

  @override
  String notifRenewalTitle(String name, String when) {
    return '$name renews $when';
  }

  @override
  String notifTrialTitle(String name, String when) {
    return '$name trial ends $when';
  }

  @override
  String notifEndingTitle(String name, String when) {
    return '$name plan ends $when';
  }

  @override
  String notifRenewalBody(String amount, String day) {
    return '$amount · $day. Still using it? There\'s time to decide calmly.';
  }

  @override
  String notifOtherBody(String day) {
    return '$day. Check whether you want to continue.';
  }

  @override
  String get permTitle => 'Reminders, right on time';

  @override
  String get permBody =>
      'Ritmia lets you know at 9:00 before a renewal, a trial end or a plan end. Only your reminders — never ads.';

  @override
  String get permPointOne => 'You choose 1, 3, 7 or 14 days before';

  @override
  String get permPointTwo => 'Works offline, on this device';

  @override
  String get permPointThree => 'Turn them off any time in Settings';

  @override
  String get permAllow => 'Turn on reminders';

  @override
  String get permLater => 'Not now';

  @override
  String get permGranted => 'Reminders are on.';

  @override
  String get permDeniedTitle => 'Notifications are blocked';

  @override
  String get permDeniedBody =>
      'Android is blocking Ritmia\'s notifications. Turn them on in Phone settings › Apps › Ritmia › Notifications, then come back.';

  @override
  String get permBlockedBanner =>
      'Notifications are blocked in phone settings.';

  @override
  String get understood => 'Got it';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get priceSection => 'Price';

  @override
  String get paidOption => 'Paid';

  @override
  String get freeOption => 'Free';

  @override
  String get becomesPaid => 'Becomes paid later';

  @override
  String get becomesPaidHelp =>
      'Set the day charges start and how much they will be.';

  @override
  String get paidFrom => 'Charges start on';

  @override
  String get amountAfter => 'Amount after that';

  @override
  String get purchaseDate => 'Purchase date';

  @override
  String get purchaseHelp =>
      'It renews every cycle from this day. Renewals appear in the calendar.';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get pickDate => 'Pick a date';

  @override
  String nextRenewalPreview(String date) {
    return 'Next renewal: $date';
  }

  @override
  String freeUntilPreview(String date, String amount) {
    return 'Free until $date, then $amount';
  }

  @override
  String get moreOptions => 'More options';

  @override
  String get searchCurrency => 'Search currency';

  @override
  String get customLook => 'Color and logo';

  @override
  String get serviceName => 'Service name';

  @override
  String get chooseCurrency => 'Currency';

  @override
  String get about => 'About';

  @override
  String get general => 'General';

  @override
  String get dataSection => 'Your data';

  @override
  String get openPhoneSettings => 'Open phone settings';

  @override
  String get notifOnSummary => 'On · 9:00 before each renewal';

  @override
  String get notifOffSummary => 'Off';

  @override
  String get notifBlockedSummary => 'Blocked in phone settings';

  @override
  String get appearanceSummary => 'Appearance';

  @override
  String get languageSummary => 'Language';

  @override
  String get autoRenew => 'Renewal';

  @override
  String get willRenew => 'Renews';

  @override
  String get stopRenewing => 'Don\'t renew';

  @override
  String get resumeRenewing => 'Renew again';

  @override
  String get notRenewing => 'Won\'t renew';

  @override
  String cancelBefore(String date) {
    return 'Cancel before $date';
  }

  @override
  String rowNotRenewing(String date) {
    return 'Don\'t renew · $date';
  }

  @override
  String get stopRenewHelp =>
      'Ritmia marks the deadline to cancel with the provider before the next charge.';

  @override
  String stopRenewTitle(String name) {
    return 'Stop renewing $name?';
  }

  @override
  String stopRenewBody(String date) {
    return 'You\'ll see $date as your deadline to cancel, with reminders before it. Ritmia doesn\'t cancel the plan for you.';
  }

  @override
  String get endsHere => 'Last day · don\'t renew';

  @override
  String get chooseIcon => 'Icon';

  @override
  String get uploadOwn => 'Upload your own image';

  @override
  String get purchasedHere => 'Purchased';
}
