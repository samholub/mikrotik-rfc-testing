# MikroTik RFC Testing

An RFC 2544-style circuit acceptance test for MikroTik RouterOS 7, the bench
research behind it, and measured Layer 2 / Layer 3 capability of MikroTik
hardware (RB4011 so far).

The test runs on the router itself, using MikroTik's built-in bandwidth test
against a bandwidth server at the far end. Every rule it applies, and every
limit it documents, was settled on a two-router bench with independent counters
and packet captures. The records are here.

## What's here

| Folder | Contents |
| --- | --- |
| [`script/`](script/) | `rfc-test.rsc`, the acceptance test (RouterOS 7) |
| [`docs/`](docs/) | [Quick reference](docs/quick-reference.md) (start here) and the [runbook](docs/RUNBOOK.md), which explains every output line and verdict |
| [`results/`](results/) | Bench records: btest's units and behaviour, and [RB4011 capacity](results/rb4011-capacity/README.md) per configuration |
| [`research/`](research/) | Survey reports (existing RFC 2544 / Y.1564 tools for MikroTik, hardware test options) and their sourced notes |
| [`tools/bench/`](tools/bench/) | The scripts that produced the bench records |

## Using the test

1. Open `script/rfc-test.rsc` and edit the configuration block at the top: the
   btest login (`testUser`, `testPass`) and your bandwidth servers (`servers`).
   The far end needs `/tool/bandwidth-server` enabled and a user for that login;
   give that user only the `test` policy.
2. Paste the script into a new script object (Winbox: System > Scripts) and run
   it from a terminal: `/system script run <name>`.
3. Answer the prompts: Brief (10 s per size) or Extended (60 s), the circuit
   speed, the server, and the frame sizes.
4. Read the result with the [runbook](docs/RUNBOOK.md).

The script reads counters only; it changes no router configuration.

## Key limits

- One run judges loss at the SLA in one direction (the return path). For an
  acceptance or a carrier escalation, run once from each end.
- RouterOS 7 at both ends. A RouterOS 6 far end counts differently.
- See [Limits of the test method](docs/quick-reference.md#limits-of-the-test-method).

## Status

Published at milestones, not with every change. Current milestone: RB4011
capacity and the meter checks (October 2026). Planned: more MikroTik models
(RB5009, CRS309/310, CCR2116), 9000 B jumbo frames, SFP handoffs.

## Contributing

Results from other hardware, carriers and RouterOS versions are especially
useful. See [CONTRIBUTING.md](CONTRIBUTING.md), and remove your own addresses,
names and passwords before posting.

## Licence

Scripts and tools: MIT ([LICENSE](LICENSE)). Documentation, research and
results: CC BY 4.0 ([LICENSE-docs.md](LICENSE-docs.md)). Not affiliated with
MikroTik.
