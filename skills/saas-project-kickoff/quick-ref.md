# 🧭 SaaS Project Kickoff — Quick Reference

## 🚨 Top 3
1. **Do not ask the user what phase they are in. Check it.** Run the detection commands against the repo.
2. **Debt from an earlier phase is resolved before advancing.** Phase 2 is never built on an unclosed Phase 0.
3. **A gate is passed with evidence, not consensus.**

---

## 🔗 Canonical chain

| Phase | Skill | Gate to pass |
|---|---|---|
| Always on | `saas-agent-rules`, `saas-definition-of-done` | Per module |
| 0 — Structure | `saas-architecture-blueprint` | 12 irreversible decisions written down |
| 1 — Development | `saas-security-workflow` + `saas-adversarial-audit` | 3 shields, 13 commandments, quick-scan with zero CRITICALs |
| 2 — Monetization | `saas-billing-unit-economics` | Red Lane signed, positive margin per tier |
| 3 — Go-live | `saas-production-readiness` | 13 layers with no REDs, smoke test, restore drill |
| On demand | `saas-compliance-readiness`, `saas-growth-geo` | Contract-driven |

---

## 🔎 Phase detection

```bash
ls docs/adr/ 2>/dev/null | wc -l
ls CLAUDE.md .mcp.json .env.example 2>/dev/null
grep -rl "tenant_id\|org_id" --include="*.sql" --include="*.prisma" . | head
grep -rl "stripe\|paddle\|lemonsqueezy" --include="*.ts" --include="*.py" . | head
```

Schema with user tables and **no** `tenant_id`/`org_id` → Phase 0 critical, stop everything.

---

## 🧩 Modes
**A** new project · **B** existing project (recovery audit) · **C** new feature on a live product · **D** live incident.

---

## 📎 Deep Context
→ Read [SKILL.md](./SKILL.md) and keep `PROJECT_STATE.md` current.
