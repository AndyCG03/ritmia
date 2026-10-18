# Revisión y cambios — Ritmia 1.2.2

## Alcance revisado
Dominio de suscripciones y recordatorios, repositorios local/Firebase, providers de sesión/preferencias, onboarding, inicio, editor, ajustes y modales, catálogo y sus recursos, traducciones, configuración Android, contratos de Functions y reglas Firestore/Storage. Los archivos generados se comprueban mediante análisis, compilación y pruebas; no se han rediseñado las capas de persistencia ni cambiado las versiones de dependencias.

## Hallazgos corregidos
| Problema | Corrección |
|---|---|
| El permiso dependía de inicializar la zona horaria | Se solicita directamente al sistema. La zona horaria solo interviene al programar; hay una segunda fuente nativa Android. |
| Una inicialización fallida quedaba cacheada | Se permite volver a inicializar después de errores transitorios. |
| Permiso concedido pero estado visual desactualizado | Se persiste la activación al aceptar y se invalida la comprobación del sistema. Al volver desde Ajustes del teléfono se reconcilia la intención previa. Desactivar manualmente se respeta. |
| No renovar podía acabar al final por no tener próxima renovación | Política pura: primero cancelaciones pendientes por fecha límite, después renovaciones por fecha, después inactivas. |
| Filtros no distinguían intención de renovación | Todas / Se renueva / No renovar. Buscar conserva el filtro. |
| Inicio y onboarding usaban una reinterpretación vectorial de Ritmia | Componente común que carga assets/brand/app-icon-ai.png. Autenticación y launcher ya utilizan el mismo original. |
| El catálogo abría limitado a IA | Todas es la selección inicial; la pestaña IA y sus búsquedas siguen disponibles. |
| Faltaba Higgsfield | SVG local de 1.839 bytes, colores originales, alias higssfield y licencia/procedencia registrada. |
| Backend rechazaba generic:music y fin igual al primer cobro | Contrato corregido con pruebas positivas y negativas. El editor aplica la misma regla de fechas. No se ha desplegado a producción. |

## Widget Android
RemoteViews nativo, sin dependencias nuevas. Muestra hasta tres planes activos con la misma prioridad que la app. Tap en una fila abre su detalle; tap en cabecera abre Ritmia. Temas claro/oscuro y español/inglés. Sigue las preferencias de la app, con idioma del teléfono cuando no hay elección manual. Vista previa con datos ficticios.

Guarda una instantánea privada mínima: identidad del registro, nombre, importe y fechas de recurrencia. No copia notas, imágenes, credenciales o URLs. Los cambios y borrados refrescan el widget. El cierre de sesión cloud vacía la instantánea. Mientras una consulta está cargando se conserva el último estado conocido.

Android recalcula las fechas desde el ancla al actualizar, incluso con Flutter cerrado. Se solicita actualización cada 30 minutos y también ante cambios de fecha, hora, zona, idioma o versión. Android/launcher pueden diferir la actualización. En modo cloud se muestran los últimos datos sincronizados por la app, no una conexión Firebase independiente desde el widget.

Una fecha límite vencida para un plan marcado No renovar permanece arriba hasta que el usuario actualiza/archiva/elimina el registro. Ritmia no puede confirmar por sí misma que el contrato externo se haya cancelado.

## Notificaciones
Canal v2 de importancia alta, contenido expandible, fecha/importe, acento coral para cancelación y acceso al detalle. Los importes se ocultan en la pantalla bloqueada mediante visibilidad privada Android. Si el sistema ya concedió permiso no vuelve a pedirlo. Si Android impide volver a preguntar después de rechazos, se ofrece abrir los ajustes del teléfono.

La programación sigue siendo local, a las 09:00, ventana de 60 días y máximo 60 avisos. Un fallo de programación aparece en Ajustes con Reintentar y no apaga un permiso ya aceptado. Se reprograma al volver a la app. La prioridad del canal no fuerza su posición ni anula No molestar o las preferencias del usuario.

## Identidad y catálogo
PNG original generado con IA: assets/brand/app-icon-ai.png. SHA-256: 5ea903c173ee7197892a7f8b8a09a3be029ddb0c07306231cdd79fe34893c1ca.
Catálogo: 3990 marcas documentadas, 3990 SVG locales, 5.11 MiB sin comprimir. No se descargan logos al abrir el selector. ChatGPT, Claude, Gemini, Perplexity, Higgsfield, Kling, Runway, Luma, Krea, Pika y Sora están disponibles.

## Validación
- Flutter: 37 pruebas aprobadas de dominio/repositorio/permisos/widgets/onboarding/catálogo/iconos; análisis estático sin incidencias.
- Android: 10 comprobaciones nativas independientes de recurrencia, incluyendo días 31, bisiestos, trimestral, semanal, fecha de compra y fecha límite vencida.
- Backend: compilación TypeScript y 6 pruebas de dominio.
- APK ARM64 release 1.2.2+5; firma de pruebas. Este APK conserva el modo local existente.
- No hay teléfono conectado ni emulador instalado: el diálogo real de permiso, colocación del widget, entrega de un aviso y apertura desde el launcher requieren prueba en teléfono. No se presentan como verificados físicamente.

## Fuentes de implementación
- [Android App Widgets](https://developer.android.com/develop/ui/views/appwidgets)
- [Añadir un widget desde la app](https://developer.android.com/develop/ui/views/appwidgets/advanced)
- [API de AppWidgetManager](https://developer.android.com/reference/android/appwidget/AppWidgetManager)
- [Higgsfield en Dashboard Icons](https://github.com/homarr-labs/dashboard-icons/blob/main/svg/higgsfield.svg)
