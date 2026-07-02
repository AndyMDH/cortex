[Client Kickoff Call - Riverside Logistics]

Tom (Riverside, Ops Director): Thanks for jumping on, excited to get started. Quick context for you both: we're a mid-size logistics company, about 40 trucks, and right now all our route planning is done manually in spreadsheets by two dispatchers.

Andy: Got it. Before we get into scope, can you walk us through a typical day for the dispatchers?

Tom: Sure. Each morning they get the day's orders, manually group them by region, then eyeball which driver should take which route based on truck capacity and roughly where people live. It works but it doesn't scale, we're planning to add another 15 trucks next year and I don't think two people can keep doing this by hand at that size.

Andy: Makes sense. So the immediate goal is some kind of route optimization tool, but let's also understand the data situation, because that usually determines how fast we can move. Where does order data currently live?

Tom: It's in our TMS system, exportable as CSV daily. Truck and driver info is in a separate spreadsheet that our fleet manager maintains manually, it's honestly not always up to date.

Andy: That spreadsheet being stale is worth flagging early, since a route optimizer is only as good as the truck capacity and availability data it's fed. We'll want to sort out a more reliable source for that before or alongside building the optimizer itself.

Tom: Agreed, that's been a nagging problem anyway.

Andy: Okay, here's what I'd propose. Phase one, two to three weeks: we build a simple ingestion pipeline from the TMS CSV export, and work with your fleet manager to get truck/driver data into something more structured, even if it's just a properly maintained spreadsheet with validation for now. Phase two: build the actual route optimization logic and a basic UI for the dispatchers to review and adjust suggested routes, since they'll want an override, not a black box.

Tom: That sounds right. How long for phase two roughly?

Andy: Hard to say precisely until we see the real data, but ballpark six to eight weeks after phase one wraps. We'll firm that up once we've seen actual order volumes and how messy the truck data really is.

Tom: Understood. One more thing, our dispatchers are pretty skeptical of "an algorithm telling them what to do", based on a bad experience with a vendor tool a few years back.

Andy: Good to know, that's a change management thing as much as a technical one. I'd suggest we involve at least one dispatcher directly in reviewing early outputs, so it's clearly a tool that assists them rather than replaces their judgment, and so we catch real-world routing constraints we wouldn't think of ourselves.

Tom: I like that, I'll loop in Dana, she's our most senior dispatcher and honestly the most skeptical, so if she's convinced that's a good sign.

Andy: Perfect. To summarize, decisions: phased approach starting with data ingestion and cleanup before building the optimizer, and Dana gets involved early as a reviewer rather than brought in only at the end. Action items: Andy's team to send a one-pager scoping phase one by end of week, Tom to set up access to the TMS CSV export and introduce us to the fleet manager, and Tom to loop in Dana for the first design review once we have early route suggestions to show.
