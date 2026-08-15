# 🛡️ SaaS Security — Quick Reference

## 🚨 Top 3 (if you read nothing else, read this)
1. **Never trust IDs from the client.** Extract `tenantId`/`userId` from the server-verified session token — never from URL params, headers, or request body.
2. **Prefix every Redis key with tenant ID.** Format: `tenant:{tenant_id}:resource:{id}`. Cache sits *before* the DB — RLS policies don't protect it.
3. **All external input is hostile.** Reviews, emails, webhooks, user messages — treat as potential prompt injection. Agents process them in read-only mode under least privilege.

---

## 🔐 The 10 Security Rules

| # | Rule | Key Directive |
|---|------|--------------|
| 1 | **IDOR** | Server extracts IDs from session, never from request. WHERE id = ? AND tenant_id = session.tenant_id |
| 2 | **RLS** | No USING (true) policies. Views use WITH (security_invoker = true) |
| 3 | **No client-side logic** | Pricing, roles, permissions computed on server only. Hiding a button ≠ security |
| 4 | **Rate limiting** | Per IP + per user on all auth & LLM endpoints. Return 429 when exceeded |
| 5 | **Zero homebrew crypto** | No custom JWT parsers. Delegate to proven auth providers |
| 6 | **Active RLS auditing** | Write adversarial tests that attempt anonymous/cross-tenant access |
| 7 | **No public LIST on storage** | Private files served via signed URLs only (60s TTL max) |
| 8 | **Expensive endpoints = authenticated** | Every LLM/API/analytics endpoint behind auth middleware |
| 9 | **SSRF blocking** | Block outbound requests to 127.0.0.1, 10.x, 172.16.x, 192.168.x, 169.254.169.254 |
| 10 | **Prompt injection defense** | External input = untrusted. Agents operate read-only, least privilege |

---

## 🏢 Multi-Tenant Isolation Matrix

| Layer | Risk | Isolation Directive |
|-------|------|-------------------|
| **Redis / Cache** | 🔴 High | Key format: `tenant:{tenant_id}:{cache_key}` |
| **Vector DB** | 🔴 High | `tenant_id` metadata filter **before** similarity search |
| **Storage / Files** | 🟡 Medium | Path: /tenants/{tenant_id}/files/ + signed URLs |
| **WebSockets / Events** | 🟡 Medium | JWT-scoped channel subscriptions per tenant |

---

## 🇪🇺 EU AI Act — Article 50 Compliance

| Requirement | Implementation |
|-------------|---------------|
| **Disclosure** | Visible, non-removable AI badge on all synthetic content |
| **Consent** | Explicit opt-in gate — pre-checked boxes forbidden |
| **Logging** | Append-only table: `timestamp`, model_name, input_hash, output_hash, user_session_id — 3yr retention |

---

## 🐗 StampHog Protocol (Red Lane Auto-Block)

CI scans every PR diff for these keywords:
`auth · token · password · stripe · billing · pii · migration · rls · rbac`

Match found → auto-merge **blocked** → escalated to senior security + human review.

---

## 📎 Deep Context

For OWASP dual framework details, NIST SP 800-218A alignment, and code examples:
→ Read [SKILL.md](./SKILL.md)
