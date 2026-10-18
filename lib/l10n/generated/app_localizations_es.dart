// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get tagline => 'Tus suscripciones, a tu ritmo.';

  @override
  String get home => 'Resumen';

  @override
  String get calendar => 'Calendario';

  @override
  String get settings => 'Ajustes';

  @override
  String get add => 'Añadir suscripción';

  @override
  String get edit => 'Editar suscripción';

  @override
  String get subscriptions => 'Tus suscripciones';

  @override
  String get emptyTitle => 'Haz espacio para lo que importa.';

  @override
  String get emptyBody =>
      'Añade tu primera suscripción. Verás cuánto cuesta y cuándo vuelve.';

  @override
  String get monthCharges => 'Cargos previstos este mes';

  @override
  String get noCharges => 'Sin cargos previstos';

  @override
  String get localMode => 'Modo local · datos en este dispositivo';

  @override
  String get all => 'Todas';

  @override
  String get paid => 'De pago';

  @override
  String get free => 'Gratis';

  @override
  String get active => 'Activa';

  @override
  String get paused => 'Pausada';

  @override
  String get archived => 'Archivada';

  @override
  String get search => 'Buscar por nombre o notas';

  @override
  String get name => 'Nombre';

  @override
  String get amount => 'Importe por ciclo';

  @override
  String get currency => 'Moneda';

  @override
  String get billingCycle => 'Periodicidad';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get quarterly => 'Trimestral';

  @override
  String get yearly => 'Anual';

  @override
  String get anchorDate => 'Primera renovación / fecha de referencia';

  @override
  String get color => 'Color';

  @override
  String get logo => 'Logo personalizado';

  @override
  String get uploadLogo => 'Cargar imagen';

  @override
  String get removeLogo => 'Quitar imagen';

  @override
  String get logoHelp => 'PNG/JPG/WebP · se optimiza a 256 px y hasta 128 KB.';

  @override
  String get catalog => 'Elige un servicio';

  @override
  String get notes => 'Notas';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Volver';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteTitle => '¿Eliminar esta suscripción?';

  @override
  String get deleteBody =>
      'Se borrará el registro de Ritmia. El contrato con el proveedor sigue vigente.';

  @override
  String get saved => 'Suscripción guardada';

  @override
  String get invalidName => 'Escribe un nombre de hasta 80 caracteres.';

  @override
  String get invalidAmount =>
      'Escribe un importe válido mayor que cero, sin separadores de miles.';

  @override
  String get invalidUrl => 'Usa una dirección https válida.';

  @override
  String get dateOrder =>
      'La fecha de fin no puede ser anterior a la fecha de inicio.';

  @override
  String get status => 'Estado';

  @override
  String get category => 'Categoría';

  @override
  String get entertainment => 'Entretenimiento';

  @override
  String get productivity => 'Productividad';

  @override
  String get storageCategory => 'Almacenamiento';

  @override
  String get education => 'Educación';

  @override
  String get health => 'Salud';

  @override
  String get utilities => 'Servicios';

  @override
  String get other => 'Otros';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get reminderHelp =>
      'Avisar a las 09:00, antes de la renovación, del fin de prueba o del fin del plan.';

  @override
  String get daysOne => '1 día';

  @override
  String get daysThree => '3 días';

  @override
  String get daysSeven => '7 días';

  @override
  String get daysFourteen => '14 días';

  @override
  String get endsOn => 'Fin del plan (opcional)';

  @override
  String get trialEndsOn => 'Fin de prueba (opcional)';

  @override
  String get clear => 'Quitar';

  @override
  String get cancelUrl => 'Enlace para gestionar / cancelar';

  @override
  String get manage => 'Gestionar con el proveedor';

  @override
  String get manageHelp =>
      'Abre la web del proveedor. Ritmia no cancela contratos ni procesa cobros.';

  @override
  String get nextRenewal => 'Próxima renovación';

  @override
  String get noRenewal => 'Sin próxima renovación';

  @override
  String get events => 'Renovaciones del día';

  @override
  String get noEvents => 'Un día sin renovaciones.';

  @override
  String get today => 'Hoy';

  @override
  String get previousMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String get language => 'Idioma';

  @override
  String get system => 'Automático';

  @override
  String get plan => 'Tu plan';

  @override
  String get freePlan => 'Ritmia Gratis';

  @override
  String get freeFeatures =>
      '5 suscripciones en total, calendario, logos, recordatorios y todas las monedas.';

  @override
  String get proPlan => 'Ritmia Pro';

  @override
  String get proFeatures =>
      'Suscripciones ilimitadas. Activación mediante compra verificada en el servidor.';

  @override
  String get proPending => 'Las compras todavía no están habilitadas.';

  @override
  String get limitMessage =>
      'Has llegado al límite gratuito de 5 suscripciones. Elimina una para añadir otra.';

  @override
  String get quotaHelp => 'Las pausadas y archivadas también ocupan una plaza.';

  @override
  String get export => 'Exportar CSV';

  @override
  String get exportHelp => 'Exporta tus registros. Los logos no se incluyen.';

  @override
  String get notificationToggle => 'Avisos en este dispositivo';

  @override
  String get notificationHelp =>
      'Se programan los próximos 60 días (hasta 60 avisos). Abre la app para actualizar la programación.';

  @override
  String get webNotificationHelp =>
      'En web, los avisos con la app cerrada se envían por correo cuando Firebase y el proveedor estén configurados.';

  @override
  String get emailToggle => 'Recordatorios por correo';

  @override
  String get emailHelp =>
      'Necesitas una cuenta con correo verificado. Envío a las 09:00 de tu zona horaria.';

  @override
  String get permissionDenied =>
      'Permite las notificaciones en los ajustes del dispositivo.';

  @override
  String get notificationError =>
      'No se pudieron actualizar los avisos. Revisa los permisos y vuelve a abrir la app.';

  @override
  String get account => 'Cuenta';

  @override
  String get signIn => 'Entrar';

  @override
  String get signUp => 'Crear cuenta';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordHelp => 'Al menos 8 caracteres.';

  @override
  String get forgotPassword => 'Restablecer contraseña';

  @override
  String get resetSent =>
      'Si existe la cuenta, recibirás un correo para restablecer la contraseña.';

  @override
  String get verificationSent =>
      'Correo de verificación enviado. Revisa tu bandeja de entrada.';

  @override
  String get verifyEmail => 'Verificar correo';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get verified => 'Correo verificado';

  @override
  String get invalidEmail => 'Escribe un correo válido.';

  @override
  String get weakPassword => 'Usa una contraseña de al menos 8 caracteres.';

  @override
  String get emailInUse => 'Ese correo ya tiene una cuenta.';

  @override
  String get credentialsError =>
      'No se pudo iniciar sesión con esas credenciales.';

  @override
  String get tooManyRequests => 'Demasiados intentos. Espera un momento.';

  @override
  String get networkError => 'No hay conexión. Inténtalo de nuevo.';

  @override
  String get genericError =>
      'No se pudo completar la operación. Inténtalo de nuevo.';

  @override
  String get conflictMessage =>
      'El registro cambió en otro dispositivo. Cierra el editor y vuelve a abrirlo.';

  @override
  String get imageError =>
      'Usa una imagen PNG/JPG/WebP que pueda reducirse a 128 KB.';

  @override
  String get preconditionError =>
      'Verifica tu correo o revisa la configuración de Firebase.';

  @override
  String get retry => 'Reintentar';

  @override
  String get loading => 'Cargando';

  @override
  String get logoPartialError =>
      'El registro se guardó, pero el logo falló. Ábrelo para volver a cargarlo.';

  @override
  String get reminderRenewal => 'Se acerca una renovación';

  @override
  String get reminderTrial => 'Tu prueba está por terminar';

  @override
  String get reminderEnding => 'Tu plan está por terminar';

  @override
  String get reminderBody =>
      'Revisa tu suscripción antes de la fecha indicada.';

  @override
  String get privacy =>
      'Tus datos se usan para gestionar tus suscripciones y los avisos que actives.';

  @override
  String get cloudSetupError =>
      'No se pudo conectar con Firebase. Revisa docs/FIREBASE.md y la configuración de arranque.';

  @override
  String get searchBrands => 'Buscar entre todas las marcas';

  @override
  String get catalogHelp =>
      'Mostrando hasta 12 coincidencias. Busca cualquier marca del catálogo.';

  @override
  String get skip => 'Omitir';

  @override
  String get next => 'Siguiente';

  @override
  String get getStarted => 'Empezar a mi ritmo';

  @override
  String get onboardEyebrowOne => 'Menos ruido. Más claridad.';

  @override
  String get onboardTitleOne => 'Todo lo que vuelve,\nen un solo lugar.';

  @override
  String get onboardBodyOne =>
      'Reúne tus suscripciones gratis y de pago. Dales su color, su logo y el lugar que merecen.';

  @override
  String get onboardEyebrowTwo => 'Tu mes, de un vistazo';

  @override
  String get onboardTitleTwo => 'Que ningún cargo\nte tome por sorpresa.';

  @override
  String get onboardBodyTwo =>
      'Mira las renovaciones en el calendario y conoce tus cargos por moneda. Sin cuentas mentales.';

  @override
  String get onboardEyebrowThree => 'Tú decides qué sigue';

  @override
  String get onboardTitleThree => 'Un aviso a tiempo.\nUna decisión tranquila.';

  @override
  String get onboardBodyThree =>
      'Elige avisos antes de renovar o terminar una prueba. Cuando quieras cancelar, abre el enlace de tu proveedor.';

  @override
  String get thisMonth => 'Este mes';

  @override
  String subscriptionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones',
      one: '1 suscripción',
      zero: '0 suscripciones',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionsHeading => 'Suscripciones';

  @override
  String get perWeek => '/ semana';

  @override
  String get perMonth => '/ mes';

  @override
  String get perQuarter => '/ trimestre';

  @override
  String get perYear => '/ año';

  @override
  String renewalLabel(String cycle) {
    return 'Renovación $cycle';
  }

  @override
  String get tapDateHint => 'Toca una fecha para ver sus renovaciones';

  @override
  String get openCalendar => 'Abrir calendario';

  @override
  String get close => 'Cerrar';

  @override
  String get filter => 'Filtrar';

  @override
  String get searchService => 'Buscar un servicio';

  @override
  String get tabAll => 'Todos';

  @override
  String get tabAi => 'Inteligencia artificial';

  @override
  String get addCustom => 'Añadir servicio personalizado';

  @override
  String get noResults => 'Ningún servicio coincide con tu búsqueda.';

  @override
  String daysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String remindersBefore(String list) {
    return '$list antes';
  }

  @override
  String get and => 'y';

  @override
  String get noReminders => 'Sin recordatorios';

  @override
  String get colorAndIcon => 'Color e icono';

  @override
  String providerHelp(String name) {
    return 'Cancela tu plan desde la web de $name.';
  }

  @override
  String get noProviderLink => 'Añade el enlace del proveedor al editar.';

  @override
  String get pauseTracking => 'Pausar seguimiento';

  @override
  String get resumeTracking => 'Reanudar seguimiento';

  @override
  String get deleteRecord => 'Eliminar registro';

  @override
  String get notCancelHelp => 'Esto no cancela tu plan con el proveedor.';

  @override
  String get theme => 'Apariencia';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get renewsToday => 'Renueva hoy';

  @override
  String get notifChannel => 'Avisos de renovación';

  @override
  String get notifChannelHelp =>
      'Avisos antes de renovaciones, fin de prueba y fin de plan.';

  @override
  String get notifToday => 'hoy';

  @override
  String get notifTomorrow => 'mañana';

  @override
  String notifInDays(int count) {
    return 'en $count días';
  }

  @override
  String notifRenewalTitle(String name, String when) {
    return '$name se renueva $when';
  }

  @override
  String notifTrialTitle(String name, String when) {
    return 'La prueba de $name termina $when';
  }

  @override
  String notifEndingTitle(String name, String when) {
    return 'El plan de $name termina $when';
  }

  @override
  String notifRenewalBody(String amount, String day) {
    return '$amount · $day. ¿Aún la usas? Tienes tiempo para decidir con calma.';
  }

  @override
  String notifOtherBody(String day) {
    return '$day. Revisa si quieres continuar.';
  }

  @override
  String get permTitle => 'Avisos justo a tiempo';

  @override
  String get permBody =>
      'Ritmia te avisa a las 09:00 antes de una renovación, del fin de una prueba o del fin de un plan. Solo tus recordatorios, nunca publicidad.';

  @override
  String get permPointOne => 'Tú eliges 1, 3, 7 o 14 días antes';

  @override
  String get permPointTwo => 'Funciona sin conexión, en este dispositivo';

  @override
  String get permPointThree => 'Desactívalos cuando quieras en Ajustes';

  @override
  String get permAllow => 'Activar avisos';

  @override
  String get permLater => 'Ahora no';

  @override
  String get permGranted => 'Avisos activados.';

  @override
  String get permDeniedTitle => 'Las notificaciones están bloqueadas';

  @override
  String get permDeniedBody =>
      'Android está bloqueando las notificaciones de Ritmia. Actívalas en Ajustes del teléfono › Aplicaciones › Ritmia › Notificaciones y vuelve.';

  @override
  String get permBlockedBanner =>
      'Las notificaciones están bloqueadas en los ajustes del teléfono.';

  @override
  String get understood => 'Entendido';

  @override
  String get notificationsSection => 'Notificaciones';

  @override
  String get priceSection => 'Precio';

  @override
  String get paidOption => 'De pago';

  @override
  String get freeOption => 'Gratis';

  @override
  String get becomesPaid => 'Pasará a ser de pago';

  @override
  String get becomesPaidHelp =>
      'Marca desde qué día empezará a cobrarse y cuánto.';

  @override
  String get paidFrom => 'Se cobrará a partir del';

  @override
  String get amountAfter => 'Importe a partir de entonces';

  @override
  String get purchaseDate => 'Fecha de compra';

  @override
  String get purchaseHelp =>
      'Se renueva cada ciclo a partir de este día. Las renovaciones se marcan en el calendario.';

  @override
  String get yesterday => 'Ayer';

  @override
  String get pickDate => 'Elegir fecha';

  @override
  String nextRenewalPreview(String date) {
    return 'Próxima renovación: $date';
  }

  @override
  String freeUntilPreview(String date, String amount) {
    return 'Gratis hasta el $date, después $amount';
  }

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get searchCurrency => 'Buscar moneda';

  @override
  String get customLook => 'Color y logo';

  @override
  String get serviceName => 'Nombre del servicio';

  @override
  String get chooseCurrency => 'Moneda';

  @override
  String get about => 'Acerca de';

  @override
  String get general => 'General';

  @override
  String get dataSection => 'Tus datos';

  @override
  String get openPhoneSettings => 'Abrir ajustes del teléfono';

  @override
  String get notifOnSummary => 'Activados · 09:00 antes de cada renovación';

  @override
  String get notifOffSummary => 'Desactivados';

  @override
  String get notifBlockedSummary => 'Bloqueados en los ajustes del teléfono';

  @override
  String get appearanceSummary => 'Apariencia';

  @override
  String get languageSummary => 'Idioma';

  @override
  String get autoRenew => 'Renovación';

  @override
  String get willRenew => 'Se renueva';

  @override
  String get stopRenewing => 'No renovar';

  @override
  String get resumeRenewing => 'Volver a renovar';

  @override
  String get notRenewing => 'No se renovará';

  @override
  String cancelBefore(String date) {
    return 'Cancela antes del $date';
  }

  @override
  String rowNotRenewing(String date) {
    return 'No renovar · $date';
  }

  @override
  String get stopRenewHelp =>
      'Ritmia marca la fecha límite para cancelar con el proveedor antes del próximo cobro.';

  @override
  String stopRenewTitle(String name) {
    return '¿No renovar $name?';
  }

  @override
  String stopRenewBody(String date) {
    return 'Verás el $date como fecha límite para cancelar, con avisos antes. Ritmia no cancela el plan por ti.';
  }

  @override
  String get endsHere => 'Fecha límite · no renovar';

  @override
  String get chooseIcon => 'Icono';

  @override
  String get uploadOwn => 'Subir imagen propia';

  @override
  String get purchasedHere => 'Fecha de compra';

  @override
  String get widgetTitle => 'Widget de inicio';

  @override
  String get widgetHelp =>
      'Tus tres próximos planes, con prioridad para los que no quieres renovar.';

  @override
  String get widgetCompactTitle => 'Widget de una fila';

  @override
  String get widgetCompactHelp =>
      'Una fila de 3 a 4 columnas con tus próximos planes.';

  @override
  String get widgetManual =>
      'Mantén pulsado un espacio de tu pantalla de inicio → Widgets → Ritmia.';

  @override
  String notifCancelTitle(String name, String when) {
    return 'Cancela $name $when';
  }

  @override
  String notifCancelBody(String amount, String date) {
    return 'Evita el próximo cobro de $amount. Fecha límite: $date. Abre Ritmia para revisar el plan.';
  }

  @override
  String get notifScheduleError =>
      'Los avisos están activados, pero no pudimos programarlos. Reintenta.';

  @override
  String get addToCalendar => 'Añadir al calendario del teléfono';

  @override
  String get calendarAddHelp =>
      'Revisa y guarda esta fecha en tu app de calendario.';

  @override
  String get calendarExport => 'Exportar al calendario';

  @override
  String get calendarExportHelp =>
      'Próximos 12 meses · hasta 1.000 fechas · archivo .ics';

  @override
  String get calendarNoDates => 'No hay fechas próximas para añadir.';

  @override
  String get calendarOpened => 'Revisa el evento y guárdalo en tu calendario.';

  @override
  String calendarRenewalTitle(String name) {
    return 'Renovación de $name';
  }

  @override
  String calendarTrialTitle(String name) {
    return 'Fin de prueba de $name';
  }

  @override
  String calendarCancelTitle(String name) {
    return 'Cancelar $name';
  }

  @override
  String get calendarEventHelp =>
      'Registrado en Ritmia. Cambiar este evento no modifica tu suscripción ni cancela tu plan.';

  @override
  String get notificationTest => 'Enviar aviso de prueba';

  @override
  String get notificationTestSent =>
      'Aviso de prueba enviado. Revisa tu panel de notificaciones.';

  @override
  String get notifTestTitle => 'Tus avisos de Ritmia están listos';

  @override
  String get notifTestBody =>
      'Este es un aviso de prueba. Aquí aparecerán los recordatorios de tus suscripciones.';

  @override
  String get guidedTour => 'Crear una suscripción paso a paso';

  @override
  String get guidedTourHelp =>
      'Un recorrido que señala los controles mientras usas la app.';

  @override
  String tourProgress(int current, int total) {
    return '$current de $total';
  }

  @override
  String get tourSkip => 'Omitir recorrido';

  @override
  String get tourNext => 'Continuar';

  @override
  String get tourBack => 'Atrás';

  @override
  String get tourFinish => 'Terminar';

  @override
  String get tourAddTitle => 'Tu primera suscripción';

  @override
  String get tourAddBody =>
      'Pulsa el botón señalado. Crearás un registro real; puedes omitir el recorrido cuando quieras.';

  @override
  String get tourBrandTitle => 'Elige una marca';

  @override
  String get tourBrandBody =>
      'Busca tu servicio y toca su nombre. También puedes crear uno personalizado. Los logos ya están en la app.';

  @override
  String get tourNameTitle => 'Ponle nombre';

  @override
  String get tourNameBody =>
      'La marca completa el nombre y el logo. Cambia el nombre si quieres distinguir un plan o una cuenta.';

  @override
  String get tourPriceTitle => '¿Gratis o de pago?';

  @override
  String get tourPriceBody =>
      'Elige el tipo de plan. Si es de pago, escribe el importe, elige la moneda y cada cuánto se cobra.';

  @override
  String get tourDateTitle => '¿Cuándo lo compraste?';

  @override
  String get tourDateBody =>
      'Selecciona la fecha de compra. Ritmia calculará la siguiente renovación desde ese día y la periodicidad elegida.';

  @override
  String get tourRemindersTitle => 'Decide cuándo avisarte';

  @override
  String get tourRemindersBody =>
      'Marca los días de anticipación. Puedes elegir varios. Los avisos requieren el permiso del teléfono.';

  @override
  String get tourSaveTitle => 'Guarda tu suscripción';

  @override
  String get tourSaveBody =>
      'Pulsa Guardar para crear el registro. Si falta algún dato, vuelve al paso anterior para completarlo.';

  @override
  String get tourRecordTitle => 'Aquí está tu plan';

  @override
  String get tourRecordBody =>
      'Toca la suscripción para ver sus detalles. Allí puedes marcar No renovar; esos planes se mostrarán primero.';

  @override
  String get tourCalendarTitle => 'Mira las fechas';

  @override
  String get tourCalendarBody =>
      'Abre el calendario para revisar las renovaciones. En el detalle puedes añadir una fecha al calendario del teléfono.';

  @override
  String get tourFilterTitle => 'Encuentra lo que necesitas';

  @override
  String get tourFilterBody =>
      'El filtro separa Se renueva y No renovar. Puedes combinarlo con la búsqueda por nombre o notas.';

  @override
  String get tourSettingsTitle => 'Ajustes a tu medida';

  @override
  String get tourSettingsBody =>
      'Aquí puedes activar y probar los avisos, elegir idioma o tema, añadir el widget y exportar fechas al calendario.';

  @override
  String get notificationSetupError =>
      'No pudimos iniciar los avisos. Actualiza Ritmia o reintenta.';

  @override
  String get proBadge => 'PAGO ÚNICO · PARA SIEMPRE';

  @override
  String get proSubtitle =>
      'Desbloquea Ritmia al completo con un solo pago, sin añadir otra suscripción a tu mes.';

  @override
  String get proBenefitUnlimitedTitle => 'Suscripciones ilimitadas';

  @override
  String get proBenefitUnlimitedBody =>
      'Registra todos tus servicios activos, pausados y archivados sin el límite de 5 plazas.';

  @override
  String get proBenefitNoAdsTitle => 'Sin anuncios';

  @override
  String get proBenefitNoAdsBody =>
      'Elimina los anuncios ocasionales para una experiencia limpia y sin interrupciones.';

  @override
  String get proBenefitOneTimeTitle => 'Pago único vitalicio';

  @override
  String get proBenefitOneTimeBody =>
      'Paga una sola vez y conserva Ritmia Pro para siempre.';

  @override
  String get proUnlockCta => 'Desbloquear Ritmia Pro';

  @override
  String get proRestoreCta => 'Restaurar compra';

  @override
  String get proActiveBadge => 'Activo · Pago único';

  @override
  String get proRestoreEmpty =>
      'No se encontraron compras previas de Ritmia Pro.';

  @override
  String get adInterstitialLabel => 'ESPACIO PATROCINADO';

  @override
  String get adInterstitialTitle => 'Pásate a Ritmia Pro sin anuncios';

  @override
  String get adInterstitialBody =>
      'Con un único pago eliminas los anuncios ocasionales y desbloqueas suscripciones ilimitadas para siempre.';

  @override
  String get adContinueFree => 'Continuar con Ritmia Gratis';
}
