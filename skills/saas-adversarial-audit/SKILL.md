---
name: saas-adversarial-audit
description: >
  Adversarial audit catalogue for AI-generated code: 40+ failure patterns that
  pass review and tests but ship exploitable gaps. Routes to stack-specific
  auditor prompts for RAG multi-tenancy, Next.js RSC and middleware, tRPC and
  GraphQL, Prisma and Postgres RLS, webhooks and cron, Clerk/JWT and OAuth,
  email templates, supply chain and DNS, and autonomous agents. Ships a
  deterministic grep scanner that flags 15 of them in seconds. Use when
  reviewing or auditing code, before a PR merge, after an AI agent writes a
  feature, when the user says "revisa el codigo", "audita", "security review",
  "esto es seguro?", or names a stack (Next.js, tRPC, Prisma, Supabase, Convex,
  Clerk, Resend, Vercel, GraphQL, RAG). Skill content is in Spanish.
---
# 🔎 AUDITORÍA ADVERSARIAL DEL CÓDIGO GENERADO POR IA

Esta skill no enseña principios: **detecta fallos concretos**. Cubre el patrón que define al código escrito por agentes — sintaxis impecable, tests unitarios en verde, y cero límites de seguridad, aislamiento multi-tenant o ciclo de vida del estado.

Las skills `saas-security-workflow` (doctrina y mandamientos) y `saas-definition-of-done` (puerta de calidad) definen **qué debe cumplirse**. Esta define **qué buscar, en qué archivo y con qué veredicto**.

---

## 0. PROTOCOLO DE USO

1. **Escaneo determinista primero.** Ejecutar `scripts/quick-scan.sh` desde la raíz del repositorio. Tarda segundos y encuentra 15 de los 40 patrones sin ambigüedad.
2. **Enrutar por stack.** Identificar qué tecnologías usa el proyecto y cargar **solo** las referencias aplicables de la tabla del §1. No cargar las ocho.
3. **Ejecutar el prompt auditor** de cada patrón aplicable contra los archivos reales, no contra la memoria de la conversación.
4. **Emitir veredicto por hallazgo** con el formato obligatorio del §2.

**Regla dura:** un hallazgo CRÍTICO bloquea el merge. No se documenta como deuda aceptada salvo firma humana nombrada y con fecha en el PR.

---

## 1. TABLA DE ENRUTAMIENTO

| Si el proyecto tiene... | Cargar referencia | Patrones cubiertos |
|---|---|---|
| RAG, embeddings, vector DB, documentos de cliente | `references/rag-multitenant.md` | 4 |
| Next.js (App Router, Server Components, Server Actions, middleware) | `references/nextjs.md` | 6 |
| tRPC, GraphQL, API routes, validación con Zod | `references/api-layer.md` | 6 |
| Clerk, Auth.js, JWT propio, OAuth, reset de contraseña, panel admin | `references/identidad-jwt.md` | 6 |
| Prisma, Postgres, Neon, Supabase, consultas lentas, réplicas | `references/datos.md` | 5 |
| Webhooks, cron jobs, Resend, Firebase, Convex, Stripe | `references/integraciones.md` | 6 |
| Dependencias npm, scripts de terceros, CORS, subdominios | `references/supply-chain.md` | 5 |
| Agentes autónomos, text-to-SQL, herramientas MCP, RBAC estático | `references/agentes-ia.md` | 5 |

---

## 2. FORMATO OBLIGATORIO DE HALLAZGO

```
[SEVERIDAD] Patrón — archivo:línea
Qué pasa:      una frase, en términos de impacto real, no de teoría.
Evidencia:     el fragmento exacto encontrado.
Explotación:   cómo lo ejecuta un atacante en tres pasos.
Parche:        el diff exacto. Nunca "considera añadir validación".
Verificación:  el comando o test que demuestra que quedó cerrado.
```

Severidades: **CRÍTICO** (fuga de datos entre clientes, bypass de autorización, pérdida financiera), **ALTO** (exposición de información o denegación de servicio), **MEDIO** (endurecimiento pendiente).

---

## 3. LEY DEL REVISOR INDEPENDIENTE

> **El modelo que construye no revisa.**

Pedirle a la misma sesión que auditó su propio código que confirme si está bien es pedirle que evalúe su propio razonamiento con el mismo sesgo que lo produjo. Dirá que está bien. En módulos de **Carril Rojo** (auth, pagos, PII, migraciones) la auditoría se ejecuta obligatoriamente en:

- una **sesión nueva sin contexto previo** del desarrollo, o
- un **subagente** lanzado explícitamente como auditor, o
- un **modelo distinto** al que escribió el código.

El auditor recibe el código y el prompt auditor. **Nunca recibe la justificación del autor** — esa justificación es precisamente el sesgo que se quiere eliminar.

---

## 4. LOS 5 PATRONES QUE MÁS APARECEN

Si solo hay tiempo para cinco comprobaciones, son estas. Aparecen en prácticamente todo proyecto generado con asistencia de IA:

1. **Validación solo en cliente.** El esquema Zod vive en el formulario y el endpoint acepta lo que sea. → `references/api-layer.md`
2. **Asignación masiva.** El handler pasa el `body` completo al ORM; el atacante añade `role: "admin"`. → `references/api-layer.md`
3. **Autorización que comprueba identidad pero no propiedad.** Usuario A pide el ID de usuario B y lo recibe. → `references/identidad-jwt.md`
4. **Webhook sin idempotencia.** Firma válida, reintento del proveedor, doble cobro. → `references/integraciones.md`
5. **Consulta sin filtro de tenant en caché, vector store o canal en tiempo real.** RLS no protege lo que está delante de la base de datos. → `references/rag-multitenant.md`

---

## 5. ENTREGABLE

Al cerrar una auditoría, el output incluye siempre:

1. Resultado del `quick-scan.sh` (salida literal).
2. Tabla de patrones evaluados: aplicable / no aplicable / hallazgo.
3. Hallazgos en el formato del §2, ordenados por severidad.
4. Veredicto explícito: **APTO PARA MERGE** o **BLOQUEADO**, con el motivo en una línea.
5. Los patrones que **no** se pudieron verificar y por qué (sin acceso al archivo, sin entorno, etc.). Un patrón no verificado nunca se reporta como superado.
