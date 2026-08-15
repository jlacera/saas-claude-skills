---
name: ops-deploy
description: >
  Production readiness and operations: the 13-layer deploy gate scored
  green/yellow/red across frontend, APIs, database, auth, hosting, cloud, CI/CD,
  security, rate limiting, caching, load balancing, error tracking and backups;
  the hybrid serverless-to-container migration pattern with message queues; the
  mandatory five-step post-deploy smoke test; and the incident runbook (contain,
  rebuild, communicate, prevent). Use before any deploy or infrastructure
  change, while handling a production incident, or when the user asks about
  despliegue, deploy, produccion, runbook, smoke test or scaling workers. Skill
  content is in Spanish.
---
# ⚙️ OPERACIONES INDUSTRIALES & DESPLIEGUE CONTINUO: EL GATE DE 13 CAPAS Y ESCALABILIDAD HÍBRIDA

Esta guía operativa detalla los procedimientos innegociables para el paso de aplicaciones a producción, la mitigación de fallos de infraestructura a gran escala y la arquitectura para procesar cargas de trabajo masivas sin comprometer la estabilidad del sistema.

---

## SECCIÓN I: EL GATE DE LAS 13 CAPAS DE PREPARACIÓN PARA PRODUCCIÓN

Ningún despliegue se fusionará a producción si tiene un solo criterio calificado en **ROJO** (sin abordar). Las capas se evalúan como Green (Listo), Yellow (Operativo con limitaciones) o Red (Riesgo crítico):

1.  **Frontend:** Manejo nativo de estados de carga, páginas de error completas, reintentos de red automáticos y maquetado responsive validado a 360px de ancho móvil.
2.  **APIs:** Contratos de datos tipados y validación rígida mediante esquemas (Zod/Valibot) en la frontera de red, timeouts explícitos y sanitización de salidas.
3.  **Database:** Creación de índices en columnas de búsqueda frecuente, interposición de un Connection Pooler (PgBouncer en puerto 6543) configurado en modo **Transaction Pooling** para evitar agotar las conexiones máximas (*max_connections*), y migraciones de base de datos estrictamente append-only.
4.  **Auth:** Manejo seguro de tokens mediante cookies de servidor `HttpOnly`, expiración estricta de JWTs, rotación de tokens de refresco y flujos de revocación de sesiones remotas.
5.  **Hosting:** Certificados SSL/TLS auto-renovables y aislamiento físico estricto de variables de entorno entre Staging y Producción.
6.  **Cloud Infrastructure:** Aplicación estricta del Principio de Menor Privilegio en credenciales IAM y presupuestos de nube configurados con alertas de gasto duras.
7.  **CI/CD:** Pipelines automáticos que bloquean el merge si falla el tipado, linter o tests locales, y un camino de rollback automatizado en menos de 60 segundos.
8.  **Seguridad Exterior:** CORS restrictivo en el servidor, cabeceras CSP, mitigaciones anti-XSS y escaneo continuo de vulnerabilidades en dependencias.
9.  **Rate Limiting:** Límites estrictos por IP y usuario en autenticación, endpoints de pago y consultas de LLMs para prevenir abusos financieros.
10. **Caching:** Namespacing estricto con el prefijo del tenant (`tenant:${tenant_id}:cache_key`) en Redis y tiempos de vida (TTL) declarados para cada recurso.
11. **Load Balancing:** Balanceo de tráfico geográfico y mecanismos de failover automatizados para resiliencia del sistema ante caídas de centros de datos.
12. **Error Tracking:** Captura de trazas de error completas en Sentry para el equipo técnico e higienización de mensajes HTTP públicos para los usuarios.
13. **Disponibilidad & Backups:** Backups automáticos diarios verificado con ejercicios recurrentes de restauración (*Restore Drill*), junto con comprobaciones sintéticas de salud (*health checks*) cada 60 segundos.

*La prioridad de remediación de elementos en Rojo es:*
1. Elementos que provoquen pérdida directa de dinero.
2. Elementos que expongan o filtren datos confidenciales de clientes (Cross-Tenant leaks).
3. Elementos que vulneren obligaciones legales o regulatorias (EU AI Act, GDPR).

---

## SECCIÓN II: ARQUITECTURA HÍBRIDA SERVERLESS ↔ CONTENEDORES

El cómputo *Serverless* tiene un límite físico estricto (timeouts de 10s-30s y desconexiones abruptas de WebSockets). El sistema migrará a una arquitectura híbrida de **Cola + Worker en Contenedor Docker** al cumplir cualquiera de estos tres disparadores:

*   **Tiempos de ejecución > 30 segundos:** Generación masiva de PDFs, entrenamiento de embeddings vectoriales, procesamiento de archivos multimedia o exportaciones pesadas.
*   **Conexiones persistentes de red:** WebSockets, sincronización de datos IoT en tiempo real o canales bidireccionales continuos.
*   **Trabajos por lotes intensivos (Cron Jobs):** Procesamiento en background que consuma APIs de LLMs sin restricciones artificiales de timeouts HTTP.

### El Patrón Arquitectónico Canónico:
```
[Cliente] -> [API HTTP Serverless (Lógica Ligera)] 
                 |
          (Inserta Trabajo)
                 v
       [Cola de Mensajes (Redis/SQS)] 
                 |
          (Consume Trabajo)
                 v
       [Worker Containerizado (Docker - Fly.io/AWS ECS)]
```
*Tanto la API Serverless como el Contenedor de background reportan de forma unificada a la misma pila de observabilidad centralizada. El contenedor Docker corre siempre bajo un usuario no-root por motivos de seguridad.*

---

## SECCIÓN III: PROTOCOLO POST-DEPLOY DE SMOKE TESTING OBLIGATORIO

En cuanto un despliegue se completa con éxito en producción, el ingeniero u organizador autónomo debe realizar obligatoriamente un **Smoke Test** manual simulando el recorrido de un usuario real bajo ventana de incógnito en el dominio público:

1.  **Registro:** Crear una cuenta con una dirección de correo electrónico real (ej. `tu+test@gmail.com`).
2.  **Confirmación:** Verificar la recepción del correo de bienvenida y confirmar que el enlace de autenticación funciona.
3.  **Core Flow:** Iniciar sesión y ejecutar el flujo clave del negocio (crear un recurso, editarlo, borrarlo).
4.  **Flujo de Cobro:** Si el módulo incluye pasarela de pago, procesar una compra real de importe mínimo para certificar que el webhook verificado de Stripe desbloquea correctamente el acceso en el backend.
5.  **Persistencia:** Cerrar la sesión, iniciarla nuevamente y validar que el estado del usuario permanece intacto.

> **Regla Directiva:** Si cualquier paso de este Smoke Test falla o se siente extraño, se ejecuta inmediatamente el Rollback de la versión. No importa que la app se vea perfecta o no arroje errores en consola.

---

## SECCIÓN IV: RUNBOOK DE GESTIÓN DE INCIDENTES EN PRODUCCIÓN

Cuando el sistema experimente una degradación de servicio o un agujero de seguridad activo, el equipo On-Call ejecutará secuencialmente el protocolo de crisis:

1.  **Contener:** Si se detecta un exploit de seguridad activo (fuga IDOR o bypass RLS en caché), el primer paso es desactivar el endpoint comprometido o activar de inmediato el **Modo Mantenimiento** de la infraestructura en el borde para detener la fuga antes de investigar.
2.  **Reconstruir:** Utilizar los logs structured en JSON y el trace ID de Sentry para reconstruir la línea de tiempo exacta del error o ataque, identificando el origen de las peticiones sospechosas.
3.  **Comunicar:** Notificar de forma honesta y transparente a los usuarios que reportaron el fallo o que se vieron potencialmente afectados. Se confirmará la recepción del incidente, los tiempos estimados de resolución y se publicará un informe post-mortem breve enfocado en la mitigación técnica, sin culpar a individuos.
4.  **Prevenir:** El patrón que provocó el incidente se documentará y se añadirá en forma de test adversarial en CI/CD y como patrón de síntomas en el catálogo del agente para que el diagnóstico y resolución sean automáticos en el futuro.
