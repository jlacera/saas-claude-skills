# ⚙️ Ops & Deploy — Quick Reference

## 🚨 Top 3 (if you read nothing else, read this)
1. **No RED items reach production.** Every layer in the 13-layer gate must be GREEN or YELLOW before deploy.
2. **Smoke test after every deploy.** 5 steps in an incognito window — if anything feels wrong, rollback immediately.
3. **Rollback must take < 60 seconds.** If you can't revert in under a minute, you're not ready to deploy.

---

## 🏗️ 13-Layer Production Gate

| # | Layer | What to verify | Status |
|---|-------|---------------|--------|
| 1 | **Frontend** | Loading states, error pages, responsive at 360px | ⬜ |
| 2 | **APIs** | Schema validation at boundary (Zod/Valibot), timeouts, typed contracts | ⬜ |
| 3 | **Database** | Indexes on search columns, connection pooler (transaction mode), append-only migrations | ⬜ |
| 4 | **Auth** | HttpOnly cookies, JWT expiry, refresh token rotation, session revocation | ⬜ |
| 5 | **Hosting** | Auto-renewing SSL/TLS, strict env isolation (staging ≠ production) | ⬜ |
| 6 | **Cloud** | IAM least privilege, budget alerts with hard caps | ⬜ |
| 7 | **CI/CD** | Linter + typecheck + tests block merge on failure, rollback path tested | ⬜ |
| 8 | **Security** | Restrictive CORS, CSP headers, dependency vulnerability scanning | ⬜ |
| 9 | **Rate Limiting** | Per IP + per user on auth, payments, and LLM endpoints | ⬜ |
| 10 | **Caching** | Tenant-scoped keys (	enant:{id}:key), explicit TTLs | ⬜ |
| 11 | **Load Balancing** | Geographic balancing, auto-failover on region outage | ⬜ |
| 12 | **Error Tracking** | Full stack traces in Sentry (private), sanitized HTTP responses (public) | ⬜ |
| 13 | **Availability** | Daily backups with restore drills, health checks every 60s | ⬜ |

**Remediation priority for RED items:** 1. Revenue loss → 2. Data exposure → 3. Legal/regulatory breach

---

## 🔀 Hybrid Architecture — When to Move Off Serverless

Migrate to **Message Queue + Docker Worker** when:

| Trigger | Examples |
|---------|---------|
| Execution > 30 seconds | Batch embeddings, PDF generation, audio transcription |
| Persistent connections | WebSockets, IoT streaming, bidirectional channels |
| Intensive scheduled jobs | LLM-heavy cron jobs, bulk data processing |

`
[Client] → [Serverless API (light)] → [Queue (Redis/SQS)] → [Docker Worker (non-root)]
`

---

## 🧪 Post-Deploy Smoke Test (5 Steps)

Run in an **incognito window** on the public domain after every deploy:

1. **Register** — create account with real test email (e.g. you+test@gmail.com)
2. **Confirm** — verify email arrives, auth link works
3. **Core flow** — create → edit → delete the primary business resource
4. **Payment** — if billing exists, process minimum real charge, verify webhook unlocks access
5. **Persistence** — logout → re-login → confirm state is intact

> ⚠️ If ANY step fails or feels off → **rollback immediately**. Don't investigate in production.

---

## 🚨 Incident Runbook

| Phase | Action |
|-------|--------|
| **1. Contain** | Disable compromised endpoint or activate maintenance mode — stop the bleeding first |
| **2. Rebuild** | Trace with Sentry + structured JSON logs + correlation IDs — reconstruct exact timeline |
| **3. Communicate** | Notify affected users honestly — ETA + short post-mortem, no finger-pointing |
| **4. Prevent** | Document the failure pattern → add adversarial test to CI → add to agent symptom catalog |

---

## 📎 Deep Context

For the full 13-layer details, container architecture patterns, and rollback procedures:
→ Read [skill.md](./skill.md)
