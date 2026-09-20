---
name: saas-compliance-readiness
description: >
  Turns compliance from a blocker into a sellable deliverable: evidence-based
  readiness assessment for ISO 27001, ENS, SOC 2 Type II, GDPR and NIS2 aimed at
  the European market, plus the build-versus-buy audit that decides which SaaS
  subscriptions a client should replace with directed AI builds. Use when an
  enterprise deal asks for a certification, when the user says "ISO 27001",
  "ENS", "SOC 2", "NIS2", "cuestionario de seguridad", "due diligence",
  "auditoria de cliente", "cumplimiento", or when scoping what to build instead
  of buy. Skill content is in Spanish.
---
# 📑 PREPARACIÓN PARA CUMPLIMIENTO Y AUDITORÍA DE STACK

Dos entregables distintos que comparten el mismo método: evidencia antes que declaración.

1. **Readiness de certificación** — qué falta para superar la diligencia debida de un cliente enterprise.
2. **Auditoría build-vs-buy** — qué suscripciones del cliente sobran y cuáles no conviene tocar.

Ambos son facturables. Ninguno requiere ser auditor certificado: preparar la evidencia no es emitir el certificado.

---

## SECCIÓN I: ORDEN DE PRIORIDAD PARA EL MERCADO EUROPEO

No todos los marcos pesan igual según quién compra. Elegir el equivocado es gastar meses en el sello que el cliente no pide.

| Marco | Cuándo importa de verdad | Coste real de entrada |
|---|---|---|
| **GDPR** | Siempre. No es opcional ni negociable en la UE | Documental, no certificable |
| **ENS** (Esquema Nacional de Seguridad) | Obligatorio para vender a administración pública española | Certificación por entidad acreditada |
| **ISO 27001** | El sello que pide el comprador corporativo europeo | Auditoría externa, ciclo anual |
| **NIS2** | Obligatorio por sector y tamaño, no por elección | Autoevaluación + responsabilidad de dirección |
| **SOC 2 Type II** | Solo si el comprador es estadounidense o filial de uno | Ventana de observación + auditor CPA |

> **Criterio.** Para un SaaS español que vende en España y la UE, el orden es GDPR → ISO 27001 → ENS si hay sector público → NIS2 si aplica por ámbito → SOC 2 solo cuando lo exija un contrato concreto. Perseguir SOC 2 primero porque aparece en los blogs anglosajones es invertir en el sello equivocado.

---

## SECCIÓN II: MATRIZ DE READINESS (EVIDENCIA, NO INTENCIÓN)

Cada control se responde con **una prueba verificable**, no con una afirmación. "Tenemos control de accesos" no es evidencia; una captura de la política de roles, la fecha de la última revisión de permisos y el registro de quién la firmó, sí.

| # | Control | Evidencia exigida | Bloquea |
|---|---|---|---|
| 1 | Control de acceso por roles y autenticación | Matriz de roles, MFA activo en cuentas privilegiadas, revisión de accesos con fecha y firma | ISO, ENS, SOC 2 |
| 2 | Cifrado en tránsito y en reposo | Configuración TLS, cifrado del proveedor de BD, gestión de claves documentada | Todos |
| 3 | Registro de auditoría | Log inmutable de acciones de usuario, accesos y cambios de sistema, con retención definida | ISO, SOC 2, NIS2 |
| 4 | Plan de respuesta a incidentes | Documento con roles nombrados, escalado, plazos de notificación y un simulacro ejecutado | NIS2 (72 h), ISO |
| 5 | Gestión de proveedores | Inventario de terceros con acceso a datos, DPA firmado por cada uno, evaluación de riesgo | GDPR, ISO, NIS2 |
| 6 | Gestión del cambio | Revisión obligatoria de PR, CI con pruebas, trazabilidad de despliegues, rollback probado | ISO, SOC 2 |
| 7 | Copias de seguridad y recuperación | Backups automatizados **y un restore drill ejecutado con fecha** | Todos |
| 8 | Base legal y derechos del interesado | Registro de actividades de tratamiento, mecanismo de acceso/borrado/portabilidad probado | GDPR |
| 9 | Continuidad de negocio | RTO y RPO declarados y medidos frente a la realidad | ISO, NIS2 |
| 10 | Concienciación y responsabilidad de dirección | Formación registrada; bajo NIS2 la dirección responde personalmente | NIS2, ISO |

**Regla de emisión.** Todo control sin evidencia se reporta como **GAP BLOQUEANTE**, nunca como "parcialmente cubierto". Un control a medias es un control que falla el día de la auditoría.

---

## SECCIÓN III: EL CUESTIONARIO DE SEGURIDAD DEL CLIENTE

Antes de la certificación llega el cuestionario. Es el filtro real que decide si el contrato avanza, y se responde en días, no en meses.

**Activo reutilizable a construir una sola vez:** un documento maestro con las 40 respuestas estándar (arquitectura, cifrado, subencargados, residencia de datos, retención, notificación de brechas, penetration testing, continuidad, formación). Cada respuesta con su evidencia enlazada. A partir de ahí, cada cuestionario nuevo es una adaptación de una hora, no una semana.

Para una agencia esto es doblemente rentable: acelera los propios contratos y se vende como servicio a clientes que se atascan ahí.

---

## SECCIÓN IV: AUDITORÍA BUILD-VS-BUY

Aplicable al propio negocio y como servicio de consultoría.

**Paso 1 — Inventario.** Listar cada suscripción SaaS y su coste mensual. Para cada una, separar funcionalidades **usadas** de funcionalidades **incluidas e ignoradas**. Marcar como CANDIDATA A CONSTRUIR toda suscripción donde se use menos del 40% de lo contratado.

**Paso 2 — Alcance del reemplazo.** Para cada candidata: qué funcionalidad concreta tendría que replicar el reemplazo, expresada en módulos. Más de cinco módulos = **ALTA COMPLEJIDAD**; recomendar mantener la suscripción salvo que ya existan construcciones similares entregadas.

**Paso 3 — Madurez del operador.** ¿Existe historial de definir alcance, dirigir la construcción y **verificar** el resultado? Si no, empezar por la candidata más simple como prueba de concepto. La diferencia entre quien sustituye software con IA y quien no lo consigue no son las herramientas: es que alguien sepa traducir una necesidad de negocio en una especificación construible y verificarla.

**Paso 4 — Ahorro frente a inversión.** Coste mensual evitado, tiempo de construcción estimado y coste de mantenimiento **continuo** del reemplazo. El mantenimiento es el coste que casi nadie incluye y el que decide si la operación tiene sentido.

**Paso 5 — Criterio de aceptación.** Qué prueba concreta demuestra que el reemplazo funciona **antes** de dar de baja la herramienta. Sin ese criterio escrito, no se cancela nada.

**Salida:** hoja de ruta priorizada por ahorro descendente y complejidad ascendente.

**Advertencia a incluir siempre en el entregable.** Velocidad sin dirección es cómo se filtran credenciales a escala. Todo reemplazo construido entra en el mismo ciclo que cualquier otro módulo: Carril de riesgo asignado, Definition of Done aplicado, auditoría adversarial superada.

---

## SECCIÓN V: ENTREGABLE

1. Marco objetivo elegido **y justificado** por quién compra, no por moda.
2. Matriz de readiness con evidencia o GAP por cada control.
3. Gaps ordenados por coste de cierre ascendente, con responsable y fecha propuesta.
4. Estimación honesta de plazo hasta readiness, señalando qué depende de un tercero (auditor, entidad certificadora, ventana de observación).
5. Lo que **no** se ha verificado y por qué.

Nunca declarar un sistema "conforme" o "certificable". El entregable es preparación para auditoría; la conformidad la dictamina el auditor.
