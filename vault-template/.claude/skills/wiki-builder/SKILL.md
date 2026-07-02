---
name: wiki-builder
description: Synthesize research-area wiki hub pages in 20-Wikis/ from clusters of meeting notes in 10-Meetings/, and keep existing wikis updated as new meetings arrive. Use after meeting-enricher has run, or when asked to build/update wikis.
---

# Wiki Builder

Turns clusters of related meeting notes into a single synthesized hub page per
topic, so the graph reads as hub-and-spoke (wikis and tags as hubs, meetings as
spokes) instead of a hairball of meeting-to-meeting links.

Vault root is the current working directory. Run this after `meeting-enricher`
has finished processing the inbox for this run.

## Step 1 — Cluster meeting notes by topic

Scan every note in `10-Meetings/`:
- Read frontmatter `tags` and `project`.
- Read the `## Related` section for tag-note links (these mirror `tags` but
  confirm them).

Skip notes tagged `fragment` when counting — fragments don't count toward wiki
eligibility (per meeting-enricher's Step 1 classification), even though they
still live in `10-Meetings/`.

For each tag (a candidate "topic"), count how many non-fragment meeting notes
carry it.

## Step 2 — Threshold check

- If a topic has **≥4** meeting notes and **no existing wiki** in `20-Wikis/`
  for it (check `20-Wikis/*.md` frontmatter `topic:` field, not just filename),
  it qualifies for a new wiki.
- If a topic has fewer than 4 meeting notes and no wiki exists yet, do nothing
  for it this run.
- If a wiki already exists for a topic, go to Step 4 (update) regardless of
  count, as long as at least one new meeting note has been added since the
  wiki's `updated` date.

## Filename convention (avoid tag/wiki collisions)

macOS's default filesystem is case-insensitive, and wiki topics are almost
always derived from tag names — so naming a wiki file after its topic exactly
(e.g. `20-Wikis/dbt.md`) will collide with the tag note of the same name
(`30-Tags/dbt.md`). Two notes with the same filename in different folders make
`[[wikilink]]`s ambiguous in Obsidian and silently break the hub-and-spoke
graph shape this system depends on.

To avoid this, **always name wiki files `<Topic> Wiki.md`** (e.g.
`20-Wikis/dbt Wiki.md`, `20-Wikis/RAG Wiki.md`), never bare `<Topic>.md`. Keep
the clean topic name in frontmatter (`topic: dbt`) and as the `# <Topic>` H1 —
only the filename (and therefore the `[[...]]` link text used to reference it)
carries the ` Wiki` suffix.

## Step 3 — Create a new wiki

For each topic crossing the threshold:

1. Read all source meeting notes for that topic in full (Summary, Key points,
   Decisions, Action items — not the raw Transcript, unless something is
   ambiguous and you need to check it).
2. Write `20-Wikis/<Topic> Wiki.md` (see filename convention above):

```markdown
---
type: wiki
topic: <topic>
created: <today's date, YYYY-MM-DD>
updated: <today's date, YYYY-MM-DD>
sources: <count>
---
# <Topic>

## Current state

Synthesized narrative of what is known/decided about this topic across all
source meetings. Write this like a living briefing document a colleague could
read to get fully up to speed — not a bullet list of links. Pull together
decisions, current direction, and unresolved tension across the source
meetings into connected prose.

## Open questions

- ...

## Timeline

- YYYY-MM-DD - [[meeting note]] - one-line what happened

## Sources

- [[meeting note 1]]
- [[meeting note 2]]
```

Use the topic's tag name (capitalized/humanized) as `<Topic>` unless the
meeting notes clearly point to a more specific, more human title.

3. Append to `90-System/pipeline.log`:
   `<ISO timestamp> NEW WIKI: <topic> - sources: <count>`

## Step 4 — Update an existing wiki

If a wiki's topic has gained meeting notes since its `updated` date:

1. Read the existing wiki in full, plus the newly added source meeting notes.
2. Rewrite `## Current state` to incorporate the new information — don't just
   append a paragraph, actually re-synthesize so the narrative stays coherent.
3. Append new entries to `## Timeline` (keep existing entries, keep
   chronological order).
4. Append new notes to `## Sources`. **Never drop existing Sources** — only add.
5. Update `sources:` count and `updated:` date in frontmatter. Leave `created:`
   untouched.
6. Append to `90-System/pipeline.log`:
   `<ISO timestamp> UPDATED WIKI: <topic> - sources: <count>`

## Step 5 — Close the loop (hub-and-spoke linking)

After creating or updating a wiki, go back to every meeting note that is a
source for it and ensure its `## Related` section contains `[[<Topic> Wiki]]`
(the actual wiki filename, per the naming convention above — this is distinct
from the `[[<tag>]]` link that's likely already there). Add the link if
missing; don't duplicate it if already present. Since the wiki and tag links
are textually different (`[[dbt Wiki]]` vs `[[dbt]]`), don't mistake the
existing tag link for satisfying this step. This is what completes the
hub-and-spoke shape — meeting-enricher may not have been able to link to a
wiki that didn't exist yet when it ran.

## Rules of engagement

- Never modify a meeting note's `## Transcript`, `## Summary`, `## Key points`,
  `## Decisions`, or `## Action items` sections — the only meeting-note edit
  this skill is allowed to make is adding a missing wikilink to `## Related`.
- Never drop existing content from a wiki (`## Sources`, `## Timeline` entries)
  when updating it.
- If two topics are near-synonyms (e.g. a tag and a project name covering
  almost the same meetings), prefer building one wiki per **tag**, since tags
  are the controlled vocabulary — don't fragment the hub structure by project
  name unless the project is clearly the more natural hub for those meetings.
