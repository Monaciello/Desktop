# Feature Name

## Why

[1-2 sentences: Problem being solved. Why now.]

## What

[Concrete deliverable. How you'll know it's done.]

## Context

**Relevant files:**
- `path/to/file` — [what it does]

**Patterns to follow:**
- [Existing convention, with example file]

**Key decisions already made:**
- [Tech choices, libraries, approaches locked in]

## Constraints

### For Python + Nix Projects

**Must:**
- flake-parts with multi-system support (`x86_64-linux`, `aarch64-linux`, `aarch64-darwin`, `x86_64-darwin`)
- uv for Python dependency management (never pip/poetry/pip-tools)
- pytest for testing with `src/` layout
- No `with` statements in Nix code
- No hardcoded paths — use `config.home.homeDirectory`
- Platform guards for Linux/Darwin-specific deps (`lib.optionals stdenv.isLinux [...]`)
- `pyproject.toml` is single source of truth for Python deps
- Type hints on public interfaces
- Nix devShell provides only: interpreter (`pkgs.python3XX`) + `pkgs.uv` + system C libs

**Must not:**
- No `import <nixpkgs>` (use flakes)
- No `pip install` or `requirements.txt` (use `uv add`)
- No hardcoded secrets (use SOPS)
- No platform-specific code without guards
- No modifying unrelated code
- No new system dependencies unless specified

**Out of scope:**
- [Adjacent features explicitly not included]

### For General Projects

**Must:**
- [Required patterns/conventions]

**Must not:**
- [No new dependencies unless specified]
- [Don't modify unrelated code]

**Out of scope:**
- [Adjacent features explicitly not included]

## Tasks

Break into tasks that:
- Can each be completed in one session
- Have a clear verify step
- Are safe to commit independently

### T1: [Noun phrase — what gets built]

**Do:** [Specific changes]

**Files:** `path/to/file`, `path/to/test`

**Verify:** `command` or "Manual: [specific check]"

### T2: [Title]
...

## Done

[End-to-end verification after all tasks]

- [ ] `nix flake check` passes (for Nix projects)
- [ ] `pytest` passes (for Python projects)
- [ ] `nix develop` drops into working shell
- [ ] Manual: [what to verify in UI/API]
- [ ] No regressions in [related area]
