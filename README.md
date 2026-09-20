# 🧠 SaaS Claude Skills — Vibe-Coding Engineering Standards

> **A plugin of Claude Code skills for building production-grade SaaS with AI agents.** For vibe-coders who want speed without giving up engineering maturity.

> **⚠️ Note:** The skills are written in **Spanish**, as they were originally created for a Spanish-speaking team. The documentation and the skill trigger descriptions are in English for maximum reach. Contributions and translations are welcome.

**v2.0.0** — the lifecycle orchestrator, the Phase 0 blueprint and the adversarial audit catalogue join the collection. See [What changed in v2](#-what-changed-in-v20).

---

## 🔥 Why This Exists

This collection was **not built from theoretical manuals**. It comes from real projects — from watching a database collapse, an API budget drain overnight, and a demo that ran perfectly turn into unmaintainable code in production, because nobody set clear boundaries for the agents.

> *"Speed without rigor doesn't produce MVPs — it produces invisible debt."*

AI-generated code has a signature failure mode: it is syntactically impeccable, passes trivial unit tests, and omits security boundaries, multi-tenant isolation and state lifecycles entirely. These skills exist to close that gap **during** development, not after the incident.

**Lazy loading** is the architecture: the agent loads security rules when it touches auth, billing rules when it touches Stripe, the audit catalogue when it reviews a diff. The context window stays lean and the output stays trustworthy.

---

## 📦 What's Inside

**10 skills**, each shipping a **2-layer architecture**, organised as a lifecycle with hard gates between phases.

| # | Skill | Domain | Summary |
|---|-------|--------|---------|
| 1 | [`saas-project-kickoff`](./skills/saas-project-kickoff/) | 🧭 Orchestration | Single entry point. Detects the real project phase, invokes the right skill, enforces Gates 0–3 and maintains `PROJECT_STATE.md` |
| 2 | [`saas-agent-rules`](./skills/saas-agent-rules/) | 🤖 Agent constitution | 6 immutable laws, Risk Lanes, multi-model routing, token-budget management, adversarial self-correction |
| 3 | [`saas-architecture-blueprint`](./skills/saas-architecture-blueprint/) | 🏗️ Phase 0 | The 12 irreversible decisions — tenancy, identity, IDs, entitlements, audit, migrations, cache isolation — closed in writing before any code |
| 4 | [`saas-security-workflow`](./skills/saas-security-workflow/) | 🛡️ Security doctrine | 3 shields, 13 commandments, 30-minute production matrix, dual OWASP (Web + LLM), EU AI Act Art. 50, StampHog gate |
| 5 | [`saas-adversarial-audit`](./skills/saas-adversarial-audit/) | 🔎 Code-level audit | 40+ failure patterns of AI-generated code, stack-routed auditor prompts, and a deterministic grep scanner |
| 6 | [`saas-definition-of-done`](./skills/saas-definition-of-done/) | ✅ Quality gate | 16-point DoD — makes "done" objective, deterministic and audit-proof |
| 7 | [`saas-billing-unit-economics`](./skills/saas-billing-unit-economics/) | 💳 Billing | Red Lane Gate, the 4 golden rules, idempotency, anti-chargeback, dunning, $0.10 cost circuit-breaker |
| 8 | [`saas-production-readiness`](./skills/saas-production-readiness/) | ⚙️ Operations | 13-layer deploy gate, smoke test on the real domain, rollback under 60s, restore drill, incident runbooks |
| 9 | [`saas-compliance-readiness`](./skills/saas-compliance-readiness/) | 📑 Compliance | Evidence-based readiness for GDPR, ISO 27001, ENS, NIS2 and SOC 2 — plus the build-vs-buy stack audit |
| 10 | [`saas-growth-geo`](./skills/saas-growth-geo/) | 📈 Growth | Generative Engine Optimization, `/api/ai-spec.json`, "The Forge" B2B doctrine, Meta anti-ban rules |

### The canonical chain

```
          TRANSVERSAL      ->  saas-agent-rules, saas-definition-of-done

FASE 0 — ESTRUCTURA        ->  saas-architecture-blueprint
   | [GATE 0: 12 decisions closed in writing]
FASE 1 — DESARROLLO        ->  saas-security-workflow + saas-adversarial-audit
   | [GATE 1: 3 shields, 13 commandments, quick-scan with zero CRITICALs]
FASE 2 — MONETIZACION      ->  saas-billing-unit-economics
   | [GATE 2: Red Lane signed, positive margin per tier]
FASE 3 — PUESTA EN MARCHA  ->  saas-production-readiness
   | [GATE 3: 13 layers with no REDs, smoke test, restore drill]
        PRODUCTION

          ON DEMAND        ->  saas-compliance-readiness, saas-growth-geo
```

### The 2 layers

Every skill ships as two files, so the agent pays for depth only when it needs depth:

| File | Size | When it's read |
|---|---|---|
| `quick-ref.md` | ~1 page | Active coding. Compact checklists and tables — no rationale |
| `SKILL.md` | full | When the agent needs the *why*, or the long-form procedure |

`saas-adversarial-audit` adds a third layer: `references/` holds eight stack-specific auditor files, loaded only when that stack is present.

---

## 🔎 The adversarial scanner

```bash
bash skills/saas-adversarial-audit/scripts/quick-scan.sh
```

Run from the root of the project under review. It proves 15 of the 40 patterns in seconds — unsafe raw SQL, mass assignment, unverified JWT decoding, wildcard CORS, unsigned webhook handlers, cron routes without a secret, secrets behind a public env prefix, and more. Exit code 1 when a CRITICAL pattern matches, so it drops straight into CI.

A clean run does **not** mean the code is safe. It means those 15 patterns are absent. The other 25 need the auditor prompts in `references/`, run by a reviewer that is **not** the session that wrote the code.

---

## 🚀 Installation

### Option A — Install as a plugin (recommended)

The repository is its own Claude Code marketplace.

```
/plugin marketplace add jlacera/saas-claude-skills
```

```
/plugin install saas-claude-skills@saas-claude-skills
```

Update later with `/plugin update saas-claude-skills`. Nothing is copied into your project, so your repository stays clean.

### Option B — Copy the skills into one project

```bash
git clone https://github.com/jlacera/saas-claude-skills /tmp/saas-claude-skills
cp -r /tmp/saas-claude-skills/skills/* YOUR_PROJECT/.claude/skills/
```

> ⚠️ Do **not** `git clone` this repository directly into `.claude/skills/`. Skills are discovered one level deep, so an extra wrapper folder means nothing loads.

### Option C — Git submodule (shared across projects)

```bash
git submodule add https://github.com/jlacera/saas-claude-skills .claude/vendor/saas-claude-skills
ln -s ../vendor/saas-claude-skills/skills/saas-security-workflow .claude/skills/saas-security-workflow
```

### Recommended: add the CLAUDE.md template

[`templates/CLAUDE.md`](./templates/CLAUDE.md) carries the rules that should be active in **every** session — the immutable laws, Risk Lane classification, security and billing baselines — plus placeholders for your stack. The skills stay lazy-loaded behind it.

```bash
cp templates/CLAUDE.md YOUR_PROJECT/CLAUDE.md
```

---

## 🧭 How the skills load

Each `SKILL.md` starts with YAML frontmatter containing a `name` and a `description`. Claude reads those descriptions and loads a skill **only when the task matches** — you don't have to name the file.

In practice: ask for a Stripe webhook handler and `saas-billing-unit-economics` loads itself. Touch an RLS policy and `saas-security-workflow` loads. Ask for a code review and `saas-adversarial-audit` loads. You can still force one explicitly:

```
Use the saas-adversarial-audit skill to review this endpoint.
```

If you are unsure which applies, start with `saas-project-kickoff`: it is the router.

---

## 📖 Skill Descriptions

### 1. 🧭 SaaS Project Kickoff — Lifecycle Orchestrator
Detects the real phase of a project instead of asking, invokes the specialised skills in order, and enforces the gates. **Hard rule:** debt from an earlier phase is resolved before advancing — Phase 2 is never built on an unclosed Phase 0. Keeps a versioned `PROJECT_STATE.md` so decisions are not re-litigated every session. Four modes: new project, recovery audit, new feature on a live product, live incident.

### 2. 🤖 SaaS Agent Rules — Operating Constitution
The 6 immutable laws: atomic flow, zero TODOs, scope freeze, traceability in the same PR, immutability of finished code, and **the independent reviewer** — the model that builds does not review. Plus Risk Lanes (🟢🟡🔴), the StampHog auto-block, canonical model routing, and token-budget context discipline.

### 3. 🏗️ SaaS Architecture Blueprint — Phase 0
The 12 irreversible decisions, each answered in writing with its cost of reversal: tenancy model, identity, ID strategy, entitlements, audit trail, migrations, serverless limits, cache isolation. Blocks scaffolding until they are closed. A user table without a tenant column is a stop condition, not a to-do.

### 4. 🛡️ SaaS Security Workflow — Doctrine
OWASP Top 10 Web plus OWASP LLM Top 10 under NIST SP 800-218A. IDOR, Supabase RLS without `USING (true)`, SSRF blocking to private and metadata ranges, no homebrew crypto, MCP human-in-the-loop, slopsquatting checks. Commandments 11–13 added in v2: agent identity, permission-scoped RAG retrieval, signature verification before reading claims. Includes the multi-tenant cross-cache isolation matrix and EU AI Act Article 50.

### 5. 🔎 SaaS Adversarial Audit — Detection
Where the doctrine skills say *what must hold*, this one says *what to look for, in which file, with what verdict*. Eight stack-routed reference files — RAG multi-tenancy, Next.js RSC and middleware, tRPC and GraphQL, identity and OAuth, Prisma and Postgres, webhooks and cron, supply chain and DNS, autonomous agents — plus a deterministic scanner and a mandatory finding format.

### 6. ✅ SaaS Definition of Done — Quality Gate
16 points covering contract, tests, cross-tenant isolation, server-side authorization, log sanitisation, observability, cost instrumentation, staging behind a flag, traceability, **a green adversarial scan**, and **an independent-reviewer audit for Red Lane modules**. Extra requirements per module type: Red Lane, UI, generative AI, and data ingestion.

### 7. 💳 SaaS Billing & Unit Economics
Provision only on a cryptographically verified webhook — never on `success_url`. One idempotency key per charge. Strict test/live key isolation. The price never comes from the client. Cost instrumented per invocation with a $0.10 flag, monthly ARPU-minus-CPU margin review, hard spend caps, anti-chargeback protocol and dunning sequence.

### 8. ⚙️ SaaS Production Readiness
13-layer traffic-light audit — one RED and there is no deploy. Pre-deploy checklist, smoke test on the real domain including mobile, rollback tested and timed under 60 seconds, backup **restore drill** executed and dated, alerts validated by causing a real staging error, and incident runbooks.

### 9. 📑 SaaS Compliance Readiness
Framework priority for the European market: GDPR → ISO 27001 → ENS for public sector → NIS2 by scope → SOC 2 only when a contract demands it. A 10-control readiness matrix answered with evidence, never intention; a reusable security-questionnaire master document; and the build-vs-buy audit that decides which subscriptions to replace with directed AI builds.

### 10. 📈 SaaS Growth & GEO
Acquisition aimed at AI agents, not only human searchers: server-rendered JSON-LD for the "Agentic 6", the public `/api/ai-spec.json` endpoint, the "Forge" no-budget B2B outreach doctrine, and the Meta anti-ban rules for WhatsApp Cloud API and Instagram automation.

---

## 🆕 What changed in v2.0.0

- **Merged two diverging sets into one.** The lifecycle plugin (orchestrator, blueprint, security workflow, billing, production readiness) and the original six topic skills are now a single versioned source of truth. The v1 topic files are preserved under [`docs/legacy/`](./docs/legacy/).
- **New:** `saas-adversarial-audit` — 40+ failure patterns of AI-generated code with stack-routed auditor prompts and `quick-scan.sh`.
- **New:** `saas-compliance-readiness` — EU-first certification readiness and the build-vs-buy audit.
- **Law 6 added** to the agent constitution: the model that builds does not review.
- **DoD grew from 14 to 16 points**: green adversarial scan, and an independent-reviewer audit on Red Lane modules.
- **Commandments 11–13 added** to the security workflow: agent identity, permission-scoped RAG, signature verification before reading claims.
- **Renamed** for a consistent `saas-*` namespace: `master-agent` → `saas-agent-rules`, `definition-of-done` → `saas-definition-of-done`, `crecimiento-growth` → `saas-growth-geo`.

---

## ✅ Validation

```bash
python3 scripts/validate.py
bash -n skills/saas-adversarial-audit/scripts/quick-scan.sh
```

The validator guards the two failure modes that have actually shipped from this repository: control characters buried in published markdown, and a `SKILL.md` without frontmatter (which makes the skill inert wherever it sits). It also checks that both layers exist for every skill and that the manifests are valid JSON. CI runs it on every push and pull request.

---

## 📄 License

MIT — see [LICENSE](./LICENSE).
