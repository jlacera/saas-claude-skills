---
name: saas-security-workflow
description: >
  Security doctrine for any SaaS or agentic project: the 3 shields, the 13
  commandments, the 30-minute production matrix, the dual OWASP framework (Web
  Top 10 + LLM Top 10 2026, plus the Agentic and MCP Top 10), multi-tenant
  cross-cache isolation, MCP authorization (OAuth 2.1), EU AI Act Article 50
  and the StampHog merge gate. Use when code touches auth, authorization, RLS,
  secrets, uploads, LLM or MCP integrations, tenant isolation or webhooks, and
  when the user says "auditoria de seguridad", "vulnerabilidades", "RLS",
  "LLM security", "prompt injection", "MCP" or "agente autonomo". Code review
  of a diff belongs to saas-adversarial-audit, deploy gates to
  saas-production-readiness and certifications to saas-compliance-readiness.
  Skill content is in Spanish.
---

# SaaS Security Workflow — Compliance Inviolable (EU / ISO Ready)

> 📎 **Skill hermana:** esta skill define **qué debe cumplirse**. Para **qué buscar, en qué archivo y con qué veredicto** —el catálogo de 40+ patrones de fallo del código generado por IA, los prompts auditores por stack y el escáner determinista— cargar `saas-adversarial-audit/SKILL.md`.

> **STATUS: MANDATORIO.** Esta skill NO es opcional. Toda tarea de planificación, arquitectura, generación de código, revisión o auditoría de un SaaS, aplicación web, API, agente IA o proyecto agentico DEBE ejecutar este workflow antes de entregar cualquier resultado. Prohibido inferir por sentido común: se aplica el método explícito descrito aquí.

---

## 0. ACTIVACIÓN (Cuándo Ejecutar Este Workflow)

Ejecutar SIEMPRE que se detecte alguna de estas condiciones:

- Solicitud de **plan o diseño técnico de seguridad** de un SaaS, API o sistema agéntico (la arquitectura general la lleva `saas-architecture-blueprint`).
- Solicitud de **hardening, pentest checklist o due diligence técnica** (la revisión de un diff concreto la lleva `saas-adversarial-audit`; la compuerta de deploy, `saas-production-readiness`; las certificaciones, `saas-compliance-readiness`).
- Palabras clave detectadas: `RLS`, `Clerk`, `Auth0`, `MCP`, `LLM`, `agente`, `PII`, `SSO`, `SAML`, `secretos`, `uploads`.
- Antes de emitir cualquier snippet de código que toque: autenticación, autorización, base de datos, endpoints, uploads, integraciones IA, webhooks, pagos, secretos. En Carril Verde (docs, estilos, tests) no se dispara.

Si el trigger aplica y el workflow NO se ejecuta, la respuesta es incorrecta por definición.

---

## 1. PROTOCOLO DE EJECUCIÓN (3 ESCUDOS + AUDITORÍA FINAL)

Aplicar en orden estricto. No saltar etapas.

### ESCUDO 01 — Rate Limiting & Anti-DDoS
- Todos los endpoints expuestos deben devolver `429 Too Many Requests` bajo carga.
- Sensibles (login/reset/signup): **5-10 req/hora por IP**.
- Endpoints LLM/costosos: **10-30 req/min por usuario autenticado**.
- Prueba obligatoria:
  ```bash
  for i in {1..20}; do curl -s -o /dev/null -w "%{http_code}\n" https://APP/api/login; done
  ```
  Debe emitir `429` antes de la 11ª petición (con el límite configurado en 10).

### ESCUDO 02 — Aislamiento de Secretos
- CERO claves hardcodeadas. Todo va a `.env` local + dashboard de producción (Vercel/Railway/Fly).
- `.env` en `.gitignore` desde el commit 0.
- Auditoría obligatoria del historial git:
  ```bash
  git log -p | grep -iE "sk-|api_key|secret|token|password|bearer"
  ```
- Si se detecta clave filtrada: **rotarla inmediatamente** en el panel del proveedor. Rebase/borrar commit NO mitiga.

### ESCUDO 03 — Validación de Entradas
- Todo input de usuario validado con schema estático: **Zod / Valibot / Yup / Pydantic**.
- Prohibida concatenación de strings en SQL. Solo ORM (Prisma, Drizzle, SQLAlchemy) o consultas parametrizadas (`$1`, `?`).
- Sanitización obligatoria contra XSS (escape en render, CSP header).

### AUDITORÍA FINAL 30-MIN — Matriz de Producción

| Área | Verificación | Comando/Prueba | Pass |
|---|---|---|---|
| RLS | RLS activo y sin `USING (true)` en toda tabla con datos de usuario | `SELECT tablename FROM pg_tables WHERE rowsecurity = false;` | [ ] |
| IDOR | Servidor valida la pertenencia del recurso a la organización del usuario (`memberships`) en todo recurso por ID | Probar `/api/resource/ID_AJENO` con token normal | [ ] |
| IA/LLM | Rate Limit + Hard Cap financiero por usuario | 100 calls/min desde un mismo token | [ ] |
| Frontend Auth | Cero decisiones de precio/plan/rol en navegador | Inspeccionar Network en checkout | [ ] |
| Storage | Buckets sin permiso `LIST` público (S3/Supabase) | Request `LIST` anónimo al bucket | [ ] |
| SSRF | Bloqueo de peticiones a rangos privados/locales | `url=http://169.254.169.254` al scraper | [ ] |
| PII/GDPR | Soft-delete + borrado legal en cascada anonimizado | Simular delete de cuenta y auditar cascada | [ ] |
| Webhooks | Firma criptográfica validada (Stripe/Clerk/GitHub) | Enviar POST sin firma → debe rechazar | [ ] |
| Secretos | Ninguna clave en git history | `git log -p \| grep -iE "sk-\|api_key\|secret"` | [ ] |
| Sesiones | Invalidar tras 30 días de inactividad + refresh token rotation | Test manual de token expirado | [ ] |

**Si CUALQUIER casilla queda en `[ ]`, el proyecto NO pasa a producción.**

---

## 2. LOS 13 MANDAMIENTOS (INNEGOCIABLES)

1. **IDOR:** Nunca confiar en el ID de la URL. Validar propiedad server-side contra la organización del usuario, no contra el ID de la URL.
2. **RLS Prohibido `USING (true)`:** Toda política RLS debe filtrar por pertenencia: `org_id IN (SELECT org_id FROM memberships WHERE user_id = auth.uid())` (`auth.uid() = user_id` solo en datos estrictamente personales). Enable RLS ≠ seguro.
3. **Cero validación de precios/roles/planes en el cliente:** Frontend es hostil. Todo permiso se decide en servidor o RLS.
4. **Rate Limit + Hard Cap financiero en IA:** Tope numérico mensual en OpenAI/Anthropic/Replicate. Un `while true` puede quemar $3000/noche.
5. **Cero auth casera / JWT firmado y verificado:** Usar Auth0, Clerk, Supabase Auth, Keycloak. Validar `exp` y firma.
6. **Auditoría lógica de RLS:** Un `SELECT` sin filtro de fila = fuga masiva entre tenants.
7. **Cero `LIST` público en buckets:** Signed URLs con caducidad ≤60s para archivos privados.
8. **Proteger endpoints costosos no autenticados:** Login requerido antes de invocar LLM.
9. **SSRF:** Bloquear `127.0.0.1`, `10.0.0.0/8`, `169.254.169.254` (metadata cloud), `::1`, `fc00::/7`.
10. **Prompt Injection & Tool Hijacking:** Agentes IA con credenciales mínimas. Toda acción irreversible requiere Human-In-The-Loop.

---

## 3. SEGURIDAD IA / LLM / MCP (OWASP LLM Top 10 2026)

### Marco Dual Obligatorio
- **Capa 1 — OWASP Top 10 Web:** IDOR/RLS, SQLi, XSS, SSRF, misconfig, logging.
- **Capa 2 — OWASP Top 10 LLM (edición 2026, publicada el 04-08-2026):** LLM01 Prompt Injection (incluye servidores MCP, salida de herramientas y memoria), LLM02 fuga de información sensible, LLM03 Excessive Agency, LLM04 cadena de suministro (incluye slopsquatting), LLM05 envenenamiento de datos y modelo, LLM06 consumo sin límite (denial-of-wallet, bucles agénticos), LLM07 desinformación, LLM08 exposición de contexto oculto (system prompt y esquemas de herramientas), LLM09 debilidades en vectores y embeddings, LLM10 manejo inseguro de la salida (incluye código generado por IA que se ejecuta).
- **Capa 2b — OWASP Top 10 for Agentic Applications (2026):** ASI01 secuestro de objetivo, ASI02 abuso de herramientas, ASI03 abuso de identidad y privilegios, ASI04 cadena de suministro agéntica, ASI05 ejecución de código inesperada, ASI06 envenenamiento de memoria y contexto, ASI07 comunicación inter-agente insegura, ASI08 fallos en cascada, ASI09 explotación de la confianza humano-agente, ASI10 agentes rebeldes. Aplica en cuanto el modelo tiene herramientas o memoria persistente.
- **Gobernanza:** NIST SP 800-218A (final desde julio de 2024; SSDF 1.2 en borrador), guía NSA/CISA de diseño seguro de MCP (02-06-2026) y de adopción de agentes (30-04-2026).

### Reglas MCP (Model Context Protocol)
- **Human-In-The-Loop obligatorio** para: pagos, reembolsos, borrado de clientes/BD, campañas masivas, cambios de precios, modificación de contratos.
- **OAuth 2.1 con PKCE** obligatorio en servidores MCP remotos (spec 2026-07-28): el cliente envía `resource` (RFC 8707), el servidor publica metadatos de recurso protegido (RFC 9728), rechaza tokens no emitidos para él y **nunca reenvía tokens** aguas abajo; el registro dinámico de clientes queda obsoleto a favor de Client ID Metadata Documents; validar `iss` (RFC 9207) y `Origin` en transporte HTTP.
- **Los servidores MCP definidos por el proyecto (`.mcp.json`) se revisan como código:** varios IDE los ejecutaban automáticamente al abrir el repo (CSA, 01-07-2026); un repo clonado no debe poder arrancar un servidor sin aprobación.
- **OWASP MCP Top 10 (beta):** tokens mal gestionados, escalada por *scope creep*, envenenamiento de herramientas (descripciones con instrucciones), inyección de comandos, servidores MCP en la sombra, sobre-compartición de contexto.
- **Log de auditoría inmutable** por cada tool call: usuario, herramienta, parámetros, timestamp, código de retorno.
- **Jamás exponer `service_role key`** al cliente/agente. Solo en Edge Functions o servidores aislados sin entrada de usuario, y nunca en la conexión que usa la funcionalidad de IA (`quick-scan.sh` lo marca para revisión).

### Supabase RLS + Agentes IA
- 100% de tablas: `ALTER TABLE t ENABLE ROW LEVEL SECURITY;`
- Views: siempre `WITH (security_invoker = true)`.
- Desde el 30-10-2026 las tablas nuevas en `public` no se exponen al Data API automáticamente: comprobar qué esquema está expuesto y que vistas `security_definer` y vistas materializadas (saltan la RLS) no estén en él; `user_metadata` nunca en políticas (lo edita el usuario).
- Antes del deploy: `quick-scan.sh` de `saas-adversarial-audit` y el plugin `claude-security` de Claude Code (`/claude-security`, salida SARIF para el CI).
- Agentes en modo **read-only** por defecto; mutaciones requieren confirmación.

### Slopsquatting / Alucinación de Dependencias
- **Prohibido** ejecutar `pip install` / `npm i` de un paquete sugerido por IA sin verificar manualmente:
  - Existe en el registro oficial.
  - Tiene historial de mantenimiento >6 meses.
  - La procedencia firmada (Sigstore/SLSA) no basta: las oleadas Shai-Hulud y CHAINDROP de 2026 publicaron paquetes con atestaciones válidas. Mitigación: lockfile congelado, edad mínima de publicación (`minimumReleaseAge` en pnpm, `min-release-age` en npm), scripts de instalación desactivados, Actions fijadas por SHA.
  - Licencia compatible.
- Pin exacto + hash SHA-256 en lockfile. SBOM obligatorio.
- CI bloquea imports de paquetes recién registrados o sin reputación.

### Protección Financiera IA
- Hard Cap mensual/diario por usuario en la BD de créditos.
- Rate Limit por IP + user_id en TODO endpoint LLM.
- Respuesta `429` clara y auditable.

---

## 4. CUMPLIMIENTO EU / ISO / SOC 2 / GDPR

Checklist legal obligatorio para comercialización en la UE:

- [ ] **GDPR — Base Legal:** Documentada por cada tipo de procesamiento (consentimiento, contrato, interés legítimo).
- [ ] **GDPR — Derecho al Olvido:** Borrado en cascada + anonimización de transacciones sin romper integridad referencial.
- [ ] **GDPR — DPA (Data Processing Agreement)** firmado con todo subprocesador (OpenAI, Anthropic, Vercel, Supabase, Stripe).
- [ ] **GDPR — Prohibición de reentrenamiento** con prompts de usuarios (opt-out contractual con proveedor LLM).
- [ ] **GDPR — Transferencias internacionales:** SCCs (Standard Contractual Clauses) para datos que salgan de la UE.
- [ ] **GDPR — Registro de Actividades de Tratamiento (Art. 30)** mantenido.
- [ ] **GDPR — DPIA (Data Protection Impact Assessment)** para procesamiento de alto riesgo (perfilado, biometría, IA con decisiones automatizadas).
- [ ] **GDPR — Notificación de brecha ≤72h** a la autoridad supervisora (AEPD en España).
- [ ] **ISO 27001 Readiness:** Audit logs inmutables de toda lectura/mutación de datos de cliente.
- [ ] **SOC 2 Type II:** Controles de acceso, cambio, backup y monitoreo documentados.
- [ ] **HIPAA (si aplica):** BAA firmado, cifrado E2E, prohibición de uso para reentrenamiento.
- [ ] **eIDAS 2 / EU Digital Identity Wallet** compatibilidad si se autentica con eID.
- [ ] **AI Act (UE 2024/1689, modificado por el Reg. 2026/1744):** Clasificar el sistema (mínimo/limitado/alto riesgo/inaceptable). Art. 50 (transparencia) aplica desde el 02-08-2026; alto riesgo Anexo III desde el 02-12-2027 y Anexo I desde el 02-08-2028. Alto riesgo exige: gestión de riesgos, gobernanza de datos, documentación técnica, transparencia, supervisión humana, robustez, ciberseguridad y logs conservados al menos 6 meses.
- [ ] **NIS2 Directive:** Aplicable si se es "entidad esencial" o "importante". Alerta temprana 24 h, notificación 72 h, informe final 1 mes. En España sin transponer (TJUE, 08-07-2026); el comprador la exige igual.
- [ ] **Cyber Resilience Act:** notificación 24 h / 72 h / 14 días vía ENISA desde el 11-09-2026 si el software es parte imprescindible de un producto con elementos digitales; el SaaS puro queda fuera.
- [ ] **Data Act:** portabilidad y cambio de proveedor (preaviso 30 días, transición 30 días); cargos por cambio prohibidos desde el 12-01-2027.
- [ ] **DORA (si fintech):** Resilencia operacional digital.

---

## 5. AUTH ENTERPRISE B2B (Antes de Escoger Proveedor)

Auditar desde el minuto 0 la compatibilidad con:

- [ ] **SAML 2.0 / OIDC** (Okta, Azure AD, Google Workspace, Ping).
- [ ] **SCIM** para aprovisionamiento automático.
- [ ] **MFA obligatorio** (TOTP, WebAuthn/Passkeys, SMS como fallback).
- [ ] **Session management:** invalidación 30 días inactividad, refresh token rotation.
- [ ] **Audit logs exportables** (SIEM-friendly: JSON estructurado + timestamps ISO 8601).
- [ ] **Portabilidad de identidades:** no depender de IDs internos que impidan migración futura.

Proveedores validados: **Auth0, Clerk, Keycloak, WorkOS, Supabase Auth (con addon Enterprise)**.

---

## 6. RESILIENCIA DE DATOS (Backup & DR)

- **Backups Inmutables (WORM):** Write Once, Read Many. Cifrados en tránsito y reposo.
- **Aislamiento de plano de control:** Identidades de backup DISTINTAS a las del tenant productivo (si cae Entra ID, el backup sigue accesible).
- **Motores duales de recuperación:**
  - *Granular:* Restaurar elementos individuales en segundos.
  - *Backup-optimized:* Restaurar TB/hora desde fuentes limpias + clean-room testing + scan antimalware pre-restore.
- **Retención personalizada:** 30d / 1a / 7a según compliance. Sin depender de retenciones default por workload.
- **Test de restauración mensual obligatorio** (misma cadencia que `saas-production-readiness`).

---

## 7. GATE DE MERGE — StampHog Protocol

Bloqueo automático de auto-merge si el diff contiene cualquiera de estas palabras:

```
auth, token, password, secret, credential, stripe, billing, payment,
pii, gdpr, migration, migrate, rls, rbac, permission, role, admin,
webhook, oauth, saml, sso, encryption, decrypt, jwt, session
```

→ Claude no ejecuta el merge: se pide **revisión humana nombrada** y quien asume el riesgo firma en el PR.

---

## 8. PROMPT DE AUDITORÍA COMPLETA (Reutilizable)

```markdown
Revisa TODO el código en busca de vulnerabilidades críticas según SaaS Security Workflow:
1. Rate Limiting en todos los endpoints (429 en abuso). Sensibles: 5-10/h. LLM: 10-30/min.
2. Secretos: cero hardcode, .env en .gitignore, historial git limpio.
3. Inyección: schemas Zod/Pydantic + consultas parametrizadas. Cero concatenación SQL.
4. RLS/IDOR: cero USING(true), toda consulta valida auth.uid()=owner_id.
5. IA/LLM: OWASP LLM Top 10 completo + Hard Cap financiero.
6. MCP: Human-In-The-Loop en acciones destructivas + audit log inmutable.
7. GDPR: DPA, borrado en cascada anonimizado, base legal documentada.
8. Auth B2B: compatibilidad SAML/SCIM desde el diseño.
9. Webhooks: firma criptográfica validada.
10. SSRF: bloqueo de rangos privados/metadata cloud.

Entrega: reporte por archivo, severidad (Alta/Media/Baja), y PARCHE EXACTO por hallazgo.
Bloquea deploy si queda alguna casilla de la Matriz 30-Min en [ ].
```

---

## 9. ENTREGABLE OBLIGATORIO

Al terminar cualquier tarea disparada por esta skill, el output DEBE incluir:

1. **Sección "Security Compliance"** con la Matriz 30-Min rellena (`[x]` / `[ ]` + evidencia).
2. **Lista de hallazgos** por severidad Alta/Media/Baja.
3. **Parche exacto** (diff o snippet) por cada hallazgo Alta/Media.
4. **Bloqueo explícito** ("NO PASA A PRODUCCIÓN") si hay Alta sin resolver.
5. **Referencia a norma** (OWASP, GDPR Art. X, ISO 27001 Anexo A.X, AI Act Art. X).

Si el output no incluye estos 5 puntos, la tarea está incompleta.

---

## 10. MANDAMIENTOS 11-13 (AMPLIACIÓN)

### 11. Identidad Propia por Agente
Ningún agente autónomo opera con credenciales humanas prestadas. Cada agente desplegado tiene credencial propia con alcance mínimo y caducidad corta, registro de auditoría inmutable por acción (`agent_id`, `timestamp`, acción, recurso, usuario representado, resultado) y procedimiento de revocación de un paso, probado. Sin identidad propia no hay trazabilidad, y sin trazabilidad no hay respuesta a incidentes ni cumplimiento NIS2.

### 12. Recuperación con Permisos en Origen (RAG)
En cualquier sistema que recupere fragmentos de documentos, el filtro por `tenant_id` es parte de la consulta al almacén vectorial, no un filtrado posterior en memoria. Filtrar después de recuperar es una fuga consumada: el dato ya salió del almacén. Todo documento se etiqueta con contexto de propiedad en el momento del embedding, y el contenido recuperado se entrega al modelo delimitado y marcado como material no confiable, nunca concatenado al prompt de sistema.

### 13. Verificación de Firma antes de Leer Claims
Ningún token se decodifica para tomar decisiones sin verificar antes su firma con la clave del proveedor, con el algoritmo fijado explícitamente y validando `exp`, `iss` y `aud`. Los permisos sensibles se resuelven contra la base de datos, no contra un claim: un claim puede ir por detrás del estado real tras una revocación.

---

## 11. MATRIZ DE AISLAMIENTO MULTI-TENANT CROSS-CACHÉ

La política RLS de la base de datos no protege lo que está **delante** de ella.

| Capa del sistema | Riesgo de fuga | Directiva de aislamiento innegociable |
| :--- | :--- | :--- |
| **Caché (Redis / LangCache)** | 🔴 Alto | Toda clave con prefijo de tenant: `tenant:${tenant_id}:cache_key` |
| **Búsqueda vectorial** | 🔴 Alto | Filtro determinista por `tenant_id` en metadatos **antes** de la búsqueda de similitud |
| **Storage / Archivos** | 🟡 Medio | Rutas bajo `/tenants/${tenant_id}/files/...` con RLS de bucket en el acceso |
| **WebSockets / Event Bus** | 🟡 Medio | Suscripción con JWT firmado y scoped que verifique pertenencia al tenant |

---

## 12. EU AI ACT — ARTÍCULO 50

Aplica desde el 2 de agosto de 2026 (el Ómnibus digital, Reg. UE 2026/1744, no lo aplazó). Solo el marcado legible por máquina del Art. 50(2) tiene gracia hasta el 2 de diciembre de 2026, y solo para sistemas ya en el mercado antes del 2 de agosto. Sanción de hasta 15M€ o el 3% de la facturación global. Referencias técnicas: directrices de la Comisión (20-07-2026) y Código de buenas prácticas de marcado y etiquetado (10-06-2026). Tres capas en toda aplicación que exponga contenido generativo:

1. **Marcado legible por máquina** del contenido generado o manipulado: metadatos firmados y con sello de tiempo (tipo C2PA) más marca de agua imperceptible, como mínimo, para contenido difundido en línea; etiqueta **visible en la primera exposición** para deepfakes y para texto de interés público sin revisión humana. Los iconos de la UE del Código son opcionales; la etiqueta, no. Quien habla con un sistema de IA debe saber que lo es (Art. 50(1)).
2. **Consent gate de opción afirmativa** (esto es GDPR, no Art. 50). Prohibidas las casillas pre-marcadas antes de que voz, texto, imágenes o datos personales entren al pipeline del LLM.
3. **Log de generación append-only** con `timestamp`, `model_name`, `input_hash`, `output_hash` y `user_session_id`, exportable para auditoría. El Art. 50 no fija retención; se recomiendan 3 años para defensa jurídica, y el alto riesgo exige al menos 6 meses (Art. 19 y 26).
