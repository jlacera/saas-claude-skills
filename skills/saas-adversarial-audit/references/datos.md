# Base de Datos — Inyección, RLS, Rendimiento y Consistencia

---

## D1 — Consulta cruda construida con entrada de usuario (CRÍTICO)

**Síntoma.** El ORM es seguro. El único sitio donde se saltó el ORM no lo es. Un campo de búsqueda, un filtro, un parámetro de orden concatenado dentro de SQL crudo.

**Detección.**
```bash
grep -rn "queryRawUnsafe\|executeRawUnsafe\|\$queryRaw(\|\$executeRaw(" --include="*.ts" .
grep -rn "execute(f\"\|execute(\"SELECT.*%s\|+ user\|+ req\." --include="*.py" --include="*.ts" . | grep -i "select\|insert\|update\|delete"
```

**Prompt auditor.**
> Comprueba: (1) Localiza todos los usos de `$queryRaw`, `$queryRawUnsafe`, `$executeRaw`, `$executeRawUnsafe`. Marca las variantes `Unsafe` como CRÍTICO sin excepción. (2) Para cada llamada raw, determina si usa template literal etiquetado (seguro) o concatenación/interpolación de cadenas (inseguro). (3) Traza la entrada de usuario desde la ruta de API hasta la consulta. (4) Verifica la validación previa: tipo, longitud, lista blanca para valores enumerados. (5) ¿Puede esa consulta raw sustituirse por métodos nativos del ORM? Entrega la implementación segura de cada hallazgo.

---

## D2 — RLS desactivada por defecto (CRÍTICO)

**Síntoma.** En Postgres gestionado (Neon, Supabase, RDS) la Row Level Security **está apagada al crear la tabla**. Se crearon las tablas, se conectó la aplicación y se siguió adelante. Cualquiera con la clave anónima consulta todas las filas.

**Detección.**
```sql
SELECT tablename FROM pg_tables WHERE schemaname='public' AND rowsecurity = false;
SELECT schemaname, tablename, policyname, qual FROM pg_policies WHERE qual = 'true';
```
La primera consulta lista las tablas sin RLS. La segunda lista las políticas escritas como `USING (true)`, que son RLS activa y completamente inútil.

**Parche canónico.** RLS activa en toda tabla con datos de usuario, política por operación (`SELECT`/`INSERT`/`UPDATE`/`DELETE`), y `WITH (security_invoker = true)` en toda vista. Test automatizado en CI que intente leer datos de otro tenant y **falle explícitamente**.

---

## D3 — Consultas correctas y lentas (ALTO)

**Síntoma.** Las consultas funcionan. Escanean la tabla entera. Con 500 filas nadie lo nota; con 100.000 el proveedor empieza a estrangular por uso excesivo y la factura sube.

**Detección.**
```sql
EXPLAIN ANALYZE <consulta>;   -- buscar "Seq Scan" sobre tablas grandes
SELECT relname, seq_scan, idx_scan FROM pg_stat_user_tables ORDER BY seq_scan DESC LIMIT 20;
```

**Parche canónico.** Índice sobre toda columna usada en `WHERE`, `JOIN` u `ORDER BY` de una consulta en caliente. Índice compuesto que empiece por `tenant_id` en tablas multi-tenant. Y comprobar el patrón N+1: un bucle que consulta por cada elemento en lugar de una consulta con `IN`.

---

## D4 — Lectura desde réplica retrasada (MEDIO)

**Síntoma.** El usuario guarda un cambio, la interfaz recarga y muestra el valor antiguo. No es un bug de caché: es retraso de replicación. Aparece en cuanto se escala más allá de una única base de datos.

**Parche canónico.** Lectura tras escritura dirigida al primario dentro de la ventana de replicación (por sesión o por token de consistencia). Nunca resolverlo con un `setTimeout` en el frontend.

---

## D5 — Un campo de un cliente degrada a todos (MEDIO)

**Síntoma.** Se añadió una columna para un cliente concreto y las consultas del resto se ralentizaron. El esquema es compartido y una personalización contaminó la tabla común.

**Parche canónico.** Las personalizaciones por cliente viven en una columna `JSONB` de extensión o en un esquema por tenant, nunca como columnas nuevas en la tabla compartida. Si un cliente necesita un esquema propio, es una decisión de arquitectura documentada, no un `ALTER TABLE` de urgencia.
