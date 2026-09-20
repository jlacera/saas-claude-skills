---
name: saas-project-kickoff
description: >
  Master orchestrator of the SaaS lifecycle. Detects the real phase of a
  project, invokes saas-architecture-blueprint, saas-security-workflow,
  saas-adversarial-audit, saas-billing-unit-economics and
  saas-production-readiness in order, enforces the gates between phases and
  keeps PROJECT_STATE.md up to date. Single entry point: when in doubt about
  which SaaS skill applies, this one runs first. Use when opening or resuming
  any SaaS project, and when the user says "nuevo proyecto", "quiero crear un
  SaaS", "vamos a empezar", "arrancamos", "kickoff", "de cero", "que hago
  primero", "en que fase estoy", "revisa mi proyecto", "audita el proyecto
  completo", "quiero hacerlo bien" or "no quiero repetir errores. Skill content
  is in Spanish.
---

# SaaS Project Kickoff — Orquestador del Ciclo de Vida

> **Rol:** punto de entrada único para cualquier proyecto SaaS. Esta skill no contiene reglas técnicas propias: detecta en qué fase está el proyecto, invoca las skills especializadas en el orden correcto y **hace cumplir los gates** entre fases.
>
> **Motivo de existir:** las skills especializadas funcionan por sí solas, pero solo si se invocan en el momento adecuado. El fallo real no es que falte conocimiento, es que se aplica tarde. Auditar seguridad después de tener 500 usuarios, o descubrir el coste por usuario después de fijar precios, es aplicar el conocimiento correcto en el orden equivocado.

---

## 0. LA CADENA CANÓNICA

```
          TRANSVERSAL      →  saas-agent-rules          (cómo trabaja el agente, siempre)
                           →  saas-definition-of-done   (puerta de cada módulo)

FASE 0 — ESTRUCTURA        →  saas-architecture-blueprint
   ↓ [GATE 0: 12 decisiones cerradas por escrito]
FASE 1 — DESARROLLO        →  saas-security-workflow    (doctrina, continua)
                           →  saas-adversarial-audit    (detección, en cada PR)
   ↓ [GATE 1: 3 escudos + 13 mandamientos + quick-scan sin CRÍTICOS]
FASE 2 — MONETIZACIÓN      →  saas-billing-unit-economics
   ↓ [GATE 2: Red Lane firmado + margen positivo por tier]
FASE 3 — PUESTA EN MARCHA  →  saas-production-readiness
   ↓ [GATE 3: 13 capas sin ROJOS + smoke test + restore drill]
        PRODUCCIÓN
   ↺ vuelta a FASE 1 para cada funcionalidad nueva

          BAJO DEMANDA     →  saas-compliance-readiness (cuando un contrato pide sello)
                           →  saas-growth-geo           (adquisición y GEO)
```

`saas-security-workflow` y `saas-adversarial-audit` no son fases que se cierran: son **transversales**. La primera fija la doctrina; la segunda detecta los patrones concretos en el código. Se re-ejecutan en cada diff que toque auth, datos, endpoints o integraciones, para siempre.

---

## 1. PROTOCOLO DE ARRANQUE

### Paso 1 — Detectar la fase real

No preguntar al usuario en qué fase cree que está. **Comprobarlo.**

| Señal a buscar | Fase deducida |
|---|---|
| No hay repositorio, o solo hay README | Fase 0 |
| Hay código pero no hay `docs/adr/` ni decisiones documentadas | **Fase 0 pendiente** (deuda) |
| Hay esquema de BD sin `tenant_id`/`org_id` en tablas de usuario | **Fase 0 crítica** — parar todo |
| Código en desarrollo, sin pasarela de pago | Fase 1 |
| Existe integración de pagos en modo test | Fase 2 |
| Claves live activas, usuarios reales | Fase 3 + Fase 1 continua |
| Ya en producción, hay incidentes | Fase 3, modo incidente |

Comprobaciones concretas a ejecutar cuando hay acceso al repositorio:

```bash
ls docs/adr/ 2>/dev/null | wc -l          # ¿hay decisiones documentadas?
ls CLAUDE.md .mcp.json .env.example 2>/dev/null  # ¿estructura canónica?
grep -rl "tenant_id\|org_id" --include="*.sql" --include="*.prisma" . | head
grep -rl "stripe\|paddle\|lemonsqueezy" --include="*.ts" --include="*.py" . | head
git log --oneline | wc -l                  # madurez del repo
```

### Paso 2 — Declarar el diagnóstico

Antes de hacer nada, decir en dos líneas: fase detectada, evidencia en la que se basa, y si hay **deuda de fase anterior** que obligue a retroceder.

**Regla dura:** si se detecta deuda de una fase anterior, se resuelve esa fase antes de avanzar. No se construye la Fase 2 sobre una Fase 0 sin cerrar. Esta es toda la razón de ser del orquestador.

### Paso 3 — Invocar la skill de la fase

Cargar y ejecutar la skill correspondiente **completa**, no un resumen de memoria. El valor está en el detalle de los checklists.

### Paso 4 — Registrar el estado

Escribir o actualizar `PROJECT_STATE.md` en la raíz del proyecto (plantilla en §3).

---

## 2. LOS GATES

Un gate no se supera por consenso ni por prisa. Se supera con evidencia.

### GATE 0 → permite empezar a codificar

- [ ] Las 12 decisiones del blueprint respondidas por escrito, con coste de revertir estimado.
- [ ] Modelo de tenancy elegido y `tenant_id`/`org_id` presente en el esquema inicial.
- [ ] Separación `users` / `organizations` / `memberships` modelada.
- [ ] ADRs creados para las decisiones de Carril Rojo.
- [ ] Estructura canónica del repo creada (`CLAUDE.md`, `.env.example`, `.claude/`).
- [ ] Risk Lanes asignados por módulo.

**Si falla:** no se genera scaffolding. Se emiten las preguntas que faltan.

### GATE 1 → permite integrar pagos

- [ ] Los 3 escudos verificados (rate limiting, aislamiento de secretos, validación de entrada).
- [ ] RLS activo sin `USING (true)` en toda tabla con datos de usuario.
- [ ] Test de aislamiento cross-tenant automatizado y en verde.
- [ ] Auditoría IDOR: ningún recurso accesible por ID sin comprobar propiedad en servidor.
- [ ] Histórico de git limpio de secretos.
- [ ] Linter y tipado estricto en CI, sin supresiones.
- [ ] `saas-adversarial-audit/scripts/quick-scan.sh` sin patrones CRÍTICOS.
- [ ] Prompts auditores del stack ejecutados por un revisor independiente (sesión, subagente o modelo distinto del autor) en todo módulo de Carril Rojo.

**Si falla:** no se toca código de pagos. Un fallo de autorización con pagos activos convierte un bug en un fraude.

### GATE 2 → permite activar cobros reales

- [ ] Checklist del Red Lane Gate firmado por un humano nombrado, con fecha.
- [ ] Webhooks con firma verificada, deduplicación e idempotencia probadas con reenvío real.
- [ ] Los 7 eventos obligatorios de suscripción manejados.
- [ ] Protocolo anti-chargeback completo (descriptor, recibos, cancelación autoservicio, TOS con constancia).
- [ ] Ningún tier con coste del usuario p95 superior al ARPU.
- [ ] Hard cap de consumo por organización activo y probado.

**Si falla:** las claves siguen en modo test.

### GATE 3 → permite el go-live

- [ ] Auditoría de 13 capas **sin ningún ROJO** (o con riesgo aceptado por escrito, con nombre y fecha).
- [ ] Checklist pre-deploy completo.
- [ ] Restore drill de backup ejecutado con éxito.
- [ ] Rollback probado y cronometrado por debajo de 60 segundos.
- [ ] Alertas validadas provocando un error real en staging (llegada < 60 s).
- [ ] Smoke test en dominio real superado, incluido móvil.
- [ ] Spend caps y límites de presupuesto configurados.
- [ ] Auditoría adversarial completa del stack sin hallazgos CRÍTICOS abiertos.
- [ ] Si el contrato exige certificación o cuestionario de seguridad: matriz de `saas-compliance-readiness` con evidencia, no declaración.

**Si falla:** no hay lanzamiento. Retrasar 24 horas cuesta menos que un incidente a las 2:00 AM.

---

## 3. PROJECT_STATE.md

Archivo vivo en la raíz del proyecto, versionado en git. Es la memoria del ciclo entre sesiones — sin él, cada sesión nueva vuelve a empezar de cero y las decisiones se re-litigan.

```markdown
# Estado del Proyecto — [nombre]

- Fase actual: [0 / 1 / 2 / 3]
- Última revisión: YYYY-MM-DD
- Stack: [resumen en una línea]

## Gates

| Gate | Estado | Fecha | Evidencia / bloqueante |
|---|---|---|---|
| 0 — Blueprint | ✅ / ⚠️ / ❌ | | |
| 1 — Seguridad | ✅ / ⚠️ / ❌ | | |
| 2 — Billing   | ✅ / ⚠️ / ❌ | | |
| 3 — Producción| ✅ / ⚠️ / ❌ | | |

## Decisiones irreversibles tomadas
[Resumen de las 12 decisiones. Enlace a docs/adr/]

## Deuda conocida y aceptada
| Ítem | Fase | Riesgo | Aceptado por | Fecha límite |
|---|---|---|---|---|

## Riesgos abiertos
[Ítems 🔴 y 🟡 vivos, con responsable]

## Próxima acción
[Una sola frase. La siguiente cosa que hay que hacer.]
```

**Regla:** toda sesión de trabajo sobre el proyecto empieza leyendo este archivo y termina actualizándolo.

---

## 4. MODOS DE OPERACIÓN

### Modo A — Proyecto nuevo desde cero

1. Ejecutar `saas-architecture-blueprint` completo. No generar código hasta cerrar el Gate 0.
2. Crear estructura canónica del repo + `PROJECT_STATE.md` + ADRs iniciales.
3. Generar el scaffolding de Fase 1 (schema, auth, tenancy) — **solo eso**. Es lo irreversible y va primero.
4. A partir de aquí, `saas-security-workflow` en cada diff.

**Orden de construcción innegociable:** lo irreversible primero (esquema, tenancy, identidad, auth), luego el negocio, luego la optimización. La tentación siempre es empezar por la pantalla bonita; es también el camino más caro.

### Modo B — Proyecto existente (auditoría de recuperación)

Este es el caso de un proyecto que ya duele.

1. Detectar la fase real por evidencia (§1).
2. **Auditar hacia atrás**: ejecutar los gates de todas las fases anteriores a la detectada, no solo la actual.
3. Producir un informe único de deuda, priorizado por: *pierdo dinero → pierdo datos → me demandan*.
4. Distinguir explícitamente entre lo que **debe** arreglarse antes de seguir y lo que puede convivir como deuda documentada.
5. Registrar la deuda aceptada en `PROJECT_STATE.md` con responsable y fecha límite. La deuda no documentada reaparece como incidente.

### Modo C — Funcionalidad nueva sobre proyecto en producción

1. Clasificar la funcionalidad en Risk Lane (Verde / Amarillo / Rojo).
2. 🟢 Verde → implementar + `saas-security-workflow` en el diff.
3. 🟡 Amarillo → añadir revisión humana de la lógica de negocio.
4. 🔴 Rojo → **retroceder a Fase 0** para esa funcionalidad: mini-blueprint, ADR y modelo de amenazas antes de una sola línea. Todo lo que toque auth, pagos, PII, migraciones o multi-tenancy es Rojo.
5. Antes de desplegar → `saas-production-readiness` en Modo B.

### Modo D — Incidente en vivo

Saltar directo a `saas-production-readiness` Modo C. No auditar arquitectura con el servicio caído. **Contener primero, entender después.** El post-mortem alimenta el `PROJECT_STATE.md`.

---

## 5. PRINCIPIOS DEL ORQUESTADOR

1. **Detectar, no preguntar.** La fase se deduce de la evidencia del repositorio. Preguntar al usuario en qué fase cree estar produce respuestas optimistas.
2. **No saltar gates por prisa.** El coste de saltarse un gate no aparece hoy; aparece en el peor momento posible y multiplicado.
3. **Deuda documentada o inexistente.** Aceptar deuda es legítimo; aceptarla en silencio no. Toda deuda lleva nombre y fecha.
4. **Lo irreversible primero.** El orden de construcción se decide por coste de reversión, no por visibilidad ni por lo que apetece hacer.
5. **Una sola próxima acción.** Al terminar cualquier invocación, la salida incluye exactamente una frase con lo siguiente a hacer. Una lista de veinte pendientes paraliza; una acción concreta desbloquea.
6. **La skill se carga completa.** Nunca aplicar "de memoria" el contenido de una skill especializada. El valor está en los checklists literales.

---

## 6. FORMATO DE SALIDA OBLIGATORIO

```markdown
## Diagnóstico
Fase detectada: [N] — [evidencia concreta en la que se basa]
Deuda de fases anteriores: [ninguna / lista]

## Gates
[Tabla de estado de los 4 gates]

## Bloqueantes
[Lo que impide avanzar, ordenado por: dinero → datos → demanda]

## Ejecutando
[Skill invocada y por qué]

## Próxima acción
[Una sola frase.]
```

