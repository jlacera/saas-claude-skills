# 💳 Billing & Unit Economics — Quick Reference

## 🚨 Top 3
1. **Provision only on a cryptographically verified webhook.** Never on `success_url`, never on a client redirect.
2. **The price never comes from the client.** The server resolves the price from its own catalogue by product ID.
3. **Red Lane Gate:** in code that touches money, the AI drafts only. A named human signs, with a date.

---

## 🏅 The 4 golden rules
Webhook signature on the raw body · asynchronous provisioning only · one idempotency key per charge · strict test/live key isolation per environment.

## 🔁 Idempotency
Store the event ID **before** processing · duplicate check before business logic · 24h replay window · return 200 on duplicates (an error triggers another retry).

## 💸 Unit economics
Cost instrumented per invocation, flag above $0.10 · monthly ARPU-minus-CPU margin review per tier · hard spend caps at the provider · per-organization consumption cap, tested.

## 🛡️ Chargebacks
Dispute rate stays under 0.75% · recognisable statement descriptor · receipts on every charge · self-service cancellation · terms accepted with a record.

---

## 🚧 Gate 2 blocks the move to live keys until
Signed Red Lane checklist · webhook dedup proven with a real replay · the 7 mandatory subscription events handled · no tier where p95 user cost exceeds ARPU.

---

## 📎 Deep Context
→ Read [SKILL.md](./SKILL.md)
