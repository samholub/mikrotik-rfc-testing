# MikroTik RFC 2544 / Y.1564 testing: community discussion outside the MikroTik forum (Reddit, X, YouTube, MUM, NANOG/WISPA, blogs)

Research date: 2026-09-30. Scope: Reddit, X/Twitter, YouTube, MUM slides, operator mailing lists, consultant blogs. The MikroTik forum, code repos, native features and the commercial tester landscape are covered by other researchers. A few MikroTik-forum items that turned up are marked [out of lane] and kept only for context.

**Method notes (read first):**
- reddit.com cannot be fetched directly from this environment ("unable to fetch from www.reddit.com"). Web search engines return almost no Reddit results for these terms: `site:reddit.com mikrotik "rfc 2544"` and `site:reddit.com "y.1564" OR "rfc2544" circuit turn up tester cheap` both came back with no Reddit hits.
- Reddit content below came from the PullPush Reddit archive API (api.pullpush.io). After a few queries it returned HTTP 429 with a message that it does not provide free scraping for agents, so I stopped using it. Coverage is partial. The comment texts below were returned verbatim by the API. Links are built as reddit.com + the API permalink and were not opened in a browser.
- The Chrome extension could not be used: two browsers were connected and a subagent cannot ask the user which one to pick.
- diswww.mit.edu NANOG archive pages were down ("Unable to connect to backend discuss server"). NANOG material comes from seclists.org mirrors instead.

---

## 1. Shared scripts, tools, blog posts, videos and MUM talks for MikroTik RFC 2544 / Y.1564 testing

### Takeaway
Outside the MikroTik forum I found **no publicly shared script that turns btest or traffic-generator into an RFC 2544 or Y.1564 acceptance test with PASS/FAIL verdicts**. What exists is generic: MUM slides on traffic-generator (2016, 2017, 2019), generic "how to run btest" YouTube videos and blogs, and one 2026 blog guide with monitoring scripts. None of it covers carrier acceptance. One Reddit commenter (2021) said RFC 2544 "can easily be done with native scripting" but shared no script.

### Cited Findings
- **MUM Europe 2017, "MikroTik Traffic Generator Study Case"**, José Manuel Román (CEO, FiberCLI; MikroTik Certified Consultant/Trainer; CTO of a WISP):
  - Presents traffic-generator as a way to test device PPS, throughput and CPU, and to measure link latency, jitter, loss and bandwidth between sites.
  - Worked examples: a single port, multi-port IPv4/IPv6 templates, and fabricated VoIP (DSCP EF/AF31) plus spoofed packets to test a queue tree.
  - No RFC 2544 procedure, no frame-size sweep, no pass/fail criteria, and nothing on carrier evidence.
  - Sources: [MUM EU17 PDF](https://mum.mikrotik.com/presentations/EU17/presentation_4081_1490963921.pdf); [SlideShare copy](https://www.slideshare.net/slideshow/mum-europe-2017-traffic-generator-case-study/74079603)
- **MUM Europe 2016, "Securing and testing with MikroTik"**, same author: MikroTik tools for testing firewall and QoS policies (SYN flood, VoIP queue tree). Not circuit acceptance. — [MUM EU16 PDF](https://mum.mikrotik.com/presentations/EU16/presentation_3025_1456818897.pdf)
- **MUM Europe 2019, "Understanding throughput OR Common misconceptions on what is 'real' device throughput"** (MikroTik presentation, author not named in the extracted text). Directly relevant to btest:
  - "Traffic generation/elimination takes at least the same amount of CPU resources as simple traffic forwarding"; the router must both generate and forward.
  - Bandwidth-test: "Until v6.44 was single threaded, now both UDP and TCP tests support multi-threading."
  - "In v6.44 we added warning message when CPU load exceeds 90% (CLI only), to inform that CPU is bottlenecking results, not the link."
  - Traffic-generator: can determine transfer rates and packet loss, detect out-of-order packets, collect latency and jitter, and replay pcap files. No TCP support. "Scares people".
  - Speed-test (v6.44+) picks the number of streams from the core count on both devices.
  - Wire overhead: a 64 B frame uses 102 B of wire time (with preamble/IFG) = 62.45%.
  - Source: [MUM EU19 PDF](https://mum.mikrotik.com/presentations/EU19/presentation_6767_1552293932.pdf)
- **Admiral Platform blog, "How to SAFELY speed test on your MikroTik Gear"**, Candice Perea, 2021-09-30 (MSP/consultant blog):
  - "if you see that BTEST is consuming 100% of the CPU on one of your endpoints... the results are probably skewed low and may be significantly inaccurate!"
  - Recommends a separate device under test (DUT) arrangement: end devices A and D run btest while B and C only pass traffic across the link being certified.
  - Also recommends Safe Mode, a `duration=` limit and `local-tx-speed`/`remote-tx-speed` caps.
  - Nothing on carriers or acceptance.
  - Source: [admiralplatform.com](https://admiralplatform.com/how-to-safely-speed-test-on-your-mikrotik-gear/)
- **Tech@Layer-x.com, "MikroTik Traffic Generator: Complete Network Stress Testing Guide"** (byline "admin", 2026-02-01):
  - Provides CLI/WinBox examples plus scheduled test and alert scripts.
  - Does **not** mention RFC 2544, Y.1564 or carrier acceptance.
  - Limits it lists: throughput depends on CPU and architecture, no stateful TCP, generation is single-threaded, and there is no microsecond latency accuracy.
  - Source: [tech.layer-x.com](https://tech.layer-x.com/mikrotik-traffic-generator-complete-network-stress-testing-guide/)
- **YouTube**: only generic btest and traffic-generator how-tos turned up. Titles and approximate ages come from search snippets; the videos were not watched.
  - "Bandwidth Test Using a Mikrotik Router - Get Accurate Throughput For Your Link" (~6 years old) — [YouTube](https://www.youtube.com/watch?v=1usOcGM6-_I)
  - "MikroTik Bandwidth Test - See Your Network Speeds!" (~2 years old) — [YouTube](https://www.youtube.com/watch?v=PWdiRDvhUBk)
  - "MikroTik Bandwidth test tool" — [YouTube](https://www.youtube.com/watch?v=mf2erbPRklE)
  - "MikroTik Traffic Generator" — [YouTube](https://www.youtube.com/watch?v=hR7fmPOPCvM)
- **Reddit, u/eli5questions**, r/networking, 2021-06-02, in "ISPs, what are you using for customer handoff":
  - "Mikrotik has no support for RFC2544/Y.1564 test but it can definitely forward it, its just UDP traffic. RouterOS traffic generator can simulate 2544 with multiple test but requires extra leg work and a less clean certificate. Can easily be done with native scripting. Y.1564 is off the table though as it is for many vendors due to some parameters in the payload."
  - No script was shared.
  - Source: [reddit](https://www.reddit.com/r/networking/comments/m72n7i/isps_what_are_you_using_for_customer_handoff/h0dce13/)
- **Reddit, r/mikrotik, 2023-05-20**: a post titled "RFC2544 test" by u/Ada-04 asks whether RFC 2544 is possible with MikroTik traffic-generator. I could not retrieve the replies. — [PullPush submission search, q=rfc2544](https://api.pullpush.io/reddit/search/submission/?q=rfc2544&size=50)
- **Reddit, u/djdrastic**, r/networking, 2017-10-20: "I use a combination of IPerf, Mikrotik BTest and 2X Mikrotik CCR's running Traffic Generator. Works decently for my purpose," linking MikroTik's wiki page "Performance Testing with Traffic Generator". — [reddit](https://www.reddit.com/r/networking/comments/77hr5v/traffic_generator/dommb1t/)
- **Reddit, u/fiberplz**, r/networking, 2015-09-17: "decent success using traffic generator on a Mikrotik CCR1036-8G-2S+EM at 10Gb... You can always look into true RFC 2544 testers." (Permalink not returned.) — [PullPush comment search](https://api.pullpush.io/reddit/search/comment/?q=mikrotik%20%22traffic%20generator%22&size=100)
- **Reddit, u/d1g1t4ld00m**, r/networking, 2014-04-26: ROS 6.x "have a traffic generator which is like a ethernet test set. You can simulate network traffic and measure the latency, jitter and packet loss over a link." (Permalink not returned.) — same PullPush search as above.
- **Reddit, r/mikrotik, 2024-12-10**, "hAP ax3 vs hAP be³ Media. Is Wi-Fi 7 Worth It?" (u/IcyBlueberry8): compares MikroTik's published RFC 2544 figures, e.g. ax3 821 Mbps bridging at small packets vs be³ 4,861 Mbps at large packets. These are MikroTik's lab numbers, not user tests. — [PullPush submission search](https://api.pullpush.io/reddit/search/submission/?q=rfc2544&size=50)

### Inferences
- The user's script, with a frame-size sweep, loss SLA verdicts, CPU-gated INCONCLUSIVE and per-direction naming, appears more structured than anything shared publicly outside the MikroTik forum. I found no prior art to compare its verdict logic against.
- Community material treats btest and traffic-generator as troubleshooting and capacity tools, not acceptance-test instruments.

### Gaps
- **X/Twitter: nothing found.** Searches tried: `x.com mikrotik rfc2544`; `twitter "rfc2544" OR "y1564" mikrotik routerboard test`; `"y.1564" mikrotik routeros twitter OR linkedin OR reddit`. All returned only MikroTik forum, product pages or Wikipedia. Nitter mirrors were not tried. X search itself needs a login and was not accessible.
- **Named trainers (The Network Berg, IP ArchiTechs / Kevin Myers, Steve Discher):** a search for `"The Network Berg" OR "IP ArchiTechs" mikrotik bandwidth test traffic generator video` turned up no acceptance-testing video from them. IP ArchiTechs' site lists "performance testing" as a service ([iparchitechs.com](https://iparchitechs.com/mikrotik-network-consulting/)), but I found no public methodology. Their YouTube channels were not browsed directly, so absence is not proven.
- No MUM talk titled on circuit acceptance, RFC 2544 or Y.1564 turn-up was found. The searches only surfaced the EU16, EU17 and EU19 talks above.
- The replies to the 2023 r/mikrotik "RFC2544 test" thread could not be read.

---

## 2. Do carriers accept MikroTik btest / traffic-generator results as turn-up or escalation evidence?

### Takeaway
**No operator post found states that a carrier accepted, or rejected, MikroTik btest output as evidence.** The indirect evidence points one way: operators describe SLA proof and "birth certificates" as coming from dedicated testers (EXFO, JDSU/Viavi, VeEX) or from NIDs and CPEs with built-in RFC 2544/Y.1564 (Ciena, Adtran, Accedian). A 2014 operator comment says MikroTik was removed from a network because RFC 2544 tests would not pass through it, which was an SLA requirement. A recurring theme is that customer-grade tests (Ookla, iperf) are easy for a carrier to "hand wave away".

### Cited Findings
- **u/Jackol1**, r/networking, 2014-08-17: "we can't get RFC2544 tests to pass when a Mikrotik device is part of the circuit. As part of our SLAs we have to be able to prove to the customer that we can pass those tests and we could not get them to pass reliably with the Mikrotik devices... The least expensive devices we found that would reliably pass RFC2544 tests are Adtran devices." (Anecdote; the dates of the tests are not given.) — [reddit](https://www.reddit.com/r/networking/comments/2dn3xj/)
- **u/nkripper**, r/networking, 2014-06-01: "Mikrotik and 'Carrier Grade' are mutually exclusive (Mikrotik cant pass RFC2544...). If you are offering any SLA, you also want to make sure that it supports Y.1731 OAM... If you don't have this, then you don't have a very sturdy leg to stand on when someone disputes a bill due to SLA violations." (Opinion, 2014.) — [reddit](https://www.reddit.com/r/networking/comments/26vx9f/)
  - **Rebuttal in the same thread**, u/tryanother292 (dated 2014-05-30 in one API response and 2014-06-02 in another): "It appears most of their new equipment is RFC2544 tested... people really just don't like the natural trend of cheaper devices." — same thread.
- **u/signalpath_mapper**, r/networking, 2025-12-16, "Ethernet analysis tools":
  - "add an active test that the carrier cannot hand wave away... For proving loss and jitter, set up RFC 2544 or Y.1564 style testing, or at least TWAMP, so you have one way delay and loss numbers tied to timestamps."
  - Suggests "a pair of small test boxes like a NetAlly LinkRunner 10G or a purpose built Ethernet service tester".
  - This is the closest direct statement on what makes carrier escalation evidence persuasive.
  - Source: [reddit](https://www.reddit.com/r/networking/comments/1pnv2gy/ethernet_analysis_tools/nucgaku/)
- **u/Mozfeth**, r/networking, 2025-12-09, "How do you check bandwidth delivery for enterprise/government DIA circuits at your ISP?" (an ISP engineer): "some of our teams use a public Ookla Speedtest as the 'proof' that we're delivering the contracted bandwidth... as a formal acceptance test, I'm not convinced it's reliable." Replies could not be retrieved. — [PullPush submission search, q=y.1564](https://api.pullpush.io/reddit/search/submission/?q=y.1564&size=100) (thread id 1pigdt7)
- **u/eli5questions**, 2021-06-02: traffic-generator can simulate 2544 but "requires extra leg work and a less clean certificate" — that is, the output is not the formatted report a tester produces. — [reddit](https://www.reddit.com/r/networking/comments/m72n7i/isps_what_are_you_using_for_customer_handoff/h0dce13/)
- **NANOG, "RFC2544 Testing Equipment", 2017-05-30**, Nick Olsen, Sr. Network Engineer, Florida High Speed Internet (a WISP):
  - Wanted L2 VPLS circuit testing to 1 Gb/s at various packet sizes, with loss and jitter.
  - Explicitly wanted a two-box reflector plus handheld test set with **customer-ready reporting**.
  - Source: [seclists NANOG 2017/May/275](https://seclists.org/nanog/2017/May/275)
  - Replies in the same thread:
    - James Breeden: bought used Agilent FrameScopes on eBay, which "worked great but we had issues getting reporting out of them."
    - Shawn L: "JDSU make some nice ones that we use to qualify cell tower back haul. Not cheap though."
    - Jeremy Austin, a WISP operator: "have you moved on to EtherSAM? That's what I'd be looking for myself."
    - Sources: [seclists 278](https://seclists.org/nanog/2017/May/278); [seclists 277](https://seclists.org/nanog/2017/May/277)
- **Vendor framing of the "birth certificate"** (vendor source, for context only): turn-up KPI results are archived as the service "birth certificate" for customer reporting and SLA comparison. — [Albedo WP-RFC2544](https://www.albedotelecom.com/src/lib/WP-RFC2544.pdf); [startrinity-hosted EXFO note 183](https://startrinity.com/VoIP/Resources/sip321.pdf)
- **u/physon**, r/networking, 2021-01-21: "More professional realm, yeah, RFC2544 or similar for L2... these are all service impacting tests." Recommends starting with passive evidence first: light levels, Ethernet discard and error counters as a percentage of frames, and smokeping. — [reddit](https://www.reddit.com/r/networking/comments/l1fb0j/scalable_load_testing_for_cpe_devices/gk19qc7/)

### Inferences
- Consensus, drawn from indirect evidence: a MikroTik btest result is at best a "claim" that gets a ticket opened. It is not accepted as a formal turn-up or SLA certificate. This matches the repo's own rule that software-counted loss is a claim and hardware or per-flow counters are evidence.
- Operators most value **reporting** (a formatted, timestamped certificate) and **carrier-recognized methodology** (RFC 2544, Y.1564, TWAMP, Y.1731). A btest-based script is weakest on both, however good its arithmetic.
- The practical escalation pattern in these threads: clean interface and optic counters first, then an active test the carrier "cannot hand wave away", ideally tied to timestamps and both ends.

### Gaps
- **No first-hand quote was found of a named carrier (Lumen, Zayo, Cogent, AT&T, Spectrum Enterprise, etc.) rejecting or accepting btest results.**
- Searches tried: `reddit carrier won't accept speedtest RFC 2544 report circuit turn up`; `reddit ISP support "packet loss" proof "iperf" carrier NOC won't accept results tester`; `nanog carrier ethernet turn-up "birth certificate" rfc2544 report customer`.
- The NANOG threads that looked most relevant (diswww ids 89326/89327/83787 on ISPs refusing outage proof; 112929/112930 on Gigabit turn-up) could not be opened because the archive backend was down.
- The r/networking 2025-12 DIA thread replies and the r/telecomNOCtechs 2025-02-22 "RFC2544 or Y.1564 testing?" thread could not be read.

---

## 3. Recommended alternatives mentioned alongside MikroTik

### Takeaway
Across Reddit and NANOG the recurring alternatives fall into three groups:
- **Handheld or two-box testers:** EXFO, JDSU/Viavi SmartClass, VeEX (TX300/TX230S, MX100e+, UX400), NetScout/NetAlly (AT 10G, LinkRunner 10G), used Agilent FrameScopes.
- **CPE/NID with built-in generators:** Ciena 39xx, Adtran, Accedian MetroNID.
- **Free software:** iperf3, Etherate (AF_PACKET), DPDK/netmap-class generators.

Operators treat iperf/UDP-socket tools as unreliable for loss at line rate.

### Cited Findings
- **Ciena 39xx as a cheap MEF CPE** with native RFC 2544/Y.1564: "provide RFC2544/Y.1564 natively... their CLI is among the worst". The same comment calls MikroTik the "best value/performance" with "little support". — u/eli5questions, r/Juniper, 2021-10-27, [reddit](https://www.reddit.com/r/Juniper/comments/qgjbr7/ex_series_as_service_delivery/hi8kp0r/)
- "Ciena is the only networking vendor that has support for both built in. Honestly its infuriating that outside dedicated HW even software seems to be non-existent for both testing." — u/eli5questions, 2021-06-02, [reddit](https://www.reddit.com/r/networking/comments/m72n7i/isps_what_are_you_using_for_customer_handoff/h0dce13/)
- **Adtran** as the cheapest devices found to reliably pass RFC 2544 through the CPE. — u/Jackol1, 2014-08-17, [reddit](https://www.reddit.com/r/networking/comments/2dn3xj/)
- **NetAlly LinkRunner 10G** or a purpose-built Ethernet service tester, or at least TWAMP. — u/signalpath_mapper, 2025-12-16, [reddit](https://www.reddit.com/r/networking/comments/1pnv2gy/ethernet_analysis_tools/nucgaku/)
- **NANOG "10G tester recommendations?", 2016-10-04:**
  - Brian Mengel: "used the Veex TX300 (now discontinued and replaced with the TX230S...) and been satisfied"; "Our primary use is RFC 2544 testing."
  - Dustin Jurman (Rapid Systems): "EXFO product line... quality product."
  - The original poster was weighing the EXFO MAX-800 against the NetScout AT 10G.
  - Source: [seclists NANOG 2016/Oct/64](https://seclists.org/nanog/2016/Oct/64)
- **NANOG "RFC2544 Testing Equipment", 2017-05** (the thread index listed participants Nick Olsen, James Breeden, Jeremy Austin, Shawn L, James Bensley and Saku Ytti):
  - James Bensley, 2017-05-31: "If you are just testing the forwarding at layer 2 and have no budget you can use free software and a laptop", pointing to his open-source Etherate ([github.com/jwbensley/Etherate](https://github.com/jwbensley/Etherate)). He also described EtherateMT, a multi-threaded PACKET_MMAP/AF_PACKET version aimed at 10G without DPDK. — [seclists 279](https://seclists.org/nanog/2017/May/279); [seclists 281](https://seclists.org/nanog/2017/May/281)
  - Saku Ytti, 2017-05-31: tools on UDP/TCP sockets such as iperf have "abysmal" UDP performance, so "you can't saturate 1GE link with any reliability", and loss cannot be measured accurately that way. AF_PACKET works at 1GE, and 10GE needs DPDK or netmap. He mentioned an unreleased Rust tool that was "80% there". — [seclists 280](https://seclists.org/nanog/2017/May/280)
  - A search-engine summary of the same thread also mentions VeEX MX100e+, Viavi SmartClass Ethernet, Y.1564 being preferable for turn-up, and Accedian MetroNID/MetroNode with built-in RFC 2544/Y.1731. I did not verify these against the individual messages because messages 276 and later were not all opened. — [seclists NANOG 2017/May index](https://seclists.org/nanog/2017/May/)
- **iperf defended:** "IPERF can be used to generate all the frames necessary as defined by RFC2544 just fine. Mikrotik simply uses XenaBay instead. IPERF testing is 100% valid so long as it is configured properly." — u/whiteknives, r/mikrotik, 2019-07-09, [reddit](https://www.reddit.com/r/mikrotik/comments/cas5oz/crs305_cant_get_10gb_speeds/etbzuns/). This contrasts with Ytti's measured-experience view above.
- **Hybrid practice:** iperf plus btest plus two CCRs running traffic-generator "works decently for my purpose". — u/djdrastic, 2017-10-20, [reddit](https://www.reddit.com/r/networking/comments/77hr5v/traffic_generator/dommb1t/)
- **"Not a substitute" view** [out of lane, MikroTik forum, 2025-11/12]:
  - chechito: "Traffic Generator is a useful tool, but keep in mind is not a substitute for a proper hardware testing appliance."
  - robertkjonesjr uses professional tools for formal verification and MikroTik for initial evaluation.
  - Source: [forum.mikrotik.com/t/traffic-generator-limitations/266687](https://forum.mikrotik.com/t/traffic-generator-limitations/266687)
- **lurker888** [out of lane, MikroTik forum, 2025-05-24]: "If you don't have a specialized test analyzer, traffic-gen is your friend." — [forum post](https://forum.mikrotik.com/t/test-configurations-details/183886/2)
- **RFC 6349** (stateful TCP) was proposed as more representative than stateless RFC 2544 for customer use cases. — u/commit_and_quit, r/mikrotik, 2023-03-21, [reddit](https://www.reddit.com/r/mikrotik/comments/11xhm5b/questions_on_mikrotik_fw_rule_test_results_on/jd4br7g/)

### Inferences
- The community's "poor man's RFC 2544" with MikroTik is two CCRs running traffic-generator, or btest, used for **troubleshooting and pre-qualification**. Formal certificates come from a handheld tester or a Y.1564-capable NID.
- For escalations, the most cited low-cost upgrade path is a NID or CPE with a built-in generator or reflector (Ciena 39xx, Accedian, Adtran), or TWAMP. Carrier NOCs recognize these.
- I found no Reddit or NANOG mention of Cisco TRex, pktgen or MoonGen being used with MikroTik for circuit acceptance. They may exist but did not surface.

### Gaps
- No community mention was found of Albedo Net.Time, the Lanner/NetScout low-cost boxes, or Juniper/Cisco built-in Y.1564 being used *together with* MikroTik gear.
- Price points for handhelds were not given in the threads I read, beyond "not cheap" (Shawn L, 2017).

---

## 4. Reported pitfalls: CPU, UDP accounting, single-core, CHR, ROS6 vs ROS7, small-frame limits by model

### Takeaway
The most consistent operator complaint is that **MikroTik devices "choke" on 64 and 128 B frames**, both as a device under test in the path and as a generator. Second is **CPU-bound generation**: btest or traffic-gen at 100% CPU understates throughput or shows loss. MikroTik itself added a warning at >90% CPU in v6.44. RB4011 routing claims were disputed by one user as not reproducible (~3 Gbps vs ~7 Gbps claimed). I found no community post off the MikroTik forum specifically about ROS6-vs-ROS7 btest accounting or CHR btest accuracy.

### Cited Findings
- **Small frames:** "I have yet to find a device that can reliably pass an RFC2544 or Y.1564 test. They all seem to choke on the 64 and 128 byte frame sizes." The devices tested were MikroTik switches and routers at or below $150, and the poster says their experience is 2+ years old. — u/Jackol1, r/networking, 2021-02-12, [reddit](https://www.reddit.com/r/networking/comments/lglye4/bgp_1m_routes_and_beyond_hardwaresoftware/gn1qc9h/); follow-up [gn1t0lz](https://www.reddit.com/r/networking/comments/lglye4/bgp_1m_routes_and_beyond_hardwaresoftware/gn1t0lz/)
- The same poster in 2020: "won't pass any RFC2544 or Y.1564 tests if that is important to your services." — [reddit, 2020-09-25](https://www.reddit.com/r/networking/comments/izvve3/isp_network_upgrade/g6lf6cb/)
- In 2014 they added "a lot of bad devices straight out of the box" (issues dating to 2012). — [reddit](https://www.reddit.com/r/networking/comments/26vx9f/)
- **Counter-view:** an x86 MikroTik pushing Mpps "would cause RFC2544 to pass for most things short of a full line rate gig", and line rate everywhere needs the switch chip. — u/Cheeze_It, 2014-06-01, [reddit](https://www.reddit.com/r/networking/comments/26vx9f/)
- **Switch CPUs cannot generate:** "Many have 850 mhz single or dual core CPUs. Even the built in traffic generator can't generate enough traffic to test wirespeed on ports more than 1 gigiabit. use router, such as RB5009... For best results, use CCR routers." — u/Due_Adagio_1690, r/mikrotik, 2026-06-29, [reddit](https://www.reddit.com/r/mikrotik/comments/1uioqmw/run_iperf3_on_mikrotik/ouk2sv9/)
- **RB4011:** "I knew of the ~7 Gbps routing limitation from MikroTik's sales page for the RB4011... even with UDP I still can't exceed that ~3 Gbps threshold" (sub-1 ms RTT, fasttrack, fewer than 20 filter rules). This is an anecdote about routed throughput, not about btest generation. — u/Egglorr, r/networking, 2022-01-26, [reddit](https://www.reddit.com/r/networking/comments/sd8tbw/rb4011_for_1_gbs_pppoe_is_enough/hucv4zz/)
- **CPU and generator overhead**, MikroTik's own MUM EU19 slides:
  - Generation costs at least as much CPU as forwarding.
  - btest was single-threaded before v6.44.
  - v6.44 added a CLI warning when CPU exceeds 90%.
  - Source: [MUM EU19 PDF](https://mum.mikrotik.com/presentations/EU19/presentation_6767_1552293932.pdf)
- **100% CPU means results skewed low**, and btest should be run from separate endpoints rather than the routers on the circuit. — [Admiral Platform, 2021-09-30](https://admiralplatform.com/how-to-safely-speed-test-on-your-mikrotik-gear/)
- **CCR2004 as generator** [out of lane, MikroTik forum]:
  - Traffic-gen on CCR2004-16G-2S+ at only 36 Mbps showed consistent drops at 64 B and variable loss at larger sizes (2025-11/12). robertkjonesjr treats 75% CPU as the practical ceiling for reliable testing. — [forum thread 266687](https://forum.mikrotik.com/t/traffic-generator-limitations/266687)
  - A separate forum post (search-snippet level only) reports CCR2004 RFC 2544 runs with one core at 100% and drops at ~350 kpps. — [forum.mikrotik.com/t/ccr2004-poor-bridge-performance/143125/10](https://forum.mikrotik.com/t/ccr2004-poor-bridge-performance/143125/10)
- **Version and clock variance** [out of lane, MikroTik forum, 2025-05-24]: v6 vs v7 shows up to 30% performance variance, clock differs across hardware revisions, and CPU queue hashing means multiple streams are needed. The poster replicated MikroTik's published numbers within about ±10%. — [lurker888](https://forum.mikrotik.com/t/test-configurations-details/183886/2)
- **UDP loss reporting is one-sided** [out of lane, MikroTik forum, snippet level]: "the remote end may be getting packet loss on transmit testing but it's not being reported to you with the tool." This is consistent with the repo's own bench finding that `lost-packets` counts only loss into the initiating router. — [forum: why UDP bandwidth test always show lost packets = 0](https://forum.mikrotik.com/t/why-udp-bandwidth-test-always-show-lost-packets-0/141229); [forum: lost packets during receive but not send](https://forum.mikrotik.com/t/bandwidth-test-lost-packets-during-receive-but-not-send/75168)
- **MikroTik's published numbers** are XenaBay RFC 2544 (UDP, 0.1% loss, 30+ s trials); Reddit users repeatedly point this out. — u/virtualdxs, r/mikrotik, 2019-07-09: "All tests are done with Xena Networks specialized test equipment" ([reddit](https://www.reddit.com/r/mikrotik/comments/cas5oz/crs305_cant_get_10gb_speeds/etbid4k/))
- **NANOG 2013, a WISP thread** (snippet only; diswww was down): the MT speed test is multi-connection, "think 20 streams", which differs from single-stream web tests. — [diswww NANOG 162066](https://diswww.mit.edu/charon/nanog/162066)

### Inferences
- The small-frame "choke" reports (2014–2021) mostly concern MikroTik as the **device in the path** (CPE/NID). For the user's script, where the MikroTik is the **generator**, the analogous risk is CPU saturation at 70 B. The repo's CPU ≥ 90% → INCONCLUSIVE rule matches MikroTik's own 90% warning threshold. One operator uses a more conservative 75%.
- No outside-forum source contradicts the repo's bench findings on btest units or loss counting. Equally, no outside-forum source independently validates them. Community discussion does not reach that level of detail.

### Gaps
- No outside-forum reports were found on: ROS6 vs ROS7 btest accounting differences; CHR btest accuracy; hEX- or CCR2116-specific btest generation ceilings.
- Searches tried: `r/mikrotik bandwidth test cpu 100% results inaccurate`; `reddit "bandwidth test" mikrotik udp "lost packets" isp circuit`; `reddit wisp mikrotik btest carrier backhaul testing loss`.

---

## 5. MUM talks and trainer videos on circuit acceptance testing

### Takeaway
No MUM talk or trainer video specifically on circuit acceptance, RFC 2544 or Y.1564 turn-up was found. The closest are the MUM EU17 traffic-generator case study and MUM EU19 "Understanding throughput" (see §1). WISPA-list discussion from 2014 suggests the WISP/MikroTik community historically sat outside the Carrier Ethernet/MEF testing culture.

### Cited Findings
- MUM EU16, EU17 and EU19 talks: see §1 for content and links. — [EU16](https://mum.mikrotik.com/presentations/EU16/presentation_3025_1456818897.pdf), [EU17](https://mum.mikrotik.com/presentations/EU17/presentation_4081_1490963921.pdf), [EU19](https://mum.mikrotik.com/presentations/EU19/presentation_6767_1552293932.pdf)
- **WISPA list, "Re: [WISPA] Mikrotik - MEF", Fred Goldstein, 2014-12-30:**
  - "The actual forwarding protocols for Carrier Ethernet don't seem to have been implemented for Linux."
  - He reports that MikroTik, asked about MEF support, replied that "they're a router company".
  - This is opinion and 2014-era, but it explains why Y.1564/Y.1731 tooling never appeared in the MikroTik ecosystem.
  - Source: [mail-archive.com WISPA](https://www.mail-archive.com/wireless@wispa.org/msg66030.html)
- **Reddit, u/andreeii**, r/mikrotik, 2024-03-17, notes RFC 2544 testing should cover IPv6 as well as IPv4 (API summary only; body not retrieved verbatim). — [reddit](https://www.reddit.com/r/mikrotik/comments/1bh8zb5/)

### Inferences
- The MikroTik training ecosystem (MUM, consultants) teaches btest and traffic-gen as throughput and QoS tools. Carrier acceptance is not a topic it has addressed publicly, which leaves the user's use case largely undocumented in community sources.

### Gaps
- No channel-level browse of The Network Berg, IP ArchiTechs, Steve Discher or the official MikroTik YouTube channel was possible here. The only evidence is the searches `youtube mikrotik bandwidth test circuit acceptance`, `youtube "rfc2544" mikrotik traffic generator test` and `"The Network Berg" OR "IP ArchiTechs" mikrotik bandwidth test traffic generator video`, none of which surfaced a relevant video.
- The MUM archive was not exhaustively indexed, so US/AU WISP-track talks on backhaul acceptance may exist.
- WISPTalk, DSLReports/BroadbandReports, AusNOG, UKNOF and LinkedIn: searched only indirectly (`wisptalk OR wispa mailing list rfc2544 tester mikrotik`). Nothing specific surfaced beyond the WISPA MEF thread.
