# Design System — SodaTurn

Fuente de verdad: `design/sodaturn_design_system/DESIGN.md` + los mockups
PNG/HTML en `design/` (home, semana, participantes, estadísticas,
configuración). Implementado en
[app_theme.dart](../lib/core/theme/app_theme.dart).

## Identidad

Base **Material Design 3**, personalidad "efervescente": primario
**Indigo Refresh** (`#24389C`) para marca y contenedores clave, acento
**Sparkling Mint** (`#5CFD80`) para acciones, éxito y highlights
(FABs, chips seleccionados, día de hoy).

## Tokens principales

| Token | Valor | Uso en la app |
|---|---|---|
| `primary` | `#24389C` | Marca, textos de énfasis, locks activos |
| `primaryContainer` | `#3F51B5` | Hero card del Home, tiles indigo |
| `secondaryContainer` (mint) | `#5CFD80` | FABs, chips activos, card del día actual |
| `onSecondaryContainer` | `#00732C` | Texto sobre mint |
| `surface` | `#FBF8FE` | Fondo de pantallas |
| `error` / `errorContainer` | `#BA1A1A` / `#FFDAD6` | Advertencias de reglas |

## Tipografía

**Plus Jakarta Sans** exclusivamente, empaquetada como asset local en
`assets/fonts/` (pesos 400/500/600/700/800) — sin descarga en runtime,
funciona offline y en tests. Headlines en Bold/ExtraBold, cuerpo Regular,
labels SemiBold.

## Formas

- **Cards**: radio 24 (`AppTheme.cardRadius`).
- **Botones y chips**: pill (`StadiumBorder`), reforzando el tema "soda".
- **Inputs**: radio 12, borde 2px indigo al enfocar.

## Adaptaciones del mockup a datos reales

Los mockups traen contenido decorativo que el dominio no tiene; se adaptó
así:

| Mockup | App real |
|---|---|
| Fotos de avatar | `InitialsAvatar` (iniciales sobre color derivado del nombre) |
| "Entrega estimada 11:30 AM", "Nivel 4" | Omitidos (no existen en el dominio) |
| Donut "Distribución de Gasto" por sabor | Gasto total real + detalle por persona (regla 9: solo gaseosa) |
| "% FAIR" por persona | Conteos reales (X gaseosas · Y vasos) |
| Tab History (5º tab) | Fuera del MVP |
| Pantalla Ajustes | Fuera del MVP (export/reset diferidos) |
