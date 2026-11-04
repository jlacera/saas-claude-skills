# 🤖 Master Agent — Quick Reference

## 🚨 Top 3 (if you read nothing else, read this)
1. **One module at a time.** Never leave a module at 90% to start another — the remaining 10% costs 40% more due to context loss.
2. **Zero TODOs in code.** Implement it now or log it in the backlog with a unique ID. The CI pipeline will break on `TODO`/`FIXME`.
3. **Attack your own conclusion.** Before every PR, act as a malicious reviewer looking for memory leaks, RLS bypasses, billing rounding errors, and hallucinated dependencies.

---

## ⚖️ The 6 Immutable Laws

| # | Law | Violation Signal |
|---|-----|-----------------|
| 1 | **Atomic Flow** — max 1 module in progress | Module stuck at ~90% while a new one is started |
| 2 | **Zero TODOs** — implement or backlog with ID | `TODO`/`FIXME` string detected in commit |
| 3 | **Scope Freeze** — no ad-hoc additions after dev starts | "Just one more thing" added mid-sprint |
| 4 | **Traceability in same PR** — matrix row updated in the PR that closes the module | PR merged without updating the traceability matrix |
| 5 | **Finished = Immutable** — no informal refactoring | Module reopened without a ticket |
| 6 | Independent reviewer | The session or model that wrote the code is the one approving it |

---

## 🎯 Model Routing

| Task Type | Model Tier | Examples |
|-----------|-----------|---------|
| Triage & speed | Haiku 5.5 | Issue classification, extraction, quick search, free chat |
| Daily development | Sonnet 5.5 | Standard logic, refactoring, MCP tools |
| Deep architecture | Opus 5.5 (default) | DB design, complex audits, system coworking, long agentic coding |
| Autonomous / audit | Fable 5.1 | End-to-end flows, adversarial Red Lane review |

---

## 🚦 Risk Lane Classification

Apply to **every PR** before writing or reviewing:

| Lane | Scope | Review Required |
|------|-------|----------------|
| 🟢 Green | Docs, CSS, unit tests, no data side-effects | Standard CI |
| 🟡 Yellow | Business logic, standard API integrations | CI + senior sign-off |
| 🔴 Red | Auth, Stripe, PII, DB migrations, public APIs | **Human review mandatory — AI is draft-only** |

**StampHog keywords** (auto-block merge if detected in diff): canonical list in `saas-security-workflow` §7 (`auth · token · password · secret · stripe · billing · pii · migration · rls · rbac · webhook · oauth · jwt · session` and more). Claude never runs that merge; a named human does.

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
→ Read [`SKILL.md`](./SKILL.md)

For domain-specific rules, lazy-load the relevant skill:
- Orchestration and phase gates → `saas-project-kickoff/`
- Phase 0 decisions → `saas-architecture-blueprint/`
- Security doctrine → `saas-security-workflow/`
- Code-level audit → `saas-adversarial-audit/`
- Quality gate → `saas-definition-of-done/`
- Deploy & ops → `saas-production-readiness/`
- Billing → `saas-billing-unit-economics/`
- Certification readiness → `saas-compliance-readiness/`
- Growth → `saas-growth-geo/`
