# ✅ Definition of Done — Quick Reference

## 🚨 Top 3 (if you read nothing else, read this)
1. **Cross-tenant isolation test in CI.** If the module touches DB, cache, storage, or queues — a test must attempt access from another tenant and **fail explicitly**.
2. **Domain logic coverage ≥ 80%.** Test business rules, not getters or UI components.
3. **Zero secrets or PII in logs.** Sanitize all HTTP responses and log output — no stack traces, tokens, or personal data exposed.

---

## 📋 Universal DoD Checklist (14 Points)

### Contract & Design
- [ ] Public entry point (e.g. index.ts) exports only allowed interfaces
- [ ] Test double (mock/stub) published for consumers
- [ ] context.md written — purpose, data owned, events, decisions, discarded alternatives

### Correctness
- [ ] Domain logic test coverage ≥ 80%
- [ ] Failure-path tests — malformed input, timeouts, downed dependencies, nulls, concurrency
- [ ] Event contract tests — emitted event structure validated
- [ ] Tests run against ephemeral Scratch DB — never shared dev/staging databases

### Security
- [ ] Cross-tenant isolation test in CI
- [ ] `tenantId`/`userId` extracted from server session only — never from client inputs
- [ ] Zero credentials, tokens, PII, or stack traces in logs or HTTP responses

### Operations
- [ ] Structured JSON logs with `tenantId`, correlationId, userId, latency_ms
- [ ] Cost instrumented per invocation (if module calls LLMs or paid APIs)
- [ ] Deployed to staging behind a feature flag
- [ ] Traceability row closed with PR link and test IDs

---

## 📦 Additional Requirements by Module Type

| Module Type | Extra Requirements |
|-------------|-------------------|
| 🔴 **Red Lane** (Auth, Payments, PII, Migrations) | Written threat model · adversarial test · human line-by-line review · AI is draft-only |
| 🖥️ **UI** | Full keyboard nav (Tab/Enter/Esc) · WCAG 2.2 AA contrast (4.5:1 / 3:1) · responsive at 360px · loading/empty/error states · zero hardcoded strings (i18n) |
| 🤖 **Gen AI** | Visible AI disclosure · affirmative opt-in consent · indirect prompt injection test |
| 🔌 **API/Webhook** | Tests against recorded real responses · graceful degradation · idempotency guarantee |

---

## 📎 Deep Context

For the full rationale, module state definitions, and detailed explanations:
→ Read [SKILL.md](./SKILL.md)
