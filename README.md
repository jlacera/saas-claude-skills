# 🧠 SaaS Claude Skills — Vibe-Coding Engineering Standards

> **A battle-tested collection of Claude Code skills for building production-grade SaaS applications with AI agents.** Designed for vibe-coders who want speed without sacrificing engineering maturity.

> **⚠️ Note:** The skills are written in **Spanish**, as they were originally created for a Spanish-speaking team. The documentation (this file) is in English for maximum reach. Contributions and translations are welcome!

---

## 🔥 Why This Exists

The shift toward a **Separation of Concerns + Lazy-Loading architecture** is the only viable path in 2026 for vibe-coding to mature into a structured, secure, and profitable software engineering discipline.

This collection was **not built from theoretical manuals or lab assumptions**. It was forged from real battle scars — from engineers who have watched databases collapse, API budgets drain overnight, and perfectly-running demos turn into spaghetti code in production because no clear boundaries were set for code agents.

> *"Speed without rigor doesn't produce MVPs — it produces invisible debt."*

The core insight is simple: **a Lazy-Loading skill architecture** means your AI agent only loads the context it needs for the task at hand — security rules when touching auth, billing rules when touching Stripe, deploy rules when going to production. This keeps the context window lean, the agent focused, and the output trustworthy.

---

## 📦 What's Inside

This repository contains **6 Claude Code skills** organized as a progressive engineering framework — from agent orchestration philosophy to growth tactics.

| # | Skill | Domain | Summary |
|---|-------|--------|---------|
| 1 | [`master-agent`](./1_master-agent/) | 🤖 Orchestration | Core operating rules: the "Vibe-Coding Paradox", 5 immutable laws, multi-model routing & token-budget management |
| 2 | [`definition-of-done`](./2_definition-of-done/) | ✅ Quality Gate | 14-point universal DoD checklist — makes "done" objective, deterministic and audit-proof |
| 3 | [`seguridad-saas`](./3_seguridad-saas/) | 🛡️ Security | Dual OWASP shield (Web + LLM), multi-tenant isolation matrix, EU AI Act Art. 50, StampHog protocol |
| 4 | [`ops-deploy`](./4_ops-deploy/) | ⚙️ Operations | 13-layer production gate, hybrid serverless ↔ container pattern, smoke test & incident runbook |
| 5 | [`billing-monetizacion`](./5_billing-monetizacion/) | 💳 Billing | Stripe transactional safety, $0.10 cost circuit-breaker, unit economics, anti-churn dunning |
| 6 | [`crecimiento-growth`](./6_crecimiento-growth/) | 📈 Growth | Agentic SEO (GEO), "The Forge" B2B doctrine, Meta API anti-ban rules |

---

## 🚀 Installation

### Option A — Claude Code (Recommended)

These skills are designed to work natively with **[Claude Code](https://claude.ai/code)** via the `.claude/skills/` convention.

1. Clone this repository into your project's `.claude/skills/` directory:

```bash
# From your project root
git clone https://github.com/jlacera/saas-claude-skills .claude/skills/saas-skills
```

2. Tell Claude Code to use a skill in your conversation:

```
Use the rules in .claude/skills/saas-skills/1_master-agent/skill.md
```

Or reference the skills in your `CLAUDE.md` so they load automatically:

```markdown
# CLAUDE.md

## Agent Operating Standards
See .claude/skills/saas-skills/1_master-agent/skill.md for the agent operating rules.
See .claude/skills/saas-skills/2_definition-of-done/skill.md for the DoD checklist.
See .claude/skills/saas-skills/3_seguridad-saas/skill.md for the security standards.
```

---

### Option B — Manual copy

Copy any skill folder directly into your project:

```bash
# Copy all skills at once
cp -r saas-claude-skills/1_master-agent YOUR_PROJECT/.claude/skills/master-agent
cp -r saas-claude-skills/2_definition-of-done YOUR_PROJECT/.claude/skills/definition-of-done
# ... and so on
```

---

### Option C — Git submodule (shared across projects)

Add this repo as a Git submodule so all your projects share the same skills:

```bash
git submodule add https://github.com/jlacera/saas-claude-skills .claude/skills/saas-skills
```

---

## 📖 Skill Descriptions

### 1. 🤖 Master Agent — Operating Constitution for AI Agents

> **File:** [`1_master-agent/skill.md`](./1_master-agent/skill.md)

The foundational "constitution" for any AI agent working on a SaaS codebase. A single reference that replaces brittle wiki docs with executable, enforceable rules.

- **The Vibe-Coding Paradox**: Why 92% of engineers use AI daily but only 29% trust auto-generated code — and how to be in the 29%
- **5 Immutable Laws**: Atomic flow (one module at a time), zero TODOs in code, scope freeze during development, traceability matrix updated in the same PR, immutability of finished modules
- **"Fable Sandwich" orchestration**: Architect (plan) → Worker (code) → Auditor (review) — each role mapped to the right model tier
- **Token-Budget-Aware context management**: Lazy loading of schemas and vector DBs, `CoD` (Chain of Draft) technique for reasoning models (68–86% token reduction with >95% accuracy)
- **Canonical model routing**: Haiku for triage · Sonnet for daily dev · Opus for deep architecture · Fable for autonomous/audit mode
- **Risk Lane system**: 🟢 Green (docs, CSS) · 🟡 Yellow (business logic) · 🔴 Red (Auth, Stripe, PII, migrations) — with StampHog auto-blocking for Red Lane PRs
- **Adversarial self-correction**: "Attack your own conclusion" cycle before every PR — checking for memory leaks, RLS bypasses, billing rounding errors, and hallucinated dependencies

---

### 2. ✅ Definition of Done — The 14-Point Quality Gate

> **File:** [`2_definition-of-done/skill.md`](./2_definition-of-done/skill.md)

Replaces subjective "done" with a deterministic, audit-proof 14-point checklist. If a module doesn't pass all 14, it doesn't merge.

**Universal DoD (all modules):**
- **Contract & Design**: Public `index.ts` contract · published test doubles (mocks/stubs) · `context.md` with decisions and discarded alternatives
- **Correctness**: ≥80% domain logic coverage · explicit failure-path tests (null, timeout, concurrent load) · contract tests for emitted events · ephemeral Scratch DBs (never shared dev/staging)
- **Security**: Cross-tenant isolation test in CI · server-side-only extraction of `tenantId`/`userId` · zero credentials or PII in logs or HTTP responses
- **Operations**: Structured JSON logs with `correlationId` · cost instrumented per function · deployed to staging behind a feature flag · traceability row closed with PR link

**Additional requirements by module type:**
- 🔴 **Red Lane** (Auth, Payments, PII, Migrations): Written threat model + adversarial test + mandatory human line-by-line review
- 🖥️ **UI modules**: Full keyboard navigation (Tab/Enter/Esc, no focus traps) · WCAG 2.2 AA contrast (4.5:1 normal, 3:1 large text) · responsive at 360px · explicit loading/empty/error states · zero hardcoded strings (i18n)
- 🤖 **Generative AI modules**: Visible AI disclosure · affirmative opt-in consent gate · indirect prompt injection test (malicious reviews, webhooks)
- 🔌 **API/Webhook ingesters**: Tests against recorded real API responses · graceful degradation if third-party is down · idempotency guarantee

---

### 3. 🛡️ SaaS Security — Dual OWASP Shield

> **File:** [`3_seguridad-saas/skill.md`](./3_seguridad-saas/skill.md)

The mandatory security standard for 2026 — combining classic web hardening with generative AI threat mitigation, under the **NIST SP 800-218A** corporate framework.

**OWASP Top 10 Web (traditional layer):**
- **IDOR prevention** `[LUPIN-RULE-001]`: `tenantId`/`userId` extracted exclusively from server-verified session tokens — never from URL params, headers, or request bodies
- **Supabase RLS** `[LUPIN-RULE-002]`: No `USING (true)` policies — every policy validates `auth.uid()`. Views must use `WITH (security_invoker = true)`
- **SSRF blocking** `[LUPIN-RULE-009]`: Active network filter on user-supplied URLs — blocks `127.0.0.1`, `10.0.0.0/8`, `169.254.169.254` (cloud metadata)
- **Zero homebrew crypto**: No custom JWT parsers or hashing functions — always delegate to proven providers (Supabase Auth, Clerk, Better Auth)

**OWASP LLM Top 10 (generative AI layer):**
- **Prompt injection** (direct & indirect): All external input (reviews, emails, webhooks) treated as hostile — agents operate read-only under least privilege
- **Excessive agency**: No autonomous destructive writes without human confirmation
- **Token DDoS**: Rate limiting per IP + per authenticated user on every LLM-touching endpoint, returning `429` when exceeded

**Multi-tenant isolation matrix:**

| Layer | Risk | Directive |
|---|---|---|
| Redis / LangCache | 🔴 High | `tenant:${tenant_id}:cache_key` prefix — mandatory |
| Vector DB | 🔴 High | `tenant_id` metadata filter applied **before** similarity search |
| Storage / Files | 🟡 Medium | `/tenants/${tenant_id}/files/` paths + 60-second signed URLs |
| WebSockets / Event Bus | 🟡 Medium | JWT-scoped subscriptions per tenant |

**EU AI Act — Article 50 (in force August 2026):**
- Visible, non-removable AI disclosure on all synthetic content (official EU iconography)
- Explicit opt-in consent gate — pre-checked boxes are strictly forbidden
- Append-only generation log: `timestamp`, `model_name`, `input_hash`, `output_hash`, `user_session_id` — 3-year minimum retention

**StampHog Protocol**: CI reviewer scans every PR diff for Red Lane keywords (`auth`, `token`, `password`, `stripe`, `billing`, `pii`, `migration`, `rls`, `rbac`). Any match → auto-merge blocked → mandatory senior security review.

---

### 4. ⚙️ Ops & Deploy — 13-Layer Production Gate

> **File:** [`4_ops-deploy/skill.md`](./4_ops-deploy/skill.md)

No deployment reaches production with a single **RED** item. Each layer is evaluated as Green / Yellow / Red:

`Frontend` → `APIs` → `Database` → `Auth` → `Hosting` → `Cloud` → `CI/CD` → `Security` → `Rate Limiting` → `Caching` → `Load Balancing` → `Error Tracking` → `Availability & Backups`

Remediation priority for RED items: **1. Revenue loss** → **2. Data exposure** → **3. Legal/regulatory breach**

**Hybrid Serverless ↔ Container architecture** — migrate to Docker workers + message queue (Redis/SQS) when:
- Execution time > 30s (batch embeddings, PDF processing, audio/video transcription)
- Persistent connections needed (WebSockets, IoT streaming)
- Intensive scheduled cron jobs calling LLM APIs

Pattern: `Lightweight Serverless API → Message Queue (Redis/SQS) → Docker Worker (non-root user)`

**Mandatory 5-step Smoke Test** after every production deploy (incognito window):
1. Register a real account with a test email
2. Confirm email arrival and auth link works
3. Execute the core business flow (create / edit / delete)
4. If billing: pay minimum amount and verify webhook activates access
5. Logout → re-login → verify state persistence

**Incident Runbook**: Contain (disable compromised endpoint / activate maintenance mode) → Rebuild (trace with Sentry + structured logs) → Communicate (honest ETA + post-mortem) → Prevent (add adversarial test to CI)

---

### 5. 💳 Billing & Monetization — Stripe Safety Rules

> **File:** [`5_billing-monetizacion/skill.md`](./5_billing-monetizacion/skill.md)

Every dollar charged through this system is governed by four non-negotiable pillars and a continuous unit economics monitor.

**4 Golden Rules of Stripe billing:**
1. **Cryptographic webhook verification**: `stripe.webhooks.constructEvent(rawBody, signature, STRIPE_WEBHOOK_SECRET)` — no exceptions. Invalid signatures return `400`
2. **Async-only provisioning**: Credits, plans, and roles activate exclusively after the verified webhook event (`checkout.session.completed`, `invoice.paid`) — never on redirect
3. **Idempotency key per charge**: UUID in every `Stripe-Idempotency-Key` header to prevent double-billing on network retries
4. **Absolute key isolation**: `sk_test_...` stays in dev/staging; `sk_live_...` never leaves production environment variables

**Unit Economics for AI — the $0.10 Circuit Breaker:**
- Instrument every LLM-touching function with OpenTelemetry / Helicone / Langfuse
- Automatic infrastructure alert if any interactive user-facing invocation exceeds **$0.10 USD**
- Monthly margin audit: `Margin = ARPU − CPU (tokens + APIs + storage per user)` — any tier running at negative margin triggers immediate pricing review

**Anti-chargeback & Dunning (up to 20% of cancellations are involuntary):**
- Transparent card descriptor (e.g., `YOURAPP.COM*PRO`) — not the legal entity name
- Detailed receipt emails + 1-click cancellation visible in the customer portal
- Auto-pause account on `charge.dispute.created` webhook — collects access logs as dispute evidence
- Stripe Smart Retries → 14-day pre-expiry email sequence → 7-day grace period with partial access before service termination

**International billing**: all timestamps in `TIMESTAMPTZ` (UTC) · Stripe adaptive multi-currency pricing · Stripe Tax for VAT/GST/Sales Tax automation

---

### 6. 📈 Growth — Agentic Acquisition & GEO

> **File:** [`6_crecimiento-growth/skill.md`](./6_crecimiento-growth/skill.md)

In 2026, acquisition traffic comes from AI buying agents — not just humans doing Google searches. If your SaaS isn't optimized for synthetic discovery, it doesn't exist.

**GEO — Generative Engine Optimization (the "Agentic 6"):**

Server-side rendered (SSR) JSON-LD Schema.org markup with >95% fill rate — AI crawlers don't execute late-injected JavaScript:

| Entity | Purpose |
|---|---|
| `Product` | SKU, GTIN-14, unique global identifiers |
| `Offer` | Price, currency, `https://schema.org/InStock` URI |
| `AggregateRating` | Aggregate score used as AI quality filter |
| `Review` | Individual reviews for semantic context |
| `FAQPage` | Direct Q&A blocks for natural language queries |
| `ReturnPolicy` | Risk evaluation signal for autonomous recommendation agents |

**`/api/ai-spec.json` endpoint** — public, machine-readable product spec for AI buying agents: pricing tiers, functional capabilities, security certifications (SOC 2, GDPR), uptime SLAs, and data export options.

**"The Forge" B2B doctrine** — for founders launching without budget or network:
1. Target **high-pain niches** (agencies, medical clinics, law firms, accounting) where manual errors cost real money daily
2. Sell the **outcome**, not the technology — "your monthly report goes from 3 days to 5 minutes, saving $1,500"
3. Send a **3-minute Loom/Tella demo** personalised to their specific business instead of requesting a 30-minute meeting
4. Provide a **1-click trial link** — let them experience value with their own data before asking for payment details

**Meta anti-ban rules:**
- **WhatsApp**: Official Business Cloud API only — QR-based senders get permanently banned with no appeal
- **Instagram automation** (7 rules): max 3 replies per execution / 36 per hour · random 20–40s delay between comments · LLM-generated unique reply per user · comment ID deduplication in DB · hard stop on `429` errors (5-minute cooldown) · ignore own-account comments · **zero links in public comments** (redirect via DMs only)

---


## 🗂️ Repository Structure

```
saas-claude-skills/
├── README.md                          ← You are here
├── CONTRIBUTING.md                    ← How to contribute
├── LICENSE                            ← MIT License
├── .gitignore
│
├── 1_master-agent/
│   └── skill.md                      ← Master agent operating rules
│
├── 2_definition-of-done/
│   └── skill.md                      ← 14-point DoD universal checklist
│
├── 3_seguridad-saas/
│   └── skill.md                      ← Dual OWASP security shield
│
├── 4_ops-deploy/
│   └── skill.md                      ← 13-layer production gate
│
├── 5_billing-monetizacion/
│   └── skill.md                      ← Stripe billing safety rules
│
└── 6_crecimiento-growth/
    └── skill.md                      ← GEO & agentic growth tactics
```

---

## 🤝 Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines on:
- Adding new skills
- Improving existing ones
- Translating skills to other languages
- Reporting outdated information

---

## 📄 License

[MIT](./LICENSE) — Free to use, modify and distribute. Attribution appreciated.

---

## ⭐ If this helps you...

Give it a star on GitHub! It helps other vibe-coders discover these standards.

Made with 🔥 by vibe-coders who learned the hard way that speed without rigor creates invisible debt.
