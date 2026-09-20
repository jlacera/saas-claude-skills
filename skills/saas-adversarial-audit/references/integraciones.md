# Integraciones — Webhooks, Cron, Email y Backends Gestionados

---

## G1 — Webhook sin idempotencia (CRÍTICO)

**Síntoma.** Se cobró dos veces la misma tarjeta, se aprovisionó dos veces el mismo usuario, se envió dos veces el mismo correo. Todas las firmas eran válidas. Stripe, Clerk, Resend y GitHub **reintentan** los webhooks fallidos, y el handler verificó la firma pero nunca contempló duplicados.

**Prompt auditor.**
> Comprueba: (1) ¿Extrae y almacena el handler el ID de evento / clave de idempotencia antes de procesar? (2) ¿Hay comprobación de duplicado antes de ejecutar la lógica de negocio? (3) ¿Es correcto el orden: guardar ID primero, procesar después? (4) ¿Hay ventana de replay que rechace eventos más antiguos que un umbral definido? (5) ¿Devuelve HTTP 200 ante un duplicado? Devolver error provoca otro reintento. (6) ¿El almacén de idempotencia tiene backend apropiado (Redis con TTL, o restricción única en base de datos)? (7) ¿Los reintentos quedan libres de efectos secundarios duplicados?

**Parche canónico.** Restricción única sobre el ID de evento, insertar antes de procesar, ventana de replay de 24 horas, y 200 en el duplicado.

---

## G2 — Webhook sin verificación de firma (CRÍTICO)

**Síntoma.** El endpoint acepta cualquier POST. Quien conozca la URL envía un evento de pago falso y recibe producto gratis y facturación ficticia.

**Detección.**
```bash
grep -rn "webhook" --include="*.ts" app/api src/ | head -20
grep -rLn "constructEvent\|verifyHeader\|svix\|createHmac" $(grep -rl "webhook" --include="*.ts" app/api 2>/dev/null) 2>/dev/null
```

**Parche canónico.** `stripe.webhooks.constructEvent(rawBody, signature, secret)` sobre el **cuerpo crudo** (no el parseado), rechazo con 400 ante firma ausente o inválida, y cero aprovisionamiento basado en `success_url`.

---

## G3 — Cron sin secreto (CRÍTICO)

**Síntoma.** Un cron de Vercel es una ruta de API con un temporizador delante. La URL es adivinable. Limpieza de base de datos, lotes de correo y renovaciones de suscripción, disparables por cualquiera.

**Prompt auditor.**
> Comprueba: (1) Lista los cron jobs de `vercel.json`. (2) ¿Verifica cada handler la cabecera `Authorization` contra `CRON_SECRET`? Marca las rutas sin protección como CRÍTICO. (3) ¿Está `CRON_SECRET` definido en variables de entorno? (4) ¿Devuelve 401 ante ausencia o error? (5) ¿Son accesibles por petición HTTP directa sin el secreto? (6) ¿Hay rate limiting acorde a la frecuencia programada? (7) ¿Los timeouts son adecuados a la duración real del trabajo?

---

## G4 — Plantilla de email inyectable (CRÍTICO)

**Síntoma.** Alguien envió un correo de phishing desde tu dominio. SPF, DKIM y DMARC pasaron. La entrada del usuario entra sin sanitizar en la plantilla: un nombre con HTML se convierte en un enlace de phishing, entregado desde tu dominio verificado, indistinguible de un correo real tuyo.

**Impacto.** Para una empresa cuyo negocio es la reputación de dominio, esto no es un incidente de seguridad: es el negocio.

**Prompt auditor.**
> Comprueba: (1) ¿Se sanitizan los valores del usuario antes de insertarlos en la plantilla? (2) ¿Se aplica escapado o eliminación de HTML a todo contenido dinámico? (3) ¿Las plantillas usan inserción de HTML crudo o variables sin escapar? CRÍTICO. (4) ¿Los componentes renderizan el contenido del usuario como nodo de texto o como HTML? (5) ¿Hay validación de entrada en los campos que aparecen en correos? (6) ¿Puede el usuario controlar alguna parte del asunto, el remitente o el reply-to? CRÍTICO. (7) ¿Se prueban las plantillas con cargas de inyección?

**Prueba.** Enviar un correo de prueba con `<a href="https://evil.example">click</a>` en cada campo. Si se renderiza como enlace pulsable, la plantilla es inyectable.

---

## G5 — Admin SDK sin reglas de seguridad (CRÍTICO)

**Síntoma.** Las Cloud Functions usan el Admin SDK de Firebase. El Admin SDK **ignora por completo las reglas de seguridad**: tiene acceso irrestricto. La función toma entrada del usuario, construye una ruta o consulta con ella, y devuelve lo que sea que haya ahí.

**Parche canónico.** Toda función con Admin SDK valida identidad y propiedad manualmente, porque no hay ninguna capa debajo que lo haga. La ruta nunca se construye por concatenación con entrada del usuario.

---

## G6 — Suscripción en tiempo real sin filtro (CRÍTICO)

**Síntoma.** La consulta que alimenta la suscripción devuelve todas las filas. Cada cliente conectado recibe los datos de todos los demás, en tiempo real, ahora mismo.

**Prompt auditor.**
> Comprueba: (1) Lista las funciones de consulta que alimentan suscripciones. (2) ¿Filtra cada una por la identidad autenticada del contexto? Marca las no filtradas como CRÍTICO. (3) ¿El filtrado ocurre en servidor o en cliente? En cliente **no es seguridad**: el dato viaja igualmente al navegador y se ve en las herramientas de desarrollo. (4) ¿Hay consultas que devuelvan todos los registros sin comprobar propiedad? (5) ¿Verifican las mutaciones que el usuario autenticado es dueño del registro? (6) ¿Recibiría la suscripción del usuario A datos del usuario B?

**Prueba.** Abrir la aplicación en dos cuentas distintas, en dos navegadores. Si A ve algo de B, lo ven todos.
