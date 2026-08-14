# 🤖 Master Agent — Quick Reference

## 🚨 Top 3 (if you read nothing else, read this)
1. **One module at a time.** Never leave a module at 90% to start another — the remaining 10% costs 40% more due to context loss.
2. **Zero TODOs in code.** Implement it now or log it in the backlog with a unique ID. The CI pipeline will break on TODO/FIXME.
3. **Attack your own conclusion.** Before every PR, act as a malicious reviewer looking for memory leaks, RLS bypasses, billing rounding errors, and hallucinated dependencies.

---

## ⚖️ The 5 Immutable Laws

| # | Law | Violation Signal |
|---|-----|-----------------|
| 1 | **Atomic Flow** — max 1 module in progress | Module stuck at ~90% while a new one is started |
| 2 | **Zero TODOs** — implement or backlog with ID | TODO/FIXME string detected in commit |
| 3 | **Scope Freeze** — no ad-hoc additions after dev starts | "Just one more thing" added mid-sprint |
| 4 | **Traceability in same PR** — matrix row updated in the PR that closes the module | PR merged without updating the traceability matrix |
| 5 | **Finished = Immutable** — no informal refactoring | Module reopened without a ticket |

---

## 🎯 Model Routing

| Task Type | Model Tier | Examples |
|-----------|-----------|---------|
| Triage & speed | Haiku / fast tier | Issue classification, quick search, free chat |
| Daily development | Sonnet / mid tier | Standard logic, refactoring, MCP tools |
| Deep architecture | Opus / high tier | DB design, complex audits, system coworking |
| Autonomous / audit | Fable / max tier | End-to-end flows, adversarial Red Lane review |

---

## 🚦 Risk Lane Classification

Apply to **every PR** before writing or reviewing:

| Lane | Scope | Review Required |
|------|-------|----------------|
| 🟢 Green | Docs, CSS, unit tests, no data side-effects | Standard CI |
| 🟡 Yellow | Business logic, standard API integrations | CI + senior sign-off |
| 🔴 Red | Auth, Stripe, PII, DB migrations, public APIs | **Human review mandatory — AI is draft-only** |

**StampHog keywords** (auto-block merge if detected in diff):
`auth · token · password · stripe · billing · pii · migration · rls · rbac`

---

## 🔄 Adversarial Pre-PR Checklist

Before submitting any code for review:

- [ ] **Memory leaks** — unclosed connections, listeners, timers?
- [ ] **Billing math** — currency rounded correctly? No floating point for money?
- [ ] **RLS bypass** — does any cache layer sit in front of DB policies and leak cross-tenant data?
- [ ] **Hallucinated packages** — every new dependency verified in official registry with active maintenance?
- [ ] **Byte parity** — if pure refactor, is the output identical to production?

---

## 📎 Deep Context

For the full operating rules, orchestration philosophy, and context management strategies:
→ Read [skill.md](./skill.md)

For domain-specific rules, lazy-load the relevant skill:
- Security → 3_seguridad-saas/
- Quality gate → 2_definition-of-done/
- Deploy & ops → 4_ops-deploy/
- Billing → 5_billing-monetizacion/
- Growth → 6_crecimiento-growth/
"@ | Out-File -FilePath "1_master-agent/quick-ref.md" -Encoding utf8; Write-Host "done1"

@"
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
- [ ] 	enantId/userId extracted from server session only — never from client inputs
- [ ] Zero credentials, tokens, PII, or stack traces in logs or HTTP responses

### Operations
- [ ] Structured JSON logs with 	enantId, correlationId, userId, latency_ms
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
→ Read [skill.md](./skill.md)
