# saas-agent-harness — Quick Reference

## 🚨 Top 3 (if you read nothing else, read this)
1. **The harness, not the model, decides most of the result.** LangChain went from 30th to 5th on Terminal Bench 2.0 by changing only the harness.
2. **A rule without a control is a hope.** About 4% of security rules in public CLAUDE.md files have a hook, linter or gate behind them. Write the control, keep the prose as the reason.
3. **Measure it or it rots.** 60% of harnesses have no test and no eval. Freeze 20-50 real tasks and compare before/after every change to CLAUDE.md, hooks, skills or model.

## 🧩 The 7 subsystems and the SaaS default

| Subsystem | Default |
|---|---|
| Loop | Stops on a deterministic check (tests, lint, smoke), with iteration and token caps |
| Tools | The minimum set; each subagent gets only its own |
| Context | CLAUDE.md of 100-200 lines as a table of contents; detail in `docs/` and skills; state on disk |
| Controls | Hooks and linters that block; prose only explains why |
| Orchestration | One agent until context runs out; isolated subagents; max 4 handoffs |
| Memory | Structured files in the repo (root cause + prevention rule), never chat dumps |
| Measurement | Frozen task set, OpenTelemetry traces, cost per completed task |

## 📄 Context rules
- `CLAUDE.md` = index. `@AGENTS.md` inside it serves Codex, Cursor, Copilot and Gemini CLI too (Claude Code reads `AGENTS.md` only when there is no `CLAUDE.md`).
- State lives in files (`PROJECT_STATE.md`, `docs/adr/`, progress file), not in the prompt. Dump to disk before compaction, re-read after.
- Machine-generated context files lowered success in an ETH Zurich study: write by hand, keep short, measure.

## 🔒 Prose → control

| Prose | Control |
|---|---|
| "No destructive commands" | `PreToolUse` hook blocking `rm -rf`, `git push --force`, `--no-verify`, `DROP`, `sudo` |
| "Respect the layered architecture" | Import linter in CI |
| "Run the formatter" | `PostToolUse` hook |
| "No payments without review" | StampHog merge gate (`saas-security-workflow` §7) |
| "No secrets in commits" | Pre-commit secret scanner |
| "Keep docs current" | Periodic doc-gardening agent opening PRs |

Every control records its reason and its expiry condition.

## ⏱️ Long-running sessions (Anthropic pattern)
`init.sh` (starts the dev server) · `claude-progress.txt` (what previous sessions did) · `feature_list.json` (every end-to-end feature, `passes: false`; agents may only flip `passes`, after testing in a real browser) · descriptive commits as checkpoints · clean, mergeable state at session end. In Claude Code: one worktree per run, scheduled tasks to relaunch.

## ✅ Verification loop
Iterate until an external check passes ("Ralph loop"). The evaluator sees only spec, tests and diff, never the author's justification. Give the agent the running app, a real browser and queryable logs. Turn every verified manual check into a smoke test.

## 🤖 Subagents: measured limits
- Isolated (brief + tools, cheap) vs forked (inherits the conversation, expensive): choose per task.
- Planner / generator / evaluator with separate contexts and tools.
- More than 4 handoffs almost always fails. A 4-role team barely beat one agent (72.2% vs 71.8%). A reviewer agent lowered success by 8%: use reviewers for Red Lane security, not for pass rate.
- No fan-out without an explicit token and agent budget.

## 🧠 Memory
One fact per entry: what happened, root cause, prevention rule, date, owner. Verify named files/flags before applying. Delete what is no longer true.

## 📊 Evals and cost
- 20-50 frozen real tasks with automatic success criteria; cases where a rule must fire and where it must not.
- `claude plugin eval` for plugins (real model calls: set a budget, pin models in CI).
- Cost per **completed** task, not per request. `effort` low for subagents and triage, high for architecture and audit; never tell the model to think less.
- Traces via OpenTelemetry or a local `metrics.jsonl`; a hook that logs which skill fired. Retire tools and skills unused for a month.

## 🚫 Anti-patterns
800-line CLAUDE.md · prose-only security rules · unmeasured generated context · six-agent teams for everything · reviewer agents to raise pass rate · harness without evals · memory as chat dumps · long sessions without a progress file.

## 📦 Deliverable
Trimmed CLAUDE.md/AGENTS.md · prose-to-control table · hooks and linters with reason and expiry · subagent topology with budgets · memory and progress-file scheme · harness eval set with baseline and cost per task · what has not been measured yet.

---
Full context: `SKILL.md` in this skill. Related: `saas-agent-rules` (what the agent must do), `saas-architecture-blueprint` §5 (where `.claude/` files live).
