# RB4011 capacity (bench, 2026-09-30 / 10-01)

What one RB4011iGS+ (ROS 7.20.7) forwards before it drops 0.1%, per configuration, and the quirks
found on the way. Bench only: this is not the field test. Field acceptance stays on `rfc-test.rsc`.


## Our standard handoff (2026-10-01)

The field build (vendor tag on a VLAN interface, bridged to an untagged client port, customer tags inside =
QinQ) runs on the CPU and carries 1 Gb/s both ways at 64-2040 B with loss under 0.01%, CPU 95-100% at
full-duplex line rate. The RB4011 cannot hardware-offload a QinQ client port (`tag-stacking` sets
hw-offload=false). MTU limit found: the vendor port L2 MTU must be customer MTU + 8 (2032 for 2024), or
frames above it are silently dropped; the VLAN interface MTU does not matter. Records `...-q1-mtu-qinq.txt`, `...-mtu-standard.txt`,
`...20261001-q1q2-handoff.txt`. The SFP+ cage has no switch chip (CPU path); RB4011 ports allow L2 MTU 9578.

## Which meter counts what (2026-10-02)

Verified with packet counts at both ends and a sniffer capture
(`bench-rb4011-20261002-meter-layers.txt`). For an Ethernet frame of `f` bytes including FCS:

| Meter | Bytes per packet | Layer |
|---|---|---|
| Wire / line rate (1 Gb/s) | f + 20 | L1: preamble + inter-frame gap |
| `/interface` counters, switch-chip counters, `monitor-traffic` / Winbox graphs | f | L2 with FCS |
| Ethernet `driver-*-byte`, sniffer `size`, traffic-generator `packet-size` | f - 4 | L2 without FCS |
| btest throttle and `*-udp-tx-size` | f - 18 | L3: IP packet |
| btest `tx/rx-total-average` | f - 46 | L4: UDP payload |

A VLAN tag counts as frame bytes in every L2 meter. Mb/s figures in this README are L2 with FCS
(`f` x pps); "line rate" is L1.

## Placement rules (the short version)

1. **Bridging inside one switch chip is wire speed** (ether1-5 is one chip, ether6-10 the other),
   with or without VLAN filtering. VLAN filtering stays hardware-offloaded on 7.20.7.
2. **Keep heavy L2 on one side of the box.** Crossing ether1-5 <-> ether6-10 goes through the CPU
   even though both ports show `H`: ~450k pps at 64 B, CPU 100% at 512 B, 4-7 ms latency tails.
3. **Routed sites should use fasttrack.** Fasttrack routes a single flow at >= 600k pps (the
   generator's limit); without it one flow gets ~100-200k pps (one CPU core).
4. **One flow = one core.** A single tunnel, a single big transfer, or a single UDP stream sees the
   single-flow numbers below, not the multi-flow ones.
5. **Tunnels need an underlay MTU above the client MTU.** EoIP/VXLAN carry full-size frames by fragmenting on
   a 1500 underlay, which halves or worse their capacity. Underlay MTU 1590 fixed it for 1518 B frames (RB4011
   ports allow L2 MTU 9578). VPLS uses the port's l2mtu and does not fragment.
6. **Encrypted EoIP is the RB4011's hard limit: ~25k pps clean, ~55k pps ceiling** (AES-256-CBC/SHA1,
   hardware). About 100 Mbps at 512 B, ~240 Mbps at 1518 B. Above ~50 Mbps of small-packet or
   ~200 Mbps of mixed traffic over an encrypted tunnel, use a bigger box.
7. **One-way traffic through a hardware bridge floods to the CPU** until the far MAC is learned
   (static host, or any return traffic). Seen as 66-100% DUT CPU on a "hardware" bridge.

## Results

pps with loss under 0.1% on every trial; `>=` = the generator ran out first (the DUT did better);
`line` = 1 Gb/s line rate (1.488M pps @64, 235k @512, 81k @1518). Single direction. Bench management
firewall rules present on the DUT (13 filter rules), so there is no IPv4 fast path.

| Config | 64 B, 1 flow | 64 B, 256 flows | 512 B | 1518 B | Notes |
|---|---|---|---|---|---|
| Bridge, same chip (HW) | >= 739k | - | line | line | DUT CPU ~10% |
| Bridge VLAN filtering, same chip | >= 710k | - | line | line | stays HW-offloaded |
| Bridge, across chips | ~450k | ~500k | line, CPU 100% | line | via CPU despite `H` |
| Bridge VLAN filtering, across chips | ~380k | - | line, CPU 100% | line | |
| Bridge hw=no (CPU) | >= 775k | ~800k | line, CPU 100% | line | |
| Routed, no conntrack | ~100-200k | ~400k | ~100k (1 flow) / line (256) | line | |
| Routed, conntrack | ~100-150k | ~400k | ~50k (1 flow) / line (256) | line | |
| **Routed, fasttrack** | **>= 600k** | ~500k | line | line | DUT CPU 78% at 600k |
| EoIP (encap) | ~300-400k | ~200k | ~100k | 40k frag / >= 60k at MTU 1590 | 0.03-0.06% loss floor |
| VXLAN (encap) | ~250k | ~200-250k | ~200k | 20k frag / >= 60k at MTU 1590 | |
| VPLS (encap, LDP) | ~300k | ~400k | ~200k | ~line (no frag) | lowest CPU of the tunnels |
| EoIP + IPsec (pair) | ~25k | ~25k | ~25k | ~20k (frag) | hard ceiling ~55-57k pps |

Tunnel figures are encapsulation on the DUT only (the generator counts its packets inside the
tunnel), except EoIP+IPsec, where the generator also decrypts: that row is an RB4011 pair.
At 512 B and above, tunnels also lose 42-50 B per packet of 1G underlay capacity.

## Quirks worth knowing

- **EoIP + IPsec requires `allow-fast-path=no`** ("cannot enable fastpath together with ipsec yet").
- **EoIP has a steady ~0.03-0.06% loss floor at 512 B even at 60% CPU.** VXLAN and VPLS don't.
  At a 0.1% SLA, EoIP has little headroom.
- **Loss is not monotonic in rate on single-flow tunnels.** EoIP 1-flow lost 0.6% at 500k pps and
  0.04-0.27% at 800-900k. Random spikes near 0.1% appear well below the limit on several paths.
- **The DUT restarted unprompted once, near the end of the EoIP+IPsec test.** No supout, logs were
  memory-only. After that restart it forwarded at about half speed until a clean reboot. Disk
  logging is now on for BENCH-712. Practical rule: reboot before an acceptance test after heavy
  reconfiguration.
- **During EoIP+IPsec at 256 flows / 1518 B / overload, delivery collapsed to zero** for 30 s,
  with the DUT still answering. Possibly IPsec anti-replay drops after multi-core reordering;
  not verified.
- **Possible loss when flows first get fasttracked**: the first trial after connection setup lost
  0.2-1.8%, twice. Not confirmed.
- **No reordering in any single-flow test.** Multi-flow out-of-order counts are across flows
  (one sequence for the whole stream), not a fault.

## Method

- Generator BENCH-NEW (RB4011, ROS 7.19.5), `/tool/traffic-generator`, ether3 out; back on ether4
  (same chip) or ether7 (other chip). DUT BENCH-712. 1 flow = one UDP 5-tuple, 256 flows = 256 source
  ports. Pass = loss under 0.1% on all three 10 s trials at a rate and at every lower rate
  (`tools/bench/tg-scan.rsc`). Phase 1 used a binary search (`tg-sweep.rsc`); it was replaced
  because loss is not monotonic, and the mid-range phase-1 results were rescanned.
- `packet-size` excludes FCS (64 B frame = 60). DUT CPU is the peak per-core load, read over
  `ssh-exec` from a 1 s scheduler.

## Limits

- The generator is an RB4011: ~740k pps single-flow at 64 B. `>=` cells are floors.
- One unit, 1G ports, single direction, three trials per point. Repeat runs moved results +-10-20%.
  Treat every number as a range.
- Bench management firewall present throughout; a box with no rules may route faster.
- Not tested: plain policy-based IPsec, IPsec decap-only, bidirectional load, SFP+/10G, ROS 6 / 7.12.

## Records

| File | Contents |
|---|---|
| `...20260930-cap-A..F-*.txt`, `...-cap-BC-256flow.txt` | Phase 1 (search method): bridges, routed, VLAN filtering |
| `...20261001-cap-G-eoip-encap.txt` | EoIP search + scans |
| `...20261001-cap-H-vxlan-encap.txt` | VXLAN scans |
| `...20261001-cap-I-vpls-encap.txt` | VPLS scans |
| `...20261001-cap-J-eoip-ipsec.txt` | EoIP + IPsec scans |
| `...20261001-cap-K-routed-firewall.txt` | INVALID (degraded DUT), kept |
| `...20261001-cap-X-drift-check.txt` | The unprompted restart and the reboot that fixed it |
| `...20261001-cap-K-routed-firewall-rerun.txt` | Notrack / conntrack / fasttrack on a clean DUT |
| `...20261001-cap-rechecks-G2-M-B2.txt` | EoIP recheck, underlay MTU 1590, cross-chip rescan |
| `...20261001-research-q5-q6.txt` | Research questions 5 (one-way traffic-generator counting) and 6 (burst test) |
