# GitHub code search (authenticated), 2026-09-30

Run with `gh search code` (legacy code-search API, first 100 hits per query) as the owner's
account. The raw hit list is not published.

## Queries and hit counts

| Query | Hits | Notes |
|---|---|---|
| `lost-packets` extension:rsc | 0 | No .rsc file on GitHub reads `lost-packets`. |
| `rfc2544` extension:rsc | 0 | |
| `rfc2544 mikrotik`, `rfc2544 routeros`, `rfc2544 btest` | 0 each | |
| `y1564 mikrotik`, `y.1564 routeros` | 0 each | |
| `bandwidth-test` extension:rsc | 10 | Throughput loggers and config exports. |
| `traffic-generator` extension:rsc | 20 | Config exports; one TG config (below). |
| `local-udp-tx-size` / `remote-udp-tx-size` | 18 / 20 | Mostly LLM reference docs, grammars, API wrappers. |
| `lost-packets bandwidth-test` | 20 | Mostly centrs, MikroDash, docs. |
| `tx-total-average` / `rx-total-average lost-packets` | 29 / 16 | Same set plus loggers. |
| `packet-template`, `ethersam`, `traffic-generator routeros stats`, `traffic-generator quick packet-size` | 100 / 100 / 100 / 91 | Almost entirely unrelated (smart contracts, ns-3 5G, dotfiles). |

Conclusion unchanged: **no code on GitHub implements an RFC 2544 or Y.1564 test with RouterOS tools.**
Caveat: legacy code search only indexes default branches and caps at 100 results per query.

## New repos read (not in the first round)

- **SecOps-7/MikroDash** (602 stars, pushed 2026-09-28), `internal/diag/btest.go`. A RouterOS 7
  dashboard with a btest diagnostic. It reports the run's loss as `last["lost-packets"]`, the
  final reply only (line 124). Given the owner's bench finding that `lost-packets` is a
  per-interval delta, this shows only the last interval's loss, not the run's. The most-starred
  btest consumer found reads the field the way the owner's bench says is wrong. Its comment
  also cites the "110% of what arrives" UDP behaviour.
  https://github.com/SecOps-7/MikroDash/blob/main/internal/diag/btest.go
- **tikoci/centrs** error doc `btest-udp-tx-size-ignored.md` (pushed 2026-09-28): "For UDP
  `--direction both`, the btest wire protocol carries a **single** `tx-size` field, so the
  client and the server transmit with the same packet size." It says `remote-udp-tx-size` is discarded
  when it differs from `local-udp-tx-size` under direction=both. rfc-test.rsc sets both to the same
  `$size` (rfc-test.rsc line ~174), so it is unaffected. Worth a RUNBOOK note if anyone
  edits one without the other. This is clone behaviour, not verified on RouterOS.
  https://github.com/tikoci/centrs/blob/main/docs/errors/routeros/btest-udp-tx-size-ignored.md
- **sfmix/sfmix** (San Francisco Metropolitan Internet eXchange) deploys a **btest-rs** public
  server via Ansible (`snappy.sfmix.org`), with `remote-udp-tx-size=1500` in its example. Per the
  first round, btest-rs sends `tx_size` bytes of UDP payload (not IP packet), so frame sizes
  against it would be 28 B larger than against RouterOS.
  https://github.com/sfmix/sfmix/tree/main/ansible/roles/btest_rs
- **Druvis-Timma/Mikrotik** (126 stars) `BGP with Maris exports/tg.rsc`: a CCR2216 config export
  (RouterOS 7.14alpha21, 2023-12) with two traffic-generator packet templates spraying UDP to wide
  destination ranges, a BGP/routing load rig. Not RFC 2544. (Export contains the device
  serial; not reproduced.)
- **Anrijs/MikroTik-Scripts** `InfluxDB/btest.rsc` (2023): TCP btest transmit then receive, 10
  connections, plus flood-ping, posted to InfluxDB. Logger; ignores loss.
- **euggnio/TestadorMPRS** (Java, 2026, Portuguese): automates btest via the RouterOS API for a
  Brazilian state agency's hosts. 10 s transmit and receive runs, UDP or TCP, averages
  only.
- **tombatossals/troncales** (2013, guifi.net Spain): 8-10 s TCP btest script feeding link graphs.
- **drqst/netmark** (Rust, 2026): a generic load tester with UDP sequence-based loss and
  out-of-order; not MikroTik-specific.
