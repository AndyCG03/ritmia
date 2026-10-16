# Producto y evolución
## Posicionamiento
Ritmia: control tranquilo sobre los servicios que vuelven. Evitar lenguaje de banco o promesas de cancelar automáticamente. Objetivo único: saber qué tienes, qué cuesta y cuándo decidir.

## Gratis / Pro
| Función | Gratis | Pro |
|---|---|---|
| Registros, incluidos pausados/archivados | 5 | Ilimitados |
| Calendario y resumen por moneda | Sí | Sí |
| Logos del catálogo / personalizados | Sí | Sí |
| Recordatorios / fin de prueba / enlaces | Sí | Sí |
| Idiomas / exportación | Sí | Sí |
| Activación por compra real | No implementada | Requiere servidor y tienda |

El límite corresponde a suscripciones, según la aclaración del usuario, no a imágenes. Sin publicidad ni bloqueo de recordatorios. Precios y productos de compra pendientes de decisión. La pantalla de Pro comunica que las compras aún no están habilitadas.

## Semántica
- El importe representa un cargo por ciclo, no un promedio mensual.
- El resumen muestra cargos previstos que caen en el mes actual, agrupados por moneda.
- Gratis es coste cero, distinto de trial: una prueba tiene su fecha de fin y puede preceder al primer cargo de una suscripción de pago.
- Pausar/archivar detiene calendarios y avisos dentro de Ritmia.
- El usuario sigue siendo responsable de confirmar la cancelación con el proveedor.
- No almacenar contraseñas de proveedores, números de tarjeta ni credenciales bancarias.

## Evolución priorizada
1. Cuenta y cloud en dispositivos reales; activación de servicios y configuración de correo.
2. Compra/restauración Pro, comprobación de recibos y gestión de expiración/reembolso.
3. Borrado de cuenta con reautenticación, eliminación recursiva y de logos/cola.
4. Importación CSV y migración explícita local → cloud con gestión de duplicados/cuota.
5. Historial de cargos confirmados por el usuario; mantenerlo separado de previsiones.
6. Push FCM, materialización de próximas alarmas y tareas por usuario si aumenta el tráfico.
7. Resúmenes históricos y presupuesto por divisa; conversión FX solo con fuente/tasa/fecha visibles.
8. Más idiomas mediante ARB, sin mezclar copy con lógica.

No se han simulado funciones pendientes como si estuvieran operativas.
