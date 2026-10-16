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
