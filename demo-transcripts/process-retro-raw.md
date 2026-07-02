internal retro - incident response process

Sam: so this is the retro on the outage from last week, not to re-litigate the incident itself, we already did that postmortem, this is specifically about whether our incident response process worked.

Dana: from my side, the biggest issue was we didn't have a clear on-call handoff. I paged the wrong person first because the on-call schedule in the tool was actually a week stale.

Sam: yeah that's a real gap, how did it get stale?

Dana: someone updated it in the spreadsheet we used before migrating to the new on-call tool, but the migration didn't actually pull that update in, so it silently reverted to an older schedule.

Sam: okay so that's a one-time migration bug, but it points at a bigger risk, nobody was checking that the on-call tool matched reality. Do we want some kind of periodic check?

Dana: I'd say a lightweight one, like a bot that posts the current on-call person in a channel every Monday, so at least it gets a passive sanity check every week from people who'd probably notice if it's wrong.

Sam: I like that, cheap to build. Second thing on my list, once we did get the right person paged, response was actually fast, so I don't want to lose sight of what worked. The runbook for that service was accurate and up to date, that made a real difference.

Dana: agreed, that's worth calling out explicitly so people keep runbooks updated, it's easy for that kind of thing to only get attention right after it helps you.

Sam: third thing, communication to customers was slower than I'd like, about 25 minutes after we confirmed impact before the status page was updated.

Dana: that was on me, I was heads down on the actual fix and didn't think to delegate the status page update to someone else. We should have a rule that the first responder assigns someone specifically to comms within the first five minutes, even if it's not them.

Sam: yeah let's make that a hard rule, not just a suggestion. I think that covers the main things. decisions: build a lightweight weekly bot posting the current on-call person for passive verification, and add an explicit rule that comms gets assigned to a specific person within five minutes of confirmed impact, separate from whoever's fixing the issue. action items: dana to build the on-call verification bot, sam to update the incident response runbook template with the five minute comms assignment rule, and dana to fix the underlying on-call tool migration gap so the stale schedule issue can't recur.
