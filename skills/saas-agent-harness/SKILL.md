---
name: saas-agent-harness
description: >
  Harness engineering for AI coding agents on a SaaS codebase: how to build
  and measure the scaffolding around the model (CLAUDE.md and AGENTS.md as a
  table of contents, docs as the knowledge base, deterministic hooks and
  architecture linters instead of prose rules, context and compaction
  discipline, subagent topology, structured memory, long-running sessions
  with progress files and feature lists, verification loops, harness evals,
  observability and token cost). Use when setting up or tuning CLAUDE.md,
  AGENTS.md, hooks, subagents, memory or evals, when an agent loses context,
  loops, ignores rules or burns tokens, when planning multi-hour autonomous
  runs, and when the user says "harness", "andamiaje", "contexto", "hooks",
  "subagentes", "memoria del agente", "compactacion", "evals del agente",
  "el agente se pierde", "sesiones largas" or "Ralph loop". Skill content is
  in Spanish.
---

# SaaS Agent Harness — Ingeniería del Andamiaje

> **Idea central.** El modelo es una parte del resultado; el resto lo pone el *harness*: herramientas, contexto, controles, orquestación, memoria y medición. El equipo de LangChain pasó del puesto 30 al 5 en Terminal Bench 2.0 sin cambiar de modelo, solo cambiando el harness (sep. 2026). Lo que esta skill define es cómo construir ese andamiaje para un SaaS y, sobre todo, cómo saber si funciona.

**Relación con el resto del plugin.** `saas-agent-rules` dice *qué* debe hacer el agente (leyes, carriles, revisor independiente). `saas-architecture-blueprint` §5 dice *dónde* viven los ficheros de `.claude/`. Esta skill dice *cómo* se construye, se mide y se mantiene el andamiaje que hace cumplir lo anterior sin depender del criterio del modelo.

**Fuentes de las que parte (verificadas el 2026-11-04):** Anthropic, *Effective harnesses for long-running agents* (26-11-2025); OpenAI, *Harness engineering* (feb. 2026); estudio de código fuente de once harnesses (arXiv 2609.00006); estudio exploratorio sobre 2.853 repos (arXiv 2602.14690); Marmelab, *The state of AI harness engineering 2026* (24-09-2026).

---

## 1. LOS SIETE SUBSISTEMAS

Todo harness de agente de código tiene estas piezas; la decisión por defecto para un SaaS va en la tercera columna.

| Subsistema | Qué resuelve | Decisión por defecto |
|---|---|---|
| **Bucle** | Cuándo para, cuándo pide ayuda, cómo reintenta | Para en check determinista (tests, lint, smoke), nunca en "parece bien". Tope de iteraciones y de tokens por tarea. |
| **Herramientas** | Qué puede tocar el agente | Las mínimas: pocas herramientas bien descritas rinden más y cuestan menos que muchas. Un subagente solo recibe las suyas. |
| **Contexto** | Qué sabe al empezar y cómo no se ahoga | `CLAUDE.md` corto como índice; detalle en ficheros bajo demanda; estado en disco, no en el prompt. |
| **Controles** | Qué no puede hacer aunque quiera | Hooks y linters que bloquean; la prosa solo explica el porqué. |
| **Orquestación** | Cuándo delegar y en cuántos | Un agente hasta que el contexto no da más; subagentes aislados con herramientas restringidas; máximo 4 traspasos por tarea. |
| **Memoria** | Qué sobrevive a la sesión | Ficheros estructurados en el repo con dueño (causa raíz + regla de prevención), nunca volcados de conversación. |
| **Medición** | Cómo se sabe que el harness mejora | 20-50 tareas congeladas, antes/después; trazas OpenTelemetry; coste por tarea completada. |

---

## 2. CONTEXTO: EL RECURSO ESCASO

1. **`CLAUDE.md` es un índice, no un manual.** Entre 100 y 200 líneas: comandos de build y test, convenciones no deducibles del código, límites, y enlaces al detalle. El resto va a `docs/` (base de conocimiento) y a skills que se cargan cuando el tema aparece. Un `CLAUDE.md` largo se paga en cada turno y degrada todas las respuestas.
2. **`AGENTS.md` para equipos con varios agentes.** Lo leen Codex, Cursor, Copilot y Gemini CLI; Claude Code lo lee desde la 2.1.277 solo si no hay `CLAUDE.md`. Un `CLAUDE.md` que contenga `@AGENTS.md` sirve a todos sin duplicar.
3. **El estado vive en ficheros, no en el prompt.** Plan, progreso, decisiones y hallazgos se escriben en disco (`PROJECT_STATE.md`, `docs/adr/`, fichero de progreso). Así sobreviven a la compactación y a la sesión siguiente.
4. **Carga diferida siempre.** Esquemas de BD, documentación de APIs y bases vectoriales se consultan cuando hacen falta, nunca al arrancar.
5. **Compactación con cuidado.** Antes de compactar, volcar a disco lo que no puede perderse; después, releer el fichero de progreso. No confiar en que el resumen conserve los detalles.
6. **Contexto generado por máquina: medir antes de adoptar.** Un estudio de ETH Zúrich encontró que los ficheros de contexto autogenerados reducían el éxito frente a no tener ninguno y subían el coste. Se escriben a mano, cortos, y se miden (§8).

---

## 3. REGLAS MECÁNICAS, NO PROSA

Solo alrededor del 4% de las reglas de seguridad escritas en `CLAUDE.md` públicos tienen detrás un control que las haga cumplir. Una regla sin control es una esperanza.

| Regla que se suele escribir | Control que la hace real |
|---|---|
| "No ejecutes comandos destructivos" | Hook `PreToolUse` que bloquea `rm -rf`, `git push --force`, `--no-verify`, `DROP`, `sudo` |
| "Respeta la arquitectura por capas" | Linter propio (reglas de import, `dependency-cruiser`, `ruff` con reglas por carpeta) en CI |
| "Pasa el formateador" | Hook `PostToolUse` tras cada edición |
| "No toques pagos sin revisión" | Gate StampHog de `saas-security-workflow` §7 que bloquea el merge |
| "No commitees secretos" | Hook pre-commit con detector de secretos |
| "Mantén la documentación al día" | Agente periódico de *doc-gardening* que abre PR con las desviaciones |

**Higiene del harness.** Cada control lleva escrito su motivo y una condición de caducidad (qué tendría que pasar para quitarlo). Los controles que nadie recuerda por qué existen son los que acaban desactivados "para que pase el CI".

**Permisos.** Un sistema de permisos estructurado (listas de herramientas y comandos permitidos por contexto) rinde mejor que reglas de confianza en prosa. Dato a tener en cuenta: los usuarios que pre-escribieron reglas de permiso bloquearon 20 puntos menos de acciones malas que los que aprobaban acción por acción; las reglas pre-escritas se revisan como código y se miden.

---

## 4. SESIONES LARGAS (HORAS, VARIAS VENTANAS DE CONTEXTO)

Patrón de Anthropic para trabajo autónomo que no cabe en una sesión:

1. **Agente inicializador (primera sesión).** Prepara el entorno: `init.sh` que arranca el servidor de desarrollo, `claude-progress.txt` vacío, `feature_list.json` con todas las funcionalidades de extremo a extremo y `passes: false`, commit inicial.
2. **Agente de código (sesiones siguientes).** Al arrancar: ejecuta `init.sh`, lee `claude-progress.txt` y `git log`, hace una comprobación básica de que lo anterior sigue funcionando, y solo entonces toma la siguiente funcionalidad.
3. **`feature_list.json` es contrato.** El agente solo puede cambiar el campo `passes`; no borra ni reescribe funcionalidades. Marca `passes: true` solo tras probar la funcionalidad como un usuario, con navegador real (Puppeteer o Playwright MCP), no por "los tests pasan".
4. **Commits como puntos de control.** Mensajes descriptivos tras cada avance; si algo se rompe, se vuelve al último commit bueno en vez de arreglar hacia delante.
5. **Estado limpio al cerrar.** Código listo para mergear, sin bugs conocidos, progreso escrito. La sesión siguiente arranca con contexto vacío: todo lo que no esté en disco o en git no existe.

**Adaptación a Claude Code (noviembre de 2026):** cada ejecución larga en su *worktree* (`claude --worktree`); los *scheduled tasks* en la nube sustituyen al humano que relanza la sesión; la memoria automática del proyecto no reemplaza al fichero de progreso, lo complementa.

---

## 5. VERIFICACIÓN: EL BUCLE QUE PARA SOLO

- **Criterio de parada determinista.** El bucle itera hasta que un check externo pasa: tests, tipado, lint, smoke test, captura comparada. El "Ralph loop" (repetir el mismo prompt hasta que el check pase) funciona precisamente porque el criterio no lo pone el modelo.
- **El evaluador no ve la justificación.** Quien evalúa recibe solo la especificación, los tests y el diff. Es la misma Ley 6 de `saas-agent-rules`: el sesgo que se quiere eliminar es la explicación del autor.
- **Dar al agente la aplicación corriendo.** Servidor por copia de trabajo, navegador real, logs consultables (una pila de logging desechable por entorno). Un agente que no puede ejecutar lo que escribe solo puede opinar.
- **Convertir lo verificado en smoke test.** Cada comprobación manual que funcionó se guarda como test; la siguiente sesión la hereda.

---

## 6. SUBAGENTES Y ORQUESTACIÓN

- **Aislado o bifurcado.** Un subagente *aislado* recibe un brief y sus herramientas: barato, sin ruido. Uno *bifurcado* hereda la conversación: útil cuando el matiz importa, caro. Elegir por tarea, no por costumbre.
- **Planificador, generador, evaluador.** Tres roles, tres contextos, herramientas distintas. El evaluador no es el generador (§5).
- **Límites medidos.** Más de cuatro traspasos entre agentes casi siempre acaba en fallo (Microsoft). Un equipo de cuatro roles apenas superó a un agente solo (72,2% frente a 71,8%). Un agente revisor bajó el éxito un 8% en una ablación: el revisor sirve para seguridad en Carril Rojo, no para subir el porcentaje de tareas resueltas.
- **Herramientas por subagente.** Cada subagente recibe solo las que necesita; el de lectura no escribe, el de escritura no despliega.
- **Presupuesto explícito.** Todo abanico de subagentes (`Workflow`, `Agent`) lleva tope de tokens y de número de agentes antes de lanzarse. Sin presupuesto no se lanza.

---

## 7. MEMORIA

- **Estructurada, no transcrita.** Cada entrada: qué pasó, causa raíz, regla de prevención, fecha, dueño. Un directorio del repo (`docs/memory/` o el que fije el proyecto), revisable en PR.
- **Una memoria, un hecho.** Nada de ficheros "varios"; lo que no se puede resumir en un hecho no es memoria, es un log.
- **Caducidad.** Lo que nombra ficheros, flags o versiones se verifica antes de aplicarse; lo que ya no es cierto se borra, no se acumula.

---

## 8. EVALS DEL HARNESS

El 60% de los repos con harness no tienen ni un test ni un eval del harness; los harnesses se degradan solos cuando el modelo cambia (*harness rot*).

1. **Congelar 20-50 tareas reales** del proyecto (bugs resueltos, funcionalidades pequeñas) con su criterio de éxito automático.
2. **Medir antes y después** de cada cambio de `CLAUDE.md`, hooks, skills o modelo. Sin medición, un cambio de harness es una opinión.
3. **Dos tipos de caso.** Donde la regla o skill debe dispararse y donde **no** debe hacerlo; los falsos positivos cuestan tanto como los negativos.
4. **Plugins y skills:** `claude plugin eval` ejecuta cada caso con y sin el plugin y da la diferencia; cuesta llamadas reales, así que se fija presupuesto y se pinan los modelos en CI.
5. **Coste por tarea completada**, no por petición: entrada, caché, salida y reintentos divididos por tareas resueltas. Una petición más barata que necesita más vueltas no es más barata.

---

## 9. OBSERVABILIDAD Y COSTE

- **Trazas:** OpenTelemetry desde Claude Code, o un `metrics.jsonl` local con tarea, tokens, herramientas y resultado. Sin trazas no hay evals creíbles.
- **Qué se dispara:** hook que registra qué skill o regla se activó y en qué tarea; es la única forma de saber si una skill está muerta.
- **Esfuerzo por tarea:** `effort` bajo en subagentes y triaje, alto en arquitectura y auditoría; nunca ordenar al modelo que piense menos.
- **Superficie mínima:** cada herramienta y skill expuesta cuesta tokens en cada turno. Lo que no se usa en un mes se retira.

---

## 10. ANTIPATRONES

| Antipatrón | Por qué falla | Qué hacer |
|---|---|---|
| `CLAUDE.md` de 800 líneas | Se paga en cada turno y el modelo lo ignora | Índice de 100-200 líneas y detalle bajo demanda |
| Reglas de seguridad en prosa | El 96% no tiene control detrás | Hook, linter o gate |
| Contexto autogenerado sin medir | Reduce el éxito y sube el coste | Escribir a mano y evaluar |
| Equipo de seis agentes para todo | Más traspasos, mismo resultado, triple coste | Un agente y subagentes puntuales con presupuesto |
| Revisor para subir el pass rate | Lo baja | Revisor solo como control de seguridad |
| Harness sin evals | Nadie sabe si mejora o se degrada | 20-50 tareas congeladas |
| Memoria como volcado de chat | No se puede verificar ni caducar | Un hecho por entrada, con dueño y fecha |
| Sesión larga sin fichero de progreso | La siguiente sesión repite o deshace | `claude-progress.txt` + `feature_list.json` + commits |

---

## 11. ENTREGABLE

Al aplicar esta skill a un proyecto, el resultado incluye:

1. `CLAUDE.md` (o `AGENTS.md`) recortado a índice, con enlaces a `docs/` y a las skills.
2. Lista de reglas en prosa y, para cada una, el control mecánico que la sustituye o la nota de por qué se queda en prosa.
3. Hooks y linters añadidos, cada uno con motivo y condición de caducidad.
4. Topología de subagentes (quién, con qué herramientas, con qué presupuesto).
5. Esquema de memoria y de ficheros de progreso para sesiones largas.
6. Conjunto de evals del harness con la medición inicial (línea base) y el coste por tarea.
7. Lo que **no** se ha medido todavía, dicho explícitamente.
