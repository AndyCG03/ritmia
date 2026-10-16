# Ritmia · inspiración de pantallas

Cuatro PNG generados con IA a partir de la identidad original de Ritmia. Se aplicaron los criterios de las skills **design-critique** y **design-system**: jerarquía, navegación simple, espaciado, consistencia y accesibilidad.

| Archivo | Función |
|---|---|
| 01-inicio-claro.png | Resumen mensual, semana compacta y lista en modo claro |
| 02-calendario-oscuro.png | Calendario completo en modal, modo oscuro |
| 03-detalle-modal.png | Detalle, recordatorios y gestión de una suscripción |
| 04-buscador-ia.png | Alta mediante catálogo de servicios de IA |

Abre [la galería](galeria.html) para comparar las cuatro. Cada imagen tiene su prompt completo en el archivo .prompt.txt correspondiente. Se usó el generador de imágenes integrado y se guardaron los resultados originales, sin recortar ni retocar.

Para continuar la app en Claude, utiliza **CONTINUAR_EN_CLAUDE.md**. Contiene las decisiones más recientes, rutas, reglas del negocio, criterios de implementación, estado real de Firebase y pasos de validación.

## Dirección de diseño
- Una pantalla principal; calendario, detalles, catálogo y ajustes en modales.
- Filas y separadores, tipografía sobria, importes alineados, acentos lavanda.
- Claro marfil y oscuro berenjena con superficies diferenciadas.
- Sin etiquetas Modo local, FREE/PRO o información de backend en la cabecera.
- Onboarding con idioma automático del teléfono y Lotties originales.
- Catálogo general de al menos 100 marcas, con búsqueda y filtro de IA.

Las marcas de las imágenes son referencias visuales; en la app deben usarse assets autorizados. Los importes son ejemplos de diseño. La UI Flutter existente todavía no refleja estas nuevas referencias.

## Revisión antes de implementar
1. Mantener contraste medido y áreas táctiles de 48 dp.
2. Verificar el calendario con fechas calculadas, no copiar una cuadrícula fija.
3. Ajustar tipografía a pantallas pequeñas y texto grande.
4. Evitar reproducir la textura tenue del generador; las superficies reales son planas.
5. Dar estados vacíos, carga, error y límite alcanzado.
6. No confundir pausar seguimiento con cancelar el contrato del proveedor.

Fecha de preparación: 16 de octubre de 2026.
