# MikroTik forum and docs: RFC 2544 / Y.1564 testing with RouterOS

Scope: forum.mikrotik.com (old phpBB `viewtopic.php` URLs and the newer Discourse `/t/` URLs) plus help.mikrotik.com. Research date 2026-09-30, via web search + page fetches (about 27 tool calls). Thread contents were read through a summarizing fetch tool, so short quotes are as that tool returned them. Where a "no staff reply" claim appears, it means none showed up in the fetched page.

## 1. Are there posted RouterOS scripts implementing RFC 2544 or Y.1564 style tests?

### Takeaway
None found. No forum thread I could locate posts a `.rsc` that steps frame sizes, binary-searches for throughput, or runs CIR/EIR steps with btest or traffic-generator. The btest scripts posted on the forum are one-shot speed checks that alert or log. The user's script seems to be further along than anything public on the MikroTik forum.

### Cited Findings
- "Bandwidth test script?" (28 Feb 2023, oguruma; replies rextended, cdhtlr): asks how to run periodic btests and store results for customer-slowness complaints. No script is posted. cdhtlr suggests running btest or an Ookla speedtest container from `/tool netwatch`. No sizes, UDP/TCP choice or loss parsing is discussed. — [forum](https://forum.mikrotik.com/t/bandwidth-test-script/164778)
- "Mikrotik Bandwidth test scriptting" (Jan-May 2020, cumhureren): a btest script that sends rx speed to Telegram, and fixes so it only alerts under 7 Mbps. sopyan0807 gives `:if ($rxta <= "7") do={ /tool fetch url=... }`. SiB parses the number before "M": `[pick $Rx 0 [:find $Rx "M"]]`. It is a throughput alarm, with no loss or size sweep. — [forum](https://forum.mikrotik.com/t/mikrotik-bandwidth-test-scriptting/136274)
- Other btest scripting threads came up in search but were not opened. Their titles suggest scheduled or logged speed tests, not RFC 2544 methodology: "script to run manual bandwidth test and save to file" ([t/115494](https://forum.mikrotik.com/t/script-to-run-manual-bandwidth-test-and-save-to-file/115494)), "Bandwidth test daily" ([t/117724](https://forum.mikrotik.com/t/bandwidth-test-daily/117724)), "Bandwidth-test in a script" ([t/17175](https://forum.mikrotik.com/t/bandwidth-test-in-a-script/17175)), "bandwidth tests script" ([t/1625](https://forum.mikrotik.com/t/bandwidth-tests-script/1625)). — [search results](https://forum.mikrotik.com/t/bandwidth-test-in-a-script/17175)
- A search for rfc2544 plus frame sizes 64/128/256/512/1024/1518 plus bandwidth-test returned no forum script that sweeps those sizes. — [search](https://forum.mikrotik.com/t/mikrotik-bandwidth-test-scriptting/136274)

### Inferences
- There seems to be no community precedent for scripted RFC 2544 or Y.1564 on RouterOS. When forum users run real RFC 2544 or Y.1564 tests, they use external testers (see section 5).

### Gaps
- The site search engine only indexes part of the forum. Discourse's own search (forum.mikrotik.com/search) was not queried directly, so a low-visibility script post could have been missed.
- The four btest-script threads listed only by title were not opened.
- No Y.1564 or CIR/EIR step script was found anywhere.

## 2. /tool/traffic-generator for RFC 2544: capabilities, limits, bugs

### Takeaway
Traffic-generator is MikroTik's raw-packet tester for a DUT or SUT. It measures latency, jitter, loss and out-of-order, and has a `quick` mode. It runs on the router CPU, though, and staff say small frames hit that limit first. In a Nov 2025 thread, MikroTik staff (BartoszP) told a user whose 64 B zero-loss test failed to use external generators. The docs never mention RFC 2544 or Y.1564.

### Cited Findings
- Docs: it is "a tool that allows evaluating the performance of DUT (Device Under Test) or SUT (System Under Test)". It generates raw packets and can route them back to itself.
  - It collects latency and jitter, including `/tool traffic-generator stats latency-distribution`; loss as LOST-PACKET and LOST-RATE; out-of-order when `measure-out-of-order` is on; and TX/RX Mbps and pps.
  - `quick` "allows to quickly start the packet generator and print the stats output to the terminal", overriding `duration`, `mbps`, `packet-size`, `pps` and `stream`.
  - `packet-template` settings: `header-stack` (mac, vlan, ip, udp, raw); `packet-size` as a single value or a random range such as "100-1500"; up to 16 values each for `ip-src`, `ip-dst` and the udp ports; at most 16 templates.
  - `stream` takes `mbps`, `pps`, `packet-size`, `tx-template` and `port`. `port` maps `interface`.
  - On multi-core CPUs `measure-out-of-order=no` is the default, because enabling it pins a stream to one core.
  - The page does not mention RFC 2544 or Y.1564. — [help.mikrotik.com Traffic Generator](https://help.mikrotik.com/docs/spaces/ROS/pages/128221376/Traffic+Generator)
- "Traffic Generator Limitations?" (26 Nov - 13 Dec 2025, dc_rl):
  - Setup: two CCR2004-16G-2S+ testing a switch at 36 Mbps with 64/128/256/512/1024/1280/1518 B. 64 B dropped packets consistently and other sizes were inconsistent. The pass criterion was zero loss.
  - chechito: TG "is not a substitute for a proper hardware testing appliance."
  - **BartoszP (MikroTik staff)**: "Built-in traffic generator relies on router's CPU... The smaller packets, the closer that point is." He recommends external generators, and later adds "the more accurate the measure... the lower average speed you have."
  - robertkjonesjr: watch System > Resources and treat CPU over ~75% as the device's capacity. He uses TG only as a first cut before professional tools. — [forum t/266687](https://forum.mikrotik.com/t/traffic-generator-limitations/266687)
- "How to use traffic generator" (May 2015, David1234): posts `add name=r12 header-stack=mac,ip,udp ip-gateway=... ip-dst=...` and runs a quick test with 60 B packets at 1 Mbps across two bridged units.
  - First result: TX but zero RX. Second: about 90% loss, latency 72.6 ms to 4.19 s. No staff reply and no resolution, so it looks like a configuration error (gateway/MAC). — [forum t=96920](https://forum.mikrotik.com/viewtopic.php?t=96920)
- Search snippets say that in quick mode the speed is set per stream, so two streams on a port each need half the rate. This came from a search summary, not verified on a fetched page. — [search result pointing to t=96920 / docs](https://forum.mikrotik.com/viewtopic.php?t=96920)
- The old wiki page "Manual:Performance Testing with Traffic Generator" now 307-redirects to help.mikrotik.com/docs, and archive.org could not be fetched, so its contents are unverified. — [wiki URL](https://wiki.mikrotik.com/Manual:Performance_Testing_with_Traffic_Generator)
- A MUM EU 2016 deck, "Securing and testing with Mikrotik" (José Manuel Román), came up for traffic-generator latency and jitter. It is out of lane (MUM) and was not read. — [MUM PDF](https://mum.mikrotik.com/presentations/EU16/presentation_3025_1456818897.pdf)

### Inferences
- TG measures more than btest does: one-way latency and jitter on looped-back streams, out-of-order, and arbitrary L2 headers. It also works port to port, with no btest server login. But it has the same CPU ceiling the user has already seen with btest. The user's INCONCLUSIVE-at-CPU>=90% rule matches the forum view, and the ~75% rule of thumb is more conservative.
- TG sends from one router's ports and measures what comes back to that same router. For a circuit test that means a far-end loopback, which is how RFC 2544 testers work. btest's two-ended client/server model is different.

### Gaps
- No forum thread found with a worked RFC 2544 procedure on TG: binary search, back-to-back or burst tests, or a stepped size sweep.
- No threads found listing TG bugs by RouterOS version. The v7 changelogs were not searched for "traffic-generator".
- It is unconfirmed whether TG `packet-size` counts with or without FCS. The docs fetched don't say.

## 3. Requests for built-in RFC 2544 / Y.1564 / TWAMP / Y.1731, and staff responses

### Takeaway
The only formal feature request found is for Y.1731 performance monitoring. It ran from 2014 to 2022 with community +1s and no staff reply, and it has not been implemented. No request threads were found for RFC 2544, Y.1564 or TWAMP. The closest staff position is normis in 2006: btest is proprietary and you can't install anything on the router.

### Cited Findings
- "Request: Y.1731 Performance Monitoring" (Hammy, 18 Dec 2014 to 4 Nov 2022): asks for ITU-T Y.1731 frame delay, delay variation, loss and throughput measurement to MEF standards.
  - +1s from mmario (2015), nz_monkey (2015 and 2017; wants SNMP traps and Dude integration for SLA monitoring), 3dstrey, omega-00 (2017), and chubbs596 (2022, who also wants IP-SLA). 802.3ah/802.1ag are also mentioned.
  - No MikroTik staff reply. Status: not implemented, not declined. — [forum t=92278](https://forum.mikrotik.com/viewtopic.php?t=92278); [#3 nz_monkey](https://forum.mikrotik.com/t/request-y-1731-performance-monitoring/83838/3)
- "Mikrotik bandwidth test software; using iperf?" (2006-2015):
  - **normis (MikroTik staff), 12 Apr 2006**: "btest is proprietary, and you can't install anything on a router."
  - stephend (30 Dec 2009): "BTEST does not report latency, jitter or packet loss like IPERF does." He also claims "IPERF ... follows RFC2544". That claim is wrong: iperf does not implement RFC 2544 methodology.
  - FIPTech (Jun 2011): "Never measure device using device itself. Results will never be proper." and "RFC 2544 and EtherSAM ITU-T Y.1564 are standards." He also says iperf lacks mixed multi-stream tests, which matter for mixing VoIP and data.
  - doush (2011): "Mikrotik has to support it" (iperf). — [forum t=7854](https://forum.mikrotik.com/viewtopic.php?t=7854)
- A TWAMP search of the forum found no TWAMP responder or feature-request thread. — [search](https://forum.mikrotik.com/t/routeros-questions/182693)
- A Y.1564 search of the forum found one real hit, the Anritsu thread in section 5. The other hits were unrelated: release threads and a GPON thread. — [forum p=1091689](https://forum.mikrotik.com/viewtopic.php?p=1091689)

### Inferences
- MikroTik has never engaged on carrier SLA test standards in any thread I found. The only visible staff guidance is "use external tools" (BartoszP 2025) and "you can't install anything on the router" (normis 2006). That fits the user's documented one-end limit and the "software-counted loss is a claim" convention.

### Gaps
- MikroTik's non-forum feature-request channel (support tickets and the ideas board) was not checked. Neither was whether RouterOS 7 changelogs added any SLA probe or TWAMP. No evidence was seen for either.

## 4. Known btest inaccuracies discussed

### Takeaway
The forum and docs agree on four points: btest is CPU-bound, UDP receive-direction loss is "normal", lost-packets does not report loss on the far end's transmit path, and a router should not be tested with itself. The docs say UDP size counts IP + UDP headers + data. This matches the user's bench finding that the throttle is metered on the IP packet. No forum thread discusses the payload-versus-IP accounting of `tx-total-average` or the ROS6/ROS7 difference the user measured.

### Cited Findings
- Bandwidth Test docs:
  - The UDP tester sends "110% or more packets than currently reported as received on the other side of the link".
  - "If you use UDP protocol then Bandwidth Test counts IP header+UDP header+UDP data".
  - "Up to RouterOS version 6.44beta39 Bandwidth Test used only single CPU core and reached its limits when core was 100% loaded"; the tool "uses a lot of resources".
  - To test a router's real throughput, "run bandwidth test through the tested router not from or to it... at least 3 routers connected in chain".
  - `lost-packets` is not defined beyond example output, and there is no mention of RFC 2544. — [help.mikrotik.com Bandwidth Test](https://help.mikrotik.com/docs/spaces/ROS/pages/7962644/Bandwidth+Test)
- "bandwidth test - lost packets during receive but not send" (13-14 Mar 2014, dipdip; answered by joshaven): "It is normal to get packet loss with UDP bandwidth on Rx tests because of the way the test works." Loss on the remote's transmit side is not reported back to the client. No staff reply. — [forum t/75168](https://forum.mikrotik.com/t/bandwidth-test-lost-packets-during-receive-but-not-send/75168)
  - This is independent community corroboration of the user's bench finding (2026-09-25) that lost-packets counts only loss into the router that started the test.
- "Why UDP Bandwidth Test always show Lost Packets = 0?" (10 Jul 2020, mikruser; mkx, CZFan): mkx says UDP gives no sender feedback, so a 0 may mean "no data". He thinks the UI should show "N/A or something".
  - He adds that returning stats can fail when end-to-end throughput is below the TX rate and a router is buffering heavily.
  - The discussion mixes in iperf behaviour. No staff reply. — [forum t/141229](https://forum.mikrotik.com/t/why-udp-bandwidth-test-always-show-lost-packets-0/141229)
- Search snippets attribute to normis the statement that "Btest generates random data ... you are maxing out the CPU. You can't run the test on the same router which you are testing". A result also mentions "Slow Btest on Gigabit Routers". Neither page was opened, so treat the quote as unverified. — [forum t=57890](https://forum.mikrotik.com/viewtopic.php?t=57890)
- Other related threads came up in search but were not opened: "CCR2004-1G-12S+2XS - Strange packet loss" ([t/152784](https://forum.mikrotik.com/t/ccr2004-1g-12s-2xs-strange-packet-loss/152784)), "Bandwith test does not provide packet lost when it finish" ([t=85470](https://forum.mikrotik.com/viewtopic.php?t=85470)), "Bandwidth Test with UDP Not Working" ([t=154725](https://forum.mikrotik.com/viewtopic.php?t=154725)).
  - The second title is relevant to the user's finding that the final `done testing` callback is its own interval.
- "Unrecorded packet drops and low level UDP packet loss" (Mar 2011 to Oct 2015; strangermi, RB750G, ROS 4.17): iperf through the router showed 0-1% UDP loss at normal CPU, with no drop counters recorded. No staff reply. — [forum t/45531](https://forum.mikrotik.com/t/unrecorded-packet-drops-and-low-level-udp-packet-loss/45531)
- MikroTik's own published performance methodology, as quoted by lurker888 (24 May 2025): "RFC2544, UDP, 0.1% loss, 30+ sec attempts", configuration "as stated, nothing else".
  - He notes MikroTik does not publish the ROS version, fasttrack state, stream count or ports used, and says v7 is about 30% lower than v6.
  - A search snippet adds that MikroTik tests with Xena test systems at 64/512/1518 B. — [forum t/183886/2](https://forum.mikrotik.com/t/test-configurations-details/183886/2); [p=1144453](https://forum.mikrotik.com/viewtopic.php?p=1144453)

### Inferences
- MikroTik's own RFC 2544 figures use a 0.1% loss threshold and trials of 30 s or more. That lines up with the user's 0.10% SLA and supports the 60 s Extended mode over the 10 s Brief mode for acceptance.
- Nothing on the forum contradicts the user's bench results. The forum's answers are qualitative ("it's normal"). The user's per-flow-counter bench work (units, direction, per-interval delta, ~93% capture) is more rigorous than anything posted there.

### Gaps
- No forum thread found on payload-versus-IP accounting of `tx-total-average` or `rx-total-average`, on ROS6 versus ROS7 btest counting differences, or on lost-packets being a per-interval delta.
- The normis "random data maxes CPU" quote is unverified.

## 5. MikroTik used alongside dedicated testers (EXFO, Viavi, Spirent, Anritsu, Xena, and others)

### Takeaway
Several threads show MikroTik gear as the device under test in real RFC 2544 or Y.1564 runs by hardware testers: Digital Lightwave, Anritsu, TREND/Unipro, Agilent N2X, and Xena (MikroTik's own lab). None uses MikroTik as the tester. No forum mentions of EXFO, Viavi, Spirent, NetAlly, Albedo, Veex, TRex or Netrounds were found.

### Cited Findings
- "Wireless PTP link not passing Y.1564 certification Test" (16 Aug 2024, packetgrinder): two NetMetal 5 (RB921UAGS-5SHPacD) in bridge mode over 11.8 mi, SNR 40-42 dB, CCQ about 95%, tested with an **Anritsu MU909060A**. mkx asked which thresholds failed. No resolution and no ROS version. — [forum p=1091689](https://forum.mikrotik.com/viewtopic.php?p=1091689)
- "RFC2544 Test fail on VPLS circuit" (6-12 Sep 2016, kazoo106): two CCR1072s, 20 km fiber, VPLS, MTU 9100.
  - 128 B frames showed 0.1% frame loss above about 50% of 1G. On 6.36.2, 64 B maxed at about 200 Mbps and 128 B at just over 300 Mbps; the same config through a single router was "perfect".
  - nz_monkey pointed to 6.37rc fixes for VPLS out-of-order. hedele blamed a single-core encapsulation limit (~550 Mbps). — [forum t/101323](https://forum.mikrotik.com/t/rfc2544-test-fail-on-vpls-circuit/101323)
- "VPLS performance is lower than EoIP" (Aug 2014 to Feb 2016, hzdrus): **Digital Lightwave** RFC 2544 testers with smart loopback, Tester A - MT A - MT B - Tester B.
  - CCR: VPLS 150 vs EoIP 300 Mbps at 64 B.
  - CCR1009, 64 B: ROS 6.32.3 gave VPLS 274 / EoIP 304 Mbps; ROS 6.33.2 regressed to 32 / 72 Mbps. — [forum t=87922](https://forum.mikrotik.com/viewtopic.php?f=2&t=87922)
- "CCR2004 poor bridge performance" (19-21 Sep 2020, hzdrus, ROS 6.47.3): a Digital Lightwave tester looped through two 10G ports gave 3.9 Gbps (350k pps at 1396 B), with drops and one CPU core at 100%.
  - Paternot: RFC 2544 means testing "all interfaces at the same time — half with inbound traffic, the other half with outbound." — [forum t=166384](https://forum.mikrotik.com/viewtopic.php?t=166384); [#10 Znevna](https://forum.mikrotik.com/viewtopic.php?p=818112)
- "RB493AH Performance Testing with Analyser" (May-Jun 2012, kolpano, ROS 5.15): a **TREND/Unipro** analyser, compared with MikroTik's specs from **Agilent N2X** and **Xena**.
  - RFC 2544 L3 results: 64 B 38.1 Mbps / 74,405 fps; 128 B 75.6 Mbps; 512 B 96.2 Mbps; 1518 B 98.6 Mbps, at a 3% loss tolerance.
  - Staff member **janisk** explained that MikroTik's figures used independent dual streams with 1% tolerance. — [forum t=61922](https://forum.mikrotik.com/viewtopic.php?t=61922)
- Out of lane but useful context: TUM's MoonGen RFC 2544 report on a CCR1036-8G-2S+ (ROS 6.27, 64-1518 B). — [TUM PDF](https://www.net.in.tum.de/pub/router-benchmarking/rfc2544-mikrotik.pdf)

### Inferences
- The pattern on the forum is that carrier-grade acceptance uses a hardware tester, often with a far-end loopback, and MikroTik is the thing being tested. Nobody on the forum claims btest or TG results as carrier acceptance evidence. That matches the repo's rule to escalate only what both ends agree on, after a reference control.
- Small-frame (64-128 B) loss through encapsulation (VPLS/EoIP) or CPU-switched paths recurs across these threads. That is relevant if the user's 70 B trials run through tunnelled circuits.

### Gaps
- Searches for EXFO, Viavi, Spirent, NetAlly, Albedo, Veex, TRex or Netrounds on the forum found nothing. This is a negative result from web search, not an exhaustive forum search.
- None of the tester threads reached a clear resolution that says whether the failure was the link, the MikroTik config, or RouterOS.
