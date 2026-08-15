---
name: definition-of-done
description: >
  The 14-point universal Definition of Done that decides whether a module may
  merge: public contract, published test double, context.md, 80% domain
  coverage, failure-path tests, cross-tenant isolation test in CI, no secrets or
  PII in logs, structured JSON logs, cost instrumentation, staging behind a
  feature flag, traceability row closed. Adds stricter gates for Red Lane, UI,
  generative-AI and webhook modules. Use before marking anything done, before
  opening or merging a PR, or when the user asks "is this finished?", "esta
  terminado?", "definition of done", "DoD", or what the quality gate requires.
  Skill content is in Spanish.
---
# 🚪 LA PUERTA DE CALIDAD: DEFINITION OF DONE UNIVERSAL Y REQUISITOS ADICIONALES POR MÓDULO

Este documento rige la transición de estado de cualquier módulo en desarrollo. Establece criterios objetivos y deterministas para evitar que "terminado" sea un concepto subjetivo, eliminando la deuda técnica invisible en producción.

---

## SECCIÓN I: FILOSOFÍA DEL FLUJO ATÓMICO Y LOS TRES ESTADOS

### La Regla de Oro del Ritmo de Ingeniería:
> **Se cierra un módulo o se abre el siguiente. Nunca las dos cosas a la vez.**
> Como máximo, el equipo o agente puede mantener **un único módulo en estado "En Curso"** por carril de trabajo. Está estrictamente prohibido dejar tareas al 90% para abrir nuevos frentes; el 10% restante de un módulo abandonado cuesta un 40% más de esfuerzo reconstruir por pérdida de contexto.

### Matriz de Estados de un Módulo:
*   **PENDIENTE:** No se ha iniciado el desarrollo. Puede contener notas de arquitectura o de diseño preliminar.
*   **EN CURSO:** El módulo está activamente en construcción. Si un desarrollo lleva más de **dos semanas** en este estado, es un indicador de alarma en el alcance. El módulo se divide inmediatamente en dos piezas independientes.
*   **TERMINADO:** El módulo satisface el 100% de los 14 puntos del Definition of Done (DoD) Universal, se encuentra desplegado en staging y su fila correspondiente en la matriz de trazabilidad está cerrada con un enlace al Pull Request y a las pruebas de éxito.

---

## SECCIÓN II: CHECKLIST DEL DEFINITION OF DONE UNIVERSAL (14 PUNTOS)

Toda tarea o funcionalidad debe marcar conscientemente cada una de estas comprobaciones antes de solicitar su fusión a ramas protegidas:

### Contrato y Diseño
1.  [ ] **Contrato Público Explícito:** Existe un archivo central `index.ts` que exporta estrictamente los tipos, clases o funciones públicas que otros módulos pueden usar. El resto del código interno del módulo permanece inaccesible.
2.  [ ] **Doble Publicado del Módulo:** Se provee un mock, stub o servidor falso configurado para que los consumidores del módulo puedan programar y probar sus integraciones sin depender de la lógica real.
3.  [ ] **Documento de Contexto (`context.md`):** Explicación clara de qué hace el módulo, qué modelos de datos posee, qué eventos emite o consume, las decisiones técnicas tomadas y las alternativas que fueron descartadas.

### Corrección y Calidad de Pruebas
4.  [ ] **Tests Unitarios de Dominio (Cobertura ≥ 80%):** Pruebas automáticas exhaustivas sobre la lógica del negocio, excluyendo getters, setters o dependencias de frameworks.
5.  [ ] **Tests de Rutas de Fallo:** Validación sistemática de caminos alternativos y escenarios hostiles, incluyendo: entradas malformadas, llamadas con timeouts, dependencias caídas, valores nulos y condiciones de concurrencia extrema.
6.  [ ] **Tests de Contrato:** Verificación de que el módulo implementa y cumple fielmente la interfaz prometida y que emite los eventos tipados correctos para sus consumidores.
7.  [ ] **Ejecución en Scratch DBs:** Todas las pruebas automatizadas corren de manera aislada contra bases de datos efímeras sembradas en el instante, jamás contra la base de datos de desarrollo compartida ni staging.

### Seguridad y Aislamiento
8.  [ ] **Test de Aislamiento Cross-Tenant:** Si el módulo lee o escribe en base de datos, colas, caché, storage o canales en tiempo real, existe un test específico en CI que intenta acceder a datos de otro inquilino y falla explícitamente.
9.  [ ] **Autorización Validada en Servidor:** Cada punto de entrada extrae las credenciales del inquilino y usuario (`tenantId`, `userId`) exclusivamente de la sesión segura del servidor, impidiendo IDORs basados en inputs del cliente.
10. [ ] **Cero Secretos y PII en Logs:** Verificación activa por Gitleaks de que no se suben variables de entorno o credenciales, y sanitización de registros para omitir información sensible de clientes o stack traces en respuestas HTTP públicas.

### Operación e Infraestructura
11. [ ] **Observabilidad Estructurada Conectada:** El módulo escribe logs structured en JSON con etiquetas de `tenantId` y `correlationId`, e integra captura de excepciones no controladas mediante Sentry.
12. [ ] **Coste Instrumentado:** Si el módulo realiza consultas a LLMs, procesamiento pesado o llamadas a APIs pagadas, calcula su coste de ejecución promedio. Si no se puede responder "cuánto cuesta invocar esto", no se considera terminado.
13. [ ] **Despliegue en Staging Detrás de Feature Flag:** Código integrado en el entorno de pre-producción y oculto bajo una bandera de características para pruebas controladas en la nube.
14. [ ] **Fila Cerrada en Matriz de Trazabilidad:** Actualización inmediata de la línea de trazabilidad con el enlace directo al Pull Request de GitHub, la fecha y los tests correspondientes.

---

## SECCIÓN III: REQUISITOS ADICIONALES POR TIPO DE MÓDULO

### Módulos del Carril Rojo 🔴 (Auth, Pagos, PII, Migraciones)
*   [ ] **Revisión Humana Línea a Línea:** Auditoría visual profunda y firmada en el PR explicando técnicamente qué puntos se validaron.
*   [ ] **Modelo de Amenazas Escrito:** Identificación de posibles atacantes, vectores de explotación del módulo y mitigaciones técnicas activas que lo impiden.
*   [ ] **Test Adversarial Obligatorio:** Un test que intenta activamente violar las garantías del módulo (provocar doble cobro, saltar el RLS o el guardrail).
*   [ ] **IA solo Redactora de Borrador:** Todo código del carril rojo generado sintéticamente debe ser validado e implementado bajo firma humana consciente.

### Módulos con Interfaz de Usuario (UI)
*   [ ] **Recorrido Completo con Teclado:** Operación sin ratón utilizando `Tab`, `Enter` y `Esc`, visualizando un anillo de foco claro en todo control interactivo y eliminando trampas de foco (*focus traps*).
*   [ ] **Contraste WCAG 2.2 AA:** Mínimo de 4.5:1 para texto normal y 3:1 para texto grande.
*   [ ] **Etiquetas de Accesibilidad Completas:** Presencia de atributos `alt` descriptivos, `aria-label` en controles interactivos sin texto y etiquetas `<label>` para formularios.
*   [ ] **Adaptabilidad Responsive a 360px:** Verificado en Chrome DevTools a un ancho de pantalla móvil base para garantizar cero desbordamientos horizontales.
*   [ ] **Estados de UI Explícitos:** Diseño e implementación de interfaces específicas para estados de carga (*loading*), vacío (*empty slate*) y error técnico. Una pantalla en blanco no es un estado de carga.
*   [ ] **Cero Cadenas de Texto Hardcodeadas:** Todo texto visible pasa por un middleware de internacionalización (i18n) en idiomas ES y EN de manera nativa.

### Módulos de Ingesta de Datos (APIs / Webhooks)
*   [ ] **Prueba contra Respuestas Grabadas de APIs Reales:** Doble de pruebas que simula respuestas verídicas, no inferidas.
*   [ ] **Degradación Elegante:** Verificación automática de que si la API del tercero cae, el sistema continúa operando con datos cacheados y muestra una advertencia visual al usuario.
*   [ ] **Idempotencia:** Garantizar que re-procesar o re-enviar el mismo lote de datos no genera registros duplicados en el sistema.

### Módulos con IA Generativa (Agentes / LLMs)
*   [ ] **Aviso de IA Visible y Obligatorio:** Divulgación sintética explícita en cada interfaz o respuesta generada para el usuario.
*   [ ] **Consent Gate Afirmativo:** Validación activa de que el usuario optó explícitamente por enviar sus datos personales al modelo.
*   [ ] **Test de Inyección de Prompt Indirecta:** Simular la ingesta de reseñas o datos que contienen instrucciones maliciosas ocultas (ej. *"DROP TABLE..."*) y certificar que el agente ignora la orden y no rompe su flujo normal.
