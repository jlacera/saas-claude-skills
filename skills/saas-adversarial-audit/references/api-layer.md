# Capa de API — Validación, Autorización y Superficie Expuesta

---

## A1 — Validación solo en cliente (CRÍTICO)

**Síntoma.** El formulario valida con Zod. El endpoint acepta cualquier cosa. El atacante no usa el formulario: llama directamente a la API con cadenas vacías, precios negativos y campos inventados.

**Detección.**
```bash
grep -rln "zodResolver\|useForm" --include="*.tsx" . | head
grep -rLn "safeParse\|\.parse(" app/api src/app/api pages/api 2>/dev/null
```

**Prompt auditor.**
> Comprueba: (1) Identifica los esquemas Zod usados en componentes de formulario. (2) Localiza la ruta de API correspondiente a cada uno. (3) ¿La ruta valida el cuerpo con Zod ANTES de procesar? Marca las rutas sin validar como CRÍTICO. (4) ¿El esquema del servidor usa `.strict()` para rechazar campos inesperados? (5) ¿Hay divergencias entre el esquema de cliente y el de servidor? (6) ¿Hay desajustes de coerción de tipos (string numérico aceptado donde se espera número)? (7) ¿Las subidas de archivo se validan en servidor (tipo real, tamaño, extensión)?

**Parche canónico.** Un único esquema compartido, importado por ambos lados, con `.strict()` en el servidor. El formulario captura errores; el servidor captura ataques.

---

## A2 — Asignación masiva (CRÍTICO)

**Síntoma.** El handler de actualización de perfil pasa el `body` entero al ORM. El atacante añade `"role": "admin"`, `"credits": 99999` o `"priceOverride": 1`. Ninguna revisión automatizada lo marca porque el código es correcto: hace exactamente lo que dice.

**Detección.**
```bash
grep -rn "\.\.\.body\|data: body\|data: req.body\|...req.body\|Object.assign" --include="*.ts" app/api src/ pages/api 2>/dev/null
```

**Parche canónico.** Lista blanca explícita de campos actualizables. Nunca un spread del cuerpo de la petición hacia el ORM. Los campos de privilegio (`role`, `plan`, `credits`, `verified`, `tenant_id`) solo se escriben desde código de servidor que ya verificó la autorización para hacerlo.

---

## A3 — Procedimientos tRPC sin middleware (CRÍTICO)

**Síntoma.** tRPC hace que una llamada de red parezca una llamada a función local. Sigue siendo HTTP: todo procedimiento es alcanzable desde fuera. Los nuevos procedimientos no heredan nada por defecto y acaban junto a los protegidos, sin protección.

**Detección.**
```bash
grep -rn "publicProcedure\|protectedProcedure\|t.procedure" --include="*.ts" src/server server/ 2>/dev/null | sort | uniq -c
```

**Prompt auditor.**
> Comprueba: (1) Lista todos los procedimientos del router. ¿Cada uno tiene middleware de autorización? Marca los desprotegidos como CRÍTICO. (2) ¿Existe un procedimiento base protegido del que hereden los nuevos? (3) ¿Los procedimientos protegidos verifican **propiedad del recurso**, no solo autenticación? (4) ¿Puede el usuario A acceder a los datos del usuario B cambiando un parámetro de ID? CRÍTICO. (5) ¿Las mutaciones comprueban permisos de escritura? (6) ¿Las suscripciones validan acceso al recurso suscrito? (7) ¿El orden del middleware es consistente?

**Parche canónico.** `protectedProcedure` como base por defecto y `publicProcedure` como excepción explícita que hay que justificar. La autorización debe ser lo que cuesta trabajo desactivar, no lo que cuesta trabajo activar.

---

## A4 — GraphQL con introspección abierta (CRÍTICO)

**Síntoma.** Una petición devuelve el esquema completo: tipos, campos, argumentos, relaciones. Con el esquema en la mano se construyen consultas anidadas de cinco niveles que devuelven gigabytes o tumban el servidor.

**Prompt auditor.**
> Comprueba: (1) ¿Está la introspección activa en producción? CRÍTICO. (2) ¿Hay límite máximo de profundidad de consulta? (3) ¿Hay análisis de complejidad o coste que impida consultas caras? (4) ¿Los mensajes de error incluyen sugerencias de campo o pistas del esquema? CRÍTICO: revelan nombres válidos de uno en uno. (5) ¿Hay rate limiting sobre el endpoint? (6) ¿Hay autorización a nivel de resolver por rol? (7) ¿Está limitado el batching de consultas?

---

## A5 — Endpoints mutantes sin firma ni versión (ALTO)

**Síntoma.** Cualquiera que conozca la URL puede enviar una petición forjada a un endpoint que modifica estado. Y cuando haya que cambiar el contrato, no hay forma de hacerlo sin romper a los clientes existentes.

**Parche canónico.** Firma HMAC sobre método + ruta + cuerpo + timestamp en endpoints mutantes de integración, con ventana de validez corta para impedir replay. Versionado por ruta (`/api/v1/...`) desde el primer día: añadir versión después es una migración, tenerla desde el inicio es gratis.

---

## A6 — Endpoints de autenticación sin rate limit en el borde (ALTO)

**Síntoma.** El endpoint de login recibió 14.000 peticiones esta noche y ninguna era de un usuario real. Credential stuffing contra una lista de credenciales filtradas.

**Parche canónico.** Límite en el borde (antes de llegar a la aplicación), por IP **y** por identificador de cuenta, con backoff progresivo. Tres intentos de reset por email y hora. El límite por IP solo no basta: una botnet rota IPs pero ataca la misma cuenta.
