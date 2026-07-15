# SodaTurn (turn_soda)

App Flutter para decidir quién compra la **gaseosa** del almuerzo cada
día hábil y quién compra los **vasos** de la semana, con rotación justa,
reglas de negocio y persistencia local.

- 📚 **Documentación completa**: [docs/](docs/README.md)
- 🎨 **Mockups y design system**: [design/](design/)

## Correr el proyecto

Requiere Flutter (el proyecto usa FVM, canal `stable`):

```bash
fvm flutter pub get
fvm flutter run       # emulador o dispositivo Android
```

## Calidad

```bash
fvm flutter analyze
fvm flutter test
```

## Stack

Flutter + Riverpod (StateNotifier) + GoRouter + dartz, Clean Architecture
feature-first, persistencia con `shared_preferences` (fase 2 planeada:
Supabase — ver [docs/06-roadmap-supabase.md](docs/06-roadmap-supabase.md)).
