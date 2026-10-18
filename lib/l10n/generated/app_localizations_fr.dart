// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get tagline => 'Vos abonnements. Votre rythme.';

  @override
  String get home => 'Aperçu';

  @override
  String get calendar => 'Calendrier';

  @override
  String get settings => 'Réglages';

  @override
  String get add => 'Ajouter un abonnement';

  @override
  String get edit => 'Modifier l\'abonnement';

  @override
  String get subscriptions => 'Vos abonnements';

  @override
  String get emptyTitle => 'Faites place à l\'essentiel.';

  @override
  String get emptyBody =>
      'Ajoutez votre premier abonnement. Retrouvez son prix et sa date de renouvellement.';

  @override
  String get monthCharges => 'Prélèvements prévus ce mois-ci';

  @override
  String get noCharges => 'Aucun prélèvement prévu';

  @override
  String get localMode => 'Mode local · données sur cet appareil';

  @override
  String get all => 'Tous';

  @override
  String get paid => 'Payant';

  @override
  String get free => 'Gratuit';

  @override
  String get active => 'Actif';

  @override
  String get paused => 'En pause';

  @override
  String get archived => 'Archivé';

  @override
  String get search => 'Rechercher un nom ou une note';

  @override
  String get name => 'Nom';

  @override
  String get amount => 'Montant par période';

  @override
  String get currency => 'Devise';

  @override
  String get billingCycle => 'Périodicité';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get monthly => 'Mensuel';

  @override
  String get quarterly => 'Trimestriel';

  @override
  String get yearly => 'Annuel';

  @override
  String get anchorDate => 'Premier renouvellement / date de référence';

  @override
  String get color => 'Couleur';

  @override
  String get logo => 'Logo personnalisé';

  @override
  String get uploadLogo => 'Importer une image';

  @override
  String get removeLogo => 'Supprimer l\'image';

  @override
  String get logoHelp => 'PNG/JPG/WebP · optimisé à 256 px et 128 Ko maximum.';

  @override
  String get catalog => 'Choisir un service';

  @override
  String get notes => 'Notes';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Retour';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteTitle => 'Supprimer cet abonnement ?';

  @override
  String get deleteBody =>
      'Le suivi dans Ritmia sera supprimé. Votre contrat avec le fournisseur restera actif.';

  @override
  String get saved => 'Abonnement enregistré';

  @override
  String get invalidName => 'Saisissez un nom de 80 caractères maximum.';

  @override
  String get invalidAmount =>
      'Saisissez un montant valide supérieur à zéro, sans séparateur de milliers.';

  @override
  String get invalidUrl => 'Utilisez une adresse https valide.';

  @override
  String get dateOrder =>
      'La date de fin ne peut pas précéder la date de début.';

  @override
  String get status => 'État';

  @override
  String get category => 'Catégorie';

  @override
  String get entertainment => 'Divertissement';

  @override
  String get productivity => 'Productivité';

  @override
  String get storageCategory => 'Stockage';

  @override
  String get education => 'Éducation';

  @override
  String get health => 'Santé';

  @override
  String get utilities => 'Services';

  @override
  String get other => 'Autre';

  @override
  String get reminders => 'Rappels';

  @override
  String get reminderHelp =>
      'Prévenir à 09:00 avant un renouvellement, une fin d\'essai ou de forfait.';

  @override
  String get daysOne => '1 jour';

  @override
  String get daysThree => '3 jours';

  @override
  String get daysSeven => '7 jours';

  @override
  String get daysFourteen => '14 jours';

  @override
  String get endsOn => 'Fin du forfait (facultatif)';

  @override
  String get trialEndsOn => 'Fin de l\'essai (facultatif)';

  @override
  String get clear => 'Effacer';

  @override
  String get cancelUrl => 'Lien de gestion / résiliation';

  @override
  String get manage => 'Gérer chez le fournisseur';

  @override
  String get manageHelp =>
      'Ouvre le site du fournisseur. Ritmia ne résilie aucun contrat et n\'effectue aucun prélèvement.';

  @override
  String get nextRenewal => 'Prochain renouvellement';

  @override
  String get noRenewal => 'Aucun renouvellement à venir';

  @override
  String get events => 'Renouvellements ce jour-là';

  @override
  String get noEvents => 'Une journée sans renouvellement.';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get previousMonth => 'Mois précédent';

  @override
  String get nextMonth => 'Mois suivant';

  @override
  String get language => 'Langue';

  @override
  String get system => 'Langue du système';

  @override
  String get plan => 'Votre forfait';

  @override
  String get freePlan => 'Ritmia Free';

  @override
  String get freeFeatures =>
      '5 abonnements au total, calendrier, logos, rappels et toutes les devises.';

  @override
  String get proPlan => 'Ritmia Pro';

  @override
  String get proFeatures =>
      'Abonnements illimités. Activation après validation de l\'achat par le serveur.';

  @override
  String get proPending => 'Les achats ne sont pas encore disponibles.';

  @override
  String get limitMessage =>
      'Vous avez atteint la limite gratuite de 5 abonnements. Supprimez-en un pour en ajouter un autre.';

  @override
  String get quotaHelp =>
      'Les abonnements en pause et archivés occupent aussi une place.';

  @override
  String get export => 'Exporter en CSV';

  @override
  String get exportHelp =>
      'Exportez vos données. Les logos ne sont pas inclus.';

  @override
  String get notificationToggle => 'Alertes sur cet appareil';

  @override
  String get notificationHelp =>
      'Programme les 60 prochains jours (jusqu\'à 60 alertes). Ouvrez l\'app pour actualiser les rappels.';

  @override
  String get webNotificationHelp =>
      'Sur le web, les alertes lorsque l\'app est fermée utilisent l\'e-mail une fois Firebase et le service d\'envoi configurés.';

  @override
  String get emailToggle => 'Rappels par e-mail';

  @override
  String get emailHelp =>
      'Nécessite une adresse e-mail vérifiée. Envoi à 09:00 dans votre fuseau horaire.';

  @override
  String get permissionDenied =>
      'Autorisez les notifications dans les réglages de votre appareil.';

  @override
  String get notificationError =>
      'Impossible d\'actualiser les alertes. Vérifiez les autorisations et rouvrez l\'app.';

  @override
  String get account => 'Compte';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'Créer un compte';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordHelp => 'Au moins 8 caractères.';

  @override
  String get forgotPassword => 'Réinitialiser le mot de passe';

  @override
  String get resetSent =>
      'Si le compte existe, vous recevrez un e-mail de réinitialisation.';

  @override
  String get verificationSent =>
      'E-mail de vérification envoyé. Consultez votre boîte de réception.';

  @override
  String get verifyEmail => 'Vérifier l\'e-mail';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get verified => 'E-mail vérifié';

  @override
  String get invalidEmail => 'Saisissez une adresse e-mail valide.';

  @override
  String get weakPassword =>
      'Utilisez un mot de passe d\'au moins 8 caractères.';

  @override
  String get emailInUse => 'Cette adresse e-mail possède déjà un compte.';

  @override
  String get credentialsError => 'Connexion impossible avec ces identifiants.';

  @override
  String get tooManyRequests => 'Trop de tentatives. Veuillez patienter.';

  @override
  String get networkError => 'Pas de connexion. Réessayez.';

  @override
  String get genericError => 'Impossible de terminer cette action. Réessayez.';

  @override
  String get conflictMessage =>
      'Ce suivi a été modifié sur un autre appareil. Fermez et rouvrez l\'éditeur.';

  @override
  String get imageError =>
      'Utilisez une image PNG/JPG/WebP pouvant être réduite à 128 Ko.';

  @override
  String get preconditionError =>
      'Vérifiez votre e-mail ou la configuration Firebase.';

  @override
  String get retry => 'Réessayer';

  @override
  String get loading => 'Chargement';

  @override
  String get logoPartialError =>
      'Suivi enregistré, mais l\'importation du logo a échoué. Ouvrez-le pour réessayer.';

  @override
  String get reminderRenewal => 'Un renouvellement approche';

  @override
  String get reminderTrial => 'Votre essai se termine';

  @override
  String get reminderEnding => 'Votre forfait se termine';

  @override
  String get reminderBody =>
      'Vérifiez votre abonnement avant la date indiquée.';

  @override
  String get privacy =>
      'Vos données servent à gérer vos abonnements et les alertes que vous activez.';

  @override
  String get cloudSetupError =>
      'Connexion à Firebase impossible. Vérifiez docs/FIREBASE.md et la configuration de démarrage.';

  @override
  String get searchBrands => 'Rechercher parmi toutes les marques';

  @override
  String get catalogHelp =>
      'Jusqu\'à 12 résultats affichés. Recherchez une marque du catalogue.';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get getStarted => 'Trouver mon rythme';

  @override
  String get onboardEyebrowOne => 'Moins de bruit. Plus de clarté.';

  @override
  String get onboardTitleOne => 'Tout ce qui revient,\nun seul endroit serein.';

  @override
  String get onboardBodyOne =>
      'Réunissez vos abonnements gratuits et payants. Donnez à chacun sa couleur, son logo et sa place.';

  @override
  String get onboardEyebrowTwo => 'Votre mois, en un regard';

  @override
  String get onboardTitleTwo => 'Fini les renouvellements\ninattendus.';

  @override
  String get onboardBodyTwo =>
      'Retrouvez les renouvellements dans le calendrier et les dépenses prévues par devise. Sans calcul mental.';

  @override
  String get onboardEyebrowThree => 'Vous décidez ce qui reste';

  @override
  String get onboardTitleThree =>
      'Un rappel au bon moment.\nUne décision sereine.';

  @override
  String get onboardBodyThree =>
      'Choisissez des alertes avant les renouvellements ou les fins d\'essai. Pour résilier, ouvrez le lien du fournisseur.';

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String subscriptionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements',
      one: '1 abonnement',
      zero: '0 abonnement',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionsHeading => 'Abonnements';

  @override
  String get perWeek => '/ semaine';

  @override
  String get perMonth => '/ mois';

  @override
  String get perQuarter => '/ trimestre';

  @override
  String get perYear => '/ an';

  @override
  String renewalLabel(String cycle) {
    return 'Renouvellement $cycle';
  }

  @override
  String get tapDateHint => 'Touchez une date pour voir les renouvellements';

  @override
  String get openCalendar => 'Ouvrir le calendrier';

  @override
  String get close => 'Fermer';

  @override
  String get filter => 'Filtrer';

  @override
  String get searchService => 'Rechercher un service';

  @override
  String get tabAll => 'Tous';

  @override
  String get tabAi => 'Intelligence artificielle';

  @override
  String get addCustom => 'Ajouter un service personnalisé';

  @override
  String get noResults => 'Aucun service ne correspond à votre recherche.';

  @override
  String daysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String remindersBefore(String list) {
    return '$list avant';
  }

  @override
  String get and => 'et';

  @override
  String get noReminders => 'Aucun rappel';

  @override
  String get colorAndIcon => 'Couleur et icône';

  @override
  String providerHelp(String name) {
    return 'Résiliez votre forfait sur le site de $name.';
  }

  @override
  String get noProviderLink =>
      'Ajoutez le lien du fournisseur dans l\'éditeur.';

  @override
  String get pauseTracking => 'Mettre le suivi en pause';

  @override
  String get resumeTracking => 'Reprendre le suivi';

  @override
  String get deleteRecord => 'Supprimer le suivi';

  @override
  String get notCancelHelp =>
      'Cela ne résilie pas votre forfait chez le fournisseur.';

  @override
  String get theme => 'Apparence';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get renewsToday => 'Se renouvelle aujourd\'hui';

  @override
  String get notifChannel => 'Rappels de renouvellement';

  @override
  String get notifChannelHelp =>
      'Alertes avant les renouvellements et les fins d\'essai ou de forfait.';

  @override
  String get notifToday => 'aujourd\'hui';

  @override
  String get notifTomorrow => 'demain';

  @override
  String notifInDays(int count) {
    return 'dans $count jours';
  }

  @override
  String notifRenewalTitle(String name, String when) {
    return '$name se renouvelle $when';
  }

  @override
  String notifTrialTitle(String name, String when) {
    return 'L\'essai de $name se termine $when';
  }

  @override
  String notifEndingTitle(String name, String when) {
    return 'Le forfait $name se termine $when';
  }

  @override
  String notifRenewalBody(String amount, String day) {
    return '$amount · $day. L\'utilisez-vous encore ? Vous avez le temps de décider sereinement.';
  }

  @override
  String notifOtherBody(String day) {
    return '$day. Vérifiez si vous souhaitez continuer.';
  }

  @override
  String get permTitle => 'Des rappels au bon moment';

  @override
  String get permBody =>
      'Ritmia vous prévient à 09:00 avant un renouvellement, une fin d\'essai ou de forfait. Vos rappels uniquement, jamais de publicité.';

  @override
  String get permPointOne => 'Choisissez 1, 3, 7 ou 14 jours avant';

  @override
  String get permPointTwo => 'Fonctionne hors ligne, sur cet appareil';

  @override
  String get permPointThree => 'Désactivez-les à tout moment dans les Réglages';

  @override
  String get permAllow => 'Activer les rappels';

  @override
  String get permLater => 'Plus tard';

  @override
  String get permGranted => 'Les rappels sont activés.';

  @override
  String get permDeniedTitle => 'Les notifications sont bloquées';

  @override
  String get permDeniedBody =>
      'Android bloque les notifications de Ritmia. Activez-les dans Réglages du téléphone › Applications › Ritmia › Notifications, puis revenez.';

  @override
  String get permBlockedBanner =>
      'Les notifications sont bloquées dans les réglages du téléphone.';

  @override
  String get understood => 'Compris';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get priceSection => 'Prix';

  @override
  String get paidOption => 'Payant';

  @override
  String get freeOption => 'Gratuit';

  @override
  String get becomesPaid => 'Devient payant ensuite';

  @override
  String get becomesPaidHelp =>
      'Définissez la date du premier prélèvement et son montant.';

  @override
  String get paidFrom => 'Début des prélèvements';

  @override
  String get amountAfter => 'Montant ensuite';

  @override
  String get purchaseDate => 'Date d\'achat';

  @override
  String get purchaseHelp =>
      'Se renouvelle à chaque période depuis cette date. Les renouvellements apparaissent dans le calendrier.';

  @override
  String get yesterday => 'Hier';

  @override
  String get pickDate => 'Choisir une date';

  @override
  String nextRenewalPreview(String date) {
    return 'Prochain renouvellement : $date';
  }

  @override
  String freeUntilPreview(String date, String amount) {
    return 'Gratuit jusqu\'au $date, puis $amount';
  }

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get searchCurrency => 'Rechercher une devise';

  @override
  String get customLook => 'Couleur et logo';

  @override
  String get serviceName => 'Nom du service';

  @override
  String get chooseCurrency => 'Devise';

  @override
  String get about => 'À propos';

  @override
  String get general => 'Général';

  @override
  String get dataSection => 'Vos données';

  @override
  String get openPhoneSettings => 'Ouvrir les réglages du téléphone';

  @override
  String get notifOnSummary => 'Activées · à 09:00 avant chaque renouvellement';

  @override
  String get notifOffSummary => 'Désactivées';

  @override
  String get notifBlockedSummary => 'Bloquées dans les réglages du téléphone';

  @override
  String get appearanceSummary => 'Apparence';

  @override
  String get languageSummary => 'Langue';

  @override
  String get autoRenew => 'Renouvellement';

  @override
  String get willRenew => 'Renouveler';

  @override
  String get stopRenewing => 'Ne pas renouveler';

  @override
  String get resumeRenewing => 'Renouveler à nouveau';

  @override
  String get notRenewing => 'Ne sera pas renouvelé';

  @override
  String cancelBefore(String date) {
    return 'Résiliez avant le $date';
  }

  @override
  String rowNotRenewing(String date) {
    return 'Ne pas renouveler · $date';
  }

  @override
  String get stopRenewHelp =>
      'Ritmia indique la date limite de résiliation chez le fournisseur avant le prochain prélèvement.';

  @override
  String stopRenewTitle(String name) {
    return 'Ne pas renouveler $name ?';
  }

  @override
  String stopRenewBody(String date) {
    return 'Le $date sera indiqué comme date limite de résiliation, avec des rappels avant. Ritmia ne résilie pas le forfait pour vous.';
  }

  @override
  String get endsHere => 'Date limite · ne pas renouveler';

  @override
  String get chooseIcon => 'Icône';

  @override
  String get uploadOwn => 'Importer votre image';

  @override
  String get purchasedHere => 'Acheté';

  @override
  String get widgetTitle => 'Widget d\'écran d\'accueil';

  @override
  String get widgetHelp =>
      'Vos trois prochains forfaits, en donnant la priorité à ceux que vous souhaitez résilier.';

  @override
  String get widgetCompactTitle => 'Widget sur une ligne';

  @override
  String get widgetCompactHelp =>
      'Une ligne de 3 à 4 colonnes avec vos prochains forfaits.';

  @override
  String get widgetManual =>
      'Appuyez longuement sur une zone vide de l\'écran d\'accueil → Widgets → Ritmia.';

  @override
  String notifCancelTitle(String name, String when) {
    return 'Résiliez $name $when';
  }

  @override
  String notifCancelBody(String amount, String date) {
    return 'Évitez le prochain prélèvement de $amount. Date limite : $date. Ouvrez Ritmia pour vérifier ce forfait.';
  }

  @override
  String get notifScheduleError =>
      'Les alertes sont activées, mais leur programmation a échoué. Réessayez.';

  @override
  String get addToCalendar => 'Ajouter au calendrier du téléphone';

  @override
  String get calendarAddHelp =>
      'Vérifiez et enregistrez cette date dans votre application de calendrier.';

  @override
  String get calendarExport => 'Exporter vers le calendrier';

  @override
  String get calendarExportHelp =>
      '12 prochains mois · jusqu\'à 1 000 dates · fichier .ics';

  @override
  String get calendarNoDates => 'Aucune date à venir à ajouter.';

  @override
  String get calendarOpened =>
      'Vérifiez l\'événement et enregistrez-le dans votre calendrier.';

  @override
  String calendarRenewalTitle(String name) {
    return 'Renouvellement de $name';
  }

  @override
  String calendarTrialTitle(String name) {
    return 'Fin de l\'essai de $name';
  }

  @override
  String calendarCancelTitle(String name) {
    return 'Résilier $name';
  }

  @override
  String get calendarEventHelp =>
      'Suivi dans Ritmia. Modifier cet événement ne change pas votre abonnement et ne résilie pas votre forfait.';

  @override
  String get notificationTest => 'Envoyer une alerte de test';

  @override
  String get notificationTestSent =>
      'Alerte de test envoyée. Consultez votre volet de notifications.';

  @override
  String get notifTestTitle => 'Vos rappels Ritmia sont prêts';

  @override
  String get notifTestBody =>
      'Ceci est une alerte de test. Les rappels de vos abonnements apparaîtront ici.';

  @override
  String get guidedTour => 'Créer un abonnement pas à pas';

  @override
  String get guidedTourHelp =>
      'Un parcours qui met les commandes en évidence pendant l’utilisation de l’app.';

  @override
  String tourProgress(int current, int total) {
    return '$current sur $total';
  }

  @override
  String get tourSkip => 'Passer le guide';

  @override
  String get tourNext => 'Continuer';

  @override
  String get tourBack => 'Retour';

  @override
  String get tourFinish => 'Terminer';

  @override
  String get tourAddTitle => 'Votre premier abonnement';

  @override
  String get tourAddBody =>
      'Touchez le bouton en évidence. Vous créerez un vrai suivi et pourrez quitter ce guide à tout moment.';

  @override
  String get tourBrandTitle => 'Choisissez une marque';

  @override
  String get tourBrandBody =>
      'Recherchez votre service et touchez son nom. Vous pouvez aussi créer un service personnalisé. Les logos sont déjà dans l’app.';

  @override
  String get tourNameTitle => 'Donnez-lui un nom';

  @override
  String get tourNameBody =>
      'La marque renseigne le nom et le logo. Modifiez le nom pour distinguer un forfait ou un compte.';

  @override
  String get tourPriceTitle => 'Gratuit ou payant ?';

  @override
  String get tourPriceBody =>
      'Choisissez le type de forfait. S’il est payant, indiquez le montant, la devise et la fréquence des prélèvements.';

  @override
  String get tourDateTitle => 'Quand l’avez-vous acheté ?';

  @override
  String get tourDateBody =>
      'Choisissez la date d’achat. Ritmia calcule le prochain renouvellement depuis cette date et la période choisie.';

  @override
  String get tourRemindersTitle => 'Choisissez vos rappels';

  @override
  String get tourRemindersBody =>
      'Sélectionnez combien de jours avant être prévenu. Plusieurs choix sont possibles. Les alertes nécessitent l’autorisation du téléphone.';

  @override
  String get tourSaveTitle => 'Enregistrez l’abonnement';

  @override
  String get tourSaveBody =>
      'Touchez Enregistrer pour créer le suivi. S’il manque une information, revenez à l’étape précédente pour la compléter.';

  @override
  String get tourRecordTitle => 'Voici votre forfait';

  @override
  String get tourRecordBody =>
      'Touchez l’abonnement pour ouvrir ses détails. Vous pouvez y choisir Ne pas renouveler ; ces forfaits apparaissent en premier.';

  @override
  String get tourCalendarTitle => 'Retrouvez vos dates';

  @override
  String get tourCalendarBody =>
      'Ouvrez le calendrier pour vérifier les renouvellements. Les détails du forfait permettent d’ajouter une date au calendrier du téléphone.';

  @override
  String get tourFilterTitle => 'Trouvez l’essentiel';

  @override
  String get tourFilterBody =>
      'Filtrez par Renouveler ou Ne pas renouveler. Combinez le filtre avec la recherche par nom ou notes.';

  @override
  String get tourSettingsTitle => 'À votre façon';

  @override
  String get tourSettingsBody =>
      'Activez et testez les alertes, choisissez la langue ou le thème, ajoutez le widget et exportez les dates vers votre calendrier.';

  @override
  String get notificationSetupError =>
      'Impossible de démarrer les rappels. Mettez Ritmia à jour ou réessayez.';

  @override
  String get proBadge => 'ACHAT UNIQUE · À VIE';

  @override
  String get proSubtitle =>
      'Débloquez tout Ritmia en un seul paiement, sans ajouter un abonnement de plus.';

  @override
  String get proBenefitUnlimitedTitle => 'Abonnements illimités';

  @override
  String get proBenefitUnlimitedBody =>
      'Suivez tous vos services actifs, en pause et archivés sans la limite de 5 places.';

  @override
  String get proBenefitNoAdsTitle => 'Sans publicité';

  @override
  String get proBenefitNoAdsBody =>
      'Supprimez les publicités occasionnelles pour une expérience fluide.';

  @override
  String get proBenefitOneTimeTitle => 'Paiement unique à vie';

  @override
  String get proBenefitOneTimeBody =>
      'Payez une seule fois et conservez Ritmia Pro pour toujours.';

  @override
  String get proUnlockCta => 'Débloquer Ritmia Pro';

  @override
  String get proRestoreCta => 'Restaurer l’achat';

  @override
  String get proActiveBadge => 'Actif · Achat unique';

  @override
  String get proRestoreEmpty =>
      'Aucun achat précédent de Ritmia Pro n’a été trouvé.';

  @override
  String get adInterstitialLabel => 'SPONSORISÉ';

  @override
  String get adInterstitialTitle => 'Passez à Ritmia Pro sans publicité';

  @override
  String get adInterstitialBody =>
      'Avec un paiement unique, supprimez les publicités occasionnelles et débloquez les abonnements illimités à vie.';

  @override
  String get adContinueFree => 'Continuer avec Ritmia Free';
}
