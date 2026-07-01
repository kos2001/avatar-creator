# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A set of **meta-skills** for Claude Code. It contains no runtime, application code, build, or
test tooling — the deliverables are Markdown skills (`SKILL.md`) that instruct Claude how to
generate other Claude Code artifacts.

The domain concept: an **avatar** is a personalized agent for one individual, materialized as a
Claude Code **subagent** (`~/.claude/agents/<avatar>.md`) plus a set of **dedicated skills**
(`~/.claude/skills/<avatar>-<skill>/SKILL.md`).

## The three meta-skills (`skills/`)

- `create-avatar` — orchestrator. Interviews about a person, then runs the `define-role`
  procedure and the `add-skill` procedure (once per capability). Delegates; does not write files
  directly.
- `define-role` — interviews (Korean, one question at a time) and writes the subagent definition.
- `add-skill` — adds one skill to an existing avatar and updates that avatar's manifest.

Each skill is independently invokable; `create-avatar` just chains the other two.

## Install / deploy

There is no build. "Deploying" a skill means copying its folder into `~/.claude/skills/` so it is
callable from every project:

```bash
scripts/install.sh            # copies all three skill folders (bundled scripts included)
scripts/install.sh --dry-run  # preview only
```

When you edit anything under `skills/`, re-run `scripts/install.sh` — the installed copy is what
Claude actually loads. The two can drift; keep this repo as the source of truth.

## Scripts (deterministic work only)

Only genuinely deterministic/repetitive operations are scripted; all authoring (personas, skill
bodies, interviews) stays as skill instructions because it is LLM work.

- `scripts/install.sh` — dev-time installer (`CLAUDE_HOME` overridable, defaults `~/.claude`).
- `skills/add-skill/scripts/update-manifest.sh <avatar> <skill> "<desc>"` — bundled runtime helper
  that `add-skill` step 5 invokes. Idempotent; removes the `(없음)` placeholder, refuses to insert
  the section outside its bounds, and appends the entry. Do the manifest edit through this script
  rather than hand-editing so the placeholder/dedup logic stays consistent.

## Invariants to preserve when editing skills

- **Manifest is single-source.** An avatar's owned-skill list lives only in the `## 보유 skill`
  section of `~/.claude/agents/<avatar>.md`. `add-skill` edits that section (removing the
  `(없음)` placeholder on first add). Do not introduce a separate registry file.
- **Naming.** Avatar slug = lowercase kebab-case. Skill folders are always prefixed
  `<avatar>-<skill>` to namespace by owner and avoid global collisions.
- **Language split.** Frontmatter `name`/`description` and trigger phrasing stay in English (for
  reliable triggering); interview questions and generated persona/role bodies are Korean.
- **Self-contained (方式 B).** Overlap with existing skills (`skill-creator`, `agent-development`)
  is handled by embedding their key conventions inline in `define-role`/`add-skill` — not by
  runtime delegation or bundled copies. Skills must work with no other skill installed. If you
  change the embedded "저작 규약" sections, they are the reason install stays a 3-folder copy.

## Design record

`docs/superpowers/specs/2026-07-01-avatar-creator-design.md` holds the design and the dated
decision log (e.g. the self-contained referencing decision). Update it when architecture changes.
