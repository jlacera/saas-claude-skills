# 🏗️ SaaS Architecture Blueprint — Quick Reference

## 🚨 Top 3
1. **No code until the 12 decisions are written down**, each with its cost of reversal.
2. **`tenant_id` / `org_id` in the initial schema.** Retrofitting tenancy is the single most expensive migration in a SaaS.
3. **`users` / `organizations` / `memberships` modelled separately** from day one. A user is not an account.

---

## 📋 The 12 irreversible decisions

D1 Tenancy model · D2 Identity: user ≠ organization · D3 Roles and permissions (RBAC) · D4 ID format (UUIDv7 vs sequential) · D5 Entitlements and plan limits · D6 Audit trail and deletion · D7 Migration strategy · D8 Time zone, currency and localization · D9 Serverless ↔ container boundary · D10 Multi-tenant isolation in shared layers (cache, vectors, storage) · D11 Pre-wired scale traps · D12 Allowed complexity level (anti-over-engineering gate).

Each answer records: **the decision · why · what it costs to reverse · Risk Lane assigned**.

---

## 🚦 Risk Lanes
🟢 Docs, tests, local UI · 🟡 Business logic, standard integrations · 🔴 Auth, payments, PII, migrations, high-traffic public APIs (AI drafts only, human line-by-line review).

---

## ⚠️ Stop conditions
- User tables without a tenant column → stop, this is Phase 0 critical
- Stack chosen before the data model → the model drives the stack, not the reverse
- "We will add multi-tenancy later" → it is not a later, it is a rewrite

---

## 📎 Deep Context
→ Read [SKILL.md](./SKILL.md)
