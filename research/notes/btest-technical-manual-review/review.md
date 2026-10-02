# Review: "Technical Manual: MikroTik RouterOS Bandwidth Test Quirks and Idiosyncrasies"

Reviewed 2026-10-02 against this repo's bench evidence. The manual came with the
predecessor script (`Mikrotik_rfc-corrected.rsc`); the original is kept beside this
file as `_raw_technical-manual.docx` (unverified input - cite this review, not it).

**Verdict:** its core is right and matches the bench. The throttle meters the IP
packet, the displayed averages count the UDP payload, the 64 B arithmetic holds, and
loss must be summed. Five claims are wrong or overreach. The most important one: the
interface counters do not show "a perfect 10 Mbps" - no RouterOS meter counts layer 1.

## Claim by claim

| Section | Claim | Verdict | Evidence |
|---|---|---|---|
| 1 | `local/remote-tx-speed` limits the L3 rate (IP + UDP + data) | **Confirmed** | Throttle `S x 8 x 10,000` gave exactly 10,000 pps at S = 52 and 1500 (`results/rb4011-capacity/bench-rb4011-20261002-meter-layers.txt`); also `bench-rb4011-20260925-*` |
| 1 | The displayed metrics count only the UDP payload | **Confirmed for ROS 7 far ends; wrong for ROS 6** | `tx-total-average` = 24 B and 1472 B per packet at S = 52 and 1500 (same record). Against a ROS 6 far end it counted the IP packet (CLAUDE.md). Also missing: `tx-total-average` is what the FAR END received, not what this end sent. `tx-current` was not checked. |
| 1 | Applies to "v6 and v7" | **Overreach** | See above: the display meter differs on ROS 6. |
| 2 | 64 B IP = 102 B on the wire; 6,274,509 bps for 10 Mbps L1; display 3,529,411 bps | **Arithmetic confirmed** | 64 + 38 = 102; 64/102 x 10M; x 36/64. Matches the verified meters. |
| 2 | "Physical interface counters display a perfect 10 Mbps" | **Wrong** | `/interface` counters, switch counters and Winbox graphs count the frame with FCS (82 B here), so they show 8.04 Mbps; driver counters (78 B) show 7.65 Mbps. Layer 1 (preamble + gap) is not counted by any meter (meter-layers record). |
| 2 | A 3.5 Mbps display "confirms the circuit runs at exactly 10 Mbps L1" | **Only if nothing was lost** | The average is what the far end received, so it confirms delivery of the offered rate, not the line rate itself. |
| 2/summary | "64-byte" test | **Mislabelled** | `size=64` is the IP packet; the Ethernet frame is 82 B. RFC 2544 sizes are frame sizes. `rfc-test.rsc` uses true frames (setting 52 = 70 B frame). |
| 3 | `local-udp-tx-size` below 52 is rejected | **Not tested** | Plausible; the current script's smallest setting is 52. |
| 3 | A 24 B MikroTik tracking header sits in the payload | **Not tested** | Consistent with 52 - 28 = 24, but not observed directly. |
| 3 | At 52 B the user payload is 0, so display scaling divides by zero or pacing locks | **Wrong** | At S = 52 the throttle paced exactly 10,000 pps and the average read 24 B per packet - the 24 B are counted as payload (meter-layers record). The manual's own section 2 counts them too (36 B at 64 = 64 - 28). |
| 4.1 | Speed strings built with a "K" suffix silently fall back to a default rate | **Not tested** | The script avoids it: it passes integers only. A related, confirmed quirk: a `:local` passed as the speed parameter loses its integer type, so `targetBps` is a `:global` (CLAUDE.md). |
| 4.2 | `:local` variables are null inside `do={}` | **Wrong** | `rfc-test.rsc` and every bench tool set and read `:local` counters inside `do={}` (loss, averages, CPU) and they work. The real quirk is the parameter typing in 4.1's note. |
| 4.3 | `lost-packets` is a per-second delta; it must be summed | **Confirmed** | Measured 2026-09-18 and 2026-09-28; the script sums it. Missing: it counts only loss INTO the router that started the test, about 93% of true drops, and the final "done testing" callback is its own interval (CLAUDE.md). |
| Summary | "Real world interface rate 10 Mbps full symmetrical" at every size | **Wrong** | Interface counters would read 8.04 / 8.80 / 9.32 / 9.87 Mbps at 82 / 146 / 274 / 1518 B frames; "symmetrical" needs `direction=both`. |
| Summary | Correct L3 input speeds and display rates | **Arithmetic confirmed** | 7,710,843 / 8,707,482 / 9,752,925 bps and 6,024,096 / 7,755,102 / 9,570,871 bps check out. |

## Not in the manual, but needed

- The throttle has no safety margin; the current script runs at 99% of target.
- On a tagged WAN every packet carries 4 B more than `size + 38` (BACKLOG.md).
- btest's CPU figures are all-core averages (`results/btest-bench/bench-rb4011-20261002-btest-cpu.txt`).
