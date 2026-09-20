---
name: saas-production-readiness
description: >
  Mandatory before any production deploy, go-live or launch, and during any live
  incident: the 13-layer traffic-light audit, the pre-deploy checklist, the smoke
  test on the real domain, verified rollback under 60 seconds, the backup restore
  drill and the incident runbooks. Blocks the deploy while any item is RED.
  Use when the user says "deploy", "desplegar", "produccion", "go-live", "lanzar",
  "esta listo?", "checklist de lanzamiento", "se cayo", "error 500", "no funciona
  en produccion", "rollback", "backup", "restaurar", "monitoreo", "Sentry",
  "uptime", "alertas", "DDoS", "coste inesperado", "CI/CD", "GitHub Actions",
  "merge a main" or "postmortem". Skill content is in Spanish.
---

# SaaS Production Readiness — Compuerta de Despliegue y Operación

> **STATUS: MANDATORIO.** Ninguna aplicación pasa a producción sin completar la auditoría de 13 capas y el checklist pre-deploy. Compilar en local no es estar listo para producción.
>
> **Regla de oro del despliegue:** si no puedes responder "sí, está hecho" a todos los puntos del checklist, no es momento de desplegar. Es momento de cerrar el portátil y volver mañana. **El deploy que se rompe a las 2:00 AM cuesta más que el lanzamiento que se retrasa 24 horas. Siempre.**

---

## 0. ACTIVACIÓN Y MODOS

Esta skill tiene tres modos. Identificar cuál aplica antes de empezar:

| Modo | Cuándo | Sección |
|---|---|---|
| **A — Auditoría de preparación** | "¿estamos listos para producción?", go-live, primer lanzamiento | §1 |
| **B — Compuerta de deploy** | Cada despliegue, incluidos los rutinarios | §2–§4 |
| **C — Incidente en vivo** | Caída, error masivo, ataque, factura disparada | §7 |

**Posición en el ciclo:** última fase. Presupone que `saas-architecture-blueprint`, `saas-security-workflow` y `saas-billing-unit-economics` ya se ejecutaron. Si no, decirlo explícitamente antes de continuar: auditar producción sobre una arquitectura sin revisar produce un informe falso.

---

## 1. MODO A — AUDITORÍA DE LAS 13 CAPAS

Evaluar cada capa y asignar semáforo. Sin excepciones, sin "esto seguro que está bien".

| # | Capa | Qué se verifica |
|---|---|---|
| 1 | **Frontend** | Estados de error visibles, reintentos de red, lazy loading, comportamiento sin conexión, estados vacíos |
| 2 | **APIs** | Contratos tipados, serialización segura, timeouts explícitos, versionado, códigos de estado correctos |
| 3 | **Base de datos** | Índices en columnas de filtrado y FKs, connection pooling, migraciones append-only y reversibles |
| 4 | **Autenticación** | Revocación de sesión, expiración de tokens, protección en todos los endpoints, rotación de refresh tokens |
| 5 | **Hosting** | Variables de entorno aisladas por entorno, TLS auto-renovable, dominio y DNS verificados |
| 6 | **Infraestructura cloud** | Roles IAM de mínimo privilegio, redes privadas, sin buckets públicos por defecto |
| 7 | **CI/CD** | Pipeline que ejecuta linter, tipado y tests antes de desplegar; sin bypass posible |
| 8 | **Seguridad** | Cabeceras CSP/HSTS, validación de entrada en servidor, sanitización, secretos fuera del código |
| 9 | **Rate limiting** | Anti fuerza bruta por IP, control de abuso financiero en endpoints de LLM, cuota por organización |
| 10 | **Caching** | TTL explícito, política de invalidación, aislamiento por tenant |
| 11 | **Concurrencia / balanceo** | Comportamiento en picos, resiliencia a la pérdida de una instancia, prueba de carga hecha |
| 12 | **Observabilidad** | Excepciones con traza y contexto de usuario, logs estructurados, alertas que llegan de verdad |
| 13 | **Disponibilidad / backups** | Backup automático diario **con restauración probada**, plan de rollback, monitor de uptime |

### Sistema de semáforo

- 🟢 **VERDE** — listo para producción, verificado con evidencia.
- 🟡 **AMARILLO** — funciona pero con hueco identificado. Se documenta y se le pone fecha.
- 🔴 **ROJO** — no abordado o crítico. **Bloquea el lanzamiento.**

Para cada 🟡 y 🔴: describir la brecha técnica concreta y estimar el esfuerzo de remediación en horas.

### Priorización de los ROJOS

Ordenar por riesgo de negocio, en este orden innegociable:

1. **¿Qué puede hacerme perder dinero?** (facturas serverless descontroladas, caídas en el checkout, cobros duplicados)
2. **¿Qué puede hacerme perder datos?** (sin backup, sin restore probado, migración irreversible, borrado en cascada mal modelado)
3. **¿Qué puede hacerme ganar una demanda?** (PII expuesta, incumplimiento GDPR, fuga entre clientes, logs con datos sensibles)

Todo lo demás va después. Un fallo de accesibilidad importa; no importa tanto como perder la base de datos.

---

## 2. MODO B — CHECKLIST PRE-DEPLOY

### Configuración de entorno

- [ ] `.env.example` actualizado con **todos** los nombres de clave (sin valores) en la raíz.
- [ ] Variables configuradas en el host para **todos los entornos**: producción, preview y staging. *El 80% de los "funciona en local pero en producción truena" son variables faltantes o con espacios accidentales.*
- [ ] Cero URLs hardcodeadas. Nada de `localhost:3000` ni `127.0.0.1`; todo por variable.
- [ ] Secretos de producción **distintos** de los de desarrollo. Especialmente claves de pasarela de pago.
- [ ] `.env` en `.gitignore` y ausente del histórico de git: `git log -p | grep -iE "sk-|api_key|secret|password"`.

### Validación de build

- [ ] **`npm run build` local ejecutado y correcto antes de hacer push.** Que `npm run dev` funcione no garantiza nada: producción compila con tipos estrictos, lints y tree-shaking.
- [ ] Sin warnings de tipado ni de lint suprimidos con `@ts-ignore` o `eslint-disable` para pasar el build.
- [ ] Tamaño del bundle revisado. Una dependencia añadida sin mirar puede duplicarlo.
- [ ] Tests ejecutados contra **scratch DB** efímera, nunca contra la BD compartida de desarrollo ni contra staging.

### Migraciones

- [ ] Migración probada sobre una copia real de los datos de producción, no sobre una base vacía.
- [ ] Plan de reversión escrito. Si no es reversible, coordinado con backup verificado inmediatamente previo.
- [ ] Migración de esquema y despliegue de código como **dos pasos separados**, en ese orden.
- [ ] Para cambios con riesgo de downtime: patrón expand → migrate → contract.

### Observabilidad activa

- [ ] **Logs estructurados en JSON**, no `console.log` sueltos. Campos mínimos: `timestamp`, `level`, `request_id`, `user_id`, `org_id`, `endpoint`, `status_code`, `latency_ms`.
- [ ] **Rastreo de errores** (Sentry o equivalente) configurado en frontend **y** backend, con traza completa y contexto de usuario.
- [ ] **Alertas activas** a Slack/email/SMS para: tasa de error > umbral, latencia > umbral, caída del servicio, fallos de webhook, profundidad de cola.
- [ ] **Nunca registrar datos sensibles**: contraseñas, tokens de sesión, números de tarjeta, PII de clientes. Revisar los objetos que se pasan al logger, no solo los strings.
- [ ] **Validación del sistema de alertas:** provocar un error intencional en staging (`throw new Error("Test alerta")`) y cronometrar que la alerta llega en menos de 60 segundos. Una alerta no probada es una alerta que no existe.
- [ ] **Monitor de uptime sintético** verificando `200 OK` en endpoints críticos cada 60 segundos.
- [ ] **Página de estado pública** para que un incidente no se perciba como una estafa.

### Backups

- [ ] Backup automático diario activo y verificado **en el panel del proveedor**, no asumido.
- [ ] **Restore drill ejecutado**: restaurar el backup en un entorno sandbox y comprobar que los datos están íntegros.
- [ ] Retención definida y suficiente para detectar una corrupción silenciosa (mínimo 7 días, preferible 30).
- [ ] Backup almacenado fuera de la misma cuenta o región que la base de datos primaria.

> **Regla de oro del respaldo: un backup no existe hasta que has probado a restaurarlo al menos una vez.**

### Control de coste

- [ ] Límites de gasto y alertas de presupuesto configurados al 50%, 80% y 100% de la cuota mensual.
- [ ] **Spend caps** que detengan ejecuciones ante tráfico anómalo, en lugar de facturar sin límite.
- [ ] CDN/WAF con rate limiting en el borde, **antes** de que la petición toque infraestructura facturable.
- [ ] Hard cap de consumo de LLM por organización (definido en el blueprint), activo y probado.

---

## 3. PIPELINE CI/CD — GATES NO BYPASSABLES

Un hook `pre-commit` local se salta con `--no-verify` o subiendo el archivo desde la interfaz web. **El CI es el backstop real.**

Gates obligatorios en el pipeline, imposibles de esquivar:

- **Type checking y linting** estrictos, sin supresiones autogeneradas.
- **Tests unitarios y de integración**, con verificación de que se añadieron tests para todo comportamiento nuevo.
- **Escaneo de secretos** bloqueante, sobre código, fixtures, snapshots y archivos de log.
- **SAST y escaneo de dependencias**: riesgos OWASP, licencia y reputación del paquete en el registro canónico (defensa contra *slopsquatting*: paquetes inexistentes alucinados por la IA y registrados por un atacante).
- **Verificación de build** en entorno efímero, especialmente para archivos de configuración, migraciones o cambios de esquema generados por IA.
- **Test de aislamiento cross-tenant** (definido en el blueprint) si la aplicación es multi-tenant.

Backstop de escaneo de secretos:

```yaml
name: gitleaks
on: [pull_request, push]
jobs:
  scan:
    name: gitleaks-scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Uso correcto de revisores automáticos de IA:** sus comentarios son orientativos para el revisor humano, **nunca aprobación final** en rutas de Carril Rojo (auth, pagos, PII, migraciones, multi-tenancy).

### Disciplina de ramas

```
feature/nombre  --PR + linter/tests-->  dev
dev             --tests integración-->  staging
staging         --aprobación final-->   main / producción
```

**Estrictamente prohibido `git push origin main` directo desde local.** Rama `main` protegida a nivel de proveedor, no por acuerdo verbal.

### Métricas de salud del pipeline

Si la IA aumenta el número de PRs fusionadas pero también las colas de revisión, el retrabajo y los incidentes, no has ganado throughput: has movido el trabajo aguas abajo. Instrumentar por carril de riesgo:

- % de PRs asistidas por IA
- Tiempo de ciclo de PR por carril
- Carga de revisión por revisor
- Tasa de fallo de CI tras la primera revisión
- Retrabajo posterior a la revisión
- **Defectos escapados a producción** correlacionados con cambios asistidos por IA

---

## 4. SMOKE TEST EN DOMINIO REAL (POST-DEPLOY)

En `localhost` la pasarela corre en modo test, los emails van a buzones de prueba y las redirecciones funcionan en memoria. Nada de eso demuestra que producción funciona.

**Protocolo obligatorio tras cada deploy que toque flujos críticos.** Ventana de incógnito, dominio público, comportándose como un usuario real:

1. Registro con un correo real (`tu+test@gmail.com`).
2. Verificar que **llega** el email de confirmación y que el enlace **funciona**.
3. Iniciar sesión con la cuenta nueva y recorrer el flujo core completo: crear, editar, borrar.
4. Si hay cobros: **pagar 1 € real** (o con clave live de prueba) y validar que el webhook desbloquea el acceso.
5. Cerrar sesión, volver a entrar y validar que el estado persiste.
6. Repetir el flujo core desde móvil. La mitad del tráfico real llega desde ahí.

> **Si cualquier paso falla o simplemente "se siente raro", no se lanza.** Aunque la aplicación se vea perfecta.

---

## 5. ROLLBACK EN MENOS DE 60 SEGUNDOS

Todo desarrollador despliega bugs. La diferencia entre un susto y una crisis es el tiempo entre *"se rompió"* y *"ya está arreglado"*.

- **Vercel / Netlify:** Deployments → seleccionar el deploy anterior funcional → *Promote to Production*.
- **Railway / Render:** despliegues asociados a commits → `git revert <commit-id>` + `git push`.
- **Contenedores:** mantener la imagen anterior etiquetada y disponible; rollback = cambiar el tag y redesplegar.
- **Base de datos:** migraciones reversibles por diseño, o plan de reversión manual documentado y probado.

**Prueba de competencia:** debes ser capaz de encontrar y pulsar el botón de rollback de tu plataforma en menos de 30 segundos, sin buscar en la documentación. Practícalo **antes** de necesitarlo.

**Regla:** rollback primero, diagnóstico después. Investigar la causa raíz con el servicio caído es un error de juicio, no de ingeniería.

### Feature flags como red de seguridad

Toda funcionalidad nueva de riesgo va detrás de un flag. Permite desactivar la función sin revertir el deploy completo, y habilita el despliegue progresivo (1% → 10% → 50% → 100% de usuarios).

---

## 6. RUNBOOKS DE INCIDENTE

### 6.1 — Respuesta a DDoS y degradación elegante

Sin plan documentado, la reacción es pánico: tocar DNS en caliente o cambiar código bajo presión. Resultado: caída más larga y factura cloud astronómica por autoescalado descontrolado.

Toggles de emergencia **pre-construidos** en la infraestructura, no improvisados:

- **Minuto 0 — Triaje:** alerta automática al responsable de guardia. Determinar si el pico viene de una sola ASN, una región o es distribuido.
- **Minuto 2 — Modo mantenimiento:** activar `MAINTENANCE_MODE=true` a nivel de borde para servir una página estática y **desconectar el acceso a base de datos y a LLMs costosos**. Esto para la sangría económica.
- **Minuto 5 — Sala de espera:** habilitar waiting room o rate limiting de capa 7 en las rutas críticas (`/login`, `/api/ai`).
- **Minuto 10 — Mitigación superior:** activar el modo "bajo ataque" del proveedor, que exige challenge computacional a cada petición sospechosa.

### 6.2 — Fuga de datos o agujero de seguridad activo

1. **Aislamiento inmediato:** desactivar el endpoint afectado o poner la aplicación en mantenimiento mientras se audita. La disponibilidad es menos importante que la contención.
2. **Trazabilidad:** reconstruir la línea temporal con los logs estructurados (`timestamp`, `user_id`, `org_id`, `endpoint`, `status_code`).
3. **Alcance:** determinar qué datos, de qué clientes y durante cuánto tiempo. Esto determina las obligaciones de notificación.
4. **Rotación:** cualquier credencial potencialmente expuesta se rota, no se "vigila".
5. **Comunicación honesta:** nunca ocultar un incidente crítico a quien lo reportó. Confirmar recepción, resolver, publicar un post-mortem breve.
6. **Obligación legal:** bajo GDPR, notificación a la autoridad en 72 horas si hay riesgo para los derechos de los afectados. El reloj empieza cuando lo detectas, no cuando lo entiendes.

### 6.3 — Factura disparada

1. Identificar el recurso que consume: función, endpoint, cola o consulta.
2. Aplicar el toggle de emergencia de esa función concreta (no de toda la aplicación si se puede evitar).
3. Revisar si es abuso externo (scraping, bot) o bucle propio (retry infinito, useEffect mal escrito, cola sin dead-letter).
4. Contactar con el proveedor: muchos condonan picos por incidente si se reportan pronto y una sola vez.
5. Añadir el spend cap que faltaba. Este incidente no debería poder repetirse.

### 6.4 — Post-mortem sin culpa

Tras todo incidente con impacto en usuarios, en menos de 48 horas:

```markdown
# Post-mortem: [título] — YYYY-MM-DD

- Impacto: [qué vieron los usuarios, cuántos, durante cuánto tiempo]
- Detección: [cómo nos enteramos, y cuánto tardamos]
- Línea temporal: [con horas UTC]
- Causa raíz: [la técnica, no "fallo humano"]
- Qué funcionó bien:
- Qué falló en la respuesta:
- Acciones correctivas: [con responsable y fecha, no "deberíamos"]
```

Si la detección vino de un usuario y no de una alerta, la primera acción correctiva es siempre la alerta que faltaba.

---

## 7. OPERACIÓN CONTINUA

### Agentes de monitorización (heartbeats)

Hilos de larga duración con despertar programado (cada 15–30 min) que mantienen su contexto histórico:

- El agente evalúa el estado del pipeline, las colas y los despliegues.
- Si todo está normal, **duerme sin generar ruido**. Un agente que reporta "todo bien" cada 15 minutos entrena al equipo a ignorar sus alertas.
- Si detecta un fallo, redacta el diagnóstico y una propuesta de corrección **en borrador**, exigiendo confirmación humana antes de tocar producción.

### Shadow mode antes del cutover

Todo motor crítico o parser reescrito con IA (migraciones, parsers SQL, lógica de precios) corre en **shadow mode** en producción — procesando tráfico real, comparando su salida con la del sistema antiguo, sin efectos — durante un periodo definido antes del corte definitivo.

### Revisión periódica

- **Semanal:** revisar alertas disparadas, errores nuevos en Sentry, profundidad de colas, tasa de fallo de CI.
- **Mensual:** restore drill de backup (sí, otra vez), revisión de coste por usuario, revisión de dependencias desactualizadas.
- **Trimestral:** repasar la auditoría de 13 capas completa. Los amarillos que nadie mira se vuelven rojos solos.

---

## 8. FORMATO DE SALIDA OBLIGATORIO

**Modo A (auditoría):**
1. Tabla de las 13 capas con semáforo, brecha concreta y horas estimadas.
2. Lista de ROJOS priorizada por: pierdo dinero → pierdo datos → me demandan.
3. Plan de remediación con orden de ejecución.
4. Veredicto explícito: **APTO** / **APTO CON RIESGO ACEPTADO** (con firma de quién lo acepta) / **NO APTO**.

**Modo B (deploy):**
1. Checklist pre-deploy con estado real por ítem.
2. Confirmación del plan de rollback y de quién lo ejecutará.
3. Guion del smoke test post-deploy a ejecutar.
4. Veredicto: **DESPLIEGA** / **NO DESPLIEGA** + motivo.

**Modo C (incidente):**
1. Runbook aplicable con pasos numerados y tiempos.
2. Acciones inmediatas de contención, antes que el diagnóstico.
3. Plantilla de post-mortem a rellenar después.

**Regla de bloqueo final:** con cualquier ítem en 🔴, la respuesta es **NO DESPLIEGA**. Se puede aceptar el riesgo, pero por escrito, con nombre y fecha de quien lo acepta. Nunca por silencio.

