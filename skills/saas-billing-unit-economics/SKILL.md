---
name: saas-billing-unit-economics
description: >
  Mandatory before charging the first euro and in any code that touches money:
  the Red Lane Gate (AI drafts only), the 4 golden rules of billing, the 7
  mandatory subscription events, the anti-chargeback protocol, dunning, and
  cost-per-invocation instrumentation with a $0.10 flag. Blocks the move from
  test to live keys without named human verification. Use when the user says
  "Stripe", "pagos", "cobrar", "checkout", "suscripcion", "pricing", "webhook",
  "facturacion", "billing", "reembolso", "chargeback", "disputa", "churn",
  "trial", "upgrade", "prorrateo", "IVA", "unit economics", "margen", "coste por
  usuario", "limites de plan", "cuota" or "creditos". Skill content is in
  Spanish.
---

# SaaS Billing & Unit Economics — Compuerta Financiera

> **STATUS: MANDATORIO.** Todo código que toca dinero es **Carril Rojo** por definición: la IA solo redacta el borrador; un humano verifica y firma antes de pasar de `sk_test_` a `sk_live_`. Sin excepciones, sin "es que es solo un cambio pequeño".
>
> **Dos formas de morir con los cobros:** que el dinero no entre (webhooks rotos, churn involuntario, chargebacks que te congelan la cuenta) o que entre y aun así pierdas (coste por usuario superior al ingreso). Esta skill cubre las dos.

---

## 0. ACTIVACIÓN

Ejecutar siempre que aparezca:

- Integración de pasarela de pago, checkout, portal de cliente, planes o precios.
- Cualquier archivo que importe el SDK de Stripe (o Paddle, Lemon Squeezy, Chargebee) o defina un endpoint de webhook.
- Diseño o cambio de tabla de precios, tiers, trials, créditos, cuotas o límites de plan.
- Preguntas de rentabilidad: coste por usuario, margen, P&L, "¿cuánto me cuesta cada cliente?".
- Paso de entorno de test a producción en pagos.
- Aparición de reembolsos, disputas, impuestos o multidivisa.

**Posición en el ciclo:** después de `saas-architecture-blueprint` (que ya fijó entitlements y modelo de organización) y de `saas-security-workflow`. Antes de `saas-production-readiness`.

---

## 1. RED LANE GATE — LA COMPUERTA INNEGOCIABLE

Los generadores de código y app builders cablean un checkout en minutos. Ese código cubre el *happy path* y omite sistemáticamente: verificación criptográfica de webhooks, idempotencia, manejo de disputas y control de fraude.

**Carril Amarillo (IA implementa con normalidad):**
- Maquetación de tabla de precios y páginas de planes.
- UI del checkout y del portal de cliente.
- Emails transaccionales de recibo (plantilla, no lógica de envío).

**Carril Rojo (IA solo redacta borrador):** en cuanto el código toca cualquiera de esto:
- `STRIPE_SECRET_KEY` o cualquier clave secreta de pasarela.
- Endpoints de webhook.
- Movimiento de fondos: cargos, reembolsos, transferencias, payouts.
- Tabla de suscripciones, estado de plan o entitlements.
- Lógica de prorrateo, créditos o saldo.

**Checklist de la compuerta antes de activar modo live:**

```
[ ] Un humano ha leído línea por línea el handler de webhook.
[ ] Verificación de firma criptográfica confirmada manualmente en el código.
[ ] Clave de idempotencia presente en toda operación de cargo.
[ ] Probado el flujo completo en modo test con tarjetas de prueba, incluidas las de fallo.
[ ] Probado el reintento de webhook (reenviar el mismo evento dos veces → un solo efecto).
[ ] Claves live aisladas del entorno de desarrollo y de staging.
[ ] Firma explícita de responsable: nombre + fecha.
```

Si algún punto falta, no se activa live. Punto.

---

## 2. LAS 4 REGLAS DE ORO DEL BILLING

### R1 — Firma criptográfica de webhooks

Todo evento entrante se verifica contra el secreto de webhook. **Prohibido confiar en el `success_url`** al que redirige el navegador del cliente: es trivialmente falsificable escribiendo la URL a mano.

```typescript
// Endpoint de webhook — patrón canónico
import Stripe from "stripe";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

export async function POST(req: Request) {
  const signature = req.headers.get("stripe-signature");
  // CRÍTICO: cuerpo crudo, sin parsear. Un body-parser rompe la verificación.
  const rawBody = await req.text();

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(
      rawBody,
      signature!,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err) {
    // Firma inválida = petición falsa. Se rechaza sin procesar nada.
    return new Response("Invalid signature", { status: 400 });
  }

  // Deduplicación: Stripe reenvía eventos. Sin esto, un reintento duplica el efecto.
  const alreadyProcessed = await db.webhookEvents.findUnique({ where: { id: event.id } });
  if (alreadyProcessed) return new Response("OK", { status: 200 });

  await db.$transaction(async (tx) => {
    await tx.webhookEvents.create({ data: { id: event.id, type: event.type } });
    await handleEvent(event, tx);
  });

  return new Response("OK", { status: 200 });
}
```

**Gotchas que rompen esto en producción:**
- Un middleware que parsea JSON antes del handler invalida la firma. El endpoint de webhook necesita el cuerpo crudo.
- Devolver `500` ante un error de lógica hace que Stripe reintente indefinidamente. Registrar el error, devolver `200` y encolar el reproceso.
- Responder lento (>10s) provoca timeout y reintento. Procesar de forma asíncrona: acusar recibo primero, trabajar después.

### R2 — Aprovisionamiento asíncrono

**Nunca** activar la suscripción, los créditos o el acceso en el momento en que el usuario vuelve del checkout. El aprovisionamiento ocurre **exclusivamente** al recibir un webhook verificado en el backend.

Patrón de UX correcto: la página de retorno muestra "procesando tu pago…" y hace polling del estado real en tu base de datos, no asume nada.

### R3 — Idempotencia transaccional

Toda operación de cargo lleva clave de idempotencia. Un doble clic o un timeout de red no puede convertirse en un doble cobro.

```typescript
await stripe.paymentIntents.create(
  { amount, currency, customer },
  { idempotencyKey: `charge:${orgId}:${invoiceId}` } // determinista, no aleatoria
);
```

La clave debe ser **determinista y derivada del dominio** (organización + factura), no un UUID nuevo en cada intento. Un UUID aleatorio no protege de nada: cada reintento genera una clave distinta.

### R4 — Aislamiento de claves

- `sk_test_…` / `whsec_…` de test → desarrollo y staging.
- `sk_live_…` → exclusivamente producción, en el gestor de secretos del host.
- Claves restringidas por permisos cuando la pasarela lo permita (una clave que solo lee no puede mover fondos).
- Rotación documentada. Si una clave live aparece en un log, un repo o una captura: se rota inmediatamente. Borrar el commit no mitiga.

---

## 3. LA MÁQUINA DE ESTADOS DE SUSCRIPCIÓN

La fuente de verdad del acceso es **tu base de datos**, sincronizada por webhooks. Nunca consultar la API de la pasarela en el camino crítico de cada request.

Estados mínimos a modelar:

```
trialing → active → past_due → canceled
                 ↘ paused
                 ↘ incomplete (pago inicial fallido)
```

**Eventos a manejar obligatoriamente:**

| Evento | Acción |
|---|---|
| `checkout.session.completed` | Crear/activar suscripción |
| `customer.subscription.updated` | Sincronizar plan, estado y periodo |
| `customer.subscription.deleted` | Revocar acceso al final del periodo pagado |
| `invoice.paid` | Renovar periodo, resetear contadores de cuota |
| `invoice.payment_failed` | Entrar en dunning (§5) |
| `charge.dispute.created` | Pausar cuenta y recopilar evidencia (§4) |
| `charge.refunded` | Ajustar acceso y registrar en P&L |

**Reglas duras:**
- El acceso se revoca al **final del periodo pagado**, no en el momento de la cancelación. Cortar antes genera disputas.
- Toda transición de estado se escribe en `audit_log` con el `event.id` que la provocó.
- Downgrade y upgrade: decidir explícitamente si hay prorrateo y documentarlo en la página de precios. La ambigüedad aquí genera tickets de soporte eternos.
- Los entitlements se leen de **una sola función** (`getEntitlements(orgId)`), nunca dispersos por el código.

---

## 4. PROTOCOLO ANTI-CHARGEBACK

**El riesgo real:** superar el **0,75% de disputas** hace que la pasarela clasifique la cuenta como negocio de alto riesgo, congele los fondos y, en casos graves, cierre la cuenta. Es un evento de extinción para un SaaS pequeño.

**Prevención (todo esto antes del primer cobro):**

- [ ] **Descriptor bancario reconocible.** `TUMARCA.COM*PLAN`, nunca el nombre de la sociedad matriz que el cliente no reconoce en su extracto. Es la causa número uno de disputas "no reconozco este cargo".
- [ ] **Recibo por email automático** con desglose e instrucciones de cancelación en un clic.
- [ ] **Cancelación autoservicio real.** Si cancelar exige escribir un email, el cliente irá directo al banco.
- [ ] **Aviso previo de renovación** en suscripciones anuales (7 días antes, obligatorio en varias jurisdicciones).
- [ ] **Términos de servicio aceptados con constancia**: fecha, versión, IP. Es la evidencia con la que se gana una disputa.
- [ ] **Logs de acceso por cliente.** "El usuario entró 47 veces y usó la función X" es lo que revierte una disputa.

**Respuesta al evento `charge.dispute.created`:**

1. Pausar automáticamente la cuenta en base de datos para frenar la acumulación de consumo.
2. Recopilar el paquete de evidencia: registro de accesos, TOS firmados, recibos enviados, comunicaciones con el cliente.
3. Responder dentro del plazo de la pasarela. Una disputa sin respuesta se pierde automáticamente.
4. Registrar la disputa en un contador y **alertar si la tasa mensual supera el 0,5%** — el umbral de alarma, no el de sanción.

---

## 5. DUNNING — RECUPERAR EL CHURN INVOLUNTARIO

Hasta el **20% de las cancelaciones no son decisiones del cliente**: son tarjetas caducadas, límites superados o tarjetas reemplazadas por robo o pérdida. Es el ingreso más barato de recuperar que existe.

- [ ] **Reintentos inteligentes** activados en la pasarela (reintenta en el día/hora estadísticamente mejor según el banco emisor).
- [ ] **Emails pre-expiración** automáticos 14 días antes de que caduque la tarjeta registrada.
- [ ] **Secuencia de dunning** tras el fallo: aviso inmediato → recordatorio a 3 días → aviso final a 7 días.
- [ ] **Periodo de gracia de 7 días** con acceso parcialmente limitado, **nunca borrado de datos**. Borrar datos por un impago de una semana convierte un problema de cobro en una crisis reputacional.
- [ ] **Actualizador automático de tarjetas** (card account updater) habilitado si la pasarela lo ofrece.
- [ ] Enlace de "actualizar método de pago" que funciona sin necesidad de iniciar sesión (token de un solo uso).

**Métrica a vigilar:** tasa de recuperación de dunning. Por debajo del 40% hay algo roto en la secuencia.

---

## 6. INTERNACIONALIZACIÓN DE COBROS

- [ ] Todos los timestamps de transacción, alta y vencimiento en **`TIMESTAMPTZ`, UTC absoluto**. Jamás hora local del servidor. Un cálculo de renovación con hora local rompe la facturación al cruzar husos o en cambios de horario.
- [ ] Importes como **enteros en la unidad mínima** (céntimos) con campo `currency` explícito. Nunca `float`.
- [ ] **Precios en moneda local** del cliente cuando se opera internacionalmente: mejora la conversión del checkout de forma significativa y reduce disputas por importes inesperados tras la conversión del banco.
- [ ] **Impuestos delegados a la pasarela** (Stripe Tax o equivalente). Programar lógica de IVA/GST/Sales Tax a mano es una fuente inagotable de errores y de responsabilidad fiscal.
- [ ] **Facturas con los datos fiscales obligatorios** de la jurisdicción del cliente (en la UE: NIF/VAT del cliente B2B, mecanismo de inversión del sujeto pasivo cuando aplique).
- [ ] Retención de facturas según obligación legal local, independiente de la política de borrado del producto.

---

## 7. UNIT ECONOMICS — QUE NO TE QUIEBRE UN USUARIO INTENSIVO

Casi todo el mundo conoce su gasto mensual total en APIs. Casi nadie conoce **el coste de servir a un cliente concreto**. En un SaaS con IA, un usuario intensivo en el plan más barato puede consumir en tokens varias veces lo que paga. El negocio se desangra en silencio mientras las métricas de crecimiento se ven bien.

### Pilar 1 — Instrumentación coste-por-función

Rastrear consumo de tokens (entrada y salida) y llamadas a APIs externas **por endpoint y por función**, con OpenTelemetry, Helicone, Langfuse o equivalente.

- Calcular el coste medio por invocación de cada función de cara al usuario.
- **Alerta automática cuando cualquier función supere los $0.10 por uso.** Ese umbral es la señal temprana de que el modelo de precios y el de costes se están separando.
- Etiquetar cada llamada con `org_id` y `plan` para poder agregar por cliente y por tier.

### Pilar 2 — Rentabilidad por usuario y por tier

Para cada nivel de precios:

```
Margen por usuario = ARPU − (cómputo + almacenamiento + tokens + APIs de terceros + comisión de pasarela)
```

- Calcular no solo la media, sino el **percentil 95**. La media esconde al usuario que te está costando dinero.
- **Bandera roja inmediata** en cualquier tier donde el coste del usuario intensivo supere el ARPU de ese tier.
- Cruzar con los entitlements definidos en el blueprint: si el límite de plan permite un consumo que supera el precio, el límite está mal puesto, no el precio.

### Pilar 3 — P&L mensual automatizado

Dashboard que se autopuebla desde la pasarela y el proveedor de hosting:

```
Ingreso bruto
− Reembolsos y disputas
= Ingreso neto
− Comisiones de pasarela (~2,9% + fijo por transacción)
− Hosting e infraestructura
− Tokens y APIs de IA
− Servicios de terceros (email, monitorización, almacenamiento)
= Margen bruto
```

Revisión mensual obligatoria. Un margen bruto que se degrada mes a mes con crecimiento de usuarios es la señal de que el modelo de costes no escala.

### Métricas de negocio a instrumentar desde el día 1

| Métrica | Por qué importa |
|---|---|
| MRR / ARR y su desglose (nuevo, expansión, contracción, churn) | Sin el desglose, el MRR agregado miente |
| Churn de ingresos vs. churn de logos | Perder un cliente grande ≠ perder cinco pequeños |
| Tasa de conversión trial → pago | El indicador más temprano de encaje producto-mercado |
| LTV / CAC | Por debajo de 3 el crecimiento pagado destruye valor |
| Meses de recuperación de CAC | Determina cuánto capital necesitas para crecer |
| Tasa de disputas | Umbral de alarma 0,5%, sanción 0,75% |
| Recuperación de dunning | Ingreso recuperado / ingreso fallido |
| Coste de infraestructura por usuario activo | Debe bajar con la escala; si sube, hay un problema arquitectónico |

---

## 8. FUNDAMENTOS FINANCIEROS

- **Cuenta bancaria de la empresa separada** de la personal del fundador. Innegociable desde el primer euro.
- **Clasificar costes:** fijos (servidores base, dominios, licencias) vs. variables (tokens por usuario, comisiones de pasarela, almacenamiento).
- **Fondo de contingencia** equivalente a 3 meses de coste mínimo de infraestructura. Un congelamiento de fondos por disputas no puede tumbar el servicio.
- **Precio basado en valor, no en coste.** Si el producto ahorra 20 horas mensuales valoradas en 1.000 €, cobrar 99 €/mes es una propuesta irresistible independientemente de que el coste de cómputo fuera de 3 €. El *cost-plus pricing* es el error de precios más común y el más caro.
- **Punto de equilibrio explícito:** cuántos clientes de pago cubren los costes fijos. Calcularlo **antes** de invertir un euro en publicidad.

---

## 9. AUDITORÍA DE INTEGRACIÓN EXISTENTE

Prompt de auditoría a aplicar sobre código ya escrito:

```markdown
Audita mi integración de pagos contra el estándar de producción:

1. WEBHOOKS: ¿el endpoint verifica la firma criptográfica con el secreto de webhook?
   ¿Recibe el cuerpo crudo sin parsear? ¿Deduplica por event.id? ¿Responde en <10s?
2. IDEMPOTENCIA: ¿toda operación de cargo lleva clave de idempotencia determinista
   derivada del dominio (no un UUID aleatorio por intento)?
3. APROVISIONAMIENTO: ¿el acceso se concede solo tras webhook verificado, nunca en
   el retorno del navegador?
4. ESTADOS: ¿están manejados los 7 eventos obligatorios? ¿El acceso se revoca al final
   del periodo pagado, no al cancelar?
5. DISPUTAS: ¿existe manejo de charge.dispute.created con pausa de cuenta y
   recopilación de evidencia?
6. DUNNING: ¿hay reintentos, avisos pre-expiración y periodo de gracia sin borrado de datos?
7. CLAVES: ¿claves live aisladas de dev/staging? ¿alguna clave en el histórico de git?
8. I18N: ¿timestamps en TIMESTAMPTZ UTC? ¿importes en enteros con currency explícito?
9. COSTES: ¿hay instrumentación de coste por invocación? ¿existe algún tier donde el
   coste del usuario del percentil 95 supere el ARPU?

Entrega: tabla de hallazgos con severidad (crítico / alto / medio), el código corregido
de cada hallazgo crítico, y la lista de lo que bloquea el paso a modo live.
```

---

## 10. FORMATO DE SALIDA OBLIGATORIO

1. **Estado del Red Lane Gate** — checklist de §1 con marcas reales, no asumidas.
2. **Matriz de eventos de webhook** — evento → handler → efecto en base de datos → test que lo cubre.
3. **Máquina de estados de suscripción** — diagrama y tabla de transiciones.
4. **Checklist anti-chargeback y de dunning** — con estado por ítem.
5. **Tabla de unit economics** — por tier: ARPU, coste medio, coste p95, margen, bandera.
6. **Bloqueantes para pasar a live** — lista explícita. Si está vacía, decirlo; si no, no se activa live.

**Regla de bloqueo final:** ningún cambio en código de pagos se da por entregado sin que un humano nombrado haya firmado el checklist del Red Lane Gate. La IA nunca es la última firma sobre dinero ajeno.

