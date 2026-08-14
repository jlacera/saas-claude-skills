# Contributor Covenant Code of Conduct

## Contributing to saas-claude-skills

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
2. Edit the relevant skill.md file
3. Open a Pull Request with a clear description of what changed and why

**Guidelines for skill edits:**
- Keep the existing section structure (SECCIÓN I, II, etc.)
- Don't remove rules without explaining the rationale in the PR description
- If a rule has become obsolete, mark it as deprecated with a note rather than silently deleting it
- Preserve the Spanish language of the skills (for consistency with existing content)

### ➕ Add a New Skill
If you have a skill that covers a domain not already addressed (e.g., testing strategies, accessibility, AI agents orchestration), we'd love to include it.

New skills must follow this structure:

`
your-skill-name/
└── skill.md
`

The skill.md file should:
- Start with a clear title (H1) and a one-paragraph description of the domain it covers
- Be organized into numbered sections (SECCIÓN I, II, etc.)
- Use concrete, actionable rules — not vague principles
- Include code examples where applicable
- Reference specific tools, libraries or standards rather than generic advice

### 🌍 Translate Skills to Another Language
We welcome translations! If you'd like to translate a skill:
1. Create a folder your-skill-name/translations/
2. Add the translated file as skill.en.md, skill.pt.md, etc.
3. Open a PR referencing the original Spanish file

---

## Pull Request Guidelines

- **One skill per PR** when possible
- Write a descriptive PR title: ix(seguridad-saas): update RLS policy syntax for Supabase v3
- Include context in the description: what changed, why, and a reference link if applicable
- PRs that only fix typos are also welcome — small improvements matter

---

## What We Won't Merge

- Rules that promote vendor lock-in without alternatives
- Security shortcuts that contradict OWASP standards
- Content that is AI-generated without human review and validation
- Rules that haven't been tested in a real production environment

---

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](./LICENSE).
