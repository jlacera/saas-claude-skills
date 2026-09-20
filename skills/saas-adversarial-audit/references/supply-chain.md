# Cadena de Suministro, Navegador y DNS

---

## S1 — Dependencia alucinada o suplantada (CRÍTICO)

**Síntoma.** El agente recomendó un paquete cuyo nombre difiere en un carácter del real. Se instaló. Lleva desde entonces enviando las variables de entorno a un servidor desconocido. El vector se llama *slopsquatting*: los modelos alucinan nombres de paquete verosímiles y los atacantes los registran.

**Detección.**
```bash
npm ls --all 2>/dev/null | head -50
npm audit --audit-level=moderate
cat package.json | grep -E "\"\^|\"~"   # rangos abiertos
```

**Parche canónico.** Antes de instalar cualquier paquete sugerido por un modelo: verificar que existe en el registro oficial, que tiene mantenimiento activo y descargas coherentes con su supuesta popularidad, y que el repositorio enlazado es real. Fijar versión exacta y hash en el lockfile. Prohibido `npm install` de un nombre que salió de una respuesta de IA sin esta comprobación.

---

## S2 — Script de terceros con privilegios totales (ALTO)

**Síntoma.** Se añadió un widget de chat, un píxel de analítica o un chatbot con una etiqueta `<script>`. Ese script se ejecuta con los mismos privilegios que tu propio código: lee cada campo de formulario, cada pulsación de tecla y cada token en el almacenamiento del navegador. Incluidas las contraseñas.

**Parche canónico.** Content Security Policy restrictiva con lista blanca de orígenes. Subresource Integrity (`integrity` + `crossorigin`) en todo script externo con versión fijada. Los scripts de terceros nunca se cargan en páginas de login, checkout o gestión de credenciales. Revisión periódica: cada etiqueta `<script>` externa es un proveedor con acceso total a la sesión de tus usuarios.

---

## S3 — CORS abierto a todo el mundo (ALTO)

**Síntoma.** El frontend no hablaba con el backend, la primera respuesta de internet decía "permite todos los orígenes", y ahí quedó. Eso autoriza a cualquier página del planeta a llamar a tu API con las credenciales del visitante.

**Detección.**
```bash
grep -rn "Access-Control-Allow-Origin.*\*\|origin: *['\"]\*\|cors()" --include="*.ts" --include="*.js" --include="*.py" .
```

**Parche canónico.** Lista blanca explícita de orígenes por entorno. `credentials: true` con `origin: "*"` es una combinación que los navegadores rechazan precisamente porque no tiene ningún uso legítimo.

---

## S4 — Subdominio colgante (CRÍTICO)

**Síntoma.** Se levantó un entorno de staging o una landing de prueba en una plataforma de terceros. El proyecto terminó y la aplicación se eliminó. El registro DNS sigue apuntando allí. Cualquiera puede reclamar ese recurso en la plataforma y quedarse con un subdominio **tuyo**, con tu certificado y tu reputación.

**Relevancia alta** para cualquier agencia que cree y destruya entornos de cliente de forma continua.

**Detección.**
```bash
# Para cada subdominio en el DNS:
dig +short staging.ejemplo.com
curl -sI https://staging.ejemplo.com | head -3   # buscar 404 de plataforma: "no such app", "project not found"
```

**Parche canónico.** El borrado del registro DNS forma parte del procedimiento de cierre de proyecto, no de la limpieza posterior. Inventario de subdominios revisado trimestralmente. Orden correcto: primero se borra el DNS, después el recurso.

---

## S5 — SSRF hacia el servicio de metadatos (CRÍTICO)

**Síntoma.** El agente o el backend obtiene URLs a partir de entrada del usuario. Un atacante entrega una URL que apunta al servicio de credenciales de la nube. El proceso, que corre dentro de la infraestructura, la obtiene y devuelve las credenciales temporales del rol de ejecución.

**Parche canónico.** Lista negra de rangos resueltos, no de cadenas: `127.0.0.0/8`, `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `169.254.0.0/16`, `::1`, `fc00::/7`. La validación se hace **después** de resolver el DNS y se repite tras cada redirección, porque un dominio público puede resolver a una IP privada y una redirección puede llevar allí. Solo esquemas `http` y `https`. Preferible: proxy de salida dedicado con lista blanca de destinos.
