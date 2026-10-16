# Firebase — ritmia-app
Proyecto solicitado: **ritmia-app**, número **725132962702**. Android: **app.ritmia.ritmia**, Firebase app ID **1:725132962702:android:6d01d29033883eac3bd2df**.

Se registró la app Android y se descargó su configuración real a archivos locales excluidos de Git. Al inspeccionar el proyecto, Cloud Firestore API estaba deshabilitada. El APK local puede probarse sin estos servicios.

## Activación cloud
1. En Firebase Console, habilitar Authentication → Email/Password y política de contraseñas de al menos 8 caracteres. Revisar plantillas de verificación/recuperación.
2. Crear Firestore (modo producción) en una región elegida conscientemente. Las funciones usan us-central1; mantener cercanía de datos y funciones.
3. Crear el bucket de Storage. Sustituir FIREBASE_STORAGE_BUCKET por el nombre real si difiere.
4. Habilitar la facturación requerida para Cloud Functions/Scheduler y servicios que la necesiten. No se cambia la cuenta de facturación automáticamente.
5. Compilar backend y desplegar reglas y funciones:
```powershell
npm.cmd --prefix functions ci
npm.cmd --prefix functions run build
firebase.cmd deploy --project ritmia-app --only firestore,storage,functions
```
6. Compilar un APK cloud:
```powershell
flutter build apk --debug --dart-define-from-file=config/firebase.local.android.json
```
No distribuir una build cloud antes de habilitar Auth y desplegar las funciones: el editor depende de saveSubscription.

## SDK
Esta implementación inicializa FirebaseOptions mediante dart-define-from-file, con configuración específica por plataforma. No necesita insertar manualmente claves en Dart. Para iOS/web, registrar apps respectivas y generar archivos locales separados. También se puede migrar al flujo FlutterFire oficial, manteniendo los valores sensibles fuera de archivos versionados.

El SDK configuration de Firebase identifica al proyecto y no sustituye reglas, App Check ni verificación de servidor. Ninguna clave de servicio privada pertenece a la app.

## Correo con app cerrada
Instalar la extensión oficial firebase/firestore-send-email apuntando a mail. Configurar SMTP/proveedor y remitente. Las credenciales se mantienen en Secret Manager/configuración de la extensión.

functions params:
- EMAIL_DELIVERY_ENABLED=false por defecto. Cambiar a true únicamente tras configurar y probar el proveedor.
- REQUIRE_APP_CHECK=false en desarrollo. Para producción integrar firebase_app_check en Flutter y luego exigirlo en backend.

El consentimiento para email solo se puede activar con dirección verificada. La función obtiene la dirección desde Auth. El cliente nunca especifica destinatarios. Comprobar delivery, fallos y reintentos de la extensión; añadir TTL a expiresAt.

## Pro
Los documentos private/billing son de solo lectura para el cliente. Solo un servicio de pago verificado debe escribir plan y expiresAt:
- Android: Play Billing + verificación con Google Play Developer API + notificaciones de cambios.
- iOS: StoreKit + verificación/notificaciones de App Store Server.
- Web: Stripe Checkout + webhook firmado.

Registrar el ID de evento de compra para evitar doble procesamiento, validar UID/producto/entorno y manejar expiraciones, cancelaciones, reembolsos y restauración. No conceder Pro a partir de una respuesta manipulable del cliente. Aún no están implementados estos gateways ni se han configurado precios/productos.

## Hosting
Para web, registrar primero una app web y su configuración local:
```powershell
flutter build web --release --dart-define-from-file=config/firebase.local.web.json
firebase.cmd deploy --project ritmia-app --only hosting
```
firebase.json incluye rewrites SPA. Hosting publica Flutter web; el APK Android se instala/distribuye por separado.

## Emuladores
Las pruebas usan demo-ritmia y nunca datos de producción. Se verificaron descargas oficiales por SHA-256. En esta PC:
```powershell
$env:FIREBASE_EMULATORS_PATH = (Resolve-Path .emulators).Path
$env:NODE_EXTRA_CA_CERTS = (Resolve-Path .local/windows-roots.pem).Path
firebase.cmd emulators:exec --project demo-ritmia --only auth,firestore,functions,storage "node --test functions/lib/integration.test.js"
```
Node global 25 presenta un problema de cierre del CLI en Windows; las aserciones de integración terminaron correctamente antes de ese error. El runtime declarado de despliegue es Node 22. Preferir Node 22 para CLI/CI.

## Fuentes oficiales
- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/auth/flutter/start
- https://firebase.google.com/docs/firestore/security/rules-conditions
- https://firebase.google.com/docs/storage/security
- https://firebase.google.com/docs/functions/schedule-functions
- https://firebase.google.com/docs/extensions/official/firestore-send-email
