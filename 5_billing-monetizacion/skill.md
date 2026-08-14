# 💳 MONETIZACIÓN, BILLING & STRIPE OPERACIONAL: REGLAS DE CONTROL TRANSACCIONAL Y UNIT ECONOMICS

## `.claude/skills/billing-monetizacion/SKILL.md`

Esta guía operativa gobierna la integración financiera con pasarelas de pago (Stripe) y el monitoreo económico del negocio para garantizar flujos transaccionales seguros, evitar fraudes y mantener márgenes de rentabilidad saludables frente al consumo de APIs de IA.

---

## SECCIÓN I: LAS 4 REGLAS DE ORO DE BILLING

Antes de cobrar el primer dólar en un entorno en vivo, la infraestructura de pagos debe cumplir sin excepciones con cuatro pilares de seguridad transaccional:

### 1. Firma Criptográfica de Webhooks
Está estrictamente prohibido procesar activaciones de cuenta basándose en redirecciones del lado del cliente como `success_url`. Toda acción de alta o acreditación de fondos debe ejecutarse de forma reactiva al recibir un webhook directo verificado de forma criptográfica usando la clave secreta oficial:
```typescript
stripe.webhooks.constructEvent(rawBody, signature, process.env.STRIPE_WEBHOOK_SECRET);
```
Toda solicitud de webhook que carezca de firma válida o devuelva un hash incorrecto debe rechazarse explícitamente devolviendo un error HTTP `400 Bad Request`.

### 2. Aprovisionamiento Exclusivamente Asíncrono
La asignación de roles, planes o créditos de usuario en la base de datos se ejecuta exclusivamente en el backend tras el procesamiento del evento verificado del webhook (`checkout.session.completed`, `invoice.paid`). El frontend actúa únicamente como un visor del estado de la base de datos.

### 3. Idempotencia Transaccional
Para evitar cobros duplicados accidentales causados por reintentos automáticos tras micro-caídas de red, toda transacción de cobro iniciada desde la aplicación debe enviar obligatoriamente un identificador único UUID en la cabecera de Stripe:
```typescript
{ idempotencyKey: '7b9b7754-080c-43f7-91f8-002d2948c2b1' }
```

### 4. Aislamiento Absoluto de Claves
El sistema debe mantener una separación rígida de secretos por entorno. Las claves de prueba `sk_test_...` y secrets de webhook de prueba se aíslan en desarrollo y staging, mientras que las claves de producción `sk_live_...` permanecen confinadas al entorno de hosting seguro de producción y protegidas mediante políticas de mínimo privilegio.

---

## SECCIÓN II: CONTROL ECONÓMICO Y UNIT ECONOMICS IA

La viabilidad de un SaaS nativo de IA depende de un control milimétrico del consumo de tokens y llamadas de infraestructura para evitar "quiebras silenciosas" por consumo abusivo de usuarios intensivos:

### 1. Instrumentación Costo-por-Función (La Alerta de los $0.10)
*   **Monitoreo Activo:** Integrar herramientas de observabilidad de costes (OpenTelemetry, Helicone, Langfuse) para registrar el número exacto de tokens de entrada/salida y llamadas API de cada endpoint.
*   **Circuit Breaker:** Configurar una alerta de infraestructura automática cuando cualquier funcionalidad interactiva de cara al usuario supere un coste promedio de **$0.10 USD por invocación**.

### 2. Modelado de Rentabilidad por Usuario (ARPU vs. CPU)
*   El equipo evaluará mensualmente el margen unitario por cada nivel de precios (*pricing tier*) aplicando la fórmula:
    $$	ext{Margen por Usuario} = 	ext{Ingreso Promedio por Usuario (ARPU)} - 	ext{Costo de Procesamiento Unitario (CPU)}$$
*   Se considera **Bandera Roja** inmediata si el consumo de un usuario intensivo (*power user*) en un tier ilimitado o básico excede el ARPU asignado, forzando la re-evaluación de los límites del plan.

### 3. Spend Caps Duros en Proveedores
*   Configurar límites presupuestarios estrictos (Hard Spend Caps) mensuales en las cuentas de OpenAI, Anthropic, Replicate y hosting en la nube. Un bucle infinito de ejecución de un agente autónomo puede quemar miles de dólares en una madrugada si solo se cuenta con alertas informativas por correo.

---

## SECCIÓN III: PROTOCOLO ANTI-CHARGEBACK Y GESTIÓN DE DUNNING

### Prevención de Contracargos (Umbral Crítico del 0.75% de Disputas)
Si la tasa de disputas de un SaaS excede el **0.75%**, las redes de pago clasifican la cuenta como negocio de alto riesgo, procediendo a congelar fondos de manera preventiva. Mitigación obligatoria:
*   **Descriptor Bancario Claro:** Configurar un descriptor de cargo de tarjeta transparente (ej. `SEOSYX.COM*PLAN` o `HOTELBOX.NET*AI`), evitando el nombre de la empresa matriz jurídica que confunda al cliente en su extracto bancario.
*   **Emails de Recibo Detallados:** Envío automático del desglose de compra tras cada pago e integración visible de un botón de cancelación en un solo clic dentro del portal del cliente.
*   **Auto-Pausa en Disputas:** Al capturar el evento de webhook `charge.dispute.created`, el sistema pausará automáticamente la cuenta de usuario para detener el consumo de infraestructura y recopilará los logs de acceso como evidencia de defensa.

### Estrategia de Dunning (Gestión de Tarjetas Fallidas)
Hasta un **20% de las cancelaciones** de un SaaS son involuntarias. El sistema debe estructurar un flujo de recuperación de 3 pasos:
1.  **Stripe Smart Retries:** Habilitar el motor de IA de Stripe para reintentar transacciones fallidas en los mejores días y horas estadísticas según el banco emisor.
2.  **Emails Pre-Expiración:** Secuencia de avisos automáticos a clientes 14 días antes de que su tarjeta expire de forma activa.
3.  **Período de Gracia (7 Días):** Al fallar un cobro, el cliente entra en un período de gracia de 7 días con limitaciones de acceso parciales en lugar de borrar sus datos o rescindir el servicio inmediatamente.

---

## SECCIÓN IV: INTERNACIONALIZACIÓN DE COBROS Y TAXES

*   **Zonas Horarias UTC:** Todos los vencimientos, ciclos de cobro mensual y límites de cuota se calculan y guardan en base de datos bajo el formato `TIMESTAMPTZ` (UTC absoluto). Nunca usar hora local del servidor.
*   **Adaptive Pricing:** Activar la conversión automática multidivisa de Stripe para mostrar los precios en la moneda local del comprador (USD, EUR, GBP, MXN), mejorando la conversión del checkout en un 15-20%.
*   **Cálculo Impositivo Automatizado:** Delegar el cálculo del IVA, GST o Sales Tax local a herramientas nativas como **Stripe Tax** para evitar la programación de lógicas tributarias manuales propensas a errores.