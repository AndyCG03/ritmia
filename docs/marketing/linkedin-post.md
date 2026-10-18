# Post de LinkedIn: Ritmia

**Imagen:** `docs/marketing/ritmia-linkedin.png` (1080×1350, 4:5, renderizada a 2160×2700). Fuente editable: `docs/marketing/linkedin/linkedin.html`.

---

¿Cuántas suscripciones pagas al mes… y cuántas recuerdas?

Me pasaba seguido: una prueba gratis que se convertía en cargo, una renovación anual que llegaba sin aviso, servicios en dólares mezclados con otros en pesos. Así que construí **Ritmia**, una app Android para tener todas tus suscripciones bajo control.

Qué hace:

- Registras cada servicio en segundos con un catálogo de más de 200 marcas y su buscador.
- Ves todas las renovaciones del mes en un calendario.
- Recibes avisos 3 días y 1 día antes de cada cobro.
- Eliges la moneda que quieras para cada suscripción, y cada divisa conserva su propio total. Nunca se suman monedas distintas.
- Marcas un servicio como "no renovar" y Ritmia te recuerda la fecha límite para cancelarlo.
- Funciona en local, sin cuenta: tus datos se quedan en tu teléfono.

Detrás de cámaras:

- Flutter + Dart, con arquitectura por capas (dominio puro, adaptadores, Riverpod y vistas).
- Los importes se guardan como enteros en unidades menores, sin errores de redondeo.
- Las fechas de renovación se calculan desde la fecha original: si pagaste un 31, febrero cae el 28 o 29 y marzo vuelve al 31.
- Notificaciones locales, widget de pantalla de inicio, exportación CSV y a calendario.
- Backend con Firebase (Auth, Firestore y Cloud Functions con cuotas transaccionales) preparado para la sincronización en la nube.

Ya la estoy probando en mi teléfono. Me encantaría saber qué te haría falta para usarla tú también.

#Flutter #Dart #Android #Firebase #DesarrolloMovil #FinanzasPersonales #IndieDev

---

## Variante corta

Construí **Ritmia**, una app Android para que ninguna suscripción te cobre por sorpresa: calendario de renovaciones, avisos 3 días y 1 día antes del cargo, la moneda que quieras en cada servicio y más de 200 marcas en el catálogo. Hecha con Flutter, funciona sin cuenta y tus datos se quedan en tu teléfono.

¿Qué suscripción se te olvida siempre?

#Flutter #Android #IndieDev
