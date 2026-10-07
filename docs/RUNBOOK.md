# Circuit Testing Runbook

## The script

One script, `rfc-test.rsc`, RouterOS 7 only. It asks for a length first:

| Length | Trial per size | Runtime, all 6 sizes | Use when |
|---|---|---|---|
| **Brief** | 10 s | ~1.5 min | Standard turn-up check. Start here. |
| **Extended** | 60 s | ~6.5 min | Customer deliverable, or confirming something Brief showed. |

Both test the same six Ethernet frame sizes: 70, 128, 256, 512, 1024 and
1500 B. (A true 64 B frame is not possible with btest; 70 B is its floor.)
The script only reads counters and runs `/tool/bandwidth-test`. It changes no
configuration.

## Running

```
/system/script/run rfc-test
```

Four prompts, plus a password if you type an address:

1. **Length** - 1 for Brief, 2 for Extended. ENTER is Brief.
2. **Speed (Mbps)** - the circuit's line rate, digits only. Anything else
   stops the run rather than becoming an unthrottled test.
3. **Server** - pick a DC by number, or type an IP address. Typing an address
   uses the `admin` login and asks for its password.
4. **Sizes** - ENTER for all six, or indexes such as `1,3,5`. An index off the
   list stops the run.

**Run from the more capable router when you have the choice.** The router
that starts the test counts the loss, and a busy one can miscount.

### Credentials

| Login | Where it lives | Used when |
|---|---|---|
| `btest` | in the script file, plaintext | you pick a DC from the list |
| `admin` | asked each run | you type an IP address |

The login follows **how** you entered the target, not **which** target it is:
a DC address typed by hand sends `admin`, and fails if that DC expects `btest`.

RouterOS has no masked input, so the admin password echoes and stays in the
session scrollback. Close the session when done, and strip the password from
any transcript before it leaves your hands. Because the `btest` password is in
the file, **the script is secret-bearing: never paste it into a ticket or
chat.** Result blocks are safe to paste.

## The result block

Brief, 70 B, bench RB4011 -> RB4011, 2026-10-02 (`results/btest-bench/bench-rb4011-20261002-cpu-core-rule.txt`):

```
--- 70 B frame | 20 Mbps | Brief ---
  Test    : BENCH-NEW -> 192.168.78.2
  Arrived : far end got 99% | 99% came back
  Rate    : 19.775 Mbps out | 19.602 Mbps back (L1)
  Lost    : 0 of 247491 coming back (0.00%), SLA 0.10%
  CPU     : this router 31% (busiest core 39%) | far end 32%
  Latency : 0.23 avg, 0.37 max ms
  Note    : loss is counted coming back; outbound only for big loss
  Result  : PASS
```

**Header** - frame size, the speed you asked for, and the length.

**Test** - which router ran it, against which address, so a pasted block says
what was measured. No date: router clocks are often wrong. Put the date in the
ticket yourself. Traffic runs both directions at once.

**Arrived** - how much of the asked packet rate got through, each way.
`far end got` is what the far router received; `came back` is what this router
received. On a clean circuit both read 98-100%: Brief reads a point lower
than Extended because the start-up second weighs more in 10 s. Below 95% in
either direction is a FAIL (see Result).

**Rate** - the same two figures as Layer 1 throughput, including all Ethernet
overhead, so it compares directly with the circuit speed. It assumes untagged
frames. When the test leaves this router inside a VLAN (the standard build tags
it with the vendor VLAN), each packet is 4 B larger on the wire: at 70 B the
script then offers about 3% over the speed you typed, at 512 B and up under it.
Winbox and the interface counters show less than this line: they count the
frame but not the 20 B of preamble and gap (`results/rb4011-capacity/README.md`).

**Lost** - packets lost **on the way back to this router**, out of the number
sent, against the SLA. This is the precise loss figure, counted packet by
packet. The SLA is `slaLimit` at the top of the script, 0.10%. Check the
contract: premium circuits are often tighter. The verdict is judged in parts
per million, so a row can show `0.10%` and still FAIL (0.1001% or worse).

**CPU** - peak load at each end during the trial, plus this router's busiest core.
btest reports each router as an average over its cores, so one core can sit at
100% while the average reads 25-30% (bench, 2026-10-02). This router's busiest
core is read directly; the far end's is not available, so a low far-end figure
does not prove the far end kept up. At 90% or more on any of the three, a router can
lose packets itself, which is why a FAIL there becomes INCONCLUSIVE.

**Latency** - round trip under load, one ping a second during the trial. It
includes queueing in this router behind the test traffic, so a high figure
shows a bottleneck exists, not where it is. The max is one sample; do not
quote it to a carrier as jitter.

**Note** - the one limit of a single run, below.

### What one run can and cannot see

btest counts lost packets only on the router that **started** the test. So:

- **Coming back** (far end -> this router): loss is counted exactly and judged
  against the SLA.
- **Going out** (this router -> far end): only the arrival rate is known, and
  it reads 98-100% on a clean circuit. That catches big outbound loss - 5% or
  more - but not loss at the SLA level. 0.20% outbound loss reads PASS.

This is a documented limit, measured on the bench
(`results/btest-bench/bench-rb4011-20260925-forward-loss.txt`).

**Standard practice:** for a customer acceptance, or before escalating to a
carrier, run it once from each end - each run judges the direction coming back
to the router that started it. A normal turn-up is one run.

## Result

| Result | When | What to do |
|---|---|---|
| **PASS** | Loss coming back within the SLA, and at least 95% arrived each way | Nothing. |
| **FAIL** | Loss coming back over the SLA, **or** under 95% arrived either way | Confirm from the other end before escalating. |
| **INCONCLUSIVE** | It would have failed, but a router reached 90% CPU (either average, or this router's busiest core) | Not a pass. Lower the speed or skip the small frames, then re-run. |
| **NO TEST** | btest never started: a wrong address or login, a firewall, or bandwidth-server off at the far end | Nothing was measured, so it says nothing about the circuit. Fix the cause and re-run. The run stops at the first size. |

A NO TEST prints btest's own reason, for example:

```
  Result  : NO TEST - btest: authentication failed
  ! Nothing was measured. Check the address, the login, and that
  ! bandwidth-server is on at the far end, then re-run.
btest did not run
```

`authentication failed` is the login; `can not connect` is the address, a
firewall on TCP 2000, or bandwidth-server disabled. Before this check, both
read as FAIL with 0% each way (`results/btest-bench/bench-rb4011-20260928-no-connect.txt`).

A FAIL prints why, naming the direction:

```
  ! Only 0% came back
  ! Confirm from the other end before escalating
```

An INCONCLUSIVE prints the same reasons, then the CPU line, so you can see what
the overload may be hiding:

```
  Result  : INCONCLUSIVE
  ! Only 78% arrived at the far end
  ! Only 72% came back
  ! Loss coming back is over the SLA
  ! A router reached 100% CPU - that can cause this loss.
  ! Lower the speed or skip the small frames, then re-run
```

| Line | Meaning |
|---|---|
| `Only N% arrived at the far end` | Outbound is dropping, or this router could not send. A dead outbound path reads 0%. |
| `Only N% came back` | Return is dropping, or the far end could not send. A dead return reads 0%. |
| `Loss coming back is over the SLA` | The packet count, above. |
| `A router reached N% CPU` | INCONCLUSIVE: an overloaded router loses packets on its own. On the bench, two RB4011s at 100% CPU lost 1.9% on a perfect cable. |
| `This router dropped frames in its own queues: ether2 2301` | A hardware counter moved on the named port(s), with the count. On the port the test uses, it is a local fault: fix before blaming the circuit. On a port the test does not use, it is other traffic on this router and says nothing about the circuit. |
| `btest used N streams, not 20` | Figures are not comparable with other runs. |
| `Note : far end looks like ROS 6 - Out% is not meaningful` | Out% read over 110%. A RouterOS 6 far end counts differently, so Out% reads high (216% at 70 B, falling to ~101% at 1500 B). The verdict is unchanged, but "confirm from the other end" cannot be followed: ROS 6 cannot run the script. The fleet is ROS 7; test against a ROS 7 box. |

Every trial is also written to the router log, along with the Max MTU
figure. They are all written in one batch at the end of the run, so a run's
records land together:

```
/log print where message~"rfc "
```

## The summary

```
===========================================================================
  SUMMARY | BENCH-NEW -> 192.168.78.2 | 20 Mbps | Brief
===========================================================================
  Frame       Lost       Sent   Loss%  Out%  Back%  CPU%        Result
  70 B           0     247491    0.00    99     99    39          PASS
  ...
---------------------------------------------------------------------------
  PASS: 6 size(s), 0 lost of 556542 = 0.00% (SLA 0.10%)
  Loss is counted coming back. Outbound is only checked for big loss
  (under 95% arriving). To judge outbound at the SLA, run from 192.168.78.2.
  Path MTU : 1500 B
  WAN errors: ether1 clean
===========================================================================
```

`Out%` and `Back%` are the Arrived figures, `CPU%` the highest of the two ends'
averages and this router's busiest core.
The PASS aggregate covers PASS rows only.

## WAN errors

The script resolves the port the active default route leaves on (the
`immediate-gw` interface of `0.0.0.0/0`) and snapshots its `rx-error`,
`tx-error`, `rx-drop` and `tx-drop` counters before the trials, then again
after the last one. `WAN errors` in the summary reports what grew:

```
  WAN errors: ether1 clean
  WAN errors: ether1: rx-error +4 rx-drop +12
```

Any growth is frames this router's own uplink mangled during the run - treat
it like a queue drop on the test port: a local fault to fix before blaming
the circuit. `not checked - no default route` means the port could not be
resolved, nothing more. The check runs on every run, partial size lists
included; it costs two counter reads.

## Max MTU

Before printing the summary the script probes the path MTU: a binary search
of ping sizes with `do-not-fragment` set, reporting the largest IP packet
that gets a reply. The search floor is 1200 B - a circuit is never below
that - and the ceiling is `mtuCeil` (9216 B by default). The probe runs only when all
frame sizes are selected; a partial list is a diagnostic rerun, and its
summary has no `Path MTU` line. The result is the `Path MTU` line in the
summary:

```
  Path MTU : 1500 B
```

It takes ~13 probes, paced at 0.2 s so a failing probe gives up quickly. Readings are the floor of the
whole round trip - a low figure can be this router's interface MTU, a tunnel
on the way, or the far end, not necessarily the circuit. Ping's
`do-not-fragment` flags only the request; the far end's reply can come back
fragmented, so on a path with a smaller return leg the figure reads high. If
the far end answers no pings at all, the check reports itself unmeasurable -
that is ICMP filtering, and the btest results above it still stand.

## Interpreting - in this order

1. **Result.** PASS on every row is a pass for the direction coming back.
2. **INCONCLUSIVE?** A router was at its limit. Lower the speed and re-run
   before reading anything else.
3. **Queue drops on this router?** Local fault. Fix it first.
4. **FAIL?** Run the same test from the far end. Escalate only what both ends
   agree on, and ideally after a known-good circuit has been used as a control.

## Escalating to a carrier

Paste the result block and summary. A defensible claim reads:

> 512 B frames, 20 Mbps, bidirectional, 0.19% lost (171 of 88,388) on the
> return path, 99% arrived each way, CPU 11% / 12%, no queue drops. Confirmed
> from both ends.

The CPU and queue-drop figures pre-empt "it's your router".

## Known behaviours - not bugs

- **btest's live display shows one second**, the result sums the whole trial.
  `lost-packets: 0` on screen with a non-zero result is normal.
- **Brief reads about a point lower** than Extended on Arrived, from the
  start-up second.
- **The loss count is ~93% of true drops.** The connecting second and the tail
  of the trial fall outside what btest reports. It is the same at every size,
  and the SLA is judged against it.

## If bandwidth-test will not connect

`status: can not connect` means the far end drops UDP/TCP 2000 or its
bandwidth server is off. Check at the far end:

```
/tool/bandwidth-server print
/ip/firewall/filter print stats where chain=input
```

Site routers commonly drop it at input. Testing FROM the site outward needs no
firewall change. Also check the login (see Credentials): the wrong one fails to
connect rather than giving a result.

## Settling a disputed record: per-flow counters

The script cannot count the test flow in isolation. When a figure has to be
defended, count it by hand. This EDITS the firewall - do it deliberately and
remove the rules afterwards. At each end, with B the far end's address:

```
/ip firewall filter add chain=output protocol=udp dst-address=B action=passthrough comment=btc-out place-before=0
/ip firewall filter add chain=input  protocol=udp src-address=B action=passthrough comment=btc-in  place-before=0
```

(`place-before=0` errors on an empty filter list; drop it there.) Per trial:

```
/ip firewall filter reset-counters [find comment~"btc"]      # both ends, before
/ip firewall filter print stats where comment~"btc"          # both ends, after
```

`btc-out` at one end against `btc-in` at the other is the loss in that
direction, exactly. Bytes divided by packets confirms the frame size. Remove
them when finished:

```
/ip firewall filter remove [find comment~"btc"]
```

## Records produced by earlier versions

Records made before this script (the `rfc2544-brief` / `rfc2544-extended`
files, up to commit `30ad142`) used different arithmetic: several were run at
a higher rate than their label, and against a RouterOS 7 far end their Sent,
Loss%, L1 TX and Gen% are skewed by `size/(size-28)`. Their loss COUNTS are
correct. The correction tables and the test for which errors a record carries
are in that commit's runbook: `git show 30ad142:RUNBOOK.md`, section "Records
produced by earlier versions". Do not apply a correction blindly.

## Deploying to a router

Paste the file into a new script named `rfc-test` in Winbox. RouterOS caps
script source at 30,000 bytes and truncates a longer paste silently, then
reports a syntax error at the cut; `tools/check-modes.sh` keeps the file
under 29,000. On RouterOS 7.12.2, `/import` of a file breaks `/terminal/ask`,
so paste rather than import.
