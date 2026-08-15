#!/usr/bin/env python3
"""Guard the two failure modes that have actually shipped from this repository.

1. Control characters buried in published markdown. Every .md here was once
   generated from a PowerShell here-string, where the backtick is the escape
   character: `tenantId` became TAB + "enantId", `fix(...)` became FF + "ix(...)",
   `npm` became a line break. Fourteen of those reached the public repo.
2. A SKILL.md without YAML frontmatter. Claude Code discovers skills by their
   frontmatter description; without it the file is inert wherever it sits.

Run with no arguments from the repository root. Exits non-zero on any finding.
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
# Everything below 0x20 except \n. \t is included on purpose: a tab in markdown
# is either invisible indentation or the residue of an eaten backtick.
CONTROL = re.compile(r"[\x00-\x09\x0b-\x1f\x7f]")
CONTROL_NAMES = {"\t": "TAB", "\f": "FF", "\v": "VT", "\r": "CR", "\x08": "BS", "\x07": "BEL"}

errors: list[str] = []


def rel(p: pathlib.Path) -> str:
    return p.relative_to(ROOT).as_posix()


for path in sorted(ROOT.rglob("*.md")):
    if ".git" in path.parts:
        continue
    raw = path.read_bytes()
    if raw[:3] == b"\xef\xbb\xbf":
        errors.append(f"{rel(path)}: byte order mark (save as UTF-8 without BOM)")
    text = raw.decode("utf-8")
    if "\r\n" in text:
        errors.append(f"{rel(path)}: CRLF line endings (.gitattributes pins LF)")
    for lineno, line in enumerate(text.replace("\r\n", "\n").split("\n"), 1):
        for match in CONTROL.finditer(line):
            ch = match.group()
            name = CONTROL_NAMES.get(ch, f"\\x{ord(ch):02x}")
            errors.append(f"{rel(path)}:{lineno}: control character {name} in text")

skills_dir = ROOT / "skills"
skill_names: list[str] = []
for skill in sorted(p for p in skills_dir.iterdir() if p.is_dir()):
    md = skill / "SKILL.md"
    if not md.exists():
        errors.append(f"skills/{skill.name}: no SKILL.md")
        continue
    text = md.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        errors.append(f"{rel(md)}: missing YAML frontmatter, the skill will never load")
        continue
    front = text.split("---\n", 2)[1]
    name = re.search(r"^name:\s*(\S+)\s*$", front, re.M)
    if not name:
        errors.append(f"{rel(md)}: frontmatter has no 'name'")
    elif name.group(1) != skill.name:
        errors.append(f"{rel(md)}: name '{name.group(1)}' does not match folder '{skill.name}'")
    else:
        skill_names.append(skill.name)
    if not re.search(r"^description:", front, re.M):
        errors.append(f"{rel(md)}: frontmatter has no 'description', nothing will trigger the skill")
    elif not re.search(r"\bUse (when|at|before|after|while|during|for|to)\b", front):
        errors.append(f"{rel(md)}: description never says when to use the skill ('Use when ...')")
    if not (skill / "quick-ref.md").exists():
        errors.append(f"skills/{skill.name}: no quick-ref.md (the compact layer)")

for manifest in ((ROOT / ".claude-plugin/plugin.json"), (ROOT / ".claude-plugin/marketplace.json")):
    if not manifest.exists():
        errors.append(f"{rel(manifest)}: missing")
        continue
    try:
        json.loads(manifest.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        errors.append(f"{rel(manifest)}: invalid JSON ({exc})")

if errors:
    print(f"validate.py: {len(errors)} problem(s)\n")
    for e in errors:
        print(f"  {e}")
    sys.exit(1)

print(f"validate.py: OK. {len(skill_names)} skills, both layers present, manifests valid.")
print("  " + ", ".join(skill_names))
