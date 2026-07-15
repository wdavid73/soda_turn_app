# Fase 2 — Persistencia en la nube con Supabase

> **Estado: propuesta.** Nada de esto está implementado; el MVP es 100 %
> local. Este documento fija el diseño para que la migración no requiera
> tocar dominio ni presentación.

## Principio rector

`TurnosRepository` (dominio) es el único contrato de persistencia. La
fase 2 agrega una implementación remota **detrás del mismo contrato**:

```
TurnosRepository (contrato, sin cambios)
├── TurnosRepositoryImpl        ← MVP: shared_preferences
└── TurnosSupabaseRepository    ← fase 2: supabase_flutter
```

La UI, el ViewModel, los usecases y el motor de reglas no cambian. El
swap se hace en `turnosRepositoryProvider`.

## Esquema de tablas propuesto

El agregado se normaliza en 3 tablas (más el grupo, para multi-equipo):

```sql
create table groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz default now()
);

create table participants (
  id text not null,                 -- slug estable (mismo id del MVP)
  group_id uuid references groups(id) on delete cascade,
  name text not null,
  active boolean not null default true,
  primary key (group_id, id)
);

create table day_assignments (
  group_id uuid references groups(id) on delete cascade,
  date date not null,               -- clave ISO del MVP
  present text[] not null default '{}',
  gaseosa text,                     -- id de participante (nullable)
  locked boolean not null default false,
  warning text,
  primary key (group_id, date)
);

create table weekly_vasos (
  group_id uuid references groups(id) on delete cascade,
  monday date not null,             -- lunes ISO de la semana
  person_id text,
  locked boolean not null default false,
  warning text,
  primary key (group_id, monday)
);
```

El mapeo desde `TurnosStateModel` es directo: las claves de los mapas
(`yyyy-MM-dd`) pasan a columnas `date`/`monday`.

## Auth y RLS

- **Auth mínima viable**: un solo grupo compartido con *anonymous
  sign-in* o magic link por correo; cada usuario pertenece a un grupo
  (tabla `group_members(user_id, group_id)`).
- **RLS**: políticas por tabla `group_id in (select group_id from
  group_members where user_id = auth.uid())` para select/insert/update.
- Las advertencias/locks son datos del grupo, no del usuario: cualquiera
  del grupo puede editar (la app ya asume confianza total del equipo).

## Estrategia de sincronización

Recomendación para la fase 2 (en orden de esfuerzo):

1. **Remoto como fuente de verdad** (simple): `load()` lee de Supabase,
   `save()` hace upsert de las filas tocadas. Sin caché local persistente;
   `shared_preferences` queda solo como respaldo de arranque offline.
2. **Realtime opcional**: suscripción a cambios de las 3 tablas para que
   dos teléfonos vean la semana actualizarse en vivo (Supabase Realtime).
3. **Offline-first (después, si hace falta)**: cola de mutaciones con
   last-write-wins por fila; el esquema por fila (día/semana) hace que los
   conflictos sean raros y acotados.

## Migración del estado local

Al primer login: si `almuerzo-turnos-v2` existe en `shared_preferences` y
el grupo remoto está vacío, subir el estado local completo (participants
→ day_assignments → weekly_vasos) y marcar la migración hecha. Nunca
borrar el respaldo local automáticamente.

## Cambios de código previstos

| Pieza | Cambio |
|---|---|
| `pubspec.yaml` | + `supabase_flutter` |
| `main.dart` | `Supabase.initialize(url, anonKey)` (claves via `--dart-define`) |
| `features/turnos/data/datasources/` | + `turnos_remote_datasource.dart` |
| `features/turnos/data/repositories/` | + `turnos_supabase_repository.dart` |
| `turnos_providers.dart` | `turnosRepositoryProvider` decide local vs remoto |
| Nueva feature `auth/` | login (magic link/anónimo) + selección de grupo |

Todo lo demás (engine, usecases, pantallas, tests de reglas) queda igual.
