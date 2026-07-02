---
name: meeting-enricher
description: Enrich raw meeting transcripts sitting in 00-Inbox/ into structured, tagged, linked meeting notes in 10-Meetings/. Use when asked to process, enrich, or clean up inbox transcripts.
---

# Meeting Enricher

Turns raw transcript dumps in `00-Inbox/` into structured meeting notes in
`10-Meetings/`, tagged from a controlled registry and linked into the graph.

Vault root is the current working directory. All paths below are relative to it.

## Scope

Process every `.md` and `.txt` file directly inside `00-Inbox/` (not
`00-Inbox/duplicates/`). Process files **one at a time, fully, before moving to
the next** — read, enrich, move, log, then proceed.

Skip a file if its frontmatter already contains `status: enriched` — it's
already been processed. This is the idempotency guard; it means it's always
safe to re-run this skill over an inbox that partially succeeded before.

## Step 0 — Duplicate check

Read the first ~200 characters of the inbox file's body (ignore any frontmatter
if present). Compare against the first ~200 characters of the body of every
note in `10-Meetings/`. If it matches an existing note closely enough that it's
clearly the same transcript:

- Move the inbox file to `00-Inbox/duplicates/` (create the folder if needed).
- Append to `90-System/pipeline.log`:
  `<ISO timestamp> DUPLICATE: <filename> matches <existing note> - moved to duplicates/`
- Do not enrich it further. Move to the next inbox file.

## Step 1 — Classify

Read the full transcript. Decide:

- **type**: `meeting` if it reads like a conversation/discussion between people,
  `note` if it's a single-person idea, reflection, or fragment with no
  attendees/decisions/actions structure.
- **word count**: if the body is under ~50 words, this is a `fragment` regardless
  of type — it still gets frontmatter and moves to `10-Meetings/`, but skip wiki
  eligibility (wiki-builder won't count it) and always include the `fragment`
  tag in addition to any other applicable tag(s).
- **source**: `handy` if it reads like raw dictation (first-person, informal,
  no clear multi-speaker turn-taking); `pasted` if it has clear speaker labels
  or formatting suggesting it was copied from Teams/Zoom/Granola.

## Step 2 — Frontmatter

Build this frontmatter block (field order matters, keep it stable):

```yaml
---
type: meeting               # or "note" per Step 1
date: YYYY-MM-DD
title: <inferred concise title>
attendees: [<names found in transcript>]   # omit this field entirely for type: note
source: handy                # or "pasted"
project: <inferred client/project or "internal">
tags: [<from registry only - see Step 3>]
status: enriched
enriched_at: <ISO 8601 timestamp, e.g. 2026-07-01T18:30:00+02:00>
---
```

Date derivation priority: (1) a `YYYY-MM-DD` prefix already in the filename,
(2) an explicit date mentioned in the transcript content, (3) the file's
creation time (`stat` on the file) as fallback.

## Step 3 — Tagging (be reluctant)

This is the most important constraint in this skill. Tag sprawl makes the
registry useless, so the default answer is "use what exists."

1. List `30-Tags/*.md` — the filename (without `.md`) of every file there is
   the complete set of permitted tags. Nothing else is a valid tag.
2. Assign 1–4 tags. Prefer fewer over more. A tag must describe a **major
   theme** of the note — something that would appear if you summarized the
   note in one sentence — not a term that was merely mentioned in passing.
3. Creating a new tag is exceptional. Only do it if **all** of the following
   are true:
   - No existing tag covers the concept, even loosely (check synonyms/parents
     too — e.g. a specific tool under an existing broader tag doesn't qualify).
   - The concept is central to this note.
   - You can name at least two other plausible future notes that would also
     use this tag.
   If any of these fail, do not create the tag — fall back to the closest
   existing tag instead, or drop the concept from tagging entirely.
4. If a new tag is justified:
   - Create `30-Tags/<tag>.md` using `90-System/templates/tag.md`, filling in
     today's date and a one-line definition.
   - Append to `90-System/pipeline.log`:
     `<ISO timestamp> NEW TAG: <tag> - <one-line justification>`
5. Tie-break rule: if genuinely torn between reusing an existing tag and
   minting a new one, always reuse the existing one.
6. Tags are lowercase-kebab-case, matching the tag note filenames exactly.

## Step 4 — Body enrichment

Restructure the note body into this shape. For `type: note` (non-meeting
fragments), omit Decisions and Action items, and skip an attendees-driven
Summary framing — just summarize the idea.

```markdown
## Summary

2-4 sentence summary.

## Key points

- ...

## Decisions

- ...

## Action items

- [ ] ...

## Transcript

<original raw text, unmodified, collapsed under this heading>
```

Omit the Decisions section entirely if there were none, and Action items
entirely if there were none. Never invent decisions or action items that
aren't actually in the transcript.

**Never delete, summarize away, or paraphrase the original transcript text.**
It moves intact, verbatim, under `## Transcript`. Enrichment adds structure
above it; it does not touch the source material.

## Step 5 — Relations

Append a `## Related` section at the bottom, after `## Transcript`:

```markdown
## Related

- [[<tag note>]]        (one per assigned tag)
- [[<other meeting note>]]   (notes in 10-Meetings/ sharing project, attendees, or topic - search for candidates, link only genuinely related ones, max ~5)
- [[<wiki page>]]        (only if a matching wiki already exists in 20-Wikis/)
```

Every `[[wikilink]]` must point to a note that actually exists (tag notes,
other meeting notes, or wiki pages) — check before writing the link. Do not
invent links to notes that don't exist. The one exception: wiki-builder runs
after this skill in the same pipeline invocation and may create a wiki that
doesn't exist yet — you don't need to pre-link to a future wiki; wiki-builder
adds that link itself once it creates the page (see its SKILL.md).

Note: wiki pages are filed as `20-Wikis/<Topic> Wiki.md` (with a ` Wiki`
suffix), not bare `<Topic>.md` — this avoids colliding with the tag note of
the same topic name. If linking to an existing wiki, use its actual filename
(e.g. `[[dbt Wiki]]`), which is textually distinct from the tag link
(`[[dbt]]`) even though both relate to the same topic.

## Step 6 — Move

1. Determine final filename: `YYYY-MM-DD <title>.md` (using the date and title
   from frontmatter). Sanitize the title for filesystem safety (no `/`, `:`,
   etc.) but keep it human-readable.
2. Write the fully enriched content to `10-Meetings/<final filename>`.
3. Remove the original file from `00-Inbox/`.
4. Append to `90-System/pipeline.log`:
   `<ISO timestamp> ENRICHED: <final filename> - tags: [<tags>] - project: <project>`

## Rules of engagement

- Process files strictly one at a time; complete steps 0–6 for one file before
  starting the next.
- Never modify anything under `20-Wikis/` from this skill.
- Never modify the content of an existing note's `## Transcript` section for
  any note (including ones this skill itself is currently processing — the
  transcript is copied once, verbatim, and never touched again).
- If you cannot confidently classify or enrich a file (e.g. it's empty, or
  unreadable), skip it and log:
  `<ISO timestamp> SKIPPED: <filename> - <reason>`
  Leave it in `00-Inbox/` for manual review rather than guessing.
