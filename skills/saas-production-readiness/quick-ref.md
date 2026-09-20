# 🚀 Production Readiness — Quick Reference

## 🚨 Top 3
1. **One RED item and there is no deploy.** Delaying 24 hours costs less than an incident at 02:00.
2. **A backup you have never restored is not a backup.** The restore drill is executed, dated and recorded.
3. **Rollback tested and timed under 60 seconds** before go-live, not during the incident.

---

## 🧯 Pre-deploy checklist
13-layer audit with no REDs · restore drill done · rollback timed · alerts validated by causing a real staging error (arrival under 60s) · smoke test on the real domain including mobile · spend caps configured · environment variables verified per environment.

## 💨 Post-deploy smoke test (incognito window)
Landing loads · signup and login work · the core action completes end to end · a paid path reaches the provider in test mode · errors reach the observability tool.

## 🔥 Live incident
Declare the incident and the owner · stop the bleeding (rollback or feature flag) before diagnosing · communicate before customers ask · postmortem without blame, with a dated action and an owner.

## 📈 Hybrid scaling
Move from serverless to containerised workers with a queue when execution exceeds 30s, when persistent connections are needed, or for heavy scheduled jobs.

---

## 📎 Deep Context
→ Read [SKILL.md](./SKILL.md)
