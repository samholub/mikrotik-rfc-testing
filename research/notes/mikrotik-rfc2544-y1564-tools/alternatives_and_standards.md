# Alternatives to a btest-based circuit test, and what RFC 2544 / Y.1564 actually require

Scope: the non-MikroTik tool landscape (open source, hardware testers, NIDs, SaaS) and the standards' requirements. Researched 2026-09-30. Prices are reseller/eBay list prices found on the day and are approximate. Several vendor PDFs (EXFO app note 321, Viavi "Enhanced RFC 2544" brief, Lantronix RFC2544/Y.1564 guide) downloaded but could not be text-extracted, so claims from them are limited to search-result snippets.

## 1. What a proper RFC 2544 and Y.1564 test contains, and the RFC 6815 caution

### Takeaway
RFC 2544 is a lab benchmark for a single device: binary-searched zero-loss throughput at seven frame sizes, 60 s trials, 20-repeat latency, a stepped frame-loss curve, and back-to-back bursts. RFC 6815 (2012) says not to use it on production networks and points to Y.1564 and IPPM instead. Y.1564 is the service-activation standard: a stepped configuration test (25/50/75/100% CIR, CIR+EIR, policing), then a long performance test measuring IR/FTD/FDV/FLR/availability. The user's btest script matches neither. It is closest to a single-step Y.1564 service configuration test at 100% of rate, run at several frame sizes, with a loss-only acceptance criterion.

### Cited Findings
- RFC 2544 frame sizes for Ethernet: 64, 128, 256, 512, 1024, 1280, 1518 bytes. — [RFC 2544](https://datatracker.ietf.org/doc/html/rfc2544)
- Throughput is defined as "the fastest rate at which the count of test frames transmitted by the DUT is equal to the number of test frames sent to it" (zero loss). Results are plotted as frame rate against frame size, with the theoretical maximum shown. — [RFC 2544](https://datatracker.ietf.org/doc/html/rfc2544)
- Trial duration "SHOULD be at least 60 seconds". A binary search may use shorter intermediate trials, but the final value must be confirmed at full length. — [RFC 2544](https://datatracker.ietf.org/doc/html/rfc2544)
- Latency: a 120 s stream with one tagged frame at 60 s, "repeated at least 20 times with the reported value being the average." — [RFC 2544](https://datatracker.ietf.org/doc/html/rfc2544)
- Frame loss rate: start at 100% of the theoretical maximum and step down in 10% increments until two successive trials show no loss. Plotted as loss % against offered rate. — [RFC 2544](https://datatracker.ietf.org/doc/html/rfc2544)
- Back-to-back: "trial length MUST be at least 2 seconds and SHOULD be repeated at least 50 times." There are also system-recovery and reset tests. — [RFC 2544](https://datatracker.ietf.org/doc/html/rfc2544)
- RFC 2544 does not specify a search algorithm. Binary search is the common approach, and it stops when upper minus lower bound is within a resolution. — [Ostinato PerfBench search snippet](https://ostinato.org/pricing/perf-bench)
- RFC 6815 (Nov 2012, Informational): RFC 2544 methods "are intended to generate traffic that overloads network device resources" and "have never been validated on a network path". It requires an Isolated Test Environment. For production it recommends IPPM metrics, ITU-T Y.1564 and OAM standards. — [RFC 6815](https://datatracker.ietf.org/doc/html/rfc6815)
- Y.1564 KPIs: Information Rate (IR), Frame Transfer Delay (FTD), Frame Delay Variation (FDV), Frame Loss Ratio (FLR), Availability. Performance-test intervals follow ITU-T M.2110: 15 min, 2 h or 24 h. — [Wikipedia: Y.1564](https://en.wikipedia.org/wiki/Y.1564)
- Y.1564 configuration test phases per Wikipedia: CIR, EIR, Discard (overshoot), CBS and EBS. Unlike RFC 2544 it tests multiple services at once and measures jitter. — [Wikipedia: Y.1564](https://en.wikipedia.org/wiki/Y.1564)
- The step test runs 25%, 50%, 75% and 100% of CIR, then CIR+EIR, then policing. At each step, received IR, FLR, FTD and FDV are compared against the Service Acceptance Criteria (SAC). Policing rate is 125% × CIR + EIR if EIR < 20% of CIR, otherwise CIR + 125% × EIR. — [Cisco Crosswork/Accedian Y.1564 docs (search snippet)](https://docs.crossworkassurance.cisco.com/docs/using-y1564-for-service-activation-testing-sc); [Huawei Y.1564 doc](https://info.support.huawei.com/hedex/api/pages/EDOC1100277644/AEM10221/03/resources/vrp/feature_0003991827.html)
- Test sets can run Y.1564/RFC 2544 in two ways. In loopback, the far end MAC-swaps the traffic back and all measurement is local. In dual test set (DTS), each end transmits and measures independently, which shows which direction fails. — [EXFO EtherSAM app note (snippet)](https://www.exfo.com/contentassets/2f87303d99c244ab8d1928eefe9837af/exfo_anote230_ethersam-ethernet-service-testing_en.pdf); [Viavi Enhanced RFC 2544 brief (snippet)](https://www.lasercomponents.com/fileadmin/user_upload/home/Datasheets/viavi/nitro/2-enhanced-rfc-2544.pdf)

### Inferences
- How the user's script compares to RFC 2544:
  - It does not binary-search. It runs one fixed rate per size, which is closer to a single frame-loss-rate trial.
  - Its sizes (70/128/256/512/1024/1500 frame) differ from 64/1280/1518.
  - It has no 20-repeat latency test and no back-to-back test.
  - Brief mode's 10 s trials fall short of the 60 s SHOULD; Extended mode's 60 s meets it.
  - Calling it "RFC 2544" would be inaccurate. "RFC 2544-style fixed-rate loss sweep" is defensible.
- How it compares to Y.1564: it has no CIR steps, no EIR or policing step, and no 15-minute or longer performance phase. It has no FTD/FDV thresholds; it records one ping per callback, not a delay SAC. The pass/fail against a 0.10% loss limit is Y.1564-like in spirit, since Y.1564 FLR is judged against a SAC.
- RFC 6815 applies directly. Running at full rate over a live carrier circuit is exactly the production-path use it warns against. Y.1564 is the standard that fits circuit acceptance.
- `direction=both` gives two directions at once, but loss is only counted into the initiating router. That makes it neither a true loopback (which measures round trip) nor a true DTS (which gives independent per-direction loss). The user's "run from both ends" rule is a manual approximation of DTS.

### Gaps
- The ITU-T Y.1564 text itself (03/2016 edition) is paywalled or not fetched. Step and policing formulas come from vendor docs, not the Recommendation.
- Could not extract the EXFO app note 321 or the Viavi brief for test-time numbers (e.g. how long a full RFC 2544 run takes compared with Y.1564).

## 2. Open-source and low-cost software generators

### Takeaway
Real RFC 2544 automation exists in open source: the TRex NDR bench, the pktgen-dpdk rfc2544.lua script, MoonGen's rfc2544 scripts, and Ostinato PerfBench (paid). All of them assume the tester owns both ends of the path, either two ports around a DUT or a remote loopback. They need a DPDK-capable x86 box with supported NICs (Intel X710/82599, Mellanox ConnectX). I found no mature open-source Y.1564 implementation. TWAMP tools (twampy, perfSONAR) measure delay and loss at low rates, not throughput.

### Cited Findings
- **Cisco TRex NDR bench:**
  - Explicitly follows RFC 2544 to find the Non Drop Rate (0% loss), plus the Partial Drop Rate (e.g. PDR=1 allows 1% loss).
  - Uses binary search by default, or an "optimized" search that uses the measured drop % to converge faster.
  - Can apply a maximum-latency limit.
  - — [TRex NDR docs (GitHub)](https://github.com/cisco-system-traffic-generator/trex-core/blob/master/doc/trex_ndr_bench_doc.asciidoc); [TRex NDR bench page](https://trex-tgn.cisco.com/trex/doc/trex_ndr_bench_doc.html)
- **TRex topology and hardware:**
  - TRex ports sit on both sides of the DUT and traffic returns to TRex.
  - Intel X710 gives hardware per-stream flow stats. On Mellanox, per-stream stats are software.
  - X710 accepts only Intel SFP+ optics (Silicom NIC for open optics).
  - Loopback latency on X710 is around 20 µs average.
  - — [TRex manual/book](https://github.com/cisco-system-traffic-generator/trex-core/blob/master/doc/trex_book.asciidoc); [TRex manual](https://trex-tgn.cisco.com/trex/doc/trex_manual.html)
- TRex is used for 100 GbE line rate on a ConnectX-5. A PCIe Gen4 NIC matters, because Gen3 caps throughput before the cores do. — [FastNetMon, 2026-08-10](https://fastnetmon.com/2026/08/10/learning-trex-generating-100gbe-line-rate-traffic-on-a-mellanox-connectx-5/)
- **MoonGen** (DPDK + LuaJIT) timestamps thousands of packets per second, versus RFC 2544's one per 120 s. It uses NIC hardware timestamping (Intel 82599/X540 at 156.25 MHz, via PTP-type packets) for sub-microsecond latency. The repo ships an `rfc2544/` script set, and there is a third-party moongen-rfc2544 testbench covering latency, jitter, burst and frame size. — [MoonGen paper, IMC 2015](https://arxiv.org/pdf/1410.3322); [MoonGen rfc2544/master.lua](https://github.com/emmericp/MoonGen/blob/master/rfc2544/master.lua); [robidev/moongen-rfc2544](https://github.com/robidev/moongen-rfc2544)
- **pktgen-dpdk** ships `scripts/rfc2544.lua`, a throughput test over 64–1518 B frames. A GitHub issue reports the rfc2544 throughput script failing. The third-party v0l0dia/RFC2544-tests repo adds throughput, drop-rate and reset tests. — [dpdk.org pktgen rfc2544.lua](https://git.dpdk.org/apps/pktgen-dpdk/tree/scripts/rfc2544.lua); [Pktgen-DPDK issue #25](https://github.com/pktgen/Pktgen-DPDK/issues/25); [v0l0dia/RFC2544-tests](https://github.com/v0l0dia/RFC2544-tests)
- **Ostinato:**
  - Priced as a subscription: Solo $12/mo (personal, 1 Gbps/port), Pro $49/mo (commercial, 10 Gbps/port), Business $208/mo (unrestricted, includes RFC 2544 PerfBench). Turbo (DPDK) add-ons are priced separately and not listed.
  - PerfBench implements RFC 2544 throughput, latency and frame-loss (sections 26.1–26.3) but not back-to-back, recovery or reset.
  - Supports either two tester ports around a DUT or "single port remote loopback", and outputs a PDF report.
  - — [Ostinato pricing](https://ostinato.org/pricing); [PerfBench user guide](https://userguide.ostinato.org/perf-bench/); [PerfBench page](https://ostinato.org/pricing/perf-bench)
- **twampy (Nokia, Python):** TWAMP controller/sender/reflector, TWAMP-Light and STAMP. "Software timestamping only (typical accuracy: 100μs - 2ms)". Measures latency, jitter and loss with DSCP, not throughput. — [nokia/twampy](https://github.com/nokia/twampy)
- **perfSONAR:** pScheduler runs throughput via iperf3 (or iperf2/nuttcp), TWAMP (twping, since 4.1) and OWAMP one-way latency (powstream for continuous latencybg). It has no Y.1564 or RFC 2544 mode. — [perfSONAR test reference](https://docs.perfsonar.net/pscheduler_ref_tests_tools.html); [perfSONAR FAQ](https://docs.perfsonar.net/FAQ.html)
- A search for an open-source Y.1564 implementation on GitHub returned only vendor implementations (Cisco NCS, Accedian, Cisco ME 1200) and no open-source generator. — [search results incl. Wikipedia Y.1564](https://en.wikipedia.org/wiki/Y.1564)

### Inferences
- **TRex, MoonGen and pktgen-dpdk** are genuine RFC 2544 throughput engines with hardware-counted TX/RX, and hardware timestamps on supported NICs. Hardware is a used x86 server plus an X710/82599/ConnectX NIC, likely a few hundred dollars used (estimate, not sourced).
  - The catch for circuit acceptance: they need the traffic back. That means a second tester port at the far end (a second box, with clock sync for one-way delay) or a far-end L2 MAC-swap loop.
  - None of them does two-box dual-test-set coordination out of the box the way EXFO/Viavi DTS does.
- **iperf3/iperf2** are software-timestamped TCP/UDP tools with a far-end server. Structurally they are similar to btest; wrapping them does not add hardware counting. I found no maintained iperf3 "RFC 2544" wrapper.
- **Ostinato Pro/Business** is the lowest-effort "real RFC 2544 with a PDF report" option if a remote loopback exists.
- **VyOS / OPNsense / pfSense:** I found no evidence that any of them ships an RFC 2544 or Y.1564 generator. Their iperf/speedtest packages are btest-class tools.

### Gaps
- No source found for a built-in RFC 2544 feature in VyOS, OPNsense or pfSense, or for an OpenWrt TWAMP package; not searched exhaustively.
- "OpenRFC2544" as a named project: not found in these searches.
- Y.1731 open-source implementations: not researched within the call budget.
- No price for Ostinato Turbo add-ons.

## 3. Hardware test sets, NIDs and SaaS: cost, standard, reflector options

### Takeaway
The cheapest real Y.1564/RFC 2544 hardware for a small ISP is a used carrier NID. RAD ETX-2i or ETX-203AX sell for about $150–400 on eBay, and NIDs from Accedian, RAD, Lantronix, Cisco ME1200 and NCS generate and reflect in hardware. Handheld testers run from low-cost Chinese units (GAOTek, Grandway, TFN; prices unpublished) to NetAlly LinkRunner 10G at about $6.5–8.4k, and EXFO/Viavi units cost more (prices not found). SaaS/agent platforms (Juniper Paragon Active Assurance, Cisco/Accedian) implement Y.1564 in software agents; pricing is quote-only.

### Cited Findings
- **NetAlly LinkRunner 10G** (LR10G-200, $6,470–7,019; Professional Kit $7,696–8,383):
  - Its "line rate Performance Test" measures target rate, throughput, loss, latency and jitter over IPv4.
  - The far end can be a Peer (another EtherScope nXG, LinkRunner 10G or CyberScope), which reports upstream and downstream separately.
  - It can also be a Reflector (LinkRunner AT 3000/4000, or the free Windows "NPT Reflector" PC software), which gives round-trip results only.
  - — [Test Equipment Depot](https://www.testequipmentdepot.com/netally-lr10g-200-linkrunner-10g-advanced-ethernet-tester.html); [TED kit](https://www.testequipmentdepot.com/netally-lr10g-200-kit-linkrunner-10g-professional-kit.html); [CDW](https://www.cdw.com/product/netally-linkrunner-10g-advanced-ethernet-tester/7498258); [SHI](https://www.shi.com/product/46304654/NetAlly-LinkRunner-10G-PROFESSIONAL-KIT); [NetAlly KB: Performance Testing](https://support.netally.com/kbhome/kbarticle/?id=96f46e4f-d29f-48e9-81b7-e1fd81406e26); [LR10G user guide](https://www.netally.com/user-guides/linkrunner10g/Content/B_Testing-Applications/Performance/0_Chapter-Title-Performance.htm)
- **Albedo Ether.Genius / Ether10.Genius:**
  - RFC 2544 option covers throughput, frame loss, latency, jitter and burst, symmetric or asymmetric, with the far end in loopback or peer-to-peer. Y.1564 eSAM is also supported.
  - Albedo's Ether.Loop is a two-port L1–L4 loopback device for RFC 2544/eSAM.
  - No public prices.
  - — [Albedo Ether.Genius brochure](https://www.albedotelecom.com/src/lib/BR-Ether-Genius.pdf); [Ether.Genius page](https://www.albedotelecom.com/pages/fieldtools/src/ethergenius.php); [Ether10.Genius](https://albedotelecom.com/pages/fieldtools/src/ether10genius.php)
- **EXFO and Viavi:** both support Dual Test Set RFC 2544/EtherSAM, testing each direction independently so the failing direction is identified, which loopback cannot do. EXFO's AXS-200/850 does asymmetric DTS RFC 2544. — [EXFO EtherSAM app note](https://www.exfo.com/contentassets/2f87303d99c244ab8d1928eefe9837af/exfo_anote230_ethersam-ethernet-service-testing_en.pdf); [EXFO AXS-200/850 datasheet](https://accusrc.com/uploads/datasheets/Exfo%20AXS-200-850%20Datasheet.pdf); [Viavi Enhanced RFC 2544](https://www.lasercomponents.com/fileadmin/user_upload/home/Datasheets/viavi/nitro/2-enhanced-rfc-2544.pdf)
- **Low-cost handhelds:** GAOTek handheld GbE tester and Grandway FET-100 claim RFC 2544 + Y.1564. TFN T3000A (10G) claims RFC 2544/Y.1564 with L1–L4 loopback. The Viavi NSC-100 1G loopback device sells used for about £160–213. Prices for the new Chinese units were not published in results. — [eTesters Y.1564 list](https://www.etesters.com/see/9804/y-1564/); [Grandway FET-100](https://www.grandwaytelecom.com/products/instrument/testing/1157.html); [TFN T3000A](https://www.tfngj.com/ethernet-testers/t3000a-10-gigabit-ethernet-tester/); [TT Instruments RFC 2544 testers](https://www.ttinstruments.com/collections/rfc-2544-testers)
- **RAD ETX-2 NIDs** offer built-in RFC 2544/Y.1564 testers for service activation. eBay prices seen: new ETX-2i-10G $400, used ETX-2i-10G 16-port $149.99, open-box ETX-203AX $159. — [Kenton Group: RAD ETX-2](https://thekentongroup.com/technologies/carrier-ethernet/etx-2/); [eBay ETX-2i-10G](https://www.ebay.com/itm/188288180824); [eBay ETX-2i-10G used](https://www.ebay.com/itm/366106426916); [eBay ETX-203AX](https://www.ebay.com/p/1672276227)
- **Accedian (now under Cisco Provider Connectivity Assurance):** Y.1564 service activation docs moved from docs.accedian.io to docs.crossworkassurance.cisco.com. Cisco also sells an "Assurance SFP" sensor. — [redirect observed](https://docs.accedian.io/docs/using-y1564-for-service-activation-testing); [Cisco Assurance SFP datasheet](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/provider-connectivity-assurance-sensors/provider-connect-assurance-sensor-sfp-ds.html)
- **Cisco NCS 500/5500 (IOS XR 7.1+):**
  - Y.1564 SADT in "two-way" mode, where generation and measurement are local and the far end loops traffic back after a MAC swap.
  - L2 point-to-point services only (xconnect, VPWS, EVPN-VPWS).
  - Measures FL, FLR, and min/max/avg delay; "Measurement of Frame Delay Variation (Jitter) is not supported."
  - Cisco ME 1200 NIDs also do Y.1564.
  - — [xrdocs NCS Y.1564 part 1](https://xrdocs.io/ncs5500/tutorials/y-1564-sadt-nc5x-part1); [Cisco NCS5500 SAT guide](https://www.cisco.com/c/en/us/td/docs/iosxr/ncs5500/sysman/75x/b-system-management-cg-ncs5500-75x/EthernetServiceActivationTest.pdf); [Cisco ME 1200 Y.1564](https://www.cisco.com/c/en/us/td/docs/switches/metro/me1200/controller/guide/b_nid_controller_book/b_nid_controller_book_chapter_011111.html)
- **Juniper Junos:**
  - Supports Y.1564 and RFC 2544 benchmarking and uses "the same reflector configuration as RFC 2544 benchmarking tests".
  - One Y.1564 test per interface; at most 16 simultaneous tests color-blind or 8 color-aware; single-homed topologies only.
  - The platform list is in Feature Explorer.
  - — [Juniper Y.1564 config](https://www.juniper.net/documentation/us/en/software/junos/flow-monitoring/topics/topic-map/y1564-configuration.html)
- **Juniper Paragon Active Assurance (ex-Netrounds):**
  - Test Agents do Y.1564 (color-aware and color-blind), MEF 48, UDP/TCP, Y.1731, TWAMP and path trace.
  - Agents run as a VM, a container or an x86 appliance; the platform is SaaS or self-hosted on Ubuntu.
  - Pricing is not published (TrustRadius shows only "no setup fee").
  - — [PAA datasheet](https://www.juniper.net/content/dam/www/assets/datasheets/us/en/network-automation/juniper-paragon-active-assurance-datasheet.pdf); [PAA product page](https://www.juniper.net/us/en/products/network-automation/paragon-active-assurance.html); [TrustRadius](https://www.trustradius.com/products/juniper-paragon-active-assurance/pricing)
- **Microchip:** Y.1564 configuration exists for its carrier-Ethernet switch software (the silicon inside many low-cost NIDs). — [Microchip AN1124](https://www.microchip.com/content/dam/mchp/documents/ENT/ApplicationNotes/ApplicationNotes/VPPD-03908_AN.pdf)
- **Lantronix / Transition Networks:** publish an RFC 2544 / Y.1564 configuration guide for their NIDs (PDF could not be text-extracted). — [Lantronix guide](https://cdn.lantronix.com/wp-content/uploads/pdf/RFC2544-Y1564-Guide-1.pdf)

### Inferences
- For a MikroTik shop, the most cost-effective upgrade path to standards-based evidence is a pair of used NIDs (e.g. RAD ETX-203AX/ETX-2i at about $150–400 each on eBay) inline at each end during acceptance. One generates Y.1564 or RFC 2544 in hardware; the other reflects, or runs as the peer in dual-ended mode. This gives hardware-counted, per-direction results for roughly the cost of one RB4011. Check the specific model and licence for generator-vs-reflector-only capability; that was not verified.
- Handheld testers in the $6k+ class are the "carrier-grade report" option. They matter mainly when the carrier's contract names a specific test methodology.
- NetAlly's free Windows NPT Reflector means a laptop behind the MikroTik can serve as a far-end reflector for a LinkRunner 10G. Round-trip only, the same one-direction blindness as btest loopback.

### Gaps
- Could not find published prices for EXFO, Viavi (T-BERD/MTS 5800), Veex, Albedo, Accedian, NetAlly EtherScope nXG or Netscout. Used-market prices exist but were not retrieved.
- FS.com, Ubiquiti and TP-Link devices with built-in RFC 2544/Y.1564: no evidence found in these searches, and none are known to ship it (unverified).
- Ciena 3900/5100 and RAD ETX-2 generator throughput limits: not researched.
- Lanner (white-box x86 appliances usable for TRex/DPDK) and Netscout: not researched.

## 4. Can a MikroTik be the far-end reflector, and what do carriers accept?

### Takeaway
Nothing found shows RouterOS offering a standards-based reflector: no TWAMP responder and no Y.1564/RFC 2544 MAC-swap loopback. A third-party project states outright that "RouterOS provides no TWAMP responder" and supplies a TWAMP-Light reflector as a RouterOS container. Hardware testers and NIDs expect an L2 MAC-swap loop, their own peer, or a TWAMP reflector, so a MikroTik usually needs a device or container beside it to reflect. I found no citable source on what carriers formally accept as escalation evidence.

### Cited Findings
- "RouterOS provides no TWAMP responder, so the agent supplies one." MikrotikQualityAgent is Rust in a RouterOS container, providing a TWAMP-Light reflector and probe with forward and reverse loss counted separately. It notes TWAMP-Light has no session identifier (only a source allow-list for admission). It offloads throughput to `/tool/bandwidth-test`, and makes no RFC 2544/Y.1564 claim. — [ComComServicesLtd/MikrotikQualityAgent](https://github.com/ComComServicesLtd/MikrotikQualityAgent)
- Cisco NCS Y.1564 two-way mode requires the remote end to run an "Ethernet data plane loopback with MAC swap". — [xrdocs NCS Y.1564](https://xrdocs.io/ncs5500/tutorials/y-1564-sadt-nc5x-part1)
- Juniper Y.1564 reuses the RFC 2544 reflector configuration. — [Juniper Y.1564 config](https://www.juniper.net/documentation/us/en/software/junos/flow-monitoring/topics/topic-map/y1564-configuration.html)
- Albedo's Ether.Loop and TFN's L1–L4 loopback are dedicated reflector devices for these tests. — [Albedo](https://www.albedotelecom.com/src/lib/BR-Ether-Genius.pdf); [TFN T3000A](https://www.tfngj.com/ethernet-testers/t3000a-10-gigabit-ethernet-tester/)
- Loopback (reflector) testing cannot isolate which direction fails; dual test set can. — [Viavi Enhanced RFC 2544](https://www.lasercomponents.com/fileadmin/user_upload/home/Datasheets/viavi/nitro/2-enhanced-rfc-2544.pdf); [EXFO EtherSAM](https://www.exfo.com/contentassets/2f87303d99c244ab8d1928eefe9837af/exfo_anote230_ethersam-ethernet-service-testing_en.pdf); [NetAlly KB](https://support.netally.com/kbhome/kbarticle/?id=96f46e4f-d29f-48e9-81b7-e1fd81406e26)
- TWAMP-Light reflectors let you measure toward carrier devices that run responders. — [MikrotikQualityAgent](https://github.com/ComComServicesLtd/MikrotikQualityAgent); [Paragon TWAMP task docs](https://app.netrounds.com/static/3.0/support/task-types/refl/twamp.html)

### Inferences
- **MikroTik reflector options, by layer:**
  - **L3 UDP echo / TWAMP-Light:** only via a container, or a PC or host behind the router (twampy reflector, NetAlly NPT Reflector).
  - **L2 MAC swap:** not native as far as found. A cheap NID or a dedicated loopback device in front of or beside the MikroTik provides it.
  - **btest itself:** a proprietary MikroTik-to-MikroTik "peer", which is what the user already uses.
- The user's current practice (two MikroTiks, `direction=both`, run once from each end, escalate only on two-end agreement) is structurally a manual dual test set with software counters. It is methodologically closer to DTS than a single-ended loopback tester would be. What it lacks versus commercial DTS is hardware TX/RX counting, hardware timestamps, the Y.1564 step and policing structure, and a report format carriers recognise.
- **Carrier acceptance (not sourced):** carriers typically run their own Y.1564/RFC 2544 turn-up from their NID or test head at install. A customer-side btest result is likely to be treated as indicative, not contractual. Pairing it with the carrier's own NID counters, or a Y.1564 run from a customer NID, would strengthen an escalation. This should be confirmed against the user's actual carrier SLAs.

### Gaps
- No primary source found on what specific carriers accept as trouble-ticket evidence, e.g. "must be Y.1564 from a certified test set" or "customer btest accepted". The Reddit/forum/X researchers may have anecdotes.
- Whether any RouterOS 7 feature (e.g. a bridge or switch-chip rule) can emulate an L2 MAC-swap loop was not checked. It is out of lane, since the RouterOS-native researcher covers it.
- Hardware timestamp accuracy of the cheap NIDs and handhelds is not published in the sources retrieved.
