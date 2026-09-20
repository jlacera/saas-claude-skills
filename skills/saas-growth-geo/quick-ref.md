# 📈 Growth & Acquisition — Quick Reference

## 🚨 Top 3 (if you read nothing else, read this)
1. **If AI agents can't read your product page, you don't exist.** Server-side render JSON-LD Schema.org markup — AI crawlers don't execute client-side JavaScript.
2. **Sell the outcome, not the technology.** "Your monthly report goes from 3 days to 5 minutes" beats "we use GPT-4o with RAG pipelines".
3. **Zero links in public Instagram comments.** Meta's spam filters flag link-heavy comment bots instantly — redirect via DMs only.

---

## 🔍 GEO — Generative Engine Optimization

### The "Agentic 6" (SSR JSON-LD Markup)

Must be **server-side rendered** in the HTML response — not injected via client JS:

| Entity | Purpose | Fill Rate Target |
|--------|---------|-----------------|
| Product | SKU, GTIN-14, global unique identifiers | > 95% |
| Offer | Price, currency, availability (schema.org/InStock) | > 95% |
| AggregateRating | Aggregate user score — AI quality filter | > 95% |
| Review | Individual reviews — semantic context signals | > 95% |
| FAQPage | Structured Q&A — matches natural language queries | > 95% |
| ReturnPolicy | Return/refund terms — risk signal for recommendation agents | > 95% |

### /api/ai-spec.json Endpoint

Public, machine-readable product spec containing:
- [ ] Pricing tiers and billing schemes
- [ ] Functional capabilities and limits
- [ ] Security certifications (SOC 2, GDPR, ISO 27001)
- [ ] Uptime SLAs and data export options

---

## 🔥 "The Forge" B2B Doctrine

For founders launching without budget or network:

| Step | Action |
|------|--------|
| 1 | **Target high-pain niches** — sectors where manual errors cost real daily money (agencies, clinics, law firms, accounting) |
| 2 | **Sell the outcome** — "3 days → 5 minutes, saving ,500/month" — never mention the tech stack |
| 3 | **3-minute video demo** — personalized Loom/Tella showing their own business problem being solved — not a 30-minute meeting request |
| 4 | **1-click trial link** — let them experience value with their own data before asking for payment info |

---

## 📱 Meta Anti-Ban Rules

### WhatsApp
**Official Business Cloud API only** — QR-based senders (WhatsApp Web reverse engineering) get permanently banned with zero appeal. No exceptions.

### Instagram Automation (7 Rules)

| # | Rule | Limit |
|---|------|-------|
| 1 | **Execution cap** | Max 3 replies per run, **36 per hour** absolute ceiling |
| 2 | **Human-like delay** | Random pause **20–40 seconds** between each comment |
| 3 | **Unique replies** | LLM-generated per user — zero templated/repeated responses |
| 4 | **Deduplication** | Store processed comment IDs in DB — never reply twice |
| 5 | **Error brake** | On 429 Too Many Requests → full stop for **5 minutes** |
| 6 | **Self-exclusion** | Ignore comments from own account and DM-trigger keywords |
| 7 | **No public links** | Zero URLs or hashtags in comments — redirect via DM only |

---

## 📎 Deep Context

For the full GEO implementation guide, ai-spec.json schema, and Meta API configuration:
→ Read [SKILL.md](./SKILL.md)
