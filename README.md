# 🧠 SaaS Claude Skills — Vibe-Coding Engineering Standards

> **A battle-tested collection of Claude Code skills for building production-grade SaaS applications with AI agents.** Designed for vibe-coders who want speed without sacrificing engineering maturity.

> **⚠️ Note:** The skills are written in **Spanish**, as they were originally created for a Spanish-speaking team. The documentation (this file) is in English for maximum reach. Contributions and translations are welcome!

---

## 📦 What's Inside

This repository contains **6 Claude Code skills** organized as a progressive engineering framework — from orchestration philosophy to growth tactics.

| # | Skill | Summary |
|---|-------|---------|
| 1 | [`master-agent`](./1_master-agent/) | Core operating rules for AI agents: the "Vibe-Coding Paradox", 5 immutable laws, multi-model orchestration & token-budget management |
| 2 | [`definition-of-done`](./2_definition-of-done/) | 14-point universal DoD checklist that makes "done" objective and audit-proof |
| 3 | [`seguridad-saas`](./3_seguridad-saas/) | Dual OWASP security shield (Web + LLM), multi-tenant isolation matrix, EU AI Act Art. 50 compliance |
| 4 | [`ops-deploy`](./4_ops-deploy/) | 13-layer production readiness gate, hybrid serverless ↔ container architecture & incident runbook |
| 5 | [`billing-monetizacion`](./5_billing-monetizacion/) | Stripe transactional safety rules, unit economics monitoring, anti-churn & dunning strategies |
| 6 | [`crecimiento-growth`](./6_crecimiento-growth/) | Agentic SEO (GEO), "The Forge" B2B doctrine, Meta anti-ban rules for Instagram & WhatsApp |

---

## 🚀 Installation

### Option A — Claude Code (Recommended)

These skills are designed to work natively with **[Claude Code](https://claude.ai/code)** via the `.claude/skills/` convention.

1. Clone this repository into your project's `.claude/skills/` directory:

```bash
# From your project root
git clone https://github.com/YOUR_USERNAME/saas-claude-skills .claude/skills/saas-skills
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
git submodule add https://github.com/YOUR_USERNAME/saas-claude-skills .claude/skills/saas-skills
```

---

## 📖 Skill Descriptions

### 1. 🤖 Master Agent — Operating Rules for AI Agents

> **File:** [`1_master-agent/skill.md`](./1_master-agent/skill.md)

The "constitution" for any AI agent working on this codebase. Covers:
- **The Vibe-Coding Paradox**: Why 92% of engineers use AI daily but only 29% trust auto-generated code
- **5 Immutable Laws**: Atomic flow, no TODOs, scope freeze, traceability updates, immutability of finished code
- **"Fable Sandwich" multi-model orchestration**: Architect → Worker → Auditor model hierarchy
- **Token-Budget-Aware Context Management**: Lazy loading, CoD technique for reasoning models (68-86% token reduction)
- **Canonical model routing**: Haiku / Sonnet / Opus / Fable — when to use each
- **Adversarial self-correction cycle**: "Attack your own conclusion" before every PR

---

### 2. ✅ Definition of Done — The 14-Point Quality Gate

> **File:** [`2_definition-of-done/skill.md`](./2_definition-of-done/skill.md)

Makes "done" an objective, auditable state — not an opinion. Includes:
- **Contract & Design**: Public `index.ts` contract, published mocks, `context.md` documentation
- **Correctness**: ≥80% domain test coverage, failure path tests, contract tests, ephemeral Scratch DBs
- **Security**: Cross-tenant isolation tests, server-side authorization validation, zero PII in logs
- **Operations**: Structured observability, cost instrumentation per function, staging + feature flags, traceability matrix

Includes additional requirements per module type: **Red Lane** (Auth/Payments/PII), **UI modules**, **API/Webhook ingesters**, **Generative AI modules**.

---

### 3. 🛡️ SaaS Security — Dual OWASP Shield

> **File:** [`3_seguridad-saas/skill.md`](./3_seguridad-saas/skill.md)

Mandatory security standard combining traditional web security with generative AI threats:
- **OWASP Top 10 Web**: IDOR prevention, Supabase RLS policies, no client-side business logic
- **OWASP LLM Top 10**: Prompt injection, sensitive info disclosure, excessive agency, token DDoS
- **10 Commandments of SaaS Security**: Practical rules with code examples (IDOR, RLS, SSRF, rate limiting, zero homebrew crypto)
- **Multi-tenant isolation matrix**: Redis namespacing, vector DB filtering, signed URLs for storage
- **EU AI Act Article 50**: Disclosure, consent gates, immutable generation logs (3-year retention)
- **StampHog Protocol**: Automated Red Lane blocking when sensitive keywords detected in PRs

---

### 4. ⚙️ Ops & Deploy — 13-Layer Production Gate

> **File:** [`4_ops-deploy/skill.md`](./4_ops-deploy/skill.md)

No deployment passes to production with a single RED item across 13 layers:

`Frontend` → `APIs` → `Database` → `Auth` → `Hosting` → `Cloud` → `CI/CD` → `Security` → `Rate Limiting` → `Caching` → `Load Balancing` → `Error Tracking` → `Availability`

Also covers:
- **Hybrid Serverless ↔ Container architecture**: When and how to migrate heavy workloads to Docker workers + message queues
- **Mandatory smoke test protocol**: 5-step post-deploy verification in incognito mode
- **Incident management runbook**: Contain → Rebuild → Communicate → Prevent

---

### 5. 💳 Billing & Monetization — Stripe Safety Rules

> **File:** [`5_billing-monetizacion/skill.md`](./5_billing-monetizacion/skill.md)

Everything needed to charge money safely and sustainably:
- **4 Golden Rules**: Webhook cryptographic signature, async provisioning only, idempotency keys, strict key isolation (test vs. live)
- **Unit Economics for AI**: Cost-per-function instrumentation, $0.10/invocation alert circuit breaker, ARPU vs. CPU margin model
- **Anti-chargeback protocol**: <0.75% dispute threshold, clear billing descriptors, auto-pause on disputes
- **Dunning management**: Stripe Smart Retries, 14-day card expiry emails, 7-day grace period
- **International billing**: UTC timestamps, adaptive pricing, Stripe Tax for VAT/GST

---

### 6. 📈 Growth — Agentic Acquisition & GEO

> **File:** [`6_crecimiento-growth/skill.md`](./6_crecimiento-growth/skill.md)

How to make your SaaS discoverable and recommended by AI agents:
- **GEO (Generative Engine Optimization)**: The "Agentic 6" JSON-LD SSR markup (Product, Offer, AggregateRating, Review, FAQPage, ReturnPolicy)
- **`/api/ai-spec.json` endpoint**: Machine-readable product spec for AI buying agents
- **"The Forge" B2B doctrine**: High-pain niches, sell the outcome not the technology, 3-minute Loom demo, 1-click trial
- **Meta anti-ban rules**: WhatsApp Official API only; 7 Instagram bot rules (rate limits, random delays, fresh LLM-generated replies, duplicate prevention)

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
