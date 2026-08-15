# Contributing to saas-claude-skills

Thank you for your interest in improving these skills! This is a living document — contributions that keep it accurate and useful are genuinely appreciated.

---

## Ways to Contribute

### 🐛 Report an Outdated Rule or Bug
If a rule references an API, tool, or version that no longer exists or has changed behavior, please open an **Issue** with:
- The skill name and section
- What's outdated or incorrect
- A brief description of the current correct behavior

### ✍️ Improve an Existing Skill
1. Fork the repository
2. Edit `skills/<skill-name>/SKILL.md` (full context) or `quick-ref.md` (the compact layer)
3. Open a Pull Request with a clear description of what changed and why

**Guidelines for skill edits:**
- Keep the existing section structure (SECCIÓN I, II, etc.)
- Don't remove rules without explaining the rationale in the PR description
- If a rule has become obsolete, mark it as deprecated with a note rather than silently deleting it
- Preserve the Spanish language of the skills (for consistency with existing content)
- Never touch the YAML frontmatter block unless the trigger conditions genuinely changed — that block is what makes Claude load the skill
- If you edit both layers, keep them consistent: `quick-ref.md` must not state a rule that `SKILL.md` contradicts

### ➕ Add a New Skill
If you have a skill that covers a domain not already addressed (e.g., testing strategies, accessibility, AI agents orchestration), we'd love to include it.

New skills must follow this structure:

```
skills/your-skill-name/
├── SKILL.md
└── quick-ref.md
```

`SKILL.md` **must** open with YAML frontmatter. Without it Claude Code skips the file entirely, no matter where it sits:

```yaml
---
name: your-skill-name
description: >
  What the skill covers, then an explicit "Use when ..." clause naming the
  situations and trigger words that should load it. Written in English so it
  matches how users phrase requests; the body below can be in any language.
---
```

The `name` must match the folder name exactly. The body should:
- Start with a clear title (H1) and a one-paragraph description of the domain it covers
- Be organized into numbered sections (SECCIÓN I, II, etc.)
- Use concrete, actionable rules — not vague principles
- Include code examples where applicable
- Reference specific tools, libraries or standards rather than generic advice

`quick-ref.md` is the compact layer: a "Top 3", checklists and tables, no rationale, and a closing pointer back to `SKILL.md`.

### 🌍 Translate Skills to Another Language
We welcome translations! If you'd like to translate a skill:
1. Create a folder `skills/your-skill-name/translations/`
2. Add the translated file as `SKILL.en.md`, `SKILL.pt.md`, etc.
3. Open a PR referencing the original Spanish file

---

## Pull Request Guidelines

- **One skill per PR** when possible
- Write a descriptive PR title: `fix(seguridad-saas): update RLS policy syntax for Supabase v3`
- Include context in the description: what changed, why, and a reference link if applicable
- PRs that only fix typos are also welcome — small improvements matter

---

## What We Won't Merge

- Rules that promote vendor lock-in without alternatives
- Security shortcuts that contradict OWASP standards
- Content that is AI-generated without human review and validation
- Rules that haven't been tested in a real production environment
- Files written by a generator without reading the result afterwards. Shell here-strings, in particular, eat the backticks in markdown code spans and can leave control characters buried in published text. `scripts/validate.py` catches it, and CI runs it on every PR — run it locally too:

```bash
python scripts/validate.py
```

---

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](./LICENSE).
