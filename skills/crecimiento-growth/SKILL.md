---
name: crecimiento-growth
description: >
  Acquisition aimed at AI agents, not only human searchers: Generative Engine
  Optimization with server-rendered JSON-LD (Product, Offer, AggregateRating,
  Review, FAQPage, ReturnPolicy), the public /api/ai-spec.json endpoint that
  makes a product legible to AI buying agents, the "Forge" no-budget B2B
  outreach doctrine, and the Meta anti-ban rules for WhatsApp Cloud API and
  Instagram automation. Use when working on landing pages, SEO, structured data,
  outreach sequences or social automation, and when the user asks about GEO,
  SEO, schema markup, crecimiento, captacion or automatizaciones de Meta. Skill
  content is in Spanish.
---
# 📈 ADQUISICIÓN AGENTIC Y CRECIMIENTO CON IA: GENERATIVE ENGINE OPTIMIZATION (GEO), CANALES DE META Y "THE FORGE" DOCTRINA

Esta guía operativa establece los estándares técnicos de posicionamiento y adquisición de clientes para que una aplicación sea descubrible, consumible y recomendada por agentes autónomos de IA y flujos de automatización seguros.

---

## SECCIÓN I: ADQUISICIÓN AGENTIC Y GEO (GENERATIVE ENGINE OPTIMIZATION)

En 2026, el tráfico hacia los sitios web ya no procede únicamente de humanos haciendo búsquedas tradicionales; proviene de **agentes de compra de IA** (ChatGPT Search, Perplexity, Gemini, AI Overviews) que investigan y evalúan productos antes de presentárselos al usuario final. Si una empresa carece de marcado de alta fidelidad, se vuelve completamente invisible al canal de adquisición de más rápido crecimiento en el mundo.

### 1. El Marcado JSON-LD de los "Agentic 6" (Estructurado en SSR)
Para ser citado y referenciado por motores sintéticos de búsqueda, el HTML servido desde el servidor (SSR) debe inyectar de forma obligatoria las entidades estructuradas de **Schema.org** con una tasa de llenado superior al 95%.

*Los rastreadores de IA no ejecutan JavaScript de hidratación tardía (como Google Tag Manager); los datos deben existir de forma estática en la respuesta inicial del servidor:*

1.  **Product:** Entidad central del producto con identificadores únicos globales (SKU, GTIN de 14 dígitos).
2.  **Offer:** Declaración exacta del precio, divisa compatible y disponibilidad en URIs oficiales de Schema (ej. `https://schema.org/InStock`).
3.  **AggregateRating:** Puntuaciones acumuladas y valoraciones de usuarios que los agentes de IA utilizan como filtros cuantitativos de calidad.
4.  **Review:** Reseñas individuales detalladas que aportan contexto semántico real.
5.  **FAQPage:** Bloques directivos de pregunta y respuesta formateados para responder a consultas naturales de los compradores de IA.
6.  **ReturnPolicy:** Políticas de devolución claras, un factor clave en la evaluación de riesgo que realizan los algoritmos de recomendación autónomos.

### 2. El Endpoint `/api/ai-spec.json`
Toda aplicación comercial expondrá una ruta pública con la especificación de producto legible por máquinas. Este documento debe estructurar en formato JSON plano:
*   Niveles de precios y esquemas de facturación activos.
*   Capacidades funcionales y límites operativos.
*   Estándares de seguridad y cumplimiento (SOC 2, GDPR).
*   Garantías oficiales de disponibilidad (uptime SLAs) y opciones de exportación de datos.

---

## SECCIÓN II: DOCTRINA "THE FORGE" PARA EL PRIMER CLIENTE B2B

Cuando un fundador o desarrollador lanza un nuevo producto al mercado sin contar con una red de contactos o presupuesto de publicidad, aplicará la doctrina **The Forge**:

1.  **Seleccionar un Nicho de Alto Dolor (*High-Pain Niches*):** Identificar sectores donde el error manual o el consumo de tiempo administrativo cuesta dinero real de forma diaria (ej. agencias SEO, clínicas médicas, bufetes de abogados, inmobiliarias, asesores tributarios).
2.  **Vender el Resultado, Jamás la Tecnología:** Al dueño de negocio no le importa qué modelo de LLM o base de datos utilizas. Le importa que su proceso de reporte mensual pase de **3 días de trabajo manual a 5 minutos automáticos**, ahorrándole $1,500 en costes.
3.  **El Vídeo Demo de 3 Minutos (Loom / Tella):** En lugar de enviar un correo frío solicitando una reunión de 30 minutos (alta fricción), se le envía al prospecto un vídeo corto y ultra-personalizado mostrando cómo la solución optimiza directamente su propia página web o proceso en tiempo real, demostrando el valor desde el primer segundo.
4.  **Cero Fricción de Entrada:** Proveer un enlace funcional de un solo clic (*1-Click Win*) donde el prospecto experimente el beneficio del software con sus propios datos antes de solicitar datos bancarios o registros complejos.

---

## SECCIÓN III: REGLAS ANTI-BAN EN CHATBOTS DE META (INSTAGRAM & WHATSAPP)

### La API Oficial de WhatsApp contra el QR de Ingeniería Inversa
Está estrictamente prohibido utilizar conexiones basadas en escanear códigos QR de WhatsApp Web (*WhatsApp Senders/No-Oficiales*). Meta utiliza modelos de detección de spam automáticos que banean permanentemente el número de teléfono sin apelación, perdiendo todo el historial comercial. Se utilizará **exclusivamente** la API Oficial de WhatsApp Business Cloud, garantizando la aprobación de Meta y acceso a funciones interactivas robustas.

### Las 7 Reglas de Oro Anti-Ban para Comentarios en Instagram
Un bot de comentarios en Instagram que responda de forma instantánea a picos de actividad será bloqueado de manera inmediata por los filtros de spam de Meta. Para evitar esto en flujos automatizados (n8n/Make + API de Meta), el middleware debe implementar:

1.  **Límite de Ejecución Estricto:** Máximo de 3 respuestas de comentarios cada 5 minutos, con un techo absoluto de **36 respuestas por hora**.
2.  **Pausa Aleatoria Humana:** Introducción de un retraso de tiempo aleatorio entre **20 y 40 segundos** antes de responder a cada comentario para eliminar el patrón de ráfaga (*bursting*).
3.  **Redacción Contextual Fresca:** El modelo de IA redactará una respuesta única para cada usuario basándose en su comentario. Queda estrictamente prohibido usar respuestas repetitivas idénticas en masa.
4.  **Registro Inmutable de Comentarios:** Almacenamiento en base de datos de los IDs procesados para garantizar que el bot no responda por error dos veces al mismo comentario del usuario.
5.  **Freno de Seguridad ante Errores:** Si la API de Meta devuelve un código de error `429 Too Many Requests` o fallos de límite de tasa, el workflow detiene todas sus ejecuciones por 5 minutos antes de reintentar.
6.  **Exclusión de Cuentas Propias:** El robot ignorará comentarios realizados por la propia cuenta o palabras clave transaccionales asignadas a flujos directos por mensajes privados (DM).
7.  **Prohibición de Enlaces en Comentarios Públicos:** Colocar links masivos en comentarios públicos activa las alarmas de Meta. La respuesta pública debe limitarse a interactuar amablemente y redirigir al usuario a su bandeja de mensajes directos (DM) o al enlace de la biografía.
