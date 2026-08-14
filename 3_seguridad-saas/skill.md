# 🛡️ ESCUDO DE SEGURIDAD SAAS & IA: MITIGACIONES OWASP DUAL, SUPABASE RLS & PROTECCIÓN ADVERSARIAL

## `.claude/skills/seguridad-saas/SKILL.md`

Esta guía operativa constituye el estándar obligatorio e innegociable de seguridad para cualquier software, API o integración con Inteligencia Artificial que se despliegue en producción. Su cumplimiento combina las mejores prácticas de seguridad web tradicionales con las directrices de seguridad para modelos generativos de vanguardia de 2026.

---

## SECCIÓN I: MARCO DE REVISIÓN DE SEGURIDAD DUAL (OWASP TOP 10 + OWASP LLM)
Toda auditoría de seguridad del sistema debe evaluar dos capas independientes de vulnerabilidades alineadas con el estándar **NIST SP 800-218A**:

### Capa 1: OWASP Top 10 Web Application Security (La Muralla Tradicional)
1. **Control de Acceso Quebrado (IDOR/RLS):** Prevención de fugas horizontales o verticales de privilegios.
2. **Inyecciones (SQL, XSS, SSRF):** Validación y escape estricto de entradas en la frontera de red.
3. **Fallas de Autenticación:** Cero criptografía casera; delegación absoluta en proveedores consolidados (Supabase Auth, Better Auth, Clerk) validando siempre la firma y expiración del JWT.
4. **Diseño Inseguro:** Falta de modelado de amenazas previo al desarrollo de lógica crítica.
5. **Configuración de Seguridad Incorrecta:** Exposición de stack traces, rutas privadas y cabeceras de seguridad ausentes.

### Capa 2: OWASP Top 10 for LLM and Gen AI Applications (La Muralla Sintética)
1. **LLM01: Prompt Injection (Directa e Indirecta):** Inyección de instrucciones maliciosas a través de inputs del usuario o datos ingestados de terceros.
2. **LLM02: Sensitive Info Disclosure:** Fuga de datos de entrenamiento, prompts de sistema o información confidencial de otros clientes.
3. **LLM06: Excessive Agency:** Concesión de permisos de escritura excesivos o ejecución autónoma destructiva sin confirmación humana.
4. **LLM04: Model Utility/Resource Constraints (DDoS por tokens):** Consumo masivo e incontrolado de tokens o recursos de red por ráfagas maliciosas.

---

## SECCIÓN II: LOS 10 MANDAMIENTOS DE SEGURIDAD SAAS (APLICACIÓN PRÁCTICA)

### 1. IDOR (Insecure Direct Object References) — [LUPIN-RULE-001-IDOR]
*   **Regla de Oro:** Nunca confíes en parámetros de identificación (`user_id`, `tenant_id`, `resource_id`) enviados en el cuerpo del request o query strings desde el navegador. El ID del usuario y el ID de su organización se extraen **siempre** del token de sesión verificado en el servidor.
*   *Mal:* `DELETE /api/reservations?id=456&user_id=123`
*   *Bien:* `DELETE /api/reservations/456` (El controlador extrae la sesión y ejecuta `WHERE id = 456 AND tenant_id = session.tenant_id`).

### 2. Supabase RLS sin "USING (true)" — [LUPIN-RULE-002-RLS]
*   **Regla de Oro:** Una política Row-Level Security definida como `CREATE POLICY ... USING (true);` expone de forma completamente pública la tabla a DevTools. Toda política de base de datos debe validar explícitamente la correspondencia del usuario autenticado:
    ```sql
    ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
    CREATE POLICY user_access_policy ON projects 
    FOR ALL TO authenticated 
    USING (auth.uid() = user_id);
    ```
*   **Vistas Seguras en Postgres:** Al crear vistas (`views`), incluye siempre `WITH (security_invoker = true)` para forzar a la vista a respetar las políticas RLS de las tablas base, en lugar de evadirlas.

### 3. Cero Lógica de Negocio ni Validación de Precios en el Cliente — [LUPIN-RULE-003-AUTH]
*   **Regla de Oro:** El frontend es un entorno hostil manipulable por el usuario. Decisiones de precios, planes de suscripción, roles de administración y permisos de acceso deben ser computados, verificados y sellados exclusivamente en el servidor o a través de políticas RLS de base de datos. Ocultar un botón en React no protege la funcionalidad de peticiones directas.

### 4. Rate Limiting + Hard Cap Financiero en IA — [LUPIN-RULE-004-FIN]
*   **Regla de Oro:** Todo endpoint que llame a APIs de LLMs debe tener implementado un rate limit por IP y por usuario autenticado. Se devolverá un código HTTP `429 Too Many Requests` auditable cuando se superen los límites, protegiendo al negocio de un DDoS financiero.

### 5. Cero Criptografía Casera
*   **Regla de Oro:** Está terminantemente prohibido escribir parsers de JWT o algoritmos de hashing propios. Se utilizará infraestructura oficial y probada, verificando de forma explícita la firma criptográfica y la expiración (`exp`) del token en cada llamada.

### 6. Auditar la Lógica de RLS Activamente
*   **Regla de Oro:** No asumas que porque la consola muestra "RLS Enabled" la tabla está segura. Se deben escribir pruebas automatizadas adversarial que intenten acceder de forma anónima o con un token de inquilino ajeno para certificar la estanqueidad.

### 7. Buckets de Almacenamiento sin Listado Público (LIST)
*   **Regla de Oro:** Desactivar por completo el permiso de enumeración pública en buckets S3/Supabase Storage. Si un usuario autorizado solicita acceder a un documento o imagen privada, el backend generará una **URL Firmada Temporal (Signed URL)** con una ventana de caducidad estricta de 60 segundos.

### 8. Endpoints Costosos Siempre Autenticados
*   **Regla de Oro:** Cualquier endpoint que interactúe con proveedores de APIs externas costosas, ejecute modelos de IA o procese análisis pesados debe estar protegido detrás de un middleware de autenticación de sesión rígido.

### 9. SSRF (Server-Side Request Forgery) — [LUPIN-RULE-009-SSRF]
*   **Regla de Oro:** Si tu aplicación permite al usuario introducir una URL externa para scraping de competencia, importación de datos o webhooks, el servidor debe interceptar la solicitud y bloquear de forma activa conexiones a rangos de IP privados, locales o metadatos de la nube:
    *   `127.0.0.1` (Localhost)
    *   `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` (Redes Privadas)
    *   `169.254.169.254` (IP de Metadatos de AWS/GCP)

### 10. Prompt Injection y Secuestro de Herramientas
*   **Regla de Oro:** Todo input externo (reseñas de huéspedes, mensajes de WhatsApp, correos ingestados, webhooks de terceros) es considerado **no confiable** y potencialmente hostil. Los agentes autónomos encargados de leer estos inputs operarán exclusivamente en modo de **solo lectura** y bajo el principio de mínimo privilegio.

---

## SECCIÓN III: MATRIZ DE AISLAMIENTO MULTI-TENANT CROSS-CACHÉ
Cuando se comparte infraestructura entre múltiples inquilinos (*tenants*), la política RLS de base de datos no te protege si la capa de caché se sitúa delante:

| Capa del Sistema | Riesgo de Fuga | Directiva de Aislamiento Innegociable |
| :--- | :--- | :--- |
| **Caché (Redis / LangCache)** | 🔴 Alto | Toda clave almacenada en Redis debe estructurarse obligatoriamente con el prefijo del tenant: `tenant:${tenant_id}:cache_key` para evitar colisiones cruzadas. |
| **Búsqueda Vectorial (Vector DB)** | 🔴 Alto | Forzar filtros deterministas por `tenant_id` en los metadatos de la consulta vectorial **antes** de ejecutar la búsqueda de similitud. |
| **Storage / Archivos** | 🟡 Medio | Rutas estructuradas estrictamente bajo el directorio `/tenants/${tenant_id}/files/...` con validación RLS de Supabase Storage en el acceso al bucket. |
| **WebSockets / Event Bus** | 🟡 Medio | Toda suscripción a canales de mensajería en tiempo real debe requerir un token JWT firmado y scoped que verifique la pertenencia al tenant. |

---

## SECCIÓN IV: CUMPLIMIENTO REGULATORIO ARTÍCULO 50 EU AI ACT

En vigor desde el **2 de agosto de 2026** (con marcas legibles por máquina obligatorias a partir del **2 de diciembre de 2026**), el incumplimiento del **Artículo 50 del EU AI Act** acarrea multas de hasta **15M€ o el 3% de la facturación global**. Las aplicaciones que expongan contenido generativo deben implementar tres capas técnicas:

1. **Disclosure Sintético Visible y No Removible:** Todo contenido, imagen, recomendación o texto generado por IA que interactúe con un usuario final debe mostrar explícitamente un aviso indicando que ha sido redactado sintéticamente. Se utilizará el set oficial de iconos estandarizados de la Unión Europea.
2. **Consent Gates de Opción Afirmativa:** Verificación obligatoria de que el usuario acepta de forma consciente (opt-in) que sus datos personales, voz, imágenes o textos entren al pipeline del LLM para procesamiento. Queda **estrictamente prohibido** el uso de casillas pre-seleccionadas (*pre-checked boxes*).
3. **Logs de Generación Inmutables (Retención 3 años):** Almacenar en una base de datos *append-only* un registro con los campos: `timestamp`, `model_name`, `input_hash`, `output_hash` y `user_session_id`. Exportable para auditoría regulatoria en formato estandarizado.

---

## SECCIÓN V: PROTOCOLO DE REVISIÓN ADVERSARIAL STAMPHOG (CARRIL ROJO)

Para evitar la fusión autónoma de código crítico por parte de agentes, se establece el **Protocolo StampHog**:
*   **Detección de Palabras Clave Sensibles:** El revisor automático escaneará el diff de cada Pull Request en búsqueda de las palabras clave del Carril Rojo: `auth`, `token`, `password`, `stripe`, `billing`, `pii`, `migration`, `rls`, `rbac`.
*   **Bloqueo y Escalado Obligatorio:** Si la Pull Request contiene cualquiera de estos términos, se bloquea de manera inmediata la funcionalidad de auto-merge del agente. El PR se asigna de forma obligatoria a un revisor humano sénior y un ingeniero de seguridad para modelado de amenazas y verificación línea a línea. No hay omisiones por conveniencia.