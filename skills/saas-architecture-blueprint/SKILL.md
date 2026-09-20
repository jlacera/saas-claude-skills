---
name: saas-architecture-blueprint
description: >
  Phase 0 of any SaaS: closes the 12 irreversible decisions (tenancy, identity,
  ID strategy, entitlements, audit trail, migrations, serverless limits, cache
  isolation) and assigns Risk Lanes before a single line of code exists. Blocks
  code generation until the decisions are written down. Use before writing code,
  generating a plan, choosing a stack, designing a database schema or
  scaffolding, and when the user says "nuevo proyecto", "disena la
  arquitectura", "que stack uso", "modelo de datos", "multi-tenant",
  "workspaces", "scaffolding", "MVP", "estructura del repo", "CLAUDE.md",
  "migracion", "N+1", "pooling", "Redis", "cola", "worker", "Docker",
  "serverless" or "refactor grande". Skill content is in Spanish.
---

# SaaS Architecture Blueprint — Fase 0 (Decisiones Irreversibles)

> **STATUS: MANDATORIO.** Ninguna línea de código de un SaaS nuevo se genera antes de completar el Bloque 1 (Las 12 Decisiones). El coste de revertir cualquiera de ellas después de tener usuarios reales es entre 10x y 100x el coste de decidirla bien ahora.
>
> **Principio rector:** el 80% de la deuda técnica que mata un SaaS no viene de código malo, viene de decisiones estructurales tomadas por defecto, sin decidirlas.

---

## 0. ACTIVACIÓN Y ORDEN EN EL CICLO

Ejecutar esta skill cuando se detecte:

- Arranque de proyecto nuevo, MVP, scaffolding, "voy a crear un SaaS".
- Diseño o modificación del esquema de base de datos.
- Introducción de caché, colas, workers, contenedores, índices de búsqueda o almacenamiento de archivos.
- Refactor arquitectónico o migración de stack.
- Cualquier duda de "¿cómo estructuro esto?".

**Cadena canónica del ciclo SaaS:**

```
saas-architecture-blueprint  (Fase 0 — estructura)
        ↓
saas-security-workflow       (Fase 1 — durante desarrollo, en cada diff)
        ↓
saas-billing-unit-economics  (Fase 2 — antes de cobrar el primer euro)
        ↓
saas-production-readiness    (Fase 3 — antes del go-live y en cada deploy)
```

Si esta skill se salta y luego aparece un problema de aislamiento entre clientes, de escalado o de migraciones, la causa raíz es siempre una decisión no tomada aquí.

---

## 1. LAS 12 DECISIONES IRREVERSIBLES

Ninguna respuesta arquitectónica es válida hasta que las 12 estén respondidas por escrito, con una línea de justificación cada una. Formato de salida obligatorio: tabla `Decisión | Elección | Motivo | Coste de revertir`.

### D1 — Modelo de Tenancy

Elegir explícitamente y no volver atrás:

| Modelo | Cuándo | Coste de migrar después |
|---|---|---|
| **Shared schema + `tenant_id` en cada tabla + RLS** | Por defecto. B2B SaaS, hasta miles de tenants. | Bajo si se hizo bien; catastrófico si falta `tenant_id` en alguna tabla. |
| **Schema-per-tenant** | Requisitos de aislamiento fuerte, decenas/cientos de tenants, personalización por cliente. | Alto. Migraciones × N schemas. |
| **DB-per-tenant** | Enterprise, data residency por país, compliance duro. | Muy alto en operación (backups × N). |

**Reglas innegociables del modelo compartido:**
- Toda tabla que contenga datos de usuario lleva `tenant_id` (o `org_id`) **no nulo**, con índice, desde la migración inicial. Añadirlo después con datos en producción es una operación de riesgo.
- RLS activo en todas ellas. Prohibido `USING (true)`.
- La clave primaria compuesta o el índice único siempre incluye `tenant_id` cuando la unicidad es por tenant (ej. `UNIQUE(tenant_id, slug)`, nunca `UNIQUE(slug)`).

### D2 — Modelo de Identidad: Usuario ≠ Organización

Error fatal y frecuentísimo: modelar `user` como el propietario de los datos. En un SaaS B2B el propietario es la **organización/workspace**, y un usuario puede pertenecer a varias.

Estructura mínima desde el día 0, incluso si el MVP es "un usuario = una cuenta":

```
users            (identidad: email, auth_provider_id)
organizations    (tenant real: nombre, plan, estado de suscripción)
memberships      (user_id, org_id, role)  ← la tabla que te salva la vida
<recursos>       (org_id, ...)            ← todo cuelga de la organización
```

Migrar de "datos colgando de `user_id`" a "datos colgando de `org_id`" con clientes de pago es uno de los refactors más caros que existen. Se hace ahora o se paga después.

### D3 — Roles y Permisos (RBAC)

- Definir el conjunto de roles cerrado desde el inicio: mínimo `owner`, `admin`, `member`. Añadir `billing_admin` si hay pagos.
- Los permisos se evalúan **siempre en servidor**, contra `membership.role` de la organización del recurso. Nunca contra un claim del cliente.
- Regla: un endpoint sin comprobación explícita de `(user ∈ org) AND (role permite acción)` no se mergea.
- Prohibido cablear permisos en el frontend como única barrera. El frontend solo oculta; el servidor decide.

### D4 — Formato de Identificadores

- **Nunca exponer IDs autoincrementales (`serial`/`bigserial`) en URLs o APIs.** Regalan el volumen de negocio y facilitan enumeración (IDOR).
- Estándar: **UUIDv7** (ordenable temporalmente, buena localidad de índice) o ULID. UUIDv4 es aceptable pero fragmenta índices en tablas grandes.
- Patrón recomendado: ID interno numérico para joins + ID público con prefijo semántico (`org_7f3a…`, `inv_9c2b…`) al estilo Stripe. El prefijo hace que un ID mal enrutado se detecte en logs al instante.

### D5 — Entitlements y Límites de Plan

El límite de plan se decide en Fase 0, no cuando llega el primer abuso.

- Tabla o mapa canónico `plan → { límites }` (usuarios, proyectos, llamadas IA/mes, almacenamiento, retención).
- La comprobación de límite vive en **una sola función de dominio** (`assertWithinLimit(orgId, resource)`), invocada en servidor antes de cada creación de recurso o llamada costosa. Nunca dispersa en 15 endpoints.
- Todo contador con coste real (tokens, llamadas a LLM, almacenamiento) se persiste con un **hard cap por organización**, independiente del rate limit por IP.
- Sin esto, un solo usuario en plan gratuito puede generar una factura de LLM de cuatro cifras en una noche.

### D6 — Auditoría y Borrado

- **Soft delete por defecto** (`deleted_at TIMESTAMPTZ NULL`) en toda entidad de negocio. El borrado duro solo por proceso de retención o petición GDPR.
- Purga real a los 30 días. Documentada, automatizada y probada.
- **Tabla `audit_log` desde el día 0**: `id, org_id, actor_user_id, action, entity_type, entity_id, metadata jsonb, created_at`. Append-only. Es el único activo que te permite reconstruir un incidente o defenderte de una disputa.
- Borrado en cascada modelado explícitamente: al eliminar una organización, qué se borra, qué se anonimiza y qué se conserva por obligación legal/fiscal.
- Exportación de datos del usuario (GDPR, 72h) diseñada como capacidad del sistema, no como script improvisado.

### D7 — Estrategia de Migraciones

- **Append-only, sin excepciones.** Jamás modificar un archivo de migración ya aplicado en staging o producción. Toda corrección es una migración nueva superpuesta.
- **Patrón expand → migrate → contract** para todo cambio con riesgo de downtime:
  1. *Expand:* añadir la columna/tabla nueva, nullable, sin tocar la vieja.
  2. *Migrate:* backfill por lotes + escritura dual desde la app.
  3. *Contract:* eliminar la columna vieja en una migración posterior, ya con la app desplegada.
- Toda migración debe tener plan de reversión escrito. Si no es reversible, se dice explícitamente y se coordina con backup verificado previo.
- Migración de esquema y despliegue de código son **dos pasos separados**, en ese orden, nunca atómicos.

### D8 — Zona Horaria, Moneda y Localización

Decisiones que parecen triviales y rompen la facturación seis meses después:

- Todos los `timestamp` en **`TIMESTAMPTZ`, almacenados en UTC**. Nunca hora local del servidor. Nunca `TIMESTAMP` sin zona.
- Todo importe monetario en **enteros de la unidad mínima** (céntimos), nunca `float`. Campo `currency` explícito junto a cada importe.
- Textos de interfaz externalizados desde el inicio si hay la más mínima intención internacional. Retrofitear i18n sobre strings hardcodeados es un refactor de semanas.

### D9 — Frontera Serverless ↔ Contenedor

Criterio de escalada, decidido antes de construir:

Migrar a **worker en contenedor detrás de una cola (Redis/SQS/BullMQ)** cuando la carga cumpla cualquiera de estos:
- Ejecución **> 30 segundos** (generación de PDF/informes, procesamiento audio/vídeo, embeddings en lote, exportaciones masivas).
- **Conexiones persistentes:** WebSockets, realtime, streaming bidireccional.
- **Jobs de cola intensivos** o cron que procesan miles de filas o llaman LLMs sin límite de timeout HTTP.

Los endpoints HTTP permanecen ligeros en serverless y **solo encolan**. La observabilidad de ambos lados va a la misma pila (Sentry / OpenTelemetry).

Plantilla de worker endurecido:

```dockerfile
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Usuario no root: mitiga escalada de privilegios
RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 worker
USER worker

COPY --chown=worker:nodejs package*.json ./
RUN npm ci --only=production
COPY --chown=worker:nodejs ./dist ./dist

CMD ["node", "dist/workers/queue.worker.js"]
```

**Ampliación obligatoria de diseño de colas:**
- Todo job debe ser **idempotente** (reejecutable sin efectos duplicados) y llevar clave de idempotencia.
- Toda cola necesita **dead-letter queue** y política de reintentos con backoff exponencial. Un job que falla infinitamente satura el worker y la factura.
- Visibilidad: métrica de profundidad de cola con alerta. Una cola creciendo es un incidente antes de ser una caída.

### D10 — Aislamiento Multi-Tenant en Capas Compartidas

**Este es el fallo que más SaaS pequeños ha reventado.** Tu RLS en PostgreSQL puede ser perfecta y aun así filtrar datos entre clientes, porque la caché se sitúa **delante** de la base de datos y bypassea RLS por completo.

Si cacheas con clave `user:123:profile`, y el Tenant B tiene también un usuario `123` en su contexto, la caché devuelve los datos privados del Tenant A.

**Convención de clave obligatoria en Redis:**

```
tenant:{tenant_id}:{resource_type}:{resource_id}
```

**Wrapper que hace imposible el error humano:**

```typescript
export class TenantRedisClient {
  constructor(private readonly redis: Redis, private readonly tenantId: string) {
    if (!tenantId) throw new Error("CRITICAL_SECURITY: tenantId requerido para acceder a caché.");
  }

  private getKey(key: string): string {
    return `tenant:${this.tenantId}:${key}`;
  }

  async get(key: string): Promise<string | null> {
    return this.redis.get(this.getKey(key));
  }

  async set(key: string, value: string, ttlSeconds?: number): Promise<"OK"> {
    return ttlSeconds
      ? this.redis.set(this.getKey(key), value, "EX", ttlSeconds)
      : this.redis.set(this.getKey(key), value);
  }
}
```

Regla: **el cliente Redis crudo no se importa fuera de este wrapper.** Si hace falta, prohibirlo con una regla de lint (`no-restricted-imports`).

**La fuga no ocurre solo en caché. Auditar las 7 capas compartidas:**

| Capa | Riesgo | Mitigación |
|---|---|---|
| Caché (Redis/Memcached) | Clave sin prefijo de tenant | Wrapper + ACL `~tenant1:*` |
| Índice de búsqueda (Algolia/Meilisearch/ES) | Filtro de tenant aplicado en cliente | Filtro forzado en clave de API restringida por tenant |
| Colas de background jobs | Payload procesado sin scope | `tenant_id` obligatorio en el payload, validado al consumir |
| Almacenamiento de archivos (S3/R2) | Path o URL prefirmada sin aislar | Prefijo `/{tenant_id}/…` + política IAM por prefijo |
| Canales WebSocket | Suscripción sin verificar pertenencia | Autorización de canal en el servidor al suscribir |
| Pipelines de logging | PII cruzada / logs compartidos | Campo `tenant_id` estructurado, nunca payloads crudos |
| Rate limiting | Contador global en lugar de por tenant | Clave de límite compuesta por tenant |

**Test automatizado obligatorio (cross-tenant):** login como Tenant A → cargar cada página principal → logout → login como Tenant B → cargar las mismas páginas → comparar respuestas y fallar el build si aparece cualquier dato de A en la sesión de B. Este test se escribe **antes** del primer cliente real.

### D11 — Trampas de Escala Pre-Cableadas

Se resuelven en el diseño, no cuando el sistema ya está de rodillas:

- **Consultas N+1:** los ORMs (Prisma, Drizzle, SQLAlchemy) y el código generado por IA iteran haciendo una query por elemento. Rápido con 10 filas, muerte con 2.000. Auditar todo endpoint de listado y reemplazar por joins, `.include()` o batch loading (DataLoader).
- **Índices:** índice explícito en toda columna de filtrado frecuente, toda clave foránea y todo `tenant_id`. Un índice que falta no se nota hasta que ya duele.
- **Connection pooling:** interponer PgBouncer / Supabase Transaction Pooler (puerto 6543) / RDS Proxy entre app y base de datos. En serverless, **modo transaction pooling obligatorio**. Sin esto, a 50-100 usuarios concurrentes se agota `max_connections` y aparece la pantalla blanca.
- **Transacciones atómicas:** todo flujo multipaso (registro + cobro + aprovisionamiento) va dentro de `BEGIN … COMMIT/ROLLBACK`. O todo, o nada. Los registros huérfanos tras un fallo parcial son deuda permanente.
- **Patrón outbox** cuando un cambio en base de datos debe provocar un efecto externo (email, webhook, evento): escribir el evento en una tabla `outbox` dentro de la misma transacción y despacharlo con un worker. Evita el clásico "se cobró pero no se envió" y su inverso.
- **Paginación por cursor**, no por `OFFSET`, en cualquier listado que pueda superar unos miles de filas.
- **Prueba de carga controlada** (50-100 usuarios concurrentes en staging) antes del lanzamiento público. No opcional.

### D12 — Nivel de Complejidad Permitido (Gate Anti-Sobreingeniería)

**Arquitectura por defecto: monolito modular full-stack.** Next.js/TypeScript o FastAPI/Python sobre PostgreSQL (Supabase, Neon, RDS).

Prohibido en un MVP o producto sin hitos reales de escala:
- Kubernetes, microservicios distribuidos, service mesh.
- CQRS, event sourcing, DDD táctico completo.
- Capas de abstracción "por si acaso" (repositorios genéricos, factories de factories).

Cada una de estas multiplica la superficie de fallo, dispara el coste de depuración y degrada gravemente la capacidad de un asistente de IA para razonar sobre el repositorio.

Se introducen **solo** cuando existe una métrica real que lo exija, y la métrica se cita en el ADR correspondiente.

Excepción legítima al monolito: el patrón híbrido de D9 (serverless ligero + workers en contenedor). Eso no es microservicios, es separación de perfiles de carga.

---

## 2. ESTRUCTURA CANÓNICA DEL REPOSITORIO

La configuración directiva del proyecto se versiona en Git como código de primera clase:

```
proyecto/
├── CLAUDE.md              <-- Memoria global (<200 líneas): stack, comandos test/build, reglas innegociables
├── .mcp.json              <-- Servidores MCP del proyecto (GitHub, BD, Slack), compartido por Git
├── docs/adr/              <-- Architecture Decision Records numerados (ver §3)
└── .claude/
    ├── settings.json      <-- Permisos, modelo seleccionado, hooks de seguridad
    ├── reglas/            <-- Documentación modular por tema (code-style.md, testing.md, api-conventions.md)
    ├── comandos/          <-- Slash commands para flujos repetibles
    ├── habilidades/       <-- SKILL.md cargados bajo demanda
    ├── agentes/           <-- Subagentes aislados (code-reviewer.md, security-auditor.md)
    └── hooks/             <-- Scripts por evento (validate-bash.sh) que bloquean comandos destructivos
```

**Gotchas de producción:**

1. **`CLAUDE.md` ≠ manual.** Mantenerlo bajo 200 líneas como índice ejecutivo. Los manuales largos van a `.claude/habilidades/<nombre>/SKILL.md`, que solo se cargan cuando hacen falta. Saturar `CLAUDE.md` quema el context window en cada turno y degrada todas las respuestas posteriores.
2. **Hooks deterministas.** Un LLM puede intentar `rm -rf`, `sudo`, `git push --force` o `--no-verify`. Los hooks interceptan comandos peligrosos y ejecutan linter/formateador obligatoriamente tras cada edición. Es la única barrera que no depende del criterio del modelo.
3. **`.mcp.json` en la raíz tiene precedencia** sobre la configuración global del usuario. Garantiza que todo el equipo apunte a las mismas herramientas y a la BD de staging correcta, no a producción por accidente.
4. **`.env.example` versionado** con todos los nombres de clave (sin valores) desde el commit 0. `.env` real en `.gitignore` desde el commit 0, no desde el commit 40.

---

## 3. ADR: DEJAR CONSTANCIA DE POR QUÉ

Toda decisión de las 12 y todo cambio arquitectónico posterior genera un **Architecture Decision Record** en `docs/adr/NNNN-titulo.md`:

```markdown
# ADR-0007: Modelo de tenancy compartido con RLS

- Estado: aceptado
- Fecha: YYYY-MM-DD

## Contexto
[Qué problema obliga a decidir. Números reales si existen.]

## Decisión
[Qué se elige, en una frase.]

## Alternativas descartadas
[Cuáles y por qué no.]

## Consecuencias
- Positivas:
- Negativas / deuda asumida:
- Coste estimado de revertir:
- Señal que obligaría a reconsiderar: [métrica concreta]
```

Sin ADR, en seis meses nadie —ni tú, ni el asistente de IA— recuerda por qué algo está así, y se "arregla" rompiendo una restricción que existía por un motivo.

---

## 4. RISK LANES: ASIGNAR EN EL DISEÑO, NO EN EL REVIEW

Cada módulo del plan se etiqueta desde el blueprint. La etiqueta determina el nivel de autonomía que la IA puede tener sobre ese código durante todo el ciclo de vida.

| Carril | Alcance | Autonomía permitida |
|---|---|---|
| 🟢 **Verde** | UI interna, documentación, tests, refactors menores, estilos | IA implementa. Aprobación estándar + CI. |
| 🟡 **Amarillo** | Lógica de negocio, integraciones API, jobs en background | IA implementa. Aprobación estándar + sign-off humano en lógica sutil. |
| 🔴 **Rojo** | Auth, autorización, pagos, PII, criptografía, migraciones de BD, APIs públicas, multi-tenancy | **IA solo redacta borrador.** Reescritura o verificación profunda humana, revisión de seguridad y modelo de amenazas obligatorios. |

**Regla dura:** todo lo decidido en D1, D2, D3, D5, D6, D7 y D10 es Carril Rojo permanentemente. No se degrada con el tiempo ni "porque ya funciona".

**Plantilla de PR asistida por IA:**

```markdown
## AI-assisted change disclosure
- Participación de IA: ninguna / sugerida / borrador / reescritura / generación de tests
- Herramienta o flujo:
- Archivos o módulos tocados por IA:
- Risk lane: Verde / Amarillo / Rojo
- Verificación humana realizada: [explicación técnica obligatoria del autor]
```

---

## 5. TAXONOMÍA DE AUTONOMÍA DE AGENTES

El techo de autonomía no lo fija la inteligencia del modelo, sino la naturaleza de la tarea. Dos preguntas determinan el nivel:

1. **¿Es fácil de comprobar?** (test determinista vs. juicio humano)
2. **¿Es barato de revertir?** (Ctrl+Z garantizado vs. impacto en producción)

| Nivel | Combinación | Ejemplos | Modo de trabajo |
|---|---|---|---|
| **0 — Asistente** | Difícil comprobar + caro revertir | Migraciones de núcleo, motores de feature flags, cambios de alto blast radius | El humano escribe y ejecuta. La IA solo consulta. |
| **1 — Human-in-the-loop** | Difícil comprobar + barato revertir | Refactors de legibilidad, naming, evaluaciones subjetivas | IA propone borrador, humano aprueba antes del merge. |
| **2 — Delegación** | Fácil comprobar + caro revertir | Estándar del desarrollo moderno | IA implementa; el merge está protegido por gates, shadow mode y despliegue progresivo. |
| **3 — Autónomo** | Fácil comprobar + barato revertir | Bumps de dependencias, fixes de lint, añadir cobertura de tests | La IA ejecuta y abre PR sin supervisión previa. |

**Estrategias para subir de nivel legítimamente:**
- Descomponer la tarea para separar las piezas Nivel 3 de los componentes Nivel 0.
- Hacer la tarea comprobable: si escribes el test primero, la tarea sube de nivel automáticamente.
- Codificar guardarraíles en el pipeline: dry-run por defecto, aislamiento de credenciales, feature flags, shadow mode.

---

## 6. ORQUESTACIÓN DE MODELOS (ECONOMÍA DEL CONTEXTO)

### Matriz de enrutamiento por tarea

| Modelo | Cuándo | Nota |
|---|---|---|
| **Haiku** (rápido, barato) | Triaje, clasificación, chat sin archivos grandes, búsqueda web simple | No usar para razonamiento arquitectónico. |
| **Sonnet** (diario) | Desarrollo simple, refactor rutinario, redacción operativa, uso intensivo de conectores MCP | Caballo de batalla. |
| **Opus** (trabajo profundo) | Diseño de sistemas, auditorías, coworking arquitectónico | Establecer esfuerzo alto siempre. |
| **Fable / clase Mythos** (máxima autonomía) | Flujos multi-etapa de principio a fin, investigación profunda, razonamiento adversarial | Regla 90/10: reservar para el 10% de tareas que realmente lo exigen. Cuando el modelo diario se atasca, se escala. |

### El patrón sándwich (arquitecto ↔ obrero)

Nunca mezclar inspección de arquitectura e implementación en la misma ventana de contexto.

```
Fase 1 — Explorador (modelo ejecutor): mapea el repo, extrae contexto e interfaces relevantes.
Fase 2 — Arquitecto (modelo frontier, /plan): diseña la estrategia paso a paso y evalúa riesgos.
Fase 3 — Obrero (modelo ejecutor): escribe la implementación siguiendo el plan literalmente.
Fase 4 — Auditor (modelo frontier): revisión adversarial del diff antes del merge.
```

Ahorra presupuesto de tokens y, sobre todo, evita que el mismo contexto que escribió el código sea el que lo aprueba.

### Las 4 leyes de rigor del agente

1. **Leer la petición bajo las palabras.** Separar petición literal, intención operativa y condición de éxito. Si divergen, servir a la intención y notificarlo en una línea.
2. **Dividir en piezas verificables independientemente.** Cada pieza con input, output y un chequeo que no dependa de las demás.
3. **Re-derivar todo.** No aceptar como verdad ninguna afirmación del prompt ni del código previo sin validarla. No hay excepciones por "solo es una edición pequeña".
4. **Atacar la propia conclusión.** Antes del merge, actuar como adversario del propio diff: casos borde, concurrencia, entradas malformadas, estados vacíos.

### Disciplina de context window

- Agrupar comandos de terminal en una sola invocación y **filtrar siempre la salida** (`| tail -n 50`, `| grep ERROR`, `| jq`). Volcar logs crudos quema el presupuesto de todos los turnos posteriores.
- Carga diferida: leer esquemas de BD y planes maestros solo bajo demanda.
- **Prohibido añadir dependencias** a `package.json` / `requirements.txt` sin justificación arquitectónica escrita. Cada dependencia es superficie de ataque (ver *slopsquatting*) y deuda de mantenimiento.

---

## 7. FUNDAMENTOS NO NEGOCIABLES DE CÓDIGO

- **Tipado estático estricto y linters** desde el commit 0: TypeScript `strict`, ESLint/Biome; Ruff/Mypy en Python. Si el linter falla, el código no es candidato a merge. Prohibido `@ts-ignore` y `eslint-disable` generados automáticamente.
- **Separación de capas (MVC como mínimo):** jamás una query de base de datos dentro de un componente visual. Modelo / Vista / Controlador separados aunque el proyecto sea pequeño.
- **Sin estado en el LLM.** El modelo es un procesador sin estado. El estado canónico vive en PostgreSQL/Redis. Nunca almacenar perfiles, historial financiero ni estado de negocio en el contexto de chat.
- **Tests contra scratch DB.** Toda ejecución automatizada (Playwright, Jest, Vitest, pytest) corre contra una base de datos semilla efímera y aislada. Jamás contra la BD compartida de desarrollo ni contra staging.
- **Secretos desde el día 1.** `.env` + gestor de secretos del host. El código "temporal con la clave hardcodeada para probar" llega invariablemente a producción.

---

## 8. LOS 8 ERRORES CAROS (CHECKLIST DE PREVENCIÓN)

1. Confundir token con palabra al presupuestar (1M tokens ≈ 750k palabras) → sobrecoste ~30% en facturas de API.
2. Subir `.env` al repositorio. Los bots escanean GitHub en segundos. Validar el histórico: `git log -p | grep -iE "sk-|api_key|secret"`. Si apareció, **rotar la clave**: borrar el commit no mitiga.
3. Asumir que el context window es memoria permanente. Cada sesión arranca de cero; usar RAG o persistencia explícita.
4. `git push` sin `git pull` previo.
5. Confundir agente con chatbot al vender. Un chatbot responde; un agente ejecuta acciones en sistemas.
6. Hacer fine-tuning cuando bastaba un prompt mejor o RAG. El 80% se resuelve con contexto.
7. Desplegar sin `npm run build` local previo. Que `dev` funcione no garantiza que producción compile.
8. Hardcodear credenciales "temporalmente".

---

## 9. FORMATO DE SALIDA OBLIGATORIO

Toda invocación de esta skill produce, en este orden y sin excepción:

1. **Tabla de las 12 Decisiones** — `Decisión | Elección | Motivo | Coste de revertir`. Si falta información para decidir, marcar `⛔ BLOQUEANTE` y preguntar, no asumir.
2. **Diagrama del modelo de datos** — entidades, `tenant_id`/`org_id`, relaciones, índices críticos.
3. **Mapa de capas compartidas** — para cada una de las 7 de D10: cómo se aísla el tenant.
4. **Tabla de Risk Lanes por módulo** — con nivel de autonomía de agente asignado.
5. **Lista de ADRs a crear** — numerados, con título.
6. **Plan de implementación por fases** — Fase 1 = lo irreversible (schema, tenancy, identidad, auth). Fase 2 = negocio. Fase 3 = optimización. Nunca al revés.
7. **Handoff explícito** — qué queda para `saas-security-workflow`, `saas-billing-unit-economics` y `saas-production-readiness`.

**Regla de bloqueo final:** si alguna de las 12 decisiones queda sin cerrar, no se emite código de scaffolding. Se emite la pregunta que falta. Un blueprint incompleto es peor que no tenerlo, porque genera falsa confianza.

