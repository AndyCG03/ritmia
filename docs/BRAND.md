# Identidad Ritmia
Nombre propuesto: **Ritmia**. Voz: clara, cercana, tranquila. Eslogan: **Tus suscripciones, a tu ritmo.** / **Your subscriptions. Your rhythm.**

## Recursos
- assets/brand/identity-board.png: presentación inicial generada con IA.
- assets/brand/app-icon-ai.png: icono de producción generado con IA a partir de esa identidad. Se usa en launcher, cabecera, login y onboarding.
- assets/brand/mark.svg, mark-ink.svg, mark-white.svg: exploraciones vectoriales editables de la misma dirección gráfica.
- assets/brand/palette.json: tokens de color.
- assets/lottie/rhythm.json, calendar.json, bell.json: tres animaciones originales, locales y ligeras.
- docs/SERVICE_ICONS.json: revisión de Simple Icons, URL, tamaño y SHA-256 de cada SVG.
- docs/SIMPLE_ICONS_LICENSE.md: licencia del catálogo. Las marcas siguen perteneciendo a sus titulares; el catálogo identifica servicios y no implica colaboración.

## Paleta
| Token | Hex | Uso |
|---|---|---|
| Ink | #282338 | Texto, superficies oscuras |
| Lavender | #B9A3F5 | Símbolo y acentos sobre oscuro |
| Coral | #F47D68 | Punto distintivo y pequeños acentos |
| Paper | #F8F6F1 | Fondo |
| Accessible primary | #7251AF | Acciones/texto sobre fondos claros |

Lavanda y coral suaves no se usan para párrafos sobre blanco. Los colores de categorías se oscurecen para legibilidad. Tipografía Material del sistema; evitar descargas de fuentes durante el arranque.

## Movimiento
Lotties de 4 segundos a 30 fps. Desplazamientos modestos, ritmo calmado, sin flashes. Tres pasos: reunir → visualizar → decidir. Saltar y selector de idioma disponibles. MediaQuery.disableAnimations detiene reproducción y reduce transiciones.

## Generación IA
Se usó el generador de imágenes integrado, sin claves API. El prompt inicial pidió una identidad para RITMIA con símbolo orbital inspirado en R, tres segmentos rítmicos, punto coral, berenjena/lavanda/coral/marfil, sin marcas ajenas.
El prompt final tomó identity-board.png como referencia y pidió un icono cuadrado individual, símbolo preservado, fondo berenjena completo, sin texto, sin dispositivo ni marcas de agua, con márgenes seguros. No se recortó la lámina inicial para el launcher; se generó un recurso dedicado.

Para regenerar los tamaños nativos desde el PNG aprobado:
```powershell
dart run flutter_launcher_icons
```
No ejecutar render_brand.py después de este comando para producción: ese script corresponde a la exploración vectorial inicial, no al logo IA aprobado.
