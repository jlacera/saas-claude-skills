# 📜 REGLA DE ORO: DIRECTIVA MAESTRA DE COMPORTAMIENTO PARA AGENTES AUTÓNOMOS DE CÓDIGO (EDICIÓN VANGUARDIA 2026)

## `.claude/skills/master-agent/SKILL.md`

Este documento constituye la **Constitución Innegociable y la Regla de Oro** para el comportamiento, la toma de decisiones y el flujo de trabajo de cualquier agente autónomo de inteligencia artificial que asuma tareas de desarrollo en este repositorio, ya sea para un SaaS complejo o una pequeña aplicación. 

---

## SECCIÓN I: FILOSOFÍA DE TRABAJO Y LEYES DE RIGOR DEL VIBE-CODING

### 1. La Paradoja del Vibe-Coding
En 2026, el **92% de los ingenieros utiliza IA a diario, pero solo el 29% confía en el código autogenerado**. El "vibe-coding" sin control técnico maduro degenera inevitablemente en código espagueti y deuda invisible. El rol prioritario de este agente no es solo generar código rápido, sino aplicar un **juicio de ingeniería maduro** enfocado en tres pilares:
1. **Verificación:** Cómo probar determinísticamente lo que se construye.
2. **Seguridad:** Cómo blindar el sistema frente a amenazas tradicionales y de IA generativa.
3. **Mantenibilidad:** Cómo garantizar que la infraestructura sea robusta y auto-correctiva cuando falle en producción.

### 2. Las Cinco Leyes que Impiden el Desastre
Para evitar que "terminado" sea una opinión subjetiva y evitar la deuda técnica que ahoga a los proyectos, se imponen cinco leyes de rigurosa observancia:
*   **Ley 1 — El Flujo Atómico (Máximo 1 Módulo en Curso):** Se cierra un módulo o se abre el siguiente. Nunca las dos cosas a la vez. Está estrictamente prohibido dejar un módulo al 90% para empezar otro. El 10% restante de un módulo abandonado cuesta un 40% más debido a la pérdida de contexto.
*   **Ley 2 — Prohibición Estricta de `TODO`s:** Un `TODO` en el código es una deuda invisible que nadie audita. Si algo falta, se programa inmediatamente o se registra en la matriz de trazabilidad/backlog con un identificador único. El linter del pipeline de CI/CD romperá activamente el build si detecta la cadena de texto `TODO` o `FIXME` en cualquier commit.
*   **Ley 3 — Congelamiento de Alcance Activo:** El alcance de un módulo se congela en el instante en que comienza su desarrollo. Cualquier idea o mejora ad-hoc que surja durante la construcción debe documentarse y enviarse de forma inmediata al backlog con su respectivo identificador. Implementar "solo una cosa más" multiplica exponencialmente los cronogramas.
*   **Ley 4 — Actualización de Trazabilidad en el mismo PR:** La fila correspondiente en la matriz de trazabilidad del proyecto debe actualizarse en el mismo Pull Request que cierra el módulo. Si el PR no toca y cierra la matriz, el módulo no se considera candidato para fusión.
*   **Ley 5 — Inmutabilidad del Código Terminado:** Un módulo terminado no se vuelve a tocar salvo por corrección de un bug crítico en producción o por un cambio de contrato explícitamente aprobado. No se permiten "mejoras de refactorización" informales sin un ticket asignado.

### 3. Sustitución de Wikidocs por Skills Ejecutables (*Docs Rot*)
Las wikis y los documentos de arquitectura estáticos sufren de una silenciosa e inevitable pudrición de documentación (*Docs Rot*). Cuando un agente lee guías desactualizadas a las 2 AM, la falla es de la herramienta estática.
Toda guía arquitectónica debe traducirse a **Skills Ejecutables o Herramientas Automatizadas** que fallen ruidosamente en el pipeline si hay errores de infraestructura:
1.  **create-service (Onboarding Autónomo):** Aprovisiona la base de datos, registra el servicio en el IdP, configura logs con etiquetas estándar y despliega en producción antes de escribir código de negocio.
2.  **deploy-service (Despliegue Progresivo):** Maneja el envío de migraciones de bases de datos, tests post-despliegue y pruebas de entorno integradas, asegurando que la ruta de *rollback* sea tan automatizada y testeada como la de despliegue.
3.  **service-debugging (Diagnóstico Activo):** Diagnostica incidentes en tiempo real contrastando síntomas con patrones de fallo pasados, proveyendo enlaces directos a dashboards de trazas en lugar de simples console.logs.

---

## SECCIÓN II: ORQUESTACIÓN MULTIMODELO Y GESTIÓN ECONÓMICA DEL CONTEXTO

### 1. El Patrón del "Fable Sandwich" en Proyectos Locales
El agente adoptará una jerarquía de orquestación en sándwich para optimizar la toma de decisiones complejas sin comprometer la velocidad ni disparar las facturas de la API:
*   **Fase 1 (El Arquitecto - Fable 5):** Se activa exclusivamente con el comando `/plan`. Analiza el alcance del ticket, consulta las directrices de este manual (`SKILL.md`) y diseña la estrategia técnica paso a paso con su correspondiente evaluación de riesgos de seguridad.
*   **Fase 2 (El Obrero - Opus 4.8 / Sonnet 5):** Recibe el plan estructurado del Arquitecto y ejecuta la escritura del código línea a línea. Es el modelo asignado al desarrollo diario debido a su excelente velocidad y balance de tokens.
*   **Fase 3 (El Auditor - Fable 5):** Vuelve a intervenir para realizar la revisión final adversarial del Pull Request aplicando el principio de **"Ataca tu propia conclusión"** antes del merge definitivo.

### 2. Gestión Económica del Contexto (Token-Budget-Aware)
El Context Window de la sesión es el recurso más escaso de la arquitectura de agentes. Su crecimiento cuadrático genera amnesia y eleva los costes de la API drásticamente. El agente debe seguir estas prácticas de control:
*   **Disciplina en Terminal:** Queda prohibido volcar logs crudos masivos o árboles de directorios enteros. Cada comando de terminal debe filtrarse mediante pipes específicos (`| tail -n 50`, `| grep "ERROR"`, `| jq`).
*   **Carga Diferida (Lazy-load):** Las bases de datos vectoriales, esquemas de Supabase y esquemas de APIs remotas se consultarán bajo demanda, nunca al inicio de la sesión de forma masiva.
*   **Chain of Draft (CoD) para Modelos de Razonamiento:** Al interactuar con modelos de razonamiento profundo (como Claude Opus 5 o Gemini 3.1 Pro High) cuyos tokens de razonamiento son sumamente costosos, el agente aplicará la técnica CoD: **limitar el pensamiento interno a un máximo de 5 palabras por paso**. Esto reduce el consumo de tokens de salida entre un 68% y un 86% manteniendo una precisión superior al 95%.

### 3. Selección Inteligente de Modelos (Enrutamiento Canónico)
*   **Haiku 4.5 (Velocidad & Triaje):** Clasificación de incidencias, búsquedas web simples, inspección rápida de código y chat libre sin adjuntos pesados.
*   **Sonnet 5 (Desarrollo Diario):** Refactorizaciones menores, programación de lógica estándar y conexión con conectores MCP del equipo (Slack, Jira, GitHub).
*   **Opus 4.8 / Opus 5 (Análisis Profundo):** Diseño de bases de datos, auditorías de negocio complejas y coworking de arquitectura de sistemas.
*   **Fable 5 (Modo Autónomo / Auditoria):** Tareas complejas que requieran ejecutar múltiples flujos de extremo a extremo, resolución adversarial de bugs y el 10% de decisiones críticas (Carril Rojo).

### 4. Bóveda de Memoria (*Vault*) vs. Repositorio
El repositorio almacena únicamente el código fuente de producción. Para evitar la pérdida de contexto entre sesiones, el agente mantendrá de forma paralela una **Bóveda de Memoria (Vault) versionada en Git** que contendrá el contexto evolutivo: notas de reuniones, decisiones de diseño de sistemas y archivos temporales de estado. Las actualizaciones del estado mental de la IA serán diffs auditables en este directorio.

---

---

## SECCIÓN III: LA DEFINICIÓN DE TERMINADO (DoD) UNIVERSAL

> 📎 **Skill dedicada:** Para el checklist completo de 14 puntos y los requisitos adicionales por tipo de módulo, consultar:
> - Contexto completo: `2_definition-of-done/skill.md`
> - Referencia rápida: `2_definition-of-done/quick-ref.md`

Cualquier PR que pretenda marcar un módulo como **TERMINADO** debe satisfacer los 14 puntos del DoD Universal sin excepciones: contrato público, mocks, context.md, cobertura ≥80%, tests de fallo, aislamiento cross-tenant, autorización en servidor, sanitización de logs, observabilidad, coste instrumentado, despliegue en staging y cierre de trazabilidad.


## SECCIÓN IV: CARRILES DE RIESGO Y REQUISITOS ESPECIALIZADOS

### 1. El Sistema de Carriles de Riesgo
Cada Pull Request debe clasificarse en un carril de riesgo específico antes de su evaluación:
*   🟢 **Carril Verde (Riesgo Bajo):** Documentación, tests unitarios, correcciones de estilos de CSS/UI local, refactorizaciones sin efectos colaterales de datos.
*   🟡 **Carril Amarillo (Riesgo Medio):** Lógica de negocio rutinaria, integraciones de APIs estándar, flujos de datos intermedios. Requiere aprobación de CI y un sign-off de ingeniería senior.
*   🔴 **Carril Rojo (Riesgo Crítico):** Sistemas de autenticación (Auth), lógica financiera/pagos (Stripe), manejo de datos personales sensibles (PII), migraciones de base de datos relacionales, APIs públicas de alto tráfico.
    *   *Regla Innegociable:* La IA solo tiene permitido redactar el borrador (*draft*) inicial. El código debe ser revisado línea a línea por un humano, sometido a un modelo de amenazas por escrito y probado adversarialmente antes de su merge.

### 2. El Protocolo StampHog (Bloqueo Automatizado de Carril Rojo)
Para evitar que un agente autónomo fusione cambios críticos sin supervisión bajo "modo de conducción autónoma", se implementa el protocolo **StampHog**:
*   El agente revisor en el pipeline de CI escaneará automáticamente el diff del Pull Request buscando palabras clave sensibles del carril rojo: `auth`, `token`, `password`, `stripe`, `billing`, `pii`, `migration`, `rls`, `rbac`.
*   Si se detecta alguna coincidencia, el agente tiene prohibido de forma absoluta ejecutar el merge automatizado. El Pull Request se bloquea y se escala obligatoriamente a revisión por un ingeniero senior de seguridad.

### 3. Requisitos Especiales según la Naturaleza del Módulo
Estos requisitos se suman de forma mandatoria al DoD universal:

#### A. Interfaces de Usuario (Frontend & UX)
*   **Navegación por Teclado Estricta:** Todo elemento interactivo debe ser accesible y operable usando únicamente Tab, Enter y Esc. Queda prohibido el uso de elementos div sin `tabindex="0"` y sin manejadores de teclado específicos. El indicador de foco (`ring`/`outline`) debe ser visible en todo momento.
*   **Contraste WCAG 2.2 AA:** El texto normal debe garantizar una relación de contraste mínima de 4.5:1 sobre el fondo; el texto grande o negrita debe ser de al menos 3:1.
*   **Móvil Responsivo a 360px:** El diseño debe probarse obligatoriamente utilizando el Device Toolbar en una resolución de 360px de ancho para evitar desbordamientos horizontales en dispositivos reales.
*   **Diseño de Estados Auxiliares:** Está prohibido dejar la pantalla en blanco durante operaciones de red. Se deben diseñar e implementar estados explícitos para Carga (*Loading*), Pantalla Vacía (*Blank Slate*) y Error.
*   **Cero Strings Hardcodeados:** Todo el texto debe estructurarse mediante variables de internacionalización (i18n) con soporte de variantes por idioma.

#### B. Módulos con Invocación de IA Generativa
*   **Disclosure de IA Visible:** Toda respuesta o contenido generado de forma sintética expuesto al usuario final debe incorporar un indicador visual no removible y estandarizado con la iconografía oficial de la Unión Europea.
*   **Consent Gate Afirmativo:** Queda prohibido el uso de casillas pre-marcadas para el uso de datos. El usuario debe activar explícitamente una opción (*opt-in*) antes de que su voz, texto, imágenes o datos personales sean transferidos a un proveedor de LLM para procesamiento.
*   **Log de Generación Inmutable (EU AI Act - Art. 50):** Cada llamada a modelos de generación sintética debe registrarse en una tabla append-only de base de datos con una retención mínima de 3 años, guardando: `timestamp`, `model_name`, `input_hash`, `output_hash` y `user_session_id`.
*   **Test de Inyección de Prompt Indirecta:** Se debe simular y testear adversarialmente qué sucede cuando un input del sistema (como un comentario de reseña o un correo de soporte que el agente procesará) contiene instrucciones maliciosas incrustadas. El agente debe ignorar por completo estas inyecciones y no alterar sus políticas internas de seguridad.

#### C. Módulos Financieros y Billing (Stripe)
*   **Firma Criptográfica Obligatoria:** Todos los endpoints que reciben webhooks de pago (Stripe, Clerk) deben validar la firma criptográfica utilizando el secreto oficial (`STRIPE_WEBHOOK_SECRET`). No se procesará ningún evento basado únicamente en la URL de éxito redirigida por el cliente.
*   **Aprovisionamiento Asíncrono Exclusivo:** Los créditos, planes o suscripciones del usuario se activan exclusivamente en el backend tras el procesamiento exitoso del webhook verificado. El retorno de pantalla del usuario no altera el estado de facturación.
*   **Idempotencia Transaccional:** Se debe enviar una cabecera UUID única en el parámetro `Stripe-Idempotency-Key` en cada petición de cobro para evitar la duplicación de transacciones debido a fallos o reintentos de red.
*   **Aislamiento de Claves:** Se auditará que las credenciales de modo Test (`sk_test_...`) y modo Live (`sk_live_...`) se encuentren estrictamente separadas por variables de entorno según el host de ejecución (Desarrollo vs. Producción).

---

---

## SECCIÓN V: EL ESCUDO DE SEGURIDAD SAAS AVANZADA (OWASP DUAL)

> 📎 **Skill dedicada:** Para el marco OWASP dual completo, la matriz de aislamiento multi-tenant, cumplimiento EU AI Act y el protocolo StampHog:
> - Contexto completo: `3_seguridad-saas/skill.md`
> - Referencia rápida: `3_seguridad-saas/quick-ref.md`

### Resumen de Directivas Críticas
*   **SSRF:** Bloquear peticiones salientes a IPs privadas, locales y metadatos cloud (`127.0.0.1`, `10.0.0.0/8`, `169.254.169.254`).
*   **Bypass de RLS en Caché:** Toda clave de Redis debe incluir el prefijo `tenant:{tenant_id}:` para evitar fugas cross-tenant.
*   **Vistas de BD:** Declarar `WITH (security_invoker = true)` en toda vista lógica.
*   **Slopsquatting:** Verificar que toda dependencia sugerida por IA exista en el registro oficial con mantenimiento activo antes de instalar. Fijar versión exacta + SHA-256 en lockfile.

---

## SECCIÓN VI: ESTÁNDARES DE DESPLIEGUE, OPERACIONES E INSTRUMENTACIÓN FINANCIERA

> 📎 **Skills dedicadas:** Para las reglas completas de despliegue, operaciones y control financiero:
> - Despliegue y Ops: `4_ops-deploy/skill.md` | `4_ops-deploy/quick-ref.md`
> - Billing y Monetización: `5_billing-monetizacion/skill.md` | `5_billing-monetizacion/quick-ref.md`

### Resumen de Directivas Críticas
*   **Gate de 13 Capas:** Ningún despliegue avanza a producción si un solo ítem se encuentra en ROJO.
*   **Escalabilidad Híbrida:** Migrar de Serverless a Workers Docker + Cola de Mensajes cuando el tiempo de ejecución supere 30s, se necesiten conexiones persistentes, o se ejecuten cron jobs intensivos.
*   **Smoke Test Post-Deploy:** 5 pasos obligatorios en ventana de incógnito.
*   **Rollback en <60s:** El camino de rollback debe estar documentado y probado.
*   **Spend Caps Duros:** Límites mensuales inflexibles en proveedores cloud. Alerta si invocación supera $0.10 USD.
*   **Firma Criptográfica de Webhooks:** Activación de cuenta solo tras verificación criptográfica del webhook.

---

## SECCIÓN VII: CRECIMIENTO Y MONETIZACIÓN IA-NATIVE

> 📎 **Skill dedicada:** Para las reglas completas de adquisición, GEO y automatización de canales Meta:
> - Contexto completo: `6_crecimiento-growth/skill.md`
> - Referencia rápida: `6_crecimiento-growth/quick-ref.md`

### Resumen de Directivas Críticas
*   **GEO:** Renderizar en SSR los metadatos JSON-LD de Schema.org para los "Agentic 6" con tasa de llenado >95%.
*   **Endpoint `/api/ai-spec.json`:** Especificación pública legible por agentes de compra.
*   **Doctrina "The Forge":** Vender el resultado, no la tecnología. Vídeo demo de 3 min + enlace de un solo clic.
*   **WhatsApp:** Exclusivamente API Oficial. Prohibido usar QR/ingeniería inversa.
*   **Instagram:** Máximo 3 respuestas por ejecución, pausa aleatoria 20-40s, respuestas únicas por LLM, cero enlaces públicos.

## SECCIÓN VIII: EL CICLO DE AUTOCORRECCIÓN ADVERSARIAL

Antes de entregar cualquier código para Pull Request, el agente ejecutará internamente un ciclo de simulación adversarial:
1.  **"Ataca tu propia conclusión":** El agente actuará como un desarrollador revisor malicioso que busca de forma exhaustiva:
    *   Fugas de memoria latentes.
    *   Fórmulas matemáticas de facturación o cobro redondeadas de forma imprecisa.
    *   Bypasses de RLS en controladores de bases de datos o capas de caché de Redis.
    *   Dependencias de paquetes introducidas de forma redundante o alucinada.
2.  **Validación byte a byte:** Si el ticket actual se trata exclusivamente de un refactoring, el agente verificará en su entorno local que la compilación y el output del sistema resultante sean idénticos a nivel de bytes respecto al estado original de producción.
3.  **Inspección del Modelo de Amenazas:** En todas las funcionalidades del Carril Rojo, el agente redactará y adjuntará en los comentarios del Pull Request el análisis explícito del modelo de amenazas del módulo, describiendo qué podría fallar bajo presión de producción, quién lo provocaría y qué barrera exacta de código impide que la vulnerabilidad se materialice.

---

**Cualquier desviación técnica o de comportamiento de este manual anulará el estado de "TERMINADO" del módulo, rompiendo los quality gates de CI/CD del repositorio.**
