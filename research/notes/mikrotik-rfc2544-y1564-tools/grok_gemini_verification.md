# Verification of the Grok / Gemini output (2026-09-30)

Source file: `_raw_grok_gemini_2026-09-30.md`. Every URL was opened on 2026-09-30.
Access methods: X posts via `cdn.syndication.twimg.com/tweet-result` (publish.twitter.com oembed returned empty);
Reddit via the PullPush API (reddit.com returned 403, WebFetch is blocked for reddit.com); MikroTik forum via
Discourse `/t/<id>.json` plus `/t/<id>/posts.json`; YouTube via oembed and the watch page's `shortDescription`;
GTER via the pipermail message, the May 2011 thread index and the June 2011 thread and subject indexes.

Verdicts: **S** = supported, **P** = partly supported, **N** = not supported or fabricated, **U** = unreachable.
YouTube verdicts cover only the title, channel and description. No video content was watched, so Gemini's
statement that it "actually watched" them cannot be checked.

## Verdict table

### X (Grok)

| URL | Exists | Author/date | Verdict | Note |
|---|---|---|---|---|
| x.com/criptoanalista/status/1617650602540142593 | y | match (3DES @criptoanalista, 2023-01-23 22:28 UTC) | P | "Yo solo tengo curiosidad si un Mikrotik te pasa una RFC 2544 o una Y 1564, a ver si alguien cuenta su experiencia." The post replies to @410g0n3's photo post "la fiesta de las lucecitas". `conversation_count` is 1, so a reply exists, but its text could not be fetched without a login. Grok's "maybe this helps" is **U**. |
| x.com/ZA_NOG/status/2026228146521936265 | y | match (2026-02-24) | S | "Mikrotik \"btest\" is available on the #ZANOG Durban node ... Hosted on a 10G NIC server, it offers up to 2Gbps throughput without guarantees." Links nog.net.za/speed-stats/. |
| x.com/WillarShoko/status/2026229845030494533 | y | match (2026-02-24) | S | Quote post, text "Mikrotik Bandwidth Test South Africa". |
| x.com/citraweb_com/status/1812659850008285284 | y | match (2024-07-15) | S | Promotes YouTube xyoK0adVBVs, "Test Performa Router Dengan Traffic Generator - MIKROTIK TUTORIAL [ENG SUB]" (Mikrotik Indonesia - Citraweb). |
| x.com/mikrotik_id/status/1812659568830468561 | y | match (2024-07-15) | S | Same video, same text. |
| x.com/stubarea51/status/1512174020984287238 | y | match (Kevin Myers, 2022-04-07) | S | "Added a bunch more connectivity today to the #MikroTik CCR 2216s so that I can start using traffic generator w/ IMIX profiles on the attached routers to put the 2216s under load as DUT. I *think* i've cobbled together enough for 160G of throughput testing." The video thumbnail shows a cabled CCR2216 front panel. |
| x.com/Orion84x/status/2099779013036146999 | y | match (2026-09-15) | S | "MapZ enqueues RouterOS /tool bandwidth-test directly on the tester router via a lightweight collector agent. Upload, download, or both. Scheduled or on-demand. Encrypted creds, stored per host. No Winbox. No babysitting." No MapZ website or repo was found (web search; GitHub search API "mapz mikrotik" returned nothing). The attached screenshot shows a link-monitoring dashboard: local/remote `ath0`, radio RX power, capacity, CPU, a panel "Bandwidth-test results are extra traffic, not the interface max", test TX/RX plotted against live traffic, and a congestion strip. It looks like a wireless-link monitoring product that schedules btest for throughput. Nothing about loss, frame sizes or RFC 2544. |
| x.com/netadmiinplus/status/1954085199718838571 | y | match (2025-08-09) | S | Persian post linking YouTube oFtnFRubNdo (Net Admin Plus), a btest between two MikroTiks from the author's MTCNA course. |

### Reddit (Gemini)

| URL | Exists | Author/date | Verdict | Note |
|---|---|---|---|---|
| r/networking/comments/m72n7i | y | eli5questions, 2021-06-02 (thread 2021-03-17) | S | Already in the report. He also wrote: "Traffic generator: UDP raw throughput but has granularity with IP,MAC,ports,packet size, headers, etc. This is where you can simulate RFC 2544 with the 7 standard packet sizes and throw it at a reflector." |
| r/networking/comments/6e80ie | y | TKalii, 2017-05-30 | S (quote) | "RFC2544 doesn't take an average for items such as latency, it selects a single frame and uses its results whereas Y.1564 provides a true average". The quote is accurate, but the claim is wrong against RFC 2544 §26.2: "The test MUST be repeated at least 20 times with the reported value being the average of the recorded values." |
| r/networking/comments/hhouc4 | y | djamp42, 2020-06-28 | S (exists) | Gemini attributed no specific claim. No MikroTik content. 1div0: "It's a bit disappointing that there do not appear to be any open source implementations for RFC2544." |
| r/networking/comments/19at646 | y | 2024-01-19/20 | P | pstavirs is the Ostinato creator, but he only said "An automated way to do RFC2544 performance benchmarking with Ostinato is in the works". It was **eli5questions** who wrote "Ostinato and TREX are the only options I know of". |
| r/networking/comments/3w3ch7 | y | 2015-12-09/10 | P | clay584: "If I don't like what I see, I request a truck roll and an RFC2544 test." The T-BERD 5800 to a loop came from **cor3adept**. |
| r/networking/comments/1mvx31u | y | OP is **leogh0ul**, 2025-08-21 | P | Thy_OSRS only wrote "Oh great an entire new thing to study." The ECMP point is Defiant-Ad8065's: "Load balancing (ECMP) will generate packet loss if there's only a single flow used for testing." The OP and I_Heywood recommend Y.1564. |
| r/networking/comments/12197tz | y | ashafran, 2023-03-25 | P | RB5009 is **S**. commit_and_quit: "The ~$200 RB5009 can generate up to about 3.5 Gbps of TCP and around 5 Gbps of UDP test traffic." The no-mac-learning VLAN reflector is **N for this thread**. None of the 21 retrieved comments mentions it. It comes from a different thread (qwu5wv, below) and is about a **Juniper EX2300**, not MikroTik. |
| r/networking/comments/e1x9zg | y | JayTheSilverFox, 2019-11-26 | S | Provider's Accedian RFC test: "on a ramp up test from 500bytes to 1500 they were able to a achieve 500Mbps". "With a mikrotik on both ends we are getting 200Mbps up/down via the btest" (RB3011 to CCR). hackmiester: "I don't think the btest on a MikroTik has a sufficient window size to put up with a 20ms latency". Caveat: the 200 Mbps was **TCP**. The OP said "we are able to achieve 1Gbps UDP to our DC, only tcp seems to be the issue". |
| r/mikrotik/comments/iytbfk | y | 2020-09-24 | S | Illustrious-Energy-3 quotes MikroTik: "All tests are done with Xena Networks specialized test equipment (XenaBay),and done according to RFC2544 (Xena2544)". |
| r/networking/comments/77hr5v | y | 2017-10-19/20 | S | jiannone: "I am skeptical of an x86 machine generating the super precisely timed packets that RFC2544 demands for buffer overrun tests in the back to back section." moch__ recommends TRex. djdrastic uses "IPerf , Mikrotik BTest and 2X Mikrotik CCR's running Traffic Generator". |
| r/networking/comments/qwu5wv | y | 2021-11-18 | S | schenr: "Mikrotik switches that can run RouterOS have built in bandwidth testing ... But the CPU tools do not run at anything close to wire speed." |
| r/networking/comments/26vx9f | y | Jackol1, 2014-05-30 | S | Already in the report. "we couldn't get RFC2544 tests to pass when going through these devices so we removed them from our network. They seem to choke on small frame sizes." |

### MikroTik forum (Gemini)

| URL | Exists | Author/date | Verdict | Note |
|---|---|---|---|---|
| forum.mikrotik.com/t/143125 "CCR2004 poor bridge performance" | y | hzdrus, 2020-09-19/21 | P | The numbers are **S**: "100% load on one of CCR2004 cores and frame drops with just 3.9gbps traffic, 350k pps @ 1396 bytes". The pasted config shows bridges with `protocol-mode=none` and ports with `learn=no`. "There is hardware loopback on port sfp1 and tester is connected to sfp2. Traffic is generated using Digital Lightwave tester". "Test is a single stream". The CPU load was IRQ. The "(RSS)" label is not in the thread. The framing is wrong too: the CCR2004 was the **DUT**, bridged between a tester and a hardware loop plug. It was not an L2 loopback for external testers. |
| forum.mikrotik.com/t/56538 "RB493AH Performance Testing with Analyser" | y | kolpano, 2012-05 | S | TREND UNIPRO source to a loopback analyser, routed, "ConnTrack was OFF", port forced to 100 Mbps FD. 64 B fails at 1% and 2% loss tolerance and passes at 3%: "So the threshold for successful results is 3% and not the 1% you mention." 5% and 10% were also run. |
| forum.mikrotik.com/t/79837 "VPLS performance is lower than EoIP" | y | hzdrus, 2014-08 to 2015-12 | S | "two RFC2544 testers (Digital Lightwave), one is generating traffic, another one is looping it back ("smart loopback" mode)". 2015-12-03, CCR1009: 6.33.2 "EoIP - 72 Mbps ... VPLS - 32 Mbps with 64 bytes frames and 0 loss"; 6.32.3 "VPLS ... 274 Mbps ... EOIP ... 304 Mbps with no loss". Exact match. |
| forum.mikrotik.com/t/101166 (post 43) | y | janisk, 2016-09-12 | S | "little note on how to use rfc2544 published results from routerboard.com ... when you make test setup - you have reference value that you should get with your own test system. When you have that - add your configuration on the router and with the same method test for the performance. It should scale with the original test result." The post does not name Xena. |
| forum.mikrotik.com/t/114450 "MPLS/VPLS Packet Loss and Slow Speeds" | y | StubArea51, 2017-12-05 | P | StubArea51 asked "Have you run an RFC2544 test on the base RF link without MPLS to see if it passes?" and for L2/L3/MPLS MTU settings. That part matches. Gemini missed the thread's key finding (see new facts). |
| t/40250, t/60310, t/75532, t/183886, t/6185 | y (all) | - | (known) | Titles in order: "IEEE 802.3ah/IEEE 802.3ag" (2010), "RouterBOARD testing procedures" (2012), "RFC2544" (2014), "Test configurations details" (2025), "Mikrotik bandwidth test software; using iperf?" (2006). Existence only; these are already in `mikrotik_forum_native_search.md` / `community_reddit_x_forums.md`. |

### YouTube (Gemini)

| URL | Exists | Title / channel | Verdict | Note |
|---|---|---|---|---|
| youtube.com/watch?v=efRRyMYVAgg | y | "Monitoring your network using MikroTik Traffic Flow and PRTG" / MikroTik (MUM LB19, 2019-02-01) | S | Matches. Not about testing. |
| youtube.com/watch?v=Ooef_dNET80 | y | "HTB y herramientas de medida" / MikroTik (MUM BO19, 2019-12-10) | P | This is not a "Traffic Generator" talk by title. Its description says it covers HTB/QoS "y utilizar las herramientas \"speedtest\" y \"Traffic Generator\"". Speaker Juan Manuel Diaz Gómez. |
| youtube.com/watch?v=XA2lB4l4CA4 | y | "Full MikroTik MTCNA - Bandwidth Testing" / The Network Berg (2021-10-16) | S | Matches. |
| youtube.com/watch?v=jGTArZu0Ta4 | y | "How to test Interface Bandwidth using Mikrotik Router?" / **Traffic Path** (2021-04-26) | N | Not Steve Discher or Secure Media. Wrong attribution. |
| youtube.com/watch?v=FIwDg_uoK70 | y | "The Brothers WISP 105 - MUM Presentations, RFC2544 Testing, Starlink Latency" / TheBrothers WISP (2020-02-02) | S | Description: "RFC2544 testing with an AGILENT DELL FRAMESCOPE PRO". |

### Non-English

| URL | Exists | Author/date | Verdict | Note |
|---|---|---|---|---|
| eng.registro.br/pipermail/gter/2011-May/030672.html | y | match (Leandro Takeo, Mon 30 May 2011) | S (exists), and Gemini's "inaccessible" is **N** | It is a question with **no replies**. The May 2011 thread index shows no children, and the June 2011 thread/subject indexes have no "2544" or "homolog" subjects. Translation: "Has anyone managed to pass (homologate) an RFC 2544 test (Agilent, JDSU, etc.) through a Mikrotik model 450, 750 or 1100? I have already disabled and enabled connection tracking, without success. There is no firewall control or any kind of rate (queues)." So the thread found nothing beyond the asker's own failed attempts. |

### Gemini's synthesis claims

| Claim | Verdict | Evidence |
|---|---|---|
| "RFC 2544 mandates a single stream" | N | RFC 2544 §12: "The test suite SHOULD be first run with a single protocol ... source and destination address pair. The tests SHOULD then be repeated with using a random destination address", with routers tested over "a range of 256 networks". §14: bidirectional runs SHOULD be done "with the same data rate being offered from each direction". §16 defines a multi-port, multi-stream test. §15 "Single stream path" is about one input/output port pair, not one flow. RFC 2889 (LAN switches) is built around fully and partially meshed multi-port traffic (§5.1-5.4). Single-flow is the common tester default (hzdrus in t/143125: "This is how telco carriers worldwide test circuit performance"). It is not a mandate. |
| "Y.1564 requires color-aware policing" | N | Color mode is a per-service option. Juniper's Y.1564 docs: "Color-blind mode is the default. You do not need to configure the `colour-aware` statement to get color-blind mode." Netrounds/Paragon lists separate color-aware and non-color-aware EIR and policing tests. The Recommendation text itself is paywalled and was not read. |
| "Industry standard is to configure RouterOS as a loopback for external appliances" | N | No source supports it. The sources point the other way. In 12197tz, ragzilla says "For RFC2544 and the like you usually want a NID with MAC-swap functionality at the far end". The report's forum t/147223 concluded a MAC/IP-swap reflector "is not existing". In the forum threads Gemini cites (143125, 79837, 56538), the far-end loop is a **hardware plug or a second tester in loopback mode**, and the MikroTik is the device under test. |

**Tally (34 items):** 22 supported, 8 partly supported, 4 not supported (jGTArZu0Ta4 and the three synthesis claims).
One sub-claim was fabricated by misattribution: the no-mac-learning VLAN reflector in 12197tz. Another is unreachable:
the criptoanalista reply text. The five "already known" forum IDs exist and were not re-scored. No credentials appear in
any source quoted here. The t/143125 config paste contains a device serial, which is not reproduced.

## New verified facts worth adding to the report

1. **btest showed no loss where an RFC 2544 appliance and traffic-generator both did** (forum t/114450, 2017). A
   VPLS circuit over three CCR hops and Trango backhaul was tested with two Ciena RFC 2544 appliances. The results
   were 0.20-8.18% frame loss at 1518 B at every load step, and a throughput average of 57.83 of 100 Mbps. The OP:
   "I can run a Bandwidth Test and get about 200 and the bandwidth test shows no packet loss. Traffic generator
   does show loss between endpoints at anything over 10 Mbps or so." Resolution: "We plugged the RFC2544 appliance
   directly into the Trango backhaul. The test failed there." The btest protocol is not stated, and TCP (the
   default) would hide loss. This is still the only public case found where btest and hardware testers disagreed on
   the same path, and traffic-gen sided with the hardware. https://forum.mikrotik.com/t/114450
2. **MikroTik's own product-page tolerance was 1% in 2012, with two independent one-way streams** (janisk, MikroTik,
   t/56538, 2012-05-31): "the tolerance is set to 1% in our test setup and we are generating 2 independent streams,
   one in each direction." Today's pages say 0.1%. The streams are dual-ended, not a loop. A user on a loopback-only
   tester needed 3% tolerance before the RB493AH passed 64 B. https://forum.mikrotik.com/t/56538
3. **A RouterOS minor upgrade cut 64 B zero-loss throughput about 4-8x** (t/79837, CCR1009, Digital Lightwave
   generator plus smart loopback). On 6.32.3, EoIP ran at 304 and VPLS at 274 Mbps. On 6.33.2, EoIP ran at 72 and
   VPLS at 32 Mbps. The OP: "Our partners are requiring us to provide full throughput with 64-byte packets." This
   supports recording the ROS version in every acceptance record. https://forum.mikrotik.com/t/79837
4. **Single-flow tests pin one CPU core on CCR2004** (t/143125, ROS 6.47.3). A bridge with `learn=no` and
   `protocol-mode=none` was tested with a Digital Lightwave single stream at 1396 B. It capped at 3.9 Gbps and
   352 kpps with one core at 100% (IRQ). Participants explain that a single flow is kept on one core to avoid
   reordering. The OP also saw out-of-sequence frames above 1G over VPLS/EoIP. Whether btest's one UDP flow is pinned
   the same way is an inference and is untested. https://forum.mikrotik.com/t/143125
5. **Carrier acceptance requirements, first-hand** (Jackol1, r/networking 1mvx31u, 2025-08-21): "We have had multiple
   wireless carriers refuse to accept circuits that don't pass RFC tests ... We meet the requirements for the RFC test
   down to the 64 byte frames". Also: "Some of the carriers are starting to loosen up their requirements and now only
   test down to 256 or 512 byte frame sizes. The largest carriers though still require 64 bytes." And: "Most of the
   big carriers are requiring Y.1731 as well". This is not about btest, but it is the named-requirement evidence the
   report's carrier section lacked. https://www.reddit.com/r/networking/comments/1mvx31u/
6. **A cheap used NID option** (12197tz, 2023-03-28). LitreAhhCola: "buy an Adva GE114 or GE114Pro off ebay. They
   usually go for $50--200 used." ragzilla: "For RFC2544 and the like you usually want a NID with MAC-swap
   functionality at the far end." This adds to the report's RAD $150-400 option. The Adva units' generator versus
   reflector licensing was not verified. https://www.reddit.com/r/networking/comments/12197tz/
7. **TCP btest vs an RFC 2544 pass** (e1x9zg, 2019). An Accedian RFC test passed 500 Mbps over about 2,000 km, while
   TCP btest from RB3011 to CCR gave 200 Mbps and UDP btest reached 1 Gbps. The commenters blame the TCP window at
   about 20 ms RTT and btest CPU limits. This shows why the script's UDP-only design is right.
   https://www.reddit.com/r/networking/comments/e1x9zg/
8. **Where the "no-mac-learning VLAN loop" idea actually comes from** (qwu5wv, 2021). twnznz, on Juniper: "you can
   remote-loop a port (set interfaces xxxx gigether-options loopback). Combined with a no-mac-learning VLAN you can use
   this to loop RFC2544 tests." Egglorr describes "a hard loop plugged into a port carrying a VLAN you dedicate for
   RFC2544 testing". Neither is a MikroTik feature. https://www.reddit.com/r/networking/comments/qwu5wv/
9. **The GTER 2011 thread is a dead end.** It is a single unanswered question about failing RFC 2544 homologation
   through RB450/750/1100, with connection tracking toggled and no effect.
   https://eng.registro.br/pipermail/gter/2011-May/030672.html
10. **The RFC 2544 text supports the script's bidirectional design.** §14: "the test series SHOULD be run with the same
    data rate being offered from each direction." This is worth a line in the report's naming paragraph.
    https://datatracker.ietf.org/doc/html/rfc2544
11. Minor: TheBrothersWISP ep. 105 (2020-02-02) covered "RFC2544 testing with an AGILENT DELL FRAMESCOPE PRO" (not
    watched), https://www.youtube.com/watch?v=FIwDg_uoK70. Kevin Myers (StubArea51) used traffic-generator with IMIX
    to load CCR2216s as DUT at about 160G, https://x.com/stubarea51/status/1512174020984287238. MapZ (Orion84x,
    2026-09-15) is a btest scheduler/dashboard with no public site found and no loss or frame-size handling. It does not
    change the report's "nothing comparable" finding.

## Claims to discard

- 12197tz "suggests a no-mac-learning VLAN as a loopback reflector". This is not in that thread. It is Juniper-specific
  and comes from qwu5wv.
- "The industry standard is to configure RouterOS as a loopback reflector for external appliances". No source; the
  sources contradict it.
- "RFC 2544 mandates a single stream". Contradicted by RFC 2544 §12, §14 and §16.
- "Y.1564 requires color-aware policing". Color-blind is a valid mode and is Juniper's default.
- jGTArZu0Ta4 as a Steve Discher / Secure Media btest video. The channel is Traffic Path.
- Ooef_dNET80 as a "Traffic Generator" talk. It is an HTB/QoS talk that also covers speedtest and traffic-gen.
- The GTER message being "inaccessible". It is reachable, and it has no replies.
- 1mvx31u attributed to Thy_OSRS (OP is leogh0ul). 19at646 "pstavirs names Ostinato and TRex" (eli5questions did).
  3w3ch7 "clay584 T-BERD 5800" (cor3adept).
- 143125's "(RSS)" and its "CCR2004 as L2 loopback path" framing. The CCR2004 was the DUT, and the loop was a
  hardware plug.
- TKalii's "RFC 2544 doesn't average latency" (6e80ie). Accurately quoted but wrong: RFC 2544 §26.2 requires at least
  20 repeats, averaged. Do not cite it as fact.
- Grok's "one reply 'maybe this helps'" on the criptoanalista post. The reply exists (`conversation_count` 1) but its
  text is unverified.
- Gemini's "actually watched" YouTube claim. Unverifiable; only titles and descriptions were checked.
