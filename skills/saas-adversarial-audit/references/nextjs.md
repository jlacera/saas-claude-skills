# Next.js — Fugas de Payload y Bypass de Autorización

---

## N1 — El Server Component serializa la fila completa (CRÍTICO)

**Síntoma.** El componente muestra nombre, email y foto. El payload RSC que llega al navegador contiene los veinte campos de la fila: hash de contraseña, flag de rol, token de facturación. Se leen abriendo la pestaña Network.

**Detección.**
```bash
grep -rn "findUnique\|findFirst\|findMany\|select \*" --include="*.tsx" app/ src/ 2>/dev/null
```
Cada consulta dentro de un Server Component sin cláusula `select` explícita es un hallazgo.

**Prompt auditor.**
> Eres un auditor de fuga de payload en React Server Components. Comprueba: (1) Lista los Server Components que consultan base de datos o API. (2) ¿Cada uno selecciona solo los campos que renderiza, o pasa la fila completa? Marca el paso de fila completa como CRÍTICO. (3) ¿Se usan objetos de transferencia (DTO) en cada frontera de componente? (4) ¿Algún componente padre pasa un objeto completo que el hijo solo usa parcialmente? (5) ¿Hay campos sensibles (hash de contraseña, tokens, IDs internos, datos de facturación) presentes en las props de algún componente? Para cada hallazgo, entrega la selección de campos corregida.

**Parche canónico.** `select` explícito en cada consulta y un DTO por frontera. La regla mental: *el payload RSC es público*.

---

## N2 — El matcher del middleware no cubre lo que crees (CRÍTICO)

**Síntoma.** "La autenticación está en el middleware, una línea protege todas las rutas." No es cierto: el `matcher` excluye rutas de API, y una barra final, un carácter doble-codificado o un prefijo de ruta cambian cómo se evalúa. La petición pasa de largo.

**Detección.**
```bash
cat middleware.ts 2>/dev/null || cat src/middleware.ts 2>/dev/null
grep -rn "matcher" middleware.ts src/middleware.ts 2>/dev/null
```

**Prompt auditor.**
> Comprueba: (1) ¿El `matcher` incluye TODAS las rutas que requieren autenticación, incluidas las de API? Marca las exclusiones como CRÍTICO. (2) ¿Alguna ruta protegida es accesible añadiendo barra final, doble codificación o un prefijo? (3) ¿El middleware valida el token de sesión contra el almacén de sesiones, o solo comprueba que la cookie existe? Comprobar existencia acepta cookies caducadas o forjadas. (4) ¿Hay comprobación de autorización en servidor en las rutas de API, independiente del middleware? (5) ¿Los Server Components obtienen datos sin verificación propia? (6) ¿El matcher maneja rutas internacionalizadas y route groups? (7) ¿Se puede usar una ruta de archivo estático para esquivar el matcher?

**Parche canónico.** El middleware es una **capa de conveniencia, no un límite de seguridad**. Cada route handler y cada Server Component que lea datos comprueba la sesión por su cuenta.

---

## N3 — Server Actions filtrando credenciales al bundle (CRÍTICO)

**Síntoma.** El archivo exporta Server Actions que consultan la base de datos y, además, componentes de cliente. El proceso de build analiza los imports y arrastra al bundle del navegador lo que la cadena de importación toque, incluidas variables de entorno.

**Detección.**
```bash
grep -rln "use server" app/ src/ | xargs grep -ln "use client" 2>/dev/null
grep -rn "process.env" --include="*.tsx" app/ src/ | grep -v "NEXT_PUBLIC_"
npm run build && grep -rl "sk_live\|postgres://\|SUPABASE_SERVICE" .next/static/ 2>/dev/null
```
La última línea es la prueba definitiva: si encuentra algo, el secreto ya está publicado y debe rotarse.

**Parche canónico.** Server Actions en archivos propios con `"use server"` en la primera línea y sin ningún export de cliente. Nunca importar un módulo de servidor desde un componente marcado `"use client"`.

---

## N4 — El error de producción cuenta la arquitectura (ALTO)

**Síntoma.** Un usuario pulsa un enlace roto y ve el nombre de la base de datos, la ruta del archivo en el servidor y la consulta que falló.

**Detección.**
```bash
grep -rn "error.message\|error.stack\|JSON.stringify(error" --include="*.ts" --include="*.tsx" app/ src/
```

**Parche canónico.** Dos caminos separados por entorno. En producción: identificador de correlación al usuario, detalle completo solo al sistema de observabilidad. El usuario recibe un código, no una pista.

---

## N5 — Panel de administración sin pantalla de login (CRÍTICO)

**Síntoma.** `/admin` existe y funciona porque "solo yo conozco la URL". Todos los escáneres automatizados de internet ya la encontraron.

**Detección.**
```bash
find app src -type d -name "admin" -o -type d -name "dashboard" | head
```
Para cada uno: ¿hay verificación de sesión **y de rol** en el layout del servidor, no en un `useEffect` del cliente?

**Parche canónico.** Comprobación de rol en el layout de servidor del segmento, redirección antes de renderizar nada, y cero dependencia de la oscuridad de la URL.

---

## N6 — Secretos con prefijo público (CRÍTICO)

**Detección.**
```bash
grep -rn "NEXT_PUBLIC_" .env* | grep -iE "secret|key|token|password|service"
```
Cualquier variable `NEXT_PUBLIC_` con nombre de secreto ya está en el navegador de todos los visitantes. No se "arregla" renombrando: se rota.
