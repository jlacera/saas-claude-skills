# 🛡️ SaaS Security Workflow — Quick Reference

## 🚨 Top 3
1. **Nothing ships with an open HIGH finding.** The output says "NO PASA A PRODUCCIÓN" explicitly.
2. **RLS active and never `USING (true)`** on every table holding user data, with a cross-tenant CI test that fails on purpose.
3. **RLS does not protect what sits in front of it** — cache, vector store, realtime channels each need their own tenant scoping.

---

## 🧱 The 3 shields
Rate limiting and anti-DDoS · Secret isolation · Input validation.

## ⏱️ 30-minute production matrix
RLS · IDOR · AI rate limit and hard cap · zero client-side auth decisions · storage buckets without public LIST · SSRF blocked to private and metadata ranges · GDPR cascade delete · webhook signatures · no secrets in git history · session expiry and refresh rotation.

## 📜 Commandments 11-13 (added in v2)
11. **Every agent has its own scoped credential** and an immutable audit trail. No borrowed human credentials.
12. **RAG retrieval filters by tenant inside the query**, never after. Retrieved content is delimited and marked untrusted.
13. **Verify the token signature before reading any claim.** Sensitive permissions resolve against the database, not the claim.

---

## 📤 Mandatory deliverable
1. Filled 30-minute matrix with evidence · 2. Findings by severity · 3. Exact patch per High/Medium · 4. Explicit block if any High is open · 5. Standard reference (OWASP, GDPR Art., ISO 27001 Annex A, AI Act Art.).

---

## 📎 Deep Context
→ Read [SKILL.md](./SKILL.md). For file-level detection, load `saas-adversarial-audit/`.
