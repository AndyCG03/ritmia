# Ritmia 1.2.3 — revisión y cambios

## Cambios del usuario preservados
Se revisaron de nuevo los archivos actuales antes de editar. Se conservaron los mensajes flotantes con iconos de éxito/error/información, el diálogo posterior a un permiso denegado y los cambios del editor/inicio. Una copia de los archivos relevantes previos está en .local/review-1.2.3-baseline/; no se cambió el SDK ni se añadieron dependencias.

## Causa de los avisos
El APK 1.2.2 carece del recurso drawable/ic_stat_ritmia: la optimización de recursos lo eliminó porque Dart lo referencia por nombre. El complemento valida ese icono al inicializar. Pedir permiso dependía de esa inicialización, por lo que un fallo invalid_icon impedía completar la activación aunque el sistema ya hubiera concedido permiso.

Cambios:
- android/app/src/main/res/raw/ritmia_keep.xml conserva explícitamente el icono en compilaciones release.
- En Android, consultar y solicitar permiso ya no inicializa iconos, fechas o programación.
- Aceptar persiste el estado; el interruptor representa la preferencia del usuario y el subtítulo indica si Android bloquea los avisos. Un resultado de sistema desactualizado no apaga visualmente una activación aceptada.
- Enviar aviso de prueba permite probar la publicación inmediata sin esperar a las 09:00 ni configurar una fecha.
- Los errores de plataforma se traducen; el recurso faltante ya no se confunde con un permiso denegado.
- scripts/verify_android_apk.py comprueba el icono DENTRO del APK, no solo en el código. Se comprobó que detecta correctamente el defecto del APK 1.2.2.

## Calendario del teléfono
El detalle de cada suscripción incluye Añadir al calendario del teléfono. Android abre el editor de su app de calendario con un evento de día completo: renovación, fin de prueba o plazo de cancelación según corresponda. El usuario revisa y guarda; Ritmia no inserta datos silenciosamente y no requiere acceso de lectura/escritura a todos los calendarios.

Ajustes → Exportar al calendario genera ritmia.ics para los próximos 12 meses, con un máximo de 1.000 fechas. En plataformas sin editor Android se comparte el archivo .ics. La compatibilidad de importación depende de la aplicación de calendario elegida.

El archivo contiene fechas explícitas calculadas desde el ancla, para conservar 31 de enero → 28/29 de febrero → 31 de marzo. Excluye compras iniciales e inactivas, evita duplicar la conversión de una prueba como renovación y respeta las fechas de fin. Incluye recordatorios relativos en días; la app de calendario gestiona su entrega. Son exportaciones estáticas: las ediciones posteriores en Ritmia no sincronizan ni eliminan automáticamente eventos importados. Los UID son estables para clientes que deduplican por UID.

El escritor cumple el formato de fechas exclusivas de fin, escapes de texto y plegado UTF-8 de 75 octetos de iCalendar. Los importes de monedas distintas no se suman.

## Idiomas
Español, inglés, portugués y francés. Cada idioma tiene 283 mensajes, sin claves faltantes. Incluye onboarding, recorrido, formularios, estados y errores, notificaciones, calendario y nombres de monedas. Se conserva el idioma del teléfono como predeterminado y el cambio manual desde Ajustes. También se amplió el widget nativo y el contrato/mensajes de correo del backend; estos cambios de servidor no se han desplegado.

Se probaron la selección del idioma del teléfono, plurales 0/1/2 y placeholders. Los importes del widget siguen el formato decimal local; sus metadatos permiten dos líneas para que los nombres largos de estado no oculten la fecha.

## Onboarding con una suscripción real
Se conservan los tres pasos animados con Lottie. Al terminarlos comienza un recorrido de 11 pasos que señala controles reales: añadir → marca → nombre → precio/periodicidad → fecha de compra → recordatorios → guardar → registro → calendario → filtro → ajustes.

No hay formularios duplicados ni registros de ejemplo guardados automáticamente. Solo Guardar crea el registro. Los campos señalados siguen siendo interactivos; los selectores y modales pausan el recorrido. Las indicaciones se ajustan al espacio y al teclado y permiten desplazarse si el texto crece. Se respeta reducir movimiento.

Se puede omitir, retroceder dentro del formulario y repetir desde Ajustes → Crear una suscripción paso a paso. Si el plan ya ocupa las cinco plazas, el recorrido explica los registros existentes sin saltarse el límite ni crear otro registro. La finalización se guarda en este dispositivo. Tocar una notificación durante el recorrido pausa las indicaciones para permitir ver el detalle.

## Validación
- Análisis Flutter sin incidencias.
- Suite previa de 47 pruebas aprobada más prueba del puente calendario aprobada: 48 pruebas de Flutter en total.
- Prueba visual del recorrido en teléfono de 390 × 844 con fuentes reales: creación, guardado y omisión; capturas internas en .local/tour-preview/.
- 6 pruebas de backend y compilación TypeScript aprobadas.
- Comprobación negativa: el verificador de APK detecta el recurso ausente en 1.2.2.
- APK release 1.2.3+6 compilado: 29353801 bytes. Icono de notificaciones, PNG original y widget verificados dentro del APK. Firma APK v2 verificada. SHA-256: 7cf7f2b20ca205fd7542de6b9061f012648ed67b81fe1b57452a0bdf84e94744.
- Flutter web release compiló correctamente.
- No se ha probado en un teléfono conectado ni emulador. La entrega real del aviso y el guardado en Google/Samsung Calendar requieren comprobación en dispositivo.

## Fuentes oficiales
- [Complemento de notificaciones: recursos en release](https://pub.dev/documentation/flutter_local_notifications/latest/)
- [Android: abrir el editor de eventos](https://developer.android.com/guide/components/intents-common)
- [Android Calendar Provider e intents](https://developer.android.com/identity/providers/calendar-provider)
