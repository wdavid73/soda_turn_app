# Documentación — SodaTurn (turn_soda)

App Flutter para decidir, de lunes a viernes, quién compra la **gaseosa**
del almuerzo (~$7.000 COP) y quién compra los **vasos** (una vez por
semana), con rotación justa, reglas de negocio y persistencia local.

| Documento | Contenido |
|---|---|
| [01-contexto.md](01-contexto.md) | Objetivo, participantes e historia del proyecto (web v1/v2 → Flutter) |
| [02-reglas-negocio.md](02-reglas-negocio.md) | Las 9 reglas v2, su dureza y el comportamiento de advertencias |
| [03-arquitectura.md](03-arquitectura.md) | Clean Architecture, estructura de carpetas, Riverpod y flujo Either/Failure |
| [04-modelo-datos.md](04-modelo-datos.md) | Entidades, esquema JSON persistido (compatible web v2) y clave de storage |
| [05-design-system.md](05-design-system.md) | Design system SodaTurn y su mapeo a `ThemeData` |
| [06-roadmap-supabase.md](06-roadmap-supabase.md) | Fase 2: persistencia en la nube con Supabase (diseño propuesto, no implementado) |

## Comandos rápidos

El proyecto usa FVM (canal `stable`):

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter run          # dispositivo/emulador Android
```

## Alcance del MVP

Incluye: generar semana, reglas v2 completas, bloqueos 🔒, edición manual
con advertencias, gestión de participantes y estadísticas.

**Fuera del MVP** (pendiente para fases siguientes): pantalla de Ajustes
(exportar/importar respaldo, reiniciar datos, modo oscuro), tab History
del mockup, y la sincronización en la nube (ver
[06-roadmap-supabase.md](06-roadmap-supabase.md)).
