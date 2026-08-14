# 💳 Billing & Monetization — Quick Reference

## 🚨 Top 3 (if you read nothing else, read this)
1. **Never provision on redirect.** Credits, plans, and roles activate **only** after a cryptographically verified webhook event — never based on success_url redirect.
2. **Idempotency key on every charge.** Send a UUID with each payment request to prevent double-billing on network retries.
3. **.10 circuit breaker.** Auto-alert if any user-facing AI invocation exceeds .10 USD — a runaway loop can burn thousands overnight.

---

## 💰 The 4 Golden Rules of Billing

| # | Rule | Implementation |
|---|------|---------------|
| 1 | **Verify webhook signature** | Validate cryptographic signature using your webhook secret. Reject 400 if invalid |
| 2 | **Async-only provisioning** | Activate access on checkout.session.completed / invoice.paid webhook — never on client redirect |
| 3 | **Idempotency key per charge** | Attach a unique UUID to every payment request header |
| 4 | **Key isolation** | Test keys (sk_test_) in dev/staging only. Live keys (sk_live_) in production only. Never mix |

---

## 📊 Unit Economics Monitor

### Cost-per-Function
- Instrument every LLM/API-touching function with cost tracking (OpenTelemetry, Helicone, Langfuse, or equivalent)
- **Alert threshold**: any interactive user-facing invocation > **.10 USD**
- Track: tokens in/out, API calls, storage per user

### Monthly Margin Audit
`
Margin = ARPU − CPU
         │         │
         │         └─ Cost of Processing per User (tokens + APIs + storage)
         └─ Average Revenue Per User
`
🚩 **Red flag**: any pricing tier where power users' CPU exceeds the tier's ARPU → immediate pricing review.

### Hard Spend Caps
Set **hard monthly limits** (not just alerts) on: LLM API providers, cloud hosting, and third-party services. An infinite loop in an overnight autonomous agent run can drain your budget before you wake up.

---

## 🛡️ Anti-Chargeback Protocol

Dispute rate must stay **below 0.75%** — exceeding this triggers payment network penalties and fund freezes.

| Control | Implementation |
|---------|---------------|
| **Card descriptor** | Use your app name (YOURAPP.COM*PRO), not the legal entity name |
| **Receipt emails** | Auto-send detailed breakdown after every charge |
| **1-click cancel** | Visible cancellation button in customer portal |
| **Auto-pause on dispute** | On charge.dispute.created → pause account + collect access logs as evidence |

---

## 🔄 Dunning Strategy (recovering failed payments)

Up to **20% of cancellations** are involuntary (expired cards, insufficient funds).

| Step | Timing | Action |
|------|--------|--------|
| 1 | Immediate | Smart Retries — retry at optimal times based on issuing bank patterns |
| 2 | −14 days before expiry | Pre-expiry email sequence — "your card expires soon" |
| 3 | After failed charge | 7-day grace period — partial access, not instant termination |

---

## 🌐 International Billing

- **Timestamps**: All billing dates in TIMESTAMPTZ (UTC) — never server local time
- **Multi-currency**: Enable adaptive pricing to display local currency (USD, EUR, GBP, MXN)
- **Tax automation**: Delegate VAT/GST/Sales Tax to provider tax engine — don't code tax logic manually

---

## 📎 Deep Context

For the full transactional safety framework, webhook code patterns, and adaptive pricing details:
→ Read [skill.md](./skill.md)
