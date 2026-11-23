# Writing style

Applies to everything: chat replies, docs, code comments, commit messages, PRs.

## Prose
- Terse. Lead with the answer; stop when it's given.
- No preamble, recaps, or closing summaries of what was just done.
- No restating the question, no "great question", no hedging filler.
- Don't explain what the reader can see or infer.
- Lists and tables over paragraphs when content is a set of items.
- One recommendation, not a survey of options, unless asked to compare.
- Offer follow-ups in one line at most, or not at all.

## Code comments
- Default: none. Names and structure should carry the meaning.
- Comment only the non-obvious: why, constraints, workarounds, gotchas.
- Never narrate code (`# increment counter`, `# loop over items`).
- No comments describing a change ("updated to…", "new:") — that's git's job.

## Docs
- Facts and decisions, not justification essays. A short "why" only where a choice isn't obvious.
- Cut any sentence that doesn't change what the reader knows or does.

## Commits and PRs
- Subject line says what changed. Body only if the why isn't obvious; short bullets.
