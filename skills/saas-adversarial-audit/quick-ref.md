# 🔎 Adversarial Audit — Quick Reference

## 🚨 Top 3
1. **The model that built it does not review it.** Red Lane audits run in a fresh session, a dedicated subagent, or a different model — and never receive the author's justification.
2. **Run `scripts/quick-scan.sh` first.** 15 of the 40 patterns are provable with grep in seconds. Non-zero exit blocks the merge.
3. **A pattern you could not verify is never reported as passed.** Say what you could not check and why.

---

## 📋 Routing table

| Stack present | Load |
|---|---|
| RAG / embeddings / vector DB | `references/rag-multitenant.md` |
| Next.js (RSC, Server Actions, middleware) | `references/nextjs.md` |
| tRPC / GraphQL / API routes / Zod | `references/api-layer.md` |
| Clerk / JWT / OAuth / password reset / admin panel | `references/identidad-jwt.md` |
| Prisma / Postgres / Neon / Supabase | `references/datos.md` |
| Webhooks / cron / Resend / Firebase / Convex / Stripe | `references/integraciones.md` |
| npm deps / third-party scripts / CORS / subdomains | `references/supply-chain.md` |
| Autonomous agents / text-to-SQL / MCP tools | `references/agentes-ia.md` |

---

## 🔥 The five that show up everywhere

| # | Pattern | Tell |
|---|---|---|
| 1 | Client-only validation | Zod in the form, nothing in the route handler |
| 2 | Mass assignment | `data: body` straight into the ORM |
| 3 | Identity checked, ownership not | `where: { id }` without `tenantId` |
| 4 | Webhook without idempotency | Signature verified, event ID never stored |
| 5 | Unscoped cache / vector / realtime query | RLS is behind the layer that actually leaks |

---

## 📤 Finding format

```
[SEVERITY] Pattern — file:line
Qué pasa / Evidencia / Explotación / Parche / Verificación
```

**CRITICAL** = cross-tenant leak, authorization bypass, financial loss.
**ALTO** = information disclosure or denial of service. **MEDIO** = hardening.

Verdict line is mandatory: **APTO PARA MERGE** or **BLOQUEADO**.

---

## 📎 Deep Context
→ Read [SKILL.md](./SKILL.md) and only the applicable `references/` files.
