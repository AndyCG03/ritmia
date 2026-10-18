# Probar Ritmia en Android
El APK de prueba es local; no hace falta cuenta. Se conserva la selección de idioma y el onboarding solo aparece la primera vez.

## Instalación
Copiar el archivo de dist/ al teléfono, abrirlo y permitir la instalación desde la app utilizada (Archivos, navegador, Drive, etc.). La firma de esta build es de depuración; sirve para pruebas, no para publicar en Google Play.

Para probar desde USB:
```powershell
flutter devices
flutter run -d <device-id>
```

## Recorrido de prueba
1. Avanza por los tres pasos del onboarding o pulsa Omitir.
2. Busca una marca, por ejemplo Spotify o Vercel, y crea un registro.
3. Alterna gratis/de pago, moneda y periodicidad. Usa el día 31 para comprobar meses cortos.
4. Carga un logo de tu galería y elige un color.
5. Configura fin de prueba/plan, avisos de 1/3/7/14 días y enlace del proveedor.
6. Abre Calendario, cambia de mes y selecciona un día.
7. En Ajustes activa Avisos en este dispositivo y concede permiso. Android puede retrasar alertas por ahorro de energía.
8. Crea cinco registros y comprueba que el sexto se rechaza. Archivar no libera plaza; eliminar sí.
9. Cambia entre Español y English y exporta CSV.

Los recordatorios se programan a las 09:00 para los próximos 60 días, hasta 60 avisos. Para una prueba inmediata, elige una renovación de mañana con anticipación de un día antes de las 09:00. Si ya pasó esa hora, usa la renovación de pasado mañana.

## Compilar en esta PC
Java de Android Studio no reconocía los certificados HTTPS de la red. Se creó un almacén **local al proyecto** desde las raíces que ya confía Windows; no se cambiaron certificados ni variables globales.

```powershell
$env:JAVA_TOOL_OPTIONS = '-Djavax.net.ssl.trustStore=C:/Almacen/30_proyectos/activos/juegos/ritmia/.local/build-truststore.jks -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStoreType=JKS'
$env:GRADLE_OPTS = '-Dorg.gradle.daemon=false'
flutter build apk --debug
```
changeit es la contraseña estándar de un almacén que solo contiene certificados públicos, sin claves privadas. .local/ está excluido de Git. En una máquina sin este problema basta flutter build apk --debug.

## Antes de publicar
Definir firma release propia, package ID definitivo, política de privacidad, borrado de cuenta/datos, App Check y pruebas reales de notificaciones. El APK inicial no acredita envío de notificaciones en un teléfono físico; esa comprobación necesita el dispositivo.

## Versión 1.2.2 — widget de inicio
1. Instala dist/ritmia-1.2.2-arm64-release.apk sobre la versión anterior para conservar tus registros.
2. En Ajustes → Avisos en este dispositivo, activa y acepta el diálogo de Android. El interruptor debe quedar encendido. Si ya concediste permiso, no habrá otro diálogo.
3. En Ajustes → Widget de inicio, toca para abrir la confirmación del launcher. Si el launcher no admite añadirlo desde la app: mantén pulsado un espacio libre de la pantalla de inicio → Widgets → Ritmia y arrástralo.
4. Marca dos planes como No renovar y mantén al menos otro renovable. El widget debe mostrar primero los que no quieres renovar, por fecha límite, y después los demás por próxima renovación.
5. Toca una fila del widget: debe abrir el detalle correspondiente. Edita/borrar un plan y comprueba que el widget se actualice.
6. En inicio de Ritmia, usa el filtro junto a la búsqueda: Todas / Se renueva / No renovar. Al añadir, el selector comienza en Todas; busca Higgsfield o GPT.

Android controla la colocación, disponibilidad del diálogo y frecuencia efectiva de actualización del widget. Las pruebas físicas se dejan para el teléfono; no había dispositivo ni emulador disponible durante esta entrega. Ver docs/REVIEW_1.2.2.md.

## Versión 1.2.3 — avisos, calendario, idiomas y recorrido
- Instala dist/ritmia-1.2.3-arm64-release.apk encima de la versión anterior para conservar los datos.
- Activa Avisos en este dispositivo. Acepta el diálogo de Android si aún no lo has concedido. Luego pulsa Enviar aviso de prueba y comprueba el panel de notificaciones.
- Abre un plan y pulsa Añadir al calendario del teléfono; revisa el borrador y guárdalo. Para varias fechas: Ajustes → Exportar al calendario (.ics).
- Ajustes → Idioma ofrece español, inglés, portugués, francés y el idioma del sistema.
- Para ver el recorrido sin reiniciar ni borrar tus datos: Ajustes → Crear una suscripción paso a paso. El onboarding inicial también lo abre al finalizar.
- El recorrido usa un registro real y respeta las cinco plazas de Free; omitirlo no crea datos.

Compilación usada en esta entrega: flutter build apk --release --target-platform android-arm64 --build-name=1.2.3 --build-number=6.
Después de compilar: python scripts/verify_android_apk.py build/app/outputs/flutter-apk/app-release.apk --expected-version 1.2.3.
Ver docs/REVIEW_1.2.3.md para causa y límites de las comprobaciones.
