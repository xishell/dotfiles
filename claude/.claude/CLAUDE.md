# User preferences

Loaded every Claude Code session. Project-level CLAUDE.md still applies on top.

## Code comments

**Hard rules — apply even when mimicking existing file style:**
- Lowercase start (unless proper noun / acronym)
- No trailing period
- No `;`, no em-dash (`—`), no ` -- `
- Never start with `The`, `A`, `An`
- One line, even for upstream workarounds. Single cause→effect clause, ~70 chars
- No ticket ids (ENG-nnn, #123) or ADR numbers. Say the reason in words. Log/error strings may keep ids
- No tool markers (`ponytail:`, `TODO(claude):`). Shortcut with a known ceiling: name the ceiling and upgrade path in a plain comment
- Lead with WHY; if comment restates the next line, delete it
- No docstring that just restates the function name

Fragments, abbreviations, run-on phrases all fine. Grammar not required.

Good:
- `// stack auto-restores via SETTINGS=y`
- `// poll debounces for free`
- `// 4Hz easy to spot scanning QR`
- `// gpio 9 is c3 boot strap so poll not isr`

Bad:
- `// The mesh stack restores its provisioning state from NVS automatically because CONFIG_BLE_MESH_SETTINGS=y is set in sdkconfig.defaults.` → leading article, trailing period, restates config, sentence-y
- `// Increment counter` above `i++` → restates code
- `// Initializes the parser` on `fn init_parser()` → restates name
- `// until ENG-354 lands` → ticket id, use `// until live stops reprice`
- `// ponytail: global lock` → tool marker, use `// global lock, per-account locks if throughput matters`

Applies to all languages (C, Bash, Python, JS, Go, Rust, etc.). Commit messages, PR descriptions and human-facing docs use full sentences and normal punctuation — the punctuation rules above are for comments only. What those keep is the density: see below.

## Docs, tickets, PR descriptions

Written for a dev scanning, not a reader. Cut anything that isn't the instruction.

- State the rule, then stop. No sentence explaining why the rule is good — unless it's counter-intuitive, then one `**Why:**` line.
- No aphorisms. "A backlog nobody trusts is a backlog nobody reads" is writing, not instruction.
- No preamble before a table or list. The table says it.
- Say it once. A rule in a table row doesn't also get a paragraph.
- Reassurance ("this isn't used to measure you") shrinks to the clause carrying information.
- Keep lines that decide something: the rule with its consequence attached.
- Examples earn their length. Prose doesn't.

- Status updates: Shipped / Open / Next as bullets with ticket ids.
- Chat reports: findings table or bullets, no closing summary.

Applies to style guides, ADRs, READMEs, Linear tickets and comments, status updates, PR descriptions, chat reports. Code comments and commit messages have their own rules above.

## Commit messages

Conventional Commits. Subject: `<type>(<scope>): <summary>` lowercase, imperative mood ("add" not "added"), ≤72 chars.

Body only when the why isn't obvious from the subject. Multi-change commits: bullet list, no prose.

**Never** include `Co-Authored-By: Claude ...` trailer.

## Feature branch workflow

Commit without asking at every commit point, so any step can be rolled back with git instead of undone by hand. Push and PR still need a go-ahead.

| Action | Rule |
|---|---|
| Commit | automatic at a commit point, feature branch only |
| On `main` | branch first (`eng-<n>-<slug>` or `chore/<slug>`), never commit to `main` |
| Push, open or edit a PR | ask first: `Push <branch> and open PR "<title>"?` |
| Amend, rebase, squash | only unpushed commits |

A commit point is reached when both hold:
- **Atomic:** the change describes in one sentence without "and". One logical concern.
- **Green:** code builds; tests that existed before still pass.

Typical triggers:
- A test passes that didn't before
- A refactor completes and the code still builds
- A self-contained subsystem is done (parser, handler, type, etc.)
- Before a risky change or experiment, commit the green state it starts from
- Before switching to unrelated work in the same session

- Mixed concerns (refactor + feature, two fixes): split into separate commits, stage by path or hunk.
- Stage explicit paths, never `git add -A`: untracked scratch, `.env` and generated files stay out.
- Red for longer than one step: keep working, don't commit broken code to checkpoint. Revert to the last commit if the attempt fails.
- After committing, one line in chat: `Committed <sha> <subject>`.
