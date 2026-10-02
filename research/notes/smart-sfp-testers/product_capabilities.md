# Smart SFP / micro-NID products for Ethernet service activation testing: verified capability matrix (as of 2026-09-30)

Scope: whether a pair of smart SFPs, one in each end's MikroTik SFP port, can give hardware-counted, per-direction loss at line rate. Every claim below cites a vendor page or datasheet, or is marked as coming from a search-result snippet I did not fetch. PDF note: WebFetch could not read the RAD and VIAVI PDFs (it returned "binary content"). I extracted their text with a local Perl/zlib script, so the quotes are verbatim. The VIAVI brochure uses a font that drops digits, so numbers like "RFC ____" come out blank in its quotes.

## Q0. Which products exist, which were fabricated, and what is their 2026 status?

### Takeaway
PlumSpace is real, and it is the only vendor found whose smart SFP claims line-rate Y.1564 generation with one-way results and a standalone CLI. "Accedian Antentry" does not exist. Accedian's real names are the "ant" module (a small box, not an SFP) and the "Nano" smart SFP, now the Cisco Provider Connectivity Assurance / Crosswork Assurance "Assurance SFP" (formerly "SFP compute"). RAD MiNID, VIAVI Fusion JMEP and the OE Solutions/AimValley Smart SFP are real. Ciena, Adtran/ADVA, Canoga Perkins, Albis, EXFO, Juniper Paragon and Lanner all sell Y.1564 test boxes or software agents, but none of them has an SFP-form test product that I could find.

### Capability matrix (details and sources in the sections below)

| Product | Form / speed | Generates RFC 2544 / Y.1564 itself? | One-way (per-direction) results? | 64 B / line rate | Management | Controller required? | Power | Status 2026 |
|---|---|---|---|---|---|---|---|---|
| **Cisco Assurance SFP** (ex-Accedian Skylight SFP compute / Nano) S1G-*/S10G-*-PM-D-I | SFP 1G (SX, LH, copper 100/1000) and SFP+ 10G (SR, LR, ER, BiDi) | **Yes**: "RFC2544 generation and reflection", "Y.1564 generation and reflection", up to 4 SAT tests | **No for SAT**: RFC 2544 needs a peer that loops traffic back, and Y.1564 is "Only two-way" under Sensor Control. TWAMP one-way delay metrics are listed | 64 to 10,240 B; "SAT testing at line rate for any packet size"; 1 µs delay accuracy | IP/DHCP/LLDP, ZTP; managed as a "remote device" of Sensor Control, orchestrator SSHes in | **Effectively yes** (Sensor Control + orchestrator; SAT consumes a license per test) | 1.75 W (1G optical), 3.0 W (1G copper), 2.0 to 3.2 W (10G) | Current; datasheet updated 21 May 2026 |
| **RAD MiNID** (SFP sleeve; SFP with integrated optics; standalone) | FE/GbE only | **No**: "responds to RFC-2544 and Y.1564 service activation tests at wire speed"; wire-speed L2/L3/L4 loopback; TWAMP-Light **responder** | No for SAT (responder only). Y.1731 LM "synthetic and real traffic" | Wire-speed loopback; max frame 12,000 B | Web UI, CLI over SSH, SNMPv2, in-band VLAN mgmt, "Loaned IP" of host, RADview optional | **No**: standalone web/CLI | Sleeve 1.2 W max (1.65 to 1.68 W with a 10 km SFP) | Still on rad.com, no EOL notice; datasheets found date from 2013 to 2016 |
| **VIAVI Fusion JMEP** (JMEP3 1G SFP, JMEP10 10G SFP+) | 1G and 10G, optical (plus a 1G RJ45 part) | **Partly**: brochure says JMEPs "simulate multiple simultaneous loads ... via Y.1564 traffic generation"; otherwise positioned as L2/L3 loopback for VIAVI test sets | Not stated | Not stated | Addressed in-band by its own MAC (one per direction); used with T-BERD/MTS, OneAdvisor, Fusion EtherASSURE | **Appears so** (VIAVI test set or Fusion); no standalone CLI documented | Not found | Current on viavisolutions.com (JMEP10 launched May 2021) |
| **Cisco Smart SFP NID** (ME 1200 family) | 1G LX SFP | Snippet: "use RFC 2544 and Y.1564 ... methodologies" (same wording as VIAVI) | n/a | n/a | n/a | n/a | n/a | **Retired**: datasheet URL now redirects to Cisco's retired-products list |
| **OE Solutions / AimValley Smart SFP** (Ethernet OAM, IP OAM, OAM 3.0) | GbE SFP | Unclear: "Service Activation Test for Y.1564 and RFC2544" / "L2/L3/L4 activation testing"; OAM 3.0 press release says "multi-service Y.1564 test **loopbacks**" | Not stated (Y.1731 LM/DM, TWAMP) | "Gigabit Ethernet wire speed" | "API and SNMP MIBs" | Not stated | Not found | Ethernet-OAM page still live, but the current products overview lists only TDM-over-packet and rate-adaptation parts; 2023 to 2024 news covers only those |
| **PlumSpace Smart SFP Ethernet Tester** | SFP/SFP+ 1/10G | **Yes**: "BER", "RFC 2544", "Y.1564, 4 streams, 1-way, 2-way", generator/analyzer "up to 10 Gbps" | **Yes (claimed)**: "1-way, 2-way"; jitter "Symmetrical and asymmetrical" | Max frame 9,600 B; minimum not stated; line-rate claim | "CLI over SSH, SNMP, REST API", static IP/DHCP, IPv4/IPv6/VRF | **No** (standalone CLI/REST) | Not published | Current on plumspace.com |
| **PlumSpace IP SLA Probe** | 1/10G | Yes: "Y.1564, 4 streams, 1-way, 2-way", "Line rate packet generator and analyzer"; TWAMP sender/responder | Yes (claimed) | "TWAMP Light at line rate (HW offload)"; "microsecond accuracy" | CLI/SNMP/REST | No | Not published | Current |
| **PlumSpace NID / Loopback** | 1/10G | Loopback/responder: "Service Activation Test loopback (Y.1564, RFC 2544)"; TWAMP sender/responder | n/a | Hardware wire-speed claimed | CLI over SSH (NID); CLI/SNMP/REST (Loopback) | No | Not published | Current |
| Accedian **ant** module | Small box (not SFP), 1G | Gen + reflect (distributor page) | n/a | FPGA line-rate | Skylight | Yes | n/a | Legacy (ex-Accedian) |
| Juniper Paragon Active Assurance | x86/software Test Agents; **no SFP** | Y.1564 via software agents | n/a | n/a | Control Center | Yes | n/a | Hardware agents deprecated in favor of NFX150/ACX |
| EXFO BV-110 | Box with two network ports; **no SFP found** | Active tests via Worx server | n/a | n/a | EXFO Worx | Yes | n/a | n/a |
| Ciena 3916/3930/5131, ADVA/Adtran FSP 150, Canoga 9145E, Albis ACCEED | Boxes/NIDs; **no smart SFP found** | Box-level Y.1564/RFC 2544 | n/a | n/a | n/a | n/a | n/a | n/a |
| Precision Optical Transceivers, Lanner | **No smart-SFP test product found** | | | | | | | |

### Cited Findings
- PlumSpace is a real company with a smart-SFP catalogue: OTDR, IP SLA Probe, IP SLA Probe Lite, Loopback, NID, Packet Broker, "Ethernet Tester – Turn any SFP slot into a traffic generator", Router, Rate Converter and others — [PlumSpace All Smart SFP](https://plumspace.com/products/smart-sfp/)
- PlumSpace per LinkedIn (search snippet, not fetched): "founded in 2013 and is headquartered in Ajman, UAE" — [LinkedIn](https://www.linkedin.com/company/plumspace). An independent blogger calls it "Russian company Plumspace" — [benjojo blog](https://blog.benjojo.co.uk/post/smart-sfp-linux-inside)
- "Antentry": an exact-phrase search with "Accedian" returned only Accedian "ANT" module listings (ANT-1000-TX, ANT-1000-AX-R). No product called "Antentry" exists in any result — [search results incl. Accedian Wikipedia](https://en.wikipedia.org/wiki/Accedian); [Fastech NanoNID/ANT](https://www.fastech-india.com/nanonid-ant/)
- The Accedian ant module is described as "an iPhone-sized device that sits behind the cable modem" (search snippet) — [Light Reading](https://www.lightreading.com/cable-technology/accedian-steps-up-cable-business-drive)
- Accedian was acquired by Cisco in September 2023 (search snippet) — [Wikipedia: Accedian](https://en.wikipedia.org/wiki/Accedian)
- "The Cisco Provider Connectivity Assurance Sensor SFP portfolio (formerly Accedian Skylight SFP Compute Sensor)" — [Cisco Assurance Sensor SFP 1G Optical HW Install Guide (PDF, © 2025)](https://www.cisco.com/c/en/us/td/docs/interfaces_modules/transceiver_modules/installation/note/sfp-1g-optical-install.pdf)
- The Cisco Assurance SFP datasheet was last updated "May 21, 2026" — [Cisco Assurance SFP Data Sheet](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/provider-connectivity-assurance-sensors/provider-connect-assurance-sensor-sfp-ds.html)
- An EoS/EoL announcement exists for the "Cisco Provider Connectivity Assurance Sensor Capture" (5 March 2026). That is a capture product, not the SFP. Search snippet only, not fetched — [Cisco PCA support](https://www.cisco.com/c/en/us/support/cloud-systems-management/accedian-skylight/series.html)
- The Cisco "Smart SFP Network Interface Device" datasheet URL now lands on a page that says "Below are retired Cisco Switch product lines, which are no longer supported by Cisco" — [Cisco (retired)](https://www.cisco.com/c/en/us/products/collateral/switches/me-1200-series-carrier-ethernet-access-devices/datasheet-c78-734249.html)
- RAD MiNID is still listed on rad.com with no EOL notice: "Remotely managed via CLI, web interface and SNMP" — [RAD MiNID product page](https://www.rad.com/product/smart-sfps/minid-miniature-l2-l3-network-interface-device/)
- VIAVI Fusion JMEP is current: "two transceiver varieties, a 1 Gbps JMEP3 and a 10 Gbps JMEP10" — [VIAVI Fusion JMEP](https://www.viavisolutions.com/en-us/products/fusion-jmep). JMEP 10 launched 13 May 2021 — [Lightwave](https://www.lightwaveonline.com/test/network-test/article/14203249/viavi-unveils-fusion-jmep-10-smart-sfp-optical-transceiver-for-network-test-and-monitoring)
- OE Solutions/AimValley: the current products overview lists TPoP/TSoP/CPoP/VCoP and 1G1G/1G10G Rate Adaptation Smart SFPs, with no Ethernet OAM item — [smartsfp.com products overview](https://www.smartsfp.com/products-overview/). The Ethernet OAM Smart SFP page is still live — [smartsfp.com Ethernet OAM](https://www.smartsfp.com/ethernet-oam-smart-sfp/). The March 2024 announcement is the 1G10G Rate Adaptation Smart SFP — [OE Solutions blog](https://oesolutions.com/blog/oe-solutions-and-aimvalley-announce-1g10g-rate-adaptation-smart-sfp/)
- Juniper Paragon Active Assurance Test Agent hardware: "HW Small/Medium/Medium Plus/Large" appliances (Large has SFP+ ports). The page marks them deprecated, with "Juniper NFX150 ... and Juniper ACX routers" as replacements. There is no SFP-form agent — [Paragon docs 2.24 hwspecs](https://app.netrounds.com/static/2.24/support/testagents/tech-info/hwspecs.html)
- Paragon Test Agents do "service activation (Y.1564, MEF 48) ... Y.1731, TWAMP" (search snippet) — [Juniper PAA datasheet](https://www.juniper.net/content/dam/www/assets/datasheets/us/en/network-automation/juniper-paragon-active-assurance-datasheet.pdf)
- EXFO BV-110 "features dual network ports" and "automatically discovers its EXFO Worx server" (search snippet) — [EXFO BV-110 spec sheet](https://www.exfo.com/contentassets/fe1ae1ccd8f34cb48a6c948f0578b5b0/exfo_spec-sheet_bv-110_v4_en.pdf)
- Ciena 3930 "incorporates on-board Y.1564 and RFC 2544" and the 5131 Router has "RFC 2544, and ITU-T Y.1564" (search snippets; both are boxes) — [Ciena 3930 DS](https://www.westconcomstor.com/content/dam/wcgcom/US_EN/westcon/vendors/ciena/documentation/Packet-Products/packet/Ciena-3930-Service-Delivery-Switch-Data-Sheet.pdf); [Ciena 5131](https://www.ciena.com/insights/data-sheets/5131-ds)
- ADVA/Adtran FSP 150-GO102Pro "supports MEF-compliant ITU-T Y.1564 service activation testing" (a box; search snippet) — [Adtran FSP 150-GO102Pro DS](https://www.adtran.com/-/media/adva-main-site/resources/data-sheets/pdfs/fsp-150-go-102-pro-series.pdf?rev=15cc366df5ec49edb9b05c05184c9a2a&hash=E544752A325DAC19CA7B319DD1670878)
- Canoga Perkins 9145E is a "single UNI, single NNI/ENNI Metro Ethernet Network Interface device" (a box; search snippet) — [ManualMachine 9145E](https://manualmachine.com/canogaperkins/9145enidsoftwareversion410/1435376-user-manual/)
- Albis "includes a built-in Y.1564 ... in their ACCEED devices" (boxes; search snippet) — [BBC Mag](https://bbcmag.com/albiss-acceed-2104-edd-simplifies-migration-to-carrier-ethernet-services/)
- Precision OT: the search returned only standard SFP+ transceivers and passive "Loopback Connectors" — [Precision OT SFP+](https://www.precisionot.com/product-category/sfp-plus/); [Precision OT loopback connectors](https://www.precisionot.com/product/loopback-connectors/)

### Inferences
- The prior AI answer was half right. PlumSpace is genuine, and on paper it is the closest fit. "Antentry" looks like a corruption of Accedian's "ant" module, which is not an SFP anyway.
- The Cisco Smart SFP NID datasheet wording (search snippet) matches VIAVI's JMEP brochure word for word, which suggests it was an OEM'd JDSU/VIAVI JMEP. It is retired either way.

### Gaps
- No authoritative PlumSpace statement of country of incorporation or export status (LinkedIn says UAE; a blogger says Russian). Worth checking before purchase.
- Cisco EoS notices for the Assurance SFP PIDs specifically: none found; only the Sensor Capture notice (snippet).
- Lanner: no smart-SFP product found at all.

## Q1. Form factor and speed

### Takeaway
Cisco Assurance SFP, VIAVI JMEP and PlumSpace all come in both 1G SFP and 10G SFP+. RAD MiNID is FE/GbE only, and its main form is an SFP *sleeve* that holds a standard SFP. OE/AimValley OAM Smart SFPs are GbE.

### Cited Findings
- Cisco Assurance SFP PIDs: S1G-TE-PM-D-I "100/1000bT", S1G-SX-PM-D-I "SX, 850nm, 550m", S1G-LH-PM-D-I "LH, 1310nm", S10G-SR/LR/ER-PM-D-I, S10G-BD/BU and B40D/B40U BiDi — [Cisco Assurance SFP DS](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/provider-connectivity-assurance-sensors/provider-connect-assurance-sensor-sfp-ds.html)
- Legacy Accedian SFP compute part numbers include 1G duplex (770-300 etc.), copper "1 Gbps/100Mbps" (774-3xx), BiDi and 10G (770-703, 771-703, 77P-703, BiDi 77T/77U-703/713) — [Crosswork Assurance docs: SFP compute](https://docs.crossworkassurance.cisco.com/skylight/docs/sfp-compute.md)
- The 10G SFP compute runs at "10G only" and the 1G at "1G only". The 10G SFP lacks CFM (MEP/DMM/SLM), Flow broker, Policies and Bandwidth regulator — [About Remote Devices](https://docs.crossworkassurance.cisco.com/skylight/docs/about-remote-devices-2.md)
- MiNID "available in an SFP form factor, SFP sleeve form factor or in a standalone enclosure"; "MINID/SLV/GE SFP sleeve enclosure, 1 Gbps per port"; sleeve type "100BaseFx/1000BaseFx"; "MiNID can be ordered as an FE or FE/GbE device" — [RAD MiNID DS v2.3 04/16 (PDF)](https://www.rlcomunicaciones.com/docs/rad/fo/MiNID.pdf)
- "MiNID adds 33.5 mm (1.32 in.) to the depth of the host device" (sleeve) — [RAD MiNID DS v1.1 12/13 (PDF)](https://www.itfor.co.jp/it-infra/telecom-carrier/rad/RAD_PDF/MiNID.pdf)
- JMEP part numbers: "JMEP01LX10A11" (1G LX 10 km), "JMEP01ZX80A11", "JMEP01BX40D11/U11" (BiDi), "JMEP01CU00A10" (1G CU smart SFP, RJ45), "JMEP10LR10A01" (10G LR). JMEP3 is "compatible with the INF-8074i" at "up to 1.25 Gbps signaling" — [VIAVI Fusion JMEP brochure (PDF)](https://www.viavisolutions.com/en-us/literature/fusion-jmep-smart-sfp-brochures-en.pdf)
- PlumSpace Ethernet Tester "1/10 Gigabit Ethernet", "SFP/SFP+ MSA compliant" — [PlumSpace Ethernet Tester](https://plumspace.com/products/smart-sfp-ethernet-tester/). PlumSpace NID: "Line to host rate matching: 1GE to 10GE and 10GE to 1GE" — [PlumSpace NID](https://plumspace.com/products/smart-sfp-nid/)
- OE/AimValley IP OAM Smart SFP: Gigabit Ethernet, "duplex and bi-directional SFP form factors" (18 Mar 2015) — [OE Solutions press release](https://oesolutions.com/ja/oe-solutions-and-aimvalley-to-introduce-ip-oam-smart-sfp/)

### Inferences
- A MikroTik with SFP+ cages (CCR2004, RB5009, CRS3xx) can take either the 1G or 10G variants of Cisco, VIAVI or PlumSpace. The MiNID sleeve sticks out 33.5 mm, which may collide with adjacent ports or cables.

### Gaps
- None of the vendors publishes a MikroTik compatibility list.

## Q2. Does the SFP generate test traffic itself, or only reflect?

### Takeaway
Generator-capable: the Cisco/Accedian Assurance SFP (RFC 2544 and Y.1564 generation and reflection, up to 4 SAT tests), the PlumSpace Ethernet Tester and IP SLA Probe (Y.1564/RFC 2544/BER generator plus analyzer), and possibly the VIAVI JMEP (the brochure mentions "Y.1564 traffic generation", but everything else positions it as a loopback for VIAVI test sets). Responder/reflector only: the RAD MiNID (all datasheet versions 2013 to 2016), the PlumSpace NID and Loopback, and, by its own press release, the OE/AimValley OAM 3.0 ("test loopbacks").

### Cited Findings
- Cisco: "RFC2544 generation and reflection", "Y.1564 generation and reflection"; "Cisco Assurance SFPs can create and analyze up to four Layer 2 or 3 unique fully fledged RFC-2544 and Y.1564 Service Activation Test (SAT) suite"; "support full line-rate test traffic generation"; TWAMP "Maximum sessions: 4000 with a total of 80000 PPS" — [Cisco Assurance SFP DS](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/provider-connectivity-assurance-sensors/provider-connect-assurance-sensor-sfp-ds.html)
- Accedian remote devices (10G SFP compute, 1G SFP compute, modules): "RFC-2544 IPv4 and IPv6 | Yes (4 flows)"; "Y.1564 IPv4 and IPv6 | Yes (8 flows)"; "TWAMP statefull reflection | Yes (16)"; "Loopback | Yes" — [About Remote Devices](https://docs.crossworkassurance.cisco.com/skylight/docs/about-remote-devices-2.md)
- Legacy Accedian NanoNID/ant: "RFC-2544 (Generation and Reflection) & Y.1564 (Reflection and Generation)"; "all-hardware, line-rate packet FPGA processing engine" (distributor page) — [Fastech NanoNID/ANT](https://www.fastech-india.com/nanonid-ant/)
- RAD MiNID 2013: "MiNID responds to RFC-2544 and Y.1564 service activation tests" — [MiNID DS v1.1](https://www.itfor.co.jp/it-infra/telecom-carrier/rad/RAD_PDF/MiNID.pdf). 2015/2016: "MiNID responds to RFC-2544 and Y.1564 service activation tests at wire speed"; "MiNID also participates in service activation tests and offers wire-speed Layer-2/3/4 loopbacks"; "RFC-5357 TWAMP light responder with multiple session reflectors offering hardware-based time stamping" — [MiNID DS v2.00 01/15](https://bestdatasource.com/rad/data_sheets/minid.pdf); [MiNID DS v2.3 04/16](https://www.rlcomunicaciones.com/docs/rad/fo/MiNID.pdf)
- RAD 2017 brochure, "Demarc" application: "Service turn-up testing with 2544/Y.1564"; "Fault management with L2-L4 diagnostic loopbacks"; "Y.1731, TWAMP and UDP echo performance monitoring"; the "Platinum" app adds "Remote packet capture" and "Micro-burst analysis" — [RAD MiNID brochure 1/17 (PDF)](http://www.sunivy.com/upload/Images/products/MiNID-Product-Brochure.pdf)
- VIAVI JMEP: "They simulate multiple simultaneous loads on the network via Y.1564 traffic generation as well as micro-burst monitoring ... with resolution to 1 msec"; "Activates test loopbacks (L2/L3)"; "Support for Y.1731 reflector and initiator modes"; "Supports a TWAMP-Light reflector"; "RFC 6349 TrueSpeed ... test ... to and/or from a JMEP"; "Interworks with" T-BERD/MTS, NSC, vTA, vPMA, OneAdvisor — [VIAVI JMEP brochure (PDF)](https://www.viavisolutions.com/en-us/literature/fusion-jmep-smart-sfp-brochures-en.pdf)
- VIAVI product page: "Activates test loopbacks (L2/L3)", "compatible with the VIAVI T-BERD/MTS test portfolio and ... Fusion EtherASSURE centralized test solution" — [VIAVI Fusion JMEP](https://www.viavisolutions.com/en-us/products/fusion-jmep)
- OE/AimValley IP OAM Smart SFP: "L2/L3/L4 activation testing according to RFC2544/Y.1564 standards, loss and delay measurement according to TWAMP" (2015) — [OE Solutions](https://oesolutions.com/ja/oe-solutions-and-aimvalley-to-introduce-ip-oam-smart-sfp/). Ethernet OAM Smart SFP: "Service Activation Test for Y.1564 and RFC2544" — [smartsfp.com](https://www.smartsfp.com/ethernet-oam-smart-sfp/). OAM 3.0 (17 Jun 2014): "Gigabit Ethernet wire speed with multi-service Y.1564 test loopbacks" — [AimValley](https://www.aimvalley.com/oe-solutions-and-aimvalley-introduce-oam-3-0-smart-sfp-for-service-assurance/)
- smartsfp.com service assurance (search snippet): Smart SFP modules "support link and service OAM (CFM and Y.1731) and service activation test loopback (Y.1564)" — [smartsfp.com Service Assurance](https://www.smartsfp.com/service-assurance/)
- PlumSpace Ethernet Tester: "BER", "RFC 2544", "Y.1564, 4 streams, 1-way, 2-way"; traffic generation "up to 10 Gbps"; plus "Smart Loopback" — [PlumSpace Ethernet Tester](https://plumspace.com/products/smart-sfp-ethernet-tester/)
- PlumSpace IP SLA Probe: "Line rate packet generator and analyzer"; "TWAMP sender and responder" — [PlumSpace IP SLA Probe](https://plumspace.com/products/smart-sfp-ip-sla-probe/)
- PlumSpace NID: "Service Activation Test loopback (Y.1564, RFC 2544)"; "TWAMP sender and responder" — [PlumSpace NID](https://plumspace.com/products/smart-sfp-nid/). PlumSpace Loopback: L2 to L4 loopback with "MACs, IPs and TCP/UDP ports swap"; "Remote control from IP/Ethernet testers" — [PlumSpace Loopback](https://plumspace.com/products/smart-sfp-loopback/)

### Inferences
- A MiNID pair cannot run an acceptance test by itself. Both ends are responders, and a MikroTik cannot act as the Y.1564 generator. MiNID only helps as the far-end reflector for some other generator.
- For VIAVI, the brochure's "Y.1564 traffic generation" claim conflicts with every other VIAVI source, which says "activates test loopbacks" and pairs the JMEP with T-BERD/MTS or Fusion. Treat JMEP-as-generator as unconfirmed until a VIAVI datasheet or manual confirms it.

### Gaps
- No current RAD MiNID datasheet (post-2017) is publicly downloadable (rad.com gates it behind a form), so a newer firmware with a generator cannot be ruled out.
- No PlumSpace datasheet PDF was retrieved. All PlumSpace claims come from product web pages.

## Q3. Two-ended one-way (per-direction) measurement versus loopback round-trip

### Takeaway
This is the deciding question for the user, whose tool is blind to outbound loss below about 5%. Among smart SFPs, only PlumSpace explicitly claims Y.1564 "1-way" results (and "asymmetrical" jitter). The Cisco/Accedian SAT is loopback-based: RFC 2544 "must pair ... with another device that loops the traffic back", and Y.1564 under Sensor Control supports "only two-way". It therefore reports round-trip loss, hardware-counted but not split by direction. A pair of Accedian SFPs can each run a test toward the other, but each result is still round-trip.

### Cited Findings
- Accedian/Cisco RFC 2544: "You must pair the traffic generator with another device that loops the traffic back. The Skylight modules contain pre-programmed loopbacks for certain types of layer-2 frames (LBM). When testing with layer-3 packets (UDP), you must configure the peer unit with a loopback ... with a swapping action on the source/destination MAC addresses, IP addresses, and UDP port numbers"; "Received packets | Total packets received by the generator's analysis component for this test after being looped back by the peer device"; delay is "Two-way" — [Using RFC-2544 for Traffic Generation and Analysis](https://docs.crossworkassurance.cisco.com/skylight/docs/using-rfc-2544-for-traffic-generation-and-analysis.md)
- Accedian/Cisco Y.1564: "The Accedian implementation of Y.1564 supports the following types of tests: Layer-2 two-way testing. Layer-3 two-way testing."; "Delay measurement type | Only two-way delay measurement type (i.e., two-way testing) is supported on [Sensor Control]"; "Y.1564 availability measurement is not supported"; up to 500 tests and 8 services each — [Using Y.1564 for Service Activation Testing](https://docs.crossworkassurance.cisco.com/skylight/docs/using-y1564-for-service-activation-testing-1.md)
- The Accedian license tiers list a "2xOneWay session" type and TWAMP sessions (one-way PM, not SAT) — [Skylight License Tiers](https://docs.crossworkassurance.cisco.com/skylight/docs/skylight-license-tiers.md). The Cisco datasheet lists one-way delay metrics "Min/max/average, Median (p50), Percentile 25/75/95/96/98/99" and "Packet lost (number and %)" — [Cisco Assurance SFP DS](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/provider-connectivity-assurance-sensors/provider-connect-assurance-sensor-sfp-ds.html)
- PlumSpace Ethernet Tester: "Y.1564, 4 streams, 1-way, 2-way"; jitter "1-way and 2-way" and "Symmetrical and asymmetrical" — [PlumSpace Ethernet Tester](https://plumspace.com/products/smart-sfp-ethernet-tester/). IP SLA Probe: "Y.1564, 4 streams, 1-way, 2-way" — [PlumSpace IP SLA Probe](https://plumspace.com/products/smart-sfp-ip-sla-probe/)
- RAD MiNID: Y.1731 "for loss (synthetic and real traffic), delay, and delay variation measurements" (Y.1731 LM/SLM gives near-end and far-end loss, but only at OAM rates, not a line-rate SAT) — [MiNID DS v2.3](https://www.rlcomunicaciones.com/docs/rad/fo/MiNID.pdf)
- OE/AimValley: Y.1731 "frame loss and frame delay measurement" — [OE Solutions blog](https://oesolutions.com/blog/oe-solutions-and-aimvalley-add-y-1731-to-smart-sfp-portfolio/)

### Inferences
- A loopback test still improves on btest for the user. Hardware counters at line rate would see 0.10% round-trip loss, which btest cannot see outbound. But a FAIL could not be attributed to a direction without a one-way mode. Running from each end does not fix this, because each run is still round-trip.
- Y.1731 SLM (synthetic loss) on MiNID or OE smart SFPs does give per-direction (near-end/far-end) loss. It runs at low OAM rates, though, so it measures a sample of frames, not line-rate acceptance.
- PlumSpace's "1-way" is a marketing-page claim. How it reports one-way loss (does the receiving unit count per stream, and how are results collected from the far end?) is undocumented.

### Gaps
- No PlumSpace manual found describing how one-way Y.1564 pairs two units (peer discovery, result retrieval, clock sync requirements).
- Whether the standalone (non-Sensor-Control) Accedian SFP firmware ever supported one-way Y.1564 (Accedian MetroNID boxes historically did): not documented in the current docs.

## Q4. Frame sizes (64 B?), line rate, hardware loss counting, timestamp precision

### Takeaway
The Cisco/Accedian SFP explicitly supports 64 to 10,240 B at line rate with 1 µs delay accuracy. The others claim wire-speed or line-rate operation but publish no minimum frame size.

### Cited Findings
- Accedian RFC 2544 generator frame size "Acceptable values range from 64 bytes to 10240 bytes"; "For IPv6 traffic ... the minimum frame size is 80 bytes"; bit rate steps "0 to 12.5 Mbps: Steps of 0.125 Mbps; 13 Mbps to Line Rate: Steps of 1 Mbps"; flows "one to four" — [Using RFC-2544](https://docs.crossworkassurance.cisco.com/skylight/docs/using-rfc-2544-for-traffic-generation-and-analysis.md)
- RFC 2544 test suite: "Frame/Packet Sizes: All sizes defined in the RFC-2544 standard, plus Jumbo"; trial duration "1–1800 seconds"; back-to-back "minimum inter-frame gap (line rate)" — [About RFC-2544](https://docs.crossworkassurance.cisco.com/skylight/docs/about-rfc-2544-for-traffic-generation-and-analysis-1.md); [Using the RFC-2544 Test Suite](https://docs.crossworkassurance.cisco.com/skylight/docs/using-the-rfc-2544-test-suite-1.md)
- Cisco: "SAT testing at line rate for any packet size with 1-usec delay measurement accuracy" — [Cisco Assurance SFP DS](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/provider-connectivity-assurance-sensors/provider-connect-assurance-sensor-sfp-ds.html)
- RAD MiNID: "wire speed" loopbacks and SAT response; FPGA-based ("MiNID programmability is based on a powerful FPGA"); max frame 2,048 B (2013), then 12,000 B (2015/16) — [MiNID DS v2.3](https://www.rlcomunicaciones.com/docs/rad/fo/MiNID.pdf); [MiNID DS v1.1](https://www.itfor.co.jp/it-infra/telecom-carrier/rad/RAD_PDF/MiNID.pdf)
- VIAVI JMEP: "With full MAC and PCS layer implementation, the JMEP performs rate adaptation as defined by IEEE802.3"; micro-burst "resolution to 1 msec" — [VIAVI JMEP brochure](https://www.viavisolutions.com/en-us/literature/fusion-jmep-smart-sfp-brochures-en.pdf)
- PlumSpace IP SLA Probe: "Measurements with microsecond accuracy"; "Timestamp insertion in transit packets" in "NTP Timestamp format"; "TWAMP Light at line rate (HW offload)" — [PlumSpace IP SLA Probe](https://plumspace.com/products/smart-sfp-ip-sla-probe/). PlumSpace NID: "The most important functions are implemented in hardware ... while supporting wire-speed packet processing" — [PlumSpace NID](https://plumspace.com/products/smart-sfp-nid/). Ethernet Tester max frame "9600 bytes" — [PlumSpace Ethernet Tester](https://plumspace.com/products/smart-sfp-ethernet-tester/)
- Independent tests of PlumSpace's Linux CPU path (not the hardware test path). An older single-core ARMv7 unit: "the actual Linux system inside the SFP appears to be limited to 125 Mbits/sec", with an FPGA that forwards and filters traffic to the CPU — [benjojo blog](https://blog.benjojo.co.uk/post/smart-sfp-linux-inside). "almost 190 Mbps of throughput via iperf" on a 528 MHz ARMv7 (May 2020) — [NetBeez](https://netbeez.net/blog/smart-sfp/). A newer "dual core ARM Cortex A53" unit measured ~895 to 932 Mbps iperf3 in bridging/routing/NAT44 — [apalrd 2025](https://www.apalrd.net/posts/2025/network_smartsfp/)
- OE/AimValley: "hardware-accurate time-stamping" (IP OAM Smart SFP) — [OE Solutions](https://oesolutions.com/ja/oe-solutions-and-aimvalley-to-introduce-ip-oam-smart-sfp/)

### Inferences
- The independent PlumSpace numbers show its Linux CPU is far below line rate. Line-rate Y.1564 must therefore rely on the hardware engine ("HW offload" / FPGA), and the "line rate" and 64 B claims need bench verification, as the user's own testing conventions require.
- Accedian's Y.1564/RFC 2544 results come from the SFP's own FPGA counters, so round-trip loss is hardware-counted.

### Gaps
- Minimum frame size for PlumSpace, MiNID, JMEP and OE: not published.
- Whether loss counting on PlumSpace's generator is FPGA- or CPU-based: not documented.

## Q5. Management: in-band, I2C, or central controller only? Is a paid controller required?

### Takeaway
RAD MiNID and PlumSpace have standalone management (web and/or CLI over SSH, SNMP, REST for PlumSpace). The Cisco/Accedian SFP is designed as a "remote device" of Cisco Sensor Control (a VM), orchestrated by Skylight/Crosswork. Tests and results run through that stack, and SAT tests consume licenses. VIAVI JMEP is addressed in-band by MAC from VIAVI test sets or Fusion. No standalone UI for it is documented.

### Cited Findings
- Accedian: "Cisco Crosswork Assurance Sensor Control ... discover[s] remote devices (Skylight sensor: SFP compute 1G/10G and Skylight sensor: module 1G/10G modules) ... These devices can be considered as extensions of the Sensor Control, which uses the ports of the modules to deliver system functionality remotely" — [About Remote Devices](https://docs.crossworkassurance.cisco.com/skylight/docs/about-remote-devices-2.md)
- The Y.1564 test's "Outgoing Port" is "The port tied to a remote device on which traffic is to be generated"; flow state "Network Failure: Issues on the network between the [Sensor Control] and the remote device" — [Using Y.1564](https://docs.crossworkassurance.cisco.com/skylight/docs/using-y1564-for-service-activation-testing-1.md); [Using RFC-2544](https://docs.crossworkassurance.cisco.com/skylight/docs/using-rfc-2544-for-traffic-generation-and-analysis.md)
- Discovery: "newly installed modules advertise their presence on the network"; "In order to move a device to the Managed state, Skylight orchestrator must first be able to establish an SSH connection to the device and log in" — [About module Discovery](https://docs.crossworkassurance.cisco.com/skylight/docs/about-skylight-sensor-module-discovery-1.md)
- Cisco datasheet management: "Communications with Cisco Crosswork Assurance using IP address"; "Zero-Touch Provisioning (ZTP) and IPv4/IPv6 management"; "DHCP", "LLDP enabled by default"; "Firmware update via Cisco Crosswork Assurance". No local CLI/web UI is mentioned — [Cisco Assurance SFP DS](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/provider-connectivity-assurance-sensors/provider-connect-assurance-sensor-sfp-ds.html)
- Skylight module dock: a USB-attached dock with a "Management Web Interface". "Skylight sensor: compute devices are connected via the SFP port" to "pre-stage the parameters of a connected remote device" (IPv4 etc.) and apply "feature suites" — [Getting Started with the module dock](https://docs.crossworkassurance.cisco.com/skylight/docs/getting-started-with-the-skylight-module-dock-1.md); [Features and User Material](https://docs.crossworkassurance.cisco.com/skylight/docs/skylight-module-dock-features-and-user-material.md)
- RAD MiNID: "Web-based menu-driven interface; Command Line Interface (CLI) via secured Telnet (SSH); SNMPv2; Inband management (VLAN based); Out-of-band management and software configuration from any Ethernet port in the host device"; "equipped with two MAC addresses; one for management and one for services"; "Loaned IP: MiNID can be managed without a dedicated IP address, by loaning the IP address of the hosting device"; DHCP ZTP; RADview optional for PM reports — [MiNID DS v2.3](https://www.rlcomunicaciones.com/docs/rad/fo/MiNID.pdf). 2013 version: "ready for integration with host devices via I2C management channel"; "Inband management (VLAN based), via host SFP or MSA edge connector" — [MiNID DS v1.1](https://www.itfor.co.jp/it-infra/telecom-carrier/rad/RAD_PDF/MiNID.pdf)
- VIAVI JMEP: "Each direction has a unique MAC address. The network can address commands directly to the MAC for test and turn-up after which the probe can continue to operate with its own MAC or can assume the MAC address of the device to which it is connected"; DDM per SFF-8472 — [VIAVI JMEP brochure](https://www.viavisolutions.com/en-us/literature/fusion-jmep-smart-sfp-brochures-en.pdf)
- PlumSpace: "CLI over SSH, SNMP, REST API"; "Static IP, DHCP"; "IPv4, IPv6, VRF"; "Remote software upgrade" — [PlumSpace Ethernet Tester](https://plumspace.com/products/smart-sfp-ethernet-tester/); [PlumSpace Loopback](https://plumspace.com/products/smart-sfp-loopback/). An older unit had SSH at default IP "192.168.2.1" — [benjojo blog](https://blog.benjojo.co.uk/post/smart-sfp-linux-inside)
- OE/AimValley: "API and SNMP MIBs are available" — [smartsfp.com](https://www.smartsfp.com/ethernet-oam-smart-sfp/)

### Inferences
- For a small MikroTik shop, the Cisco/Accedian path means licensing and running Sensor Control plus an orchestrator. That is an enterprise-scale commitment, and effectively a controller requirement even though the SFP has an SSH login.
- MiNID's "Loaned IP" and in-band VLAN management mean a MikroTik could reach it from the host side without extra config. PlumSpace needs an IP reachable from the MikroTik (DHCP or static) on the line or host side.

### Gaps
- Whether the Cisco Assurance SFP's SSH CLI can start a SAT test and show results without Sensor Control: not documented publicly.
- JMEP standalone management (CLI/web): not documented.

## Q6. Is the SFP inline and transparent to the host?

### Takeaway
All of these are inline smart transceivers. The host provides power and a cage, and user traffic passes through. MiNID's auto-responder is "transparent to user traffic". PlumSpace supports "inline or out-of-line". No vendor documents how host traffic is handled while a line-rate generator test runs.

### Cited Findings
- MiNID: "The auto-responder mode is transparent to user traffic"; "transparently envelops a large variety of SFPs"; DDM "can be forwarded to the host" — [MiNID DS v2.3](https://www.rlcomunicaciones.com/docs/rad/fo/MiNID.pdf)
- JMEP: "seamlessly deploy inline" and can "assume the MAC address of the device to which it is connected" — [VIAVI JMEP brochure](https://www.viavisolutions.com/en-us/literature/fusion-jmep-smart-sfp-brochures-en.pdf)
- PlumSpace: "Inline or out-of-line installation" — [PlumSpace Ethernet Tester](https://plumspace.com/products/smart-sfp-ethernet-tester/). NetBeez: "can be installed either in-line (replacing existing standard SFP) or out-of-line" — [NetBeez](https://netbeez.net/blog/smart-sfp/)
- Cisco install guide: "Prior to installing a transceiver, power capabilities of the cage must be verified with the appliance vendor" — [Cisco Assurance SFP 1G Optical HW Install Guide (PDF)](https://www.cisco.com/c/en/us/td/docs/interfaces_modules/transceiver_modules/installation/note/sfp-1g-optical-install.pdf)

### Inferences
- "Out-of-line" means the SFP sits in a spare port as a test head. For the user, that means a spare SFP cage on each MikroTik and a separate test VLAN or port toward the carrier. The MikroTik then only needs to supply power and a link, and does not forward test traffic.

### Gaps
- Behaviour of host traffic during an in-service or out-of-service SAT: not documented by any vendor fetched.

## Q7. Power draw and MSA power class

### Takeaway
Most units draw 1.2 to 3.2 W. Several exceed the ~1.5 W that many SFP cages are designed for. No vendor states an SFF-8472 power level. MikroTik publishes no per-cage budget, so a bench check is needed.

### Cited Findings
- Cisco Assurance SFP: S1G-TE 3.0 W; S1G-SX/LH 1.75 W; S10G-SR 2.6 W; S10G-LR 2.7 W; S10G-ER 3.0 W; BiDi 2.7 to 3.0 W — [Cisco Assurance SFP DS](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/provider-connectivity-assurance-sensors/provider-connect-assurance-sensor-sfp-ds.html)
- Accedian 10G SFP compute (model nNID10): 850 nm 2.0 W typ / 2.4 W max; 1310 nm 2.1 / 2.5 W; 1550 nm 40 km 2.6 / 3.2 W — [Module Specifications](https://docs.crossworkassurance.cisco.com/skylight/docs/module-specifications-1.md)
- RAD MiNID: 2013 "Max 1.4W (not including SFP)"; 2015 "SFP sleeve: Max 1.2W; Max 1.68W (including standard 10km SFP) ... SFP: 1.68W (10km optics)"; 2016 "1.2W without SFP; 1.65W (including standard 10km SFP)" — [MiNID DS v1.1](https://www.itfor.co.jp/it-infra/telecom-carrier/rad/RAD_PDF/MiNID.pdf); [v2.00](https://bestdatasource.com/rad/data_sheets/minid.pdf); [v2.3](https://www.rlcomunicaciones.com/docs/rad/fo/MiNID.pdf)
- MikroTik: no per-SFP-cage power budget is published. Per a forum post (search snippet), the "S+RJ10 copper SFP is rated with 2.4W and officially supported for RB4011" — [MikroTik forum](https://forum.mikrotik.com/viewtopic.php?t=178661)

### Inferences
- The 1G optical Cisco (1.75 W) and MiNID (≤1.68 W) are the lowest-risk in a MikroTik cage. Copper (3.0 W) and 10G ER variants are the highest-risk.

### Gaps
- Power for VIAVI JMEP, PlumSpace and OE Smart SFPs: not published on the pages fetched.
- SFF-8472 power level declarations: none found for any product.

## Q8. Licensing

### Takeaway
Accedian/Cisco licenses SAT per configured test under platform tiers (Cisco RTU tiers). RAD MiNID requires a software application option (DEMARC, with Platinum as an upgrade) on top of the hardware. PlumSpace, VIAVI and OE publish no licensing terms.

### Cited Findings
- Accedian license tiers (for Accedian-purchased entitlements): "You pay licenses for the number of concurrent test sessions you want to run"; "SAT | ✔ | ✔ (centralized) | ✔ | 1 per configured test (1564, 2544)"; "TWAMP | 1 per configured session" — [Skylight License Tiers](https://docs.crossworkassurance.cisco.com/skylight/docs/skylight-license-tiers.md)
- Cisco-era licenses: "Essentials RTU License (SKY-ESS-RTU) and Advantage RTU License (SKY-ADV-RTU)"; "all software Assurance Sensors are included in the platform RTU licenses" (search snippet, not fetched) — [Cisco Software Sensors DS](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/provider-connectivity-assurance-sensors/provider-connect-assurance-software-sensor-ds.html)
- Cisco Assurance SFP: "Standard warranty: 1 year"; no license statement in the SFP datasheet — [Cisco Assurance SFP DS](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/provider-connectivity-assurance-sensors/provider-connect-assurance-sensor-sfp-ds.html)
- RAD MiNID: "Software: MINID-SW/DEMARC Service demarcation application software. Note: A hardware and software option must be ordered" — [MiNID DS v2.3](https://www.rlcomunicaciones.com/docs/rad/fo/MiNID.pdf). "Platinum Includes all Demarc features in addition to: Remote packet capture; Micro-burst analysis" — [RAD brochure 1/17](http://www.sunivy.com/upload/Images/products/MiNID-Product-Brochure.pdf)
- PlumSpace pricing: the Register quoted "£150" for the 2022 TAP-style Smart SFP (not the Ethernet Tester) — [The Register](https://www.theregister.com/2022/01/18/plumspace_smart_sfp_tap/)

### Gaps
- Prices for the Cisco Assurance SFP, MiNID, JMEP and PlumSpace Ethernet Tester: not public.
- Whether Accedian SFP generator features are licensed separately from reflector features at the SFP level: documented only as per-test platform licensing.
