# Identidad, Sesiones y OAuth

---

## I1 — JWT leído pero no verificado (CRÍTICO)

**Síntoma.** La aplicación decodifica el JWT para leer el rol. Nunca verifica la firma. El usuario decodifica su token en el navegador, cambia `"role": "user"` por `"role": "admin"`, lo vuelve a codificar y se promociona solo.

**Detección.**
```bash
grep -rn "jwt.decode\|jwtDecode\|atob(\|Buffer.from(.*base64" --include="*.ts" . | grep -i "token\|jwt"
```
Cualquier `decode` sin un `verify` correspondiente en el mismo camino de ejecución es el hallazgo.

**Prompt auditor.**
> Comprueba: (1) ¿Se verifica la firma del token con la clave pública o secreto del proveedor antes de leer cualquier claim? Marca como CRÍTICO si solo se decodifica. (2) ¿Se validan `exp`, `iss` y `aud`? (3) ¿Las decisiones de autorización se basan en claims del token o en una consulta al servidor? Los claims pueden ir por detrás del estado real tras una revocación. (4) ¿Se aceptan tokens con algoritmo `none` o con algoritmo elegido por el propio token?

**Parche canónico.** Verificación con el SDK oficial del proveedor en el servidor, algoritmo fijado explícitamente, y los permisos sensibles resueltos contra la base de datos, no contra el claim.

---

## I2 — Token de reset eterno (CRÍTICO)

**Síntoma.** Un enlace de restablecimiento de hace cuatro meses sigue funcionando. El usuario ha cambiado la contraseña dos veces. El enlace antiguo sigue dando acceso, y el segundo factor no cambia nada porque el enlace lo precede.

**Prompt auditor.**
> Comprueba: (1) ¿Tienen los tokens de reset un TTL? Marca la ausencia como CRÍTICO. (2) ¿Se invalidan tras el primer uso? Un token reutilizable permite al atacante resetear después de que el usuario ya lo hizo: CRÍTICO. (3) ¿Se invalidan los tokens anteriores al solicitar uno nuevo? (4) ¿Hay límite de peticiones por dirección de correo? (5) ¿Son criptográficamente aleatorios con al menos 32 bytes de entropía? (6) ¿Viaja el token fuera de la query string en peticiones GET? (7) ¿Un reset exitoso invalida todas las sesiones activas?

**Parche canónico.** TTL de 15 minutos, un solo uso, invalidación de los anteriores, tres solicitudes por email y hora, y cierre de todas las sesiones al completar el cambio.

---

## I3 — Autorización que comprueba identidad pero no propiedad (CRÍTICO)

**Síntoma.** El endpoint verifica que hay sesión válida. No verifica que el recurso pedido sea de quien lo pide. `GET /api/invoices/8842` devuelve la factura de otro cliente.

**Detección.**
```bash
grep -rn "params.id\|req.query.id\|params.userId\|input.id" --include="*.ts" app/api src/server | head -40
```
Para cada uno: ¿la consulta incluye `where: { id, tenantId: session.tenantId }` o solo `where: { id }`?

**Parche canónico.** El `tenantId` y el `userId` **siempre** salen de la sesión de servidor y **siempre** entran en la cláusula `where`. Nunca se aceptan como parámetro del cliente.

---

## I4 — Redirect URI abierto en OAuth (CRÍTICO)

**Síntoma.** Se añadió "Iniciar sesión con Google" y el redirect URI admite comodines o subdominios arbitrarios. Un atacante construye un enlace de login idéntico al real que devuelve el token a su servidor. El usuario ve la pantalla legítima de Google y no sospecha nada.

**Parche canónico.** Lista blanca exacta de URIs de redirección, sin comodines ni coincidencias por prefijo. Un registro por entorno.

---

## I5 — Código de autorización interceptable (ALTO)

**Síntoma.** El redirect URI está fijado y el parámetro `state` implementado. Eso detiene la falsificación de petición, pero no la interceptación del código de autorización en una red hostil: quien capture el código lo canjea antes que la aplicación.

**Parche canónico.** **PKCE** en todos los flujos, incluidos los de servidor confidencial. El código sin el `code_verifier` no vale nada para quien lo intercepte.

---

## I6 — Sesiones que nunca caducan ni se revocan (ALTO)

**Prompt auditor.**
> Comprueba: (1) ¿Caducan las sesiones por inactividad? (2) ¿Hay rotación de refresh token, y se detecta la reutilización de un refresh token ya consumido como señal de robo? (3) ¿Puede un usuario ver y cerrar sus sesiones activas? (4) ¿El cambio de contraseña, el cambio de email y la expulsión de un miembro de la organización invalidan las sesiones existentes? (5) ¿Las cookies llevan `HttpOnly`, `Secure` y `SameSite`?
