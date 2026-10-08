# MikroTik Layer 2 and RFC Testing: Quick Reference

What MikroTik routers can carry at Layer 2, how to configure them for it, how the RFC 2544-style acceptance test works, and where each of those stops being reliable. Part 1 applies to any RouterOS 7 device; Part 2 is specific to the RB4011. Everything here was measured on a two-router bench unless it says otherwise.

## Part 1: Any MikroTik deployment

### How the RFC-style test runs

The acceptance test ([`rfc-test.rsc`](../script/rfc-test.rsc), explained line by line in the [runbook](RUNBOOK.md)) is a RouterOS 7 script that drives the built-in bandwidth test (btest) against a bandwidth server at the far end. It reads counters and changes no configuration.

- **Traffic:** UDP, both directions at once, 20 streams, at the circuit speed you enter, paced so the on-wire rate (layer 1) stays at 99% of it.
- **Frame sizes:** true Ethernet frames of 70, 128, 256, 512, 1024 and 1500 B.
- **Trial length:** 10 s or 60 s per size by default; the menu is the `testLengths` array in the script, so entries can be added or changed.
- **Per size it reports:** the share of packets that arrived each way, packets lost on the return path against the SLA (0.10%), CPU at both ends, latency under load, and drops in this router's own queues.
- **At the end:** a `do-not-fragment` ping binary-search reports the largest IP packet that crosses the path - the path MTU, up to 9216 B.

| Verdict | When |
| --- | --- |
| PASS | Return-path loss within the SLA, and at least 95% arrived each way |
| FAIL | Loss over the SLA, or under 95% arrived in either direction |
| INCONCLUSIVE | It would have failed, but a router reached 90% CPU, so the router may have caused the loss |
| NO TEST | btest never started (wrong address or login, firewall, server off) |

### Reading the numbers

Each RouterOS meter counts a different part of the packet. For an Ethernet frame of `f` bytes including FCS:

| Meter | Counts | 1518 B frame | 64 B frame |
| --- | --- | --- | --- |
| Wire, "line rate" | f + 20 (preamble and gap) | 1538 | 84 |
| Winbox graphs, interface and switch counters | f | 1518 | 64 |
| Driver counters, packet capture, traffic generator size | f - 4 | 1514 | 60 |
| btest speed setting and packet size | f - 18 (IP packet) | 1500 | 46 |
| btest reported averages (RouterOS 7 far end) | f - 46 (UDP payload) | 1472 | 18 |

- A VLAN tag adds 4 B per packet to every layer 2 figure.
- btest's `tx-total-average` is what the far end received, not what this end sent.
- At full line rate with 64 B frames, Winbox shows about 76% of the link and btest about 21%. That is the meter, not loss. At 1500 B all meters agree within 4%.

Evidence: [meter-layers record](../results/rb4011-capacity/bench-rb4011-20261002-meter-layers.txt).

### Configuration rules for any RouterOS device

These are RouterOS behaviours, measured on RB4011s; expect them on other models too, and confirm the numbers per model.

| Area | Rule |
| --- | --- |
| QinQ handoff (service tag on a VLAN interface, bridged to an untagged client port) | The VLAN interface's L2 MTU, which is its port's L2 MTU - 4, caps the customer frame including any tag the customer adds. Set the vendor port's L2 MTU to the customer MTU + 8. The VLAN interface MTU does not apply to bridged traffic, and frames over the limit are dropped with no counter. |
| Tunnels | Underlay MTU at least the client MTU plus the tunnel overhead (EoIP 42 B, VXLAN 50 B), or full-size frames fragment and capacity halves or worse. VPLS uses the port's L2 MTU and does not fragment. |
| Choosing a tunnel | VPLS used the least CPU. EoIP showed a steady 0.03-0.06% loss floor. EoIP with IPsec forces `allow-fast-path=no`. |
| CPU and flows | One flow is processed on one core, so a single tunnel or transfer gets a fraction of the router's total. |
| Routing | Fasttrack is the fastest routed path, 3-6 times plain routing for one flow; connection tracking alone costs little. |
| One-way traffic through a hardware bridge | Until the far MAC is learned every frame floods and the CPU gets a copy. Return traffic or a static bridge host fixes it. |
| Removing a bridge | Remove its ports first; otherwise they stay attached to the deleted bridge and block reuse. |
| Before acceptance | Reboot after heavy reconfiguration: a router once forwarded at half speed after tunnel tests until a clean reboot. |

### Limits of the test method

- **One run judges one direction at the SLA.** btest counts lost packets only on the router that started the test. Outbound loss shows only when 5% or more goes missing. For acceptance or before escalating to a carrier, run once from each end.
- **The loss count catches about 93% of true drops**, because the connecting second and the tail fall outside the per-second readings. Loss reads slightly low.
- **The arrival percentages read 98.5-100% on a clean circuit.** They catch loss of a few percent; the packet count is the precise figure.
- **btest's CPU figures are averages across cores:** one core at 100% read as 26%. The script also checks this router's busiest core; the far end reports an average only.
- **An overloaded router makes its own loss:** 1.9% on a clean cable at 100% CPU. That is what INCONCLUSIVE guards against.
- **On a tagged WAN each packet is 4 B larger than the script assumes,** so at 70 B it offers about 3% over the speed entered; from 512 B up it stays under.
- **btest bursts:** at small frames a router can drop some of its own test packets in its queues at moderate CPU. The script reports these separately and they do not change the verdict.
- **No sizes above 1500 B:** on a 1500 B path btest packets fragment and cannot be measured.

## Part 2: RB4011

### Hardware that shapes performance

| Item | RB4011iGS+ |
| --- | --- |
| CPU | AL21400, 4 cores, 533-1900 MHz |
| Ports | 10 x 1G copper in two switch groups (ether1-5, ether6-10), 1 x SFP+ |
| Switch chips | 2 x RTL8367, one per group; traffic between them goes through the CPU |
| SFP+ cage | Connected to the CPU, not a switch chip |
| Maximum L2 MTU | 9578 copper, 9586 SFP+ |
| Hardware offload | Bridging and VLAN filtering inside one group. Not QinQ: `tag-stacking` turns offload off |

What follows from it:

- **Inside one group**, bridging runs at line rate at every frame size, with or without VLAN filtering, at about 10% CPU.
- **Across groups, through the SFP+ cage, or with a QinQ client port**, every frame is forwarded by the CPU, even when the ports show `H`.
- **Keep a circuit's ports in one group** wherever offload is possible.

### Measured capability

One 1G circuit, loss under 0.1%, one direction unless noted, RouterOS 7.20.7. "Line" is 1 Gb/s; "at least" means the test generator ran out first. Treat each figure as plus or minus 20%.

| Configuration | 64 B frames | 512 B and larger | Busiest CPU core |
| --- | --- | --- | --- |
| Bridge in one group, with or without VLAN filtering | at least 710k pps | line | about 10% |
| QinQ handoff (VLAN interface + bridge), CPU | at least 700k pps (358 Mb/s) | line, up to 2040 B frames | 74-77% |
| Same, both directions at once | 400k pps each way | line each way | **95-100%** |
| Bridge across groups | about 450k pps (230 Mb/s) | line | 100% at 512 B |
| Routed with fasttrack | at least 600k pps | line | 78% |
| Routed without fasttrack, one flow | 100-200k pps | 100k pps at 512 B; line at 1518 B | 100% |
| VPLS | about 300k pps | 200k pps at 512 B; about 970 Mb/s at 1518 B | 28-64% at 1518 B |
| VXLAN or EoIP, underlay MTU large enough | 250-400k pps | 100-200k pps at 512 B; at least 729 Mb/s at 1518 B | up to 84% |
| EoIP + IPsec, RB4011 at both ends | about 25k pps | about 25k pps (102 Mb/s at 512 B) | 100% both ends |

MikroTik's published all-port figures (no firewall, many flows, every port loaded) are higher: 5.5M pps bridging and 92k pps for one IPsec tunnel.

### Use it or upgrade

| An RB4011 is a good fit for | Choose a bigger router when |
| --- | --- |
| One 1G Layer 2 circuit, including a QinQ handoff on the CPU | The same router also runs firewall rules, queues or a second busy circuit |
| Bridging inside one switch group, at any packet size | Heavy small-packet traffic must cross between groups or through the SFP+ cage |
| L2 over a routed network with VPLS, up to about 800 Mb/s of mixed traffic | A tunnel must carry more, or the underlay MTU cannot be raised |
| Routed sites with fasttrack, up to line rate | Many firewall rules or queues prevent fasttrack |
| Encrypted L2 below about 25k pps, roughly 100 Mb/s of mixed traffic | Encrypted traffic above that |

Full detail, method and raw records: [RB4011 capacity results](../results/rb4011-capacity/README.md). Bench: two RB4011s, RouterOS 7.19.5 and 7.20.7, September-October 2026.
