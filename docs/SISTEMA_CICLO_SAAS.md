---
id: KB-009
title: "Sistema de Skills SaaS — Ciclo de Vida Completo"
domain: "Meta / Orquestación de Skills / Ciclo SaaS"
last_updated: "2026-08-03"
target_audience: "Jesús / Lupin / Builders"
---

# 🧩 MÓDULO 09: SISTEMA DE SKILLS SAAS (CICLO COMPLETO)

> Cinco skills instaladas en la cuenta que convierten esta base de conocimiento en flujo ejecutable.
> Punto de entrada único: **`saas-project-kickoff`**.

---

## 1. LA CADENA

```
            saas-project-kickoff  ← ORQUESTADOR (punto de entrada)
                     │
                     ├─ detecta fase real por evidencia del repo
                     ├─ aplica gates entre fases
                     └─ mantiene PROJECT_STATE.md
                     │
  FASE 0 ─────────── saas-architecture-blueprint      [KB Mód. 01]
     ↓ GATE 0: 12 decisiones cerradas por escrito
  FASE 1 ─────────── saas-security-workflow           [KB Mód. 02]  ← transversal, en cada diff
     ↓ GATE 1: 3 escudos + 10 mandamientos + test cross-tenant
  FASE 2 ─────────── saas-billing-unit-economics      [KB Mód. 05]
     ↓ GATE 2: Red Lane firmado + margen positivo por tier
  FASE 3 ─────────── saas-production-readiness        [KB Mód. 03]
     ↓ GATE 3: 13 capas sin ROJOS + smoke test + restore drill
                 PRODUCCIÓN
                     ↺ vuelta a Fase 1 por cada funcionalidad nueva
```

---

## 2. TABLA DE SKILLS

| Skill | Fase | Módulo KB origen | Bloquea si… |
| :--- | :---: | :--- | :--- |
| `saas-project-kickoff` | Todas | Meta (nuevo) | Hay deuda de fase anterior sin resolver |
| `saas-architecture-blueprint` | 0 | 01 + ampliación | Alguna de las 12 decisiones sin cerrar |
| `saas-security-workflow` | 1 (continua) | 02 | Falla algún escudo o mandamiento |
| `saas-billing-unit-economics` | 2 | 05 + ampliación | Red Lane sin firma humana |
| `saas-production-readiness` | 3 | 03 + ampliación | Existe cualquier ítem en 🔴 |

---

## 3. LAS 12 DECISIONES IRREVERSIBLES (RESUMEN)

Referencia rápida del Gate 0. Detalle completo en la skill.

| # | Decisión | Riesgo si se toma por defecto |
| :---: | :--- | :--- |
| D1 | Modelo de tenancy | Falta `tenant_id` → migración catastrófica con clientes |
| D2 | Usuario ≠ Organización | Datos colgando de `user_id` → refactor más caro que existe |
| D3 | Roles y permisos (RBAC) | Permisos en frontend → IDOR sistemático |
| D4 | Formato de IDs | IDs autoincrementales expuestos → enumeración |
| D5 | Entitlements y límites de plan | Sin hard cap → factura LLM de 4 cifras en una noche |
| D6 | Auditoría y borrado | Sin `audit_log` → imposible reconstruir un incidente |
| D7 | Estrategia de migraciones | No append-only → corrupción irreversible |
| D8 | UTC, moneda, i18n | `float` en dinero / hora local → facturación rota |
| D9 | Frontera serverless↔contenedor | Timeout a los 30s en producción, sin saber que existía |
| D10 | Aislamiento en capas compartidas | Caché sin prefijo → fuga cross-tenant pese a RLS perfecta |
| D11 | Trampas de escala | N+1 + sin pooling → muro a los 50-100 usuarios |
| D12 | Nivel de complejidad permitido | Sobreingeniería → superficie de fallo multiplicada |

---

## 4. AMPLIACIONES SOBRE LA BASE DE CONOCIMIENTO ORIGINAL

Contenido añadido en las skills que no estaba en los módulos 01/03/05:

**Blueprint (Fase 0):**
- Modelo `users` / `organizations` / `memberships` como estructura obligatoria desde el día 0.
- UUIDv7 + IDs públicos con prefijo semántico estilo Stripe.
- Entitlements centralizados en una única función de dominio.
- `audit_log` append-only desde la primera migración.
- Patrón expand → migrate → contract para migraciones sin downtime.
- Patrón outbox para efectos externos transaccionales.
- Paginación por cursor en lugar de OFFSET.
- Dead-letter queues y backoff exponencial en colas.
- ADRs (Architecture Decision Records) con señal de reconsideración.
- Tabla de las 7 capas compartidas con mitigación por capa.

**Billing (Fase 2):**
- Máquina de estados de suscripción con los 7 eventos obligatorios.
- Deduplicación de webhooks por `event.id` dentro de transacción.
- Gotchas: body-parser rompe la firma; devolver 500 causa reintentos infinitos.
- Idempotencia determinista derivada del dominio (no UUID aleatorio).
- Métricas de negocio: MRR desglosado, LTV/CAC, CAC payback, recuperación de dunning.
- Coste p95 por tier, no solo la media.
- Requisitos fiscales UE (VAT B2B, inversión del sujeto pasivo).

**Production Readiness (Fase 3):**
- Modos A/B/C (auditoría / deploy / incidente).
- Runbook de fuga de datos con las 72h de GDPR.
- Runbook de factura disparada.
- Plantilla de post-mortem sin culpa.
- Feature flags y despliegue progresivo como red de seguridad.
- Cadencia de revisión semanal / mensual / trimestral.
- Smoke test extendido a móvil.

---

## 5. INVOCACIÓN

| Situación | Qué decir |
| :--- | :--- |
| Proyecto nuevo | "Vamos a arrancar un SaaS nuevo" |
| Proyecto existente que duele | "Audita el proyecto completo" |
| Funcionalidad nueva en producción | "Voy a añadir [X]" |
| Antes de desplegar | "Quiero desplegar" |
| Algo se ha roto | "Está caído" / "error 500 en producción" |

En todos los casos, `saas-project-kickoff` detecta la fase y encadena lo que corresponda.
