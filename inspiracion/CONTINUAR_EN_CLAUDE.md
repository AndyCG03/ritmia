# Prompt para continuar Ritmia en Claude

Copia el siguiente bloque en Claude con acceso a esta carpeta, o abre este archivo allí. Adjunta las cuatro imágenes PNG de inspiracion si Claude no puede leer archivos locales.

---

Continúa una app Flutter existente llamada Ritmia. Trabaja en:

C:\Almacen\30_proyectos\activos\juegos\ritmia

No crees otro proyecto ni cambies Tumbo u otras carpetas hermanas. Primero inspecciona los cambios actuales, AGENTS.md, pubspec.yaml, las capas del dominio y los recursos. Respeta las ediciones del usuario.

## Mi objetivo y la dirección aprobada
Quiero una app de suscripciones minimalista, bonita, detallada y coherente, con personalidad propia. Debe tener UNA pantalla principal y abrir las alternativas en modales o bottom sheets. Quiero evitar una apariencia de plantilla generada: sin tarjetas enormes por todas partes, degradados decorativos, etiquetas redundantes, chips de plan en la cabecera ni información técnica en los flujos del usuario.

Usa estas cuatro referencias como dirección visual:
1. inspiracion/01-inicio-claro.png — principal clara con resumen mensual, semana compacta y lista.
2. inspiracion/02-calendario-oscuro.png — calendario mensual en bottom sheet, modo oscuro.
3. inspiracion/03-detalle-modal.png — detalle y acciones de una suscripción en bottom sheet oscuro.
4. inspiracion/04-buscador-ia.png — buscador y catálogo de servicios de IA en modal claro.

Los prompts de generación están junto a cada PNG, en archivos .prompt.txt. Son referencias de diseño; implementa widgets Flutter reales y accesibles, no pantallas basadas en imágenes. Los precios y fechas de las referencias son ejemplos, no precios comerciales actuales. No copies ruido/textura o pequeñas imprecisiones del raster. La UI debe ser nítida y plana.

## Skills y criterio de diseño
Usa una skill de diseño instalada. En esta PC se leyeron:
C:/Users/andyc/.codex/plugins/cache/claude-cowork/design/1.2.0/skills/design-critique/SKILL.md
C:/Users/andyc/.codex/plugins/cache/claude-cowork/design/1.2.0/skills/design-system/SKILL.md

Lee la que aplique o su equivalente disponible en tu entorno. Evalúa jerarquía, facilidad de uso, consistencia, espaciado y accesibilidad; aplica mejoras concretas. Lee también skills/subscription-engineering/SKILL.md para las reglas del dominio. Las instrucciones más recientes de este prompt prevalecen sobre planes anteriores que aún aparecen en documentación.

## Identidad
Preserva el logo original generado por IA:
assets/brand/app-icon-ai.png
La lámina de identidad está en assets/brand/identity-board.png.

Colores:
- Berenjena: #282338
- Lavanda: #B9A3F5
- Coral: #F47D68
- Marfil: #F8F6F1
- Primario accesible en claro: #7251AF
- Fondo oscuro propuesto: #121116
- Superficie de modal oscura: #1D1A24
- Texto oscuro principal: #F2EEF7
- Texto oscuro secundario: #AAA5B5
- Separadores oscuros: #34303F

Crea tokens semánticos y ThemeData claro/oscuro; evita colores hardcodeados dispersos. Sigue el modo del teléfono por defecto y permite cambiarlo desde Ajustes. No inviertas los colores de forma mecánica. Comprueba contraste 4.5:1 para texto normal, objetivos táctiles de 48 dp, teclado, áreas seguras, escalado de texto y movimiento reducido. Usa tipografía sobria del sistema, números tabulares y pesos moderados; las dimensiones de las imágenes son una guía, no coordenadas rígidas.

## Pantalla principal y navegación
- Cabecera discreta con logo, ritmia y acceso a Ajustes.
- Total de cargos previstos del mes por moneda. Nunca sumar USD con EUR o MXN.
- Mes con acceso al calendario completo en modal.
- Semana compacta con puntos de renovaciones. Si no hay eventos, mantener una composición equilibrada.
- Lista de suscripciones como filas limpias con separadores: logo, nombre, próxima fecha e importe/ciclo.
- Buscador y filtros útiles sin saturar la pantalla.
- Un botón principal para añadir.
- Abrir detalle, edición, calendario, catálogo, filtros, recordatorios y ajustes en bottom sheets o diálogos bien resueltos. Evitar apilar cadenas de modales sin control.
- Mantener acciones destructivas en el detalle, con confirmación y explicación precisa.
- Ocultar etiquetas como Modo local, FREE/PRO o implementación técnica en la pantalla principal. El límite del plan se explica en Ajustes y cuando afecta a una acción.
- Diseñar estados vacío, carga, error, desconexión, límite alcanzado y conflicto de edición.

## Catálogo e iconos de IA
Ya existen 214 marcas locales en lib/core/catalog.dart y assets/services, con procedencia/licencia en docs/SERVICE_ICONS.json y docs/SIMPLE_ICONS_LICENSE.md. Mantén al menos 100 y el buscador.

Asegura la presencia de:
ChatGPT/OpenAI, Claude/Anthropic, Google Gemini, Perplexity, Microsoft Copilot, Midjourney, Cursor, ElevenLabs, Poe, y opcionalmente Runway, Hugging Face, Replit y otras herramientas conocidas.

Añade aliases de búsqueda: GPT, ChatGPT, OpenAI; Claude, Anthropic; Gemini, Google; Copilot, Microsoft. Incluye filtro Inteligencia artificial, además del catálogo general. Separa servicio de plan: ChatGPT no es lo mismo que un plan específico ni una suscripción API de OpenAI. El usuario introduce el precio real de su plan; no precargues precios inventados.

Los iconos de las referencias son orientativos. Obtén SVG pequeños de fuentes autorizadas y comprueba licencia/uso de marca. No recortes logos de las capturas ni inventes logos de empresas. Si falta un icono autorizado, usa una alternativa tipográfica neutral y permite cargar uno.

## Dónde guardar los logos
- Catálogo de marcas conocidas: empaquetado dentro de la app como SVG pequeños; no descargarlo en cada inicio.
- Logo elegido por el usuario: miniatura comprimida y privada, sincronizada con su cuenta. Nunca hacer públicos todos los archivos.
- Firebase Storage es adecuado para escalar archivos, pero verifica sus requisitos actuales de facturación antes de elegirlo.
- El proyecto actualmente está sin facturación habilitada. Para un núcleo compatible con Spark, considera miniaturas MUY pequeñas en documentos separados de Firestore, con límites estrictos, lectura/caché por logo y validación de propiedad. Documenta el coste de almacenar binarios en Firestore y deja una migración limpia a Storage.
- La caché local no sustituye la sincronización. No habilites Blaze ni agregues una cuenta de facturación sin autorización.
- No conviertas las imágenes de inspiración en assets de la app: solo son referencias.

## Onboarding e idiomas
Existen tres Lotties originales en assets/lottie: rhythm.json, calendar.json, bell.json. Conserva la identidad y mejora su composición si hace falta.
El onboarding NO debe mostrar selector de idioma. Debe tomar automáticamente el idioma del teléfono; español e inglés ya están preparados mediante ARB. Un idioma no soportado usa un fallback claro. En Ajustes puede existir una preferencia manual, fuera del onboarding.
Tres pasos breves, omitir disponible, una acción principal, persistencia de finalización, respeto a reducir animaciones. No pedir permiso de notificaciones antes de explicar su utilidad; solicitarlo cuando el usuario las active.

## Funcionalidad y reglas a conservar
- Suscripciones gratis o de pago; moneda, periodicidad, categoría, notas, color y logo.
- Ancla de renovación estable: 31 de enero → 28/29 de febrero → 31 de marzo; año bisiesto correcto.
- Importe en unidades menores enteras, sin errores de coma flotante.
- Activas, pausadas y archivadas.
- Fecha de fin del plan y de prueba.
- Recordatorios 1, 3, 7 y 14 días antes, a las 09:00 locales, sin duplicados.
- Avisos locales Android/iOS ya implementados: ventana de 60 días, máximo 60 avisos, reconciliación tras cambios y logout. Verificar realmente en Android.
- Enlace HTTPS para gestionar/cancelar con el proveedor. Pausar o eliminar un registro de Ritmia NO cancela un contrato real.
- Exportación CSV con protección contra fórmulas.
- Gratis: CINCO suscripciones en total, incluidas pausadas/archivadas. No cinco imágenes. Pro: ilimitadas, con concesión validada por servidor; las compras aún no están conectadas.
- Vencimiento de Pro conserva los registros y permite editar/eliminar, pero bloquea nuevas altas mientras se supere la cuota.

## Firebase y estado real del proyecto
Proyecto: ritmia-app
Número: 725132962702
Android package: app.ritmia.ritmia
Firebase Android App ID: 1:725132962702:android:6d01d29033883eac3bd2df

La app Android ya fue registrada. Configuración local:
config/firebase.local.android.json
config/google-services.local.json
Esos archivos están excluidos de Git. No muestres claves ni credenciales en logs, chat o archivos versionados.

Al comprobar el proyecto, Firestore API estaba deshabilitada y billingEnabled=false. NO se completó el despliegue remoto. Verifica el estado actual antes de actuar.

IMPORTANTE: el código actual del adaptador cloud aún escribe mediante Cloud Functions. Se habló de cambiar el núcleo a Auth + Firestore para funcionar sin depender de Functions en Spark, pero ese cambio NO se implementó antes de este handoff.

Prioriza una conexión real Auth + Firestore para cuenta, datos y sincronización. Si cambias a transacciones cliente, el límite y las mutaciones del contador deben quedar protegidos por reglas Firestore, utilizando getAfter/existsAfter y evitando altas múltiples o manipulación del contador. El cliente nunca decide por sí solo que una cuenta es Pro. Prueba intentos de falsificar contador, sexta alta, altas simultáneas, acceso cruzado entre usuarios, edición/borrado y downgrade.

Los correos de recordatorio son OPCIONALES. La app puede funcionar solo con Firebase y notificaciones locales. No hagas depender la experiencia básica de un proveedor SMTP o de servicios externos. Auth sí gestiona sus propios mensajes de verificación/recuperación según configuración.

## Estado del código y validación previa
SDK instalado real: Flutter 3.47.7, Dart 3.13.5, Android SDK 36, Windows 11. La carpeta del SDK tiene un nombre antiguo; no confundirlo con la versión instalada.

Actualmente:
- Hay navegación inferior de tres secciones: todavía debe sustituirse por la pantalla única y modales.
- ThemeData solo claro: modo oscuro aún pendiente.
- Onboarding todavía incluye botones de idioma: hay que retirarlos.
- Las imágenes nuevas NO están implementadas.
- flutter analyze pasó sin errores.
- 19 pruebas Flutter principales y 2 pruebas del onboarding pasaron.
- 5 pruebas de dominio TypeScript pasaron.
- Las aserciones de integración con emuladores pasaron; Node global 25 tuvo un error de cierre del CLI después del éxito.
- Se generó un APK ARM64 de aproximadamente 25,8 MB en build/app/outputs/flutter-apk/app-release.apk. Corresponde al diseño anterior y modo local, no a estas referencias.

Lee docs/ANDROID.md para el almacén local de certificados que resolvió las descargas HTTPS de Java. No modifiques certificados o variables globales. Hay runtimes Node 20/25 instalados y Node 24 del runtime de Codex; no cambies Node global sin necesidad.

## Forma de trabajar y entrega
1. Inspecciona el estado real; resume brevemente las diferencias respecto a las referencias.
2. Implementa tokens claro/oscuro, pantalla única y componentes de modal coherentes.
3. Integra catálogo de IA y simplifica onboarding.
4. Termina la conexión Firebase dentro de la autorización y facturación disponibles.
5. Ejecuta pruebas significativas y corrige regresiones; mantén separación dominio/datos/presentación.
6. Comprueba visualmente claro y oscuro en tamaños de teléfono, teclado y texto grande.
7. Genera un APK Android ARM64 de prueba con el nuevo diseño. No sobrescribas entregables previos sin confirmación; usa un nombre versionado.
8. Entrega archivos, pruebas ejecutadas y estado verdadero de Firebase. No afirmes que el despliegue, compras o avisos reales funcionan si no los verificaste.

No necesito más propuestas genéricas: quiero una implementación detallada y fiel a las referencias, con criterio de ingeniería y diseño.
