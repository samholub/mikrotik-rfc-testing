# Cost and procurement: smart SFP test modules vs used carrier NIDs vs DIY TRex (as of 2026-09-30)

Method note for the report writer: eBay item and sold-search pages returned HTTP 403 to the fetch tool, so every eBay price below comes from the search engine's index of eBay pages, not a verified page load. Treat all of them as ASKING prices of unknown listing date (listings may have ended or sold). They were observed 2026-09-30. None were confirmed as SOLD prices. The only sold-quantity signal found is one MiNID listing showing "9 sold". Several vendor datasheets were fetched as PDFs and their text extracted locally, so those quotes are verbatim.

## 1. Current used and new prices

### Takeaway
Used carrier NIDs are very cheap: Adva FSP 150-GE114Pro asking prices run about $30-75, and RAD ETX-203AX about $15-190, mostly $40-100. That is at or below the earlier unsourced claims ($50-200 for Adva, $150-400 for RAD). Genuine smart SFP test modules have almost no used market. The one data point is a used RAD MiNID at about $175 asking. No sourced new price was found for any smart SFP, so the "$800-2,500 new" claim is still unverified.

### Cited Findings
**Option B: used carrier NIDs (all asking prices, eBay, via search index, seen 2026-09-30, listing dates unknown)**
- Adva FSP 150-GE114Pro (4xGE client, 2xGE network): listings at US$29.99 (used, Best Offer), $35.99 (with rack mount, "Best Offer accepted"), $44.95 (with power cord), $44.99, $49.95, $59.00, $64.99 and $75.00 ("Etherjack device"). Examples: [eBay 226835626638](https://www.ebay.com/itm/226835626638), [eBay 406312659921](https://www.ebay.com/itm/406312659921), [eBay 396309523575](https://www.ebay.com/itm/396309523575), [eBay 326579007936 (p/n 1078904720-02 w/ power cord)](https://www.ebay.com/itm/326579007936), [eBay 177137139599](https://www.ebay.com/itm/177137139599), [eBay 156946340513](https://www.ebay.com/itm/156946340513). None of the snippets mentions a license, firmware version or ECPA/RFC 2544 status.
- A GE114Pro listed as part number 1078904720-01 was also seen: [eBay 365649760745](https://www.ebay.com/itm/365649760745).
- Adva FSP150CC-GE114 (older, non-Pro), DC version p/n 1078904622-01, and a GE114 AC wall-mount variant are carried by a surplus reseller. Price not captured: [Confluent Group GE114 DC](https://www.confluentgroup.com/adva-fsp150cc-ge114-dc-carrier-ethernet-and-ip-demarcation-1078904622-01.html), [Confluent Group GE114-AC-WALL-NA-NM](https://www.confluentgroup.com/adva-ge114-ac-wall-na-nm-ethernet-demarcation-device.html).
- RAD ETX-203AX: asking $49.99 ([eBay 167709506925](https://www.ebay.com/itm/167709506925)), $99.99 with rack bracket ([eBay 276411715622](https://www.ebay.com/itm/276411715622)), $59.99 with RAD SFP-17BD ([eBay 276417891951](https://www.ebay.com/itm/276417891951)) and $40.00 with PSU and bracket ([eBay 285580145108](https://www.ebay.com/itm/285580145108)). The search summary also listed $15, $38.99, $100 and $190 for other configurations. One listing is "AS IS" ([eBay 387784310328](https://www.ebay.com/itm/387784310328)), and one is ETX-203AX/GE/2SFP/2UTP_PLS p/n 506076 ([eBay 266882065512](https://www.ebay.com/itm/266882065512)). No snippet states the license level. This matters because the ETX-203AX's bandwidth is license-dependent (see section 2).
- No eBay pricing was retrieved for RAD ETX-2i, Accedian MetroNID/LT, Ciena 3903/3916 or Canoga Perkins. They were not searched individually because of the tool-call budget.

**Option A: smart SFPs**
- RAD MiNID 6790020000 ("Miniature Programmable Network Interface", 30-day warranty): asking US$175.49, reduced from $194.99, on eBay. A search snippet shows "10 available and 9 sold" and "USED. REMOVED FROM SERVICE IN WORKING ORDER": [eBay 114401834096](https://www.ebay.com/itm/114401834096). Part 6790020000 appears to be the standalone or sleeve variant, not necessarily the SFP form factor. This is not verified.
- New MiNID SFP: RAD's online store lists MINID/SFP/6DH/GE [6790340000], but the product page returned 404 and no price was captured: [RADProductsOnline listing](https://radproductsonline.com/index.php?main_page=product_info&products_id=7776). UK distributor Sol Distribution also lists MINID/SFP/6DH/GE, price not captured: [Sol Distribution](https://sol-distribution.co.uk/product/rad-minid-sfp-6dh-ge-2/).
- Accedian "Nano" on eBay: an ANN-1000-LX10-H-1310 (770-303) "Nano Duplex Network Module" is listed at US$22.99 asking: [eBay 325193256622](https://www.ebay.com/itm/325193256622). The other Accedian-branded SFPs in the same results ($18.50-$185) are ordinary optics (7SA/7SP/7SV, 770-301 compatibles), not test modules: [eBay 324121282138](https://www.ebay.com/itm/324121282138), [eBay 324121302660](https://www.ebay.com/itm/324121302660).
- OE Solutions / AimValley "Smart SFP" (smartsfp.com) Ethernet OAM product: no price found anywhere. The product brief has no price: [smartsfp.com product brief](https://www.smartsfp.com/documents/Ethernet_OAM_productbrief.pdf).
- VIAVI Fusion JMEP smart SFP exists as a reflector product. No price found: [VIAVI JMEP brochure](https://www.viavisolutions.com/en-us/literature/fusion-jmep-smart-sfp-brochures-en.pdf).

**Option C: TRex parts (asking prices, eBay/retail via search index, seen 2026-09-30)**
- Intel X520-DA2 (82599, 2x10G SFP+), used: roughly $15-30 asking, with outliers near $80: [eBay product 14012067794](https://www.ebay.com/p/14012067794), [eBay 226841952969](https://www.ebay.com/itm/226841952969), [eBay 181589911918](https://www.ebay.com/itm/181589911918).
- Mellanox ConnectX-4 Lx 2x25G (MCX4121A-ACUT/ACAT, Dell CX4121C), used or open-box: $40-70 asking ($69 ACUT, $51.71 ACAT open box, $39.99-44 Dell MRT0D): [eBay product 28032818923](https://www.ebay.com/p/28032818923), [eBay 356728270078](https://www.ebay.com/itm/356728270078). Refurbished Dell 20NJD at $49.99 from a retailer: [Express Computer Systems](https://expresscomputersystems.com/products/dell-mellanox-connectx-4-lx-dual-port-25gbe-sfp28-x8-pcie-adapter-lp-20njd).

### Inferences
- ESTIMATE: two used GE114Pro units plus shipping come to about $80-200 total. Two used ETX-203AX units come to about $100-250. Two MiNIDs would be about $350+ used and are only responders (see section 4).
- The earlier claim of "Adva GE114 used $50-200" is roughly right, and it may be high for the GE114Pro today. The claim of "RAD ETX used $150-400" looks high for the ETX-203AX, whose asking prices cluster around $40-100. The ETX-2i may be pricier, but that was not checked.
- The "smart reflector SFP $100-200" claim is plausible for used MiNIDs. No new-price source was found for any smart SFP, so the "$800-2,500 new" figure stays unverified. Vendors sell these through distributors on request-for-quote terms.
- ESTIMATE, TRex box: a used SFF desktop (not priced here) plus an X520-DA2 ($15-30) plus two SFP+ optics or DACs. That is likely under $200 total, but see the platform caveats in section 6.

### Gaps
- No verified SOLD prices, because the eBay sold-search page returned 403. Listing dates are unknown.
- No price data for ETX-2i, MetroNID/LT, Ciena 3903/3916 or Canoga Perkins.
- No new or distributor price for MiNID, Accedian Nano, OE Solutions smartSFP or VIAVI JMEP.
- No listing snippet stated whether a generator or test license, or a bandwidth license, was included.

## 2. Licensing: is the generator licensed? Transferable? Firmware gated?

### Takeaway
It differs by vendor. Adva's datasheet presents the RFC 2544 generator and analyzer (ECPA) as embedded, with no license mentioned. RAD ETX-203AX sells port bandwidth (100 vs 1000 Mbps) and flow counts as license options, and TWAMP is a paid license. Ciena 3903 needs an Advanced OAM license for "benchmark". MiNID's advanced features sit in packages ("Platinum"). No source was found on transferring or activating licenses without a vendor contract, or on whether firmware downloads are gated.

### Cited Findings
- Adva FSP 150-GE100Pro series (GE112Pro/GE114Pro) datasheet, verbatim: "Embedded RFC 2544 test generator and analyzer (ECPA)", "ITU-T Y.1564 service activation testing", "ITU-T Y.1731 single- and dual-ended frame loss", "TWAMP sender/reflectors". No license wording appears next to these features: [Adtran FSP 150-GE100Pro datasheet](https://www.adtran-networks.com/-/media/adva-main-site/resources/data-sheets/pdfs/fsp-150-ge-100-pro-series.pdf).
- A search summary says the GE114 series uses "feature key" licenses for some software features ("Software Licensable Feature Management"), and that ECPA looks embedded rather than licensed. The underlying source could not be confirmed: [search result: GE11xPro installation manual copy](https://data.over-blog-kiwi.com/6/96/15/16/20230822/ob_bfbf41_dataralipitus.pdf).
- RAD ETX-203AX datasheet, verbatim: "Bandwidth: 100/1000 Mbps per port, depending on license option" and "Number of flows (EVC.cos) / shapers / MEPs: 192/2/128 or 192/30/128, depending on license option". The same datasheet describes a "built-in RFC-2544 wirespeed traffic generator and analyzer" and "Layer-2 RFC-2544 traffic generator and analyzer". "RFC-2544 testing: Yes" is listed for both hardware variants: [RAD ETX-203AX datasheet (bestdatasource mirror)](https://bestdatasource.com/rad/data_sheets/etx-203ax.pdf).
- A search summary of the ETX-203AX datasheets says it has 8 built-in wire-speed RFC-2544 testers and 8 Y.1564 testers, and that TWAMP Light generator/responder is a software license option: [ETX-203AX-T datasheet](https://www.thekentongroup.com/wp-content/uploads/2023/02/etx-203ax-t_ds.pdf).
- RAD ETX-2/ETX-2i: TWAMP is a separately sold license, "ETX-2-SW-TWAMP", described as "SW license for TWAMP activation ETX-2/2i": [Tessco](https://www.tessco.com/product/sw-license-for-twamp-activation-etx-2-2i-221253), [Radioparts](https://www.radioparts.com/rad-etx-2-sw-twamp). The ETX-2i-10G datasheet describes "multiple RFC-2544, Y.1564, and L3 SAT testers": [RAD ETX-2i-10G datasheet](https://www.rad.com/wp-content/uploads/2025/01/etx-2i-10g_ds.pdf).
- Ciena 3903: the datasheet lists "RFC 2544 Generator and Reflector" and "RFC 2544 Performance Benchmarking Test Generation and Reflection up to 1GE", plus Y.1564. Required licenses are S70-0020-900 "SAOS Advanced Ethernet Perpetual Software License" and S70-0020-901 "SAOS Advanced OAM Perpetual Software License". A Ciena community answer says benchmark requires the Advanced-OAM license key installed and enabled: [Ciena 3903 datasheet](https://media.ciena.com/documents/3903_Platform_DS.pdf), [Westcon copy of 3903 SDS datasheet](https://www.westconcomstor.com/content/dam/wcgcom/US_EN/westcon/vendors/ciena/documentation/Packet-Products/packet/Ciena-3903-Service-Delivery-Switch-Data-Sheet.pdf), [Ciena community: Benchmark command availability](https://my.ciena.com/CienaPortal/s/question/0D50z00005JK3WuCAL/benchmark-command-availability). The Ciena community pages sit behind a login and were seen only as search snippets.
- RAD MiNID: microburst monitoring is offered "Within the Platinum package", so features are tiered by package/license: [MiNID 2.6 datasheet (Pulse Supply mirror)](https://www.pulsesupply.com/images/pdf/rad/minid_2_6_ds_ga.pdf).
- Accedian RFC-2544 test suite documentation (now hosted by Cisco as "Crosswork Assurance") contains no licensing information: [Cisco/Accedian docs](https://docs.crossworkassurance.cisco.com/docs/using-the-rfc-2544-test-suite-sc).

### Inferences
- A used ETX-203AX may arrive licensed for 100 Mbps per port. Buyers should confirm the license level before purchase, because eBay snippets never state it. The CLI shows the license level. That is inferred, not sourced.
- Ciena 3903/3916 is only useful if the used unit still carries the Advanced OAM license. Otherwise it is a switch.
- Adva GE114Pro is the least license-encumbered option on paper, but this rests only on the datasheet saying nothing about a license. It is not a positive statement.

### Gaps
- Whether Adva ECPA, RAD ETX Y.1564 or MiNID L3 SAT can be activated on a used unit without a vendor contract, and whether licenses are tied to serial numbers or transferable. No source found.
- Whether Adtran (Adva), RAD, Ciena or Cisco (Accedian) gate firmware downloads behind support contracts. No source found. The Ciena portal requires login, which suggests gating, but that is not confirmed.

## 3. Management: local CLI or web UI, or is a paid EMS required? Resetting used units

### Takeaway
The GE114Pro, ETX-203AX, MiNID and Accedian units can all be run locally, with no EMS required according to the sources. Adva has serial/USB CLI plus web GUI (older "eVision" web tool), RAD has RS-232/Telnet/SSH CLI and web for MiNID, and Accedian runs the RFC-2544 suite from the device web UI. The EMS products (Adva Ensemble, RADview, Skylight) are optional. Used Adva units can be factory-reset from the serial console.

### Cited Findings
- Adva GE100Pro management, verbatim: "Serial connector (RJ45) using CLI", "Local LAN port (RJ45) using CLI, SNMP and Web GUI interfaces", "USB (Type B Micro/Mini) using CLI", "Telnet, SSH (v1/v2), HTTP/HTTPS, SNMP", "NETCONF/YANG". The datasheet also lists "Ensemble management and control" as the EMS: [Adtran FSP 150-GE100Pro datasheet](https://www.adtran-networks.com/-/media/adva-main-site/resources/data-sheets/pdfs/fsp-150-ge-100-pro-series.pdf).
- Older Adva FSP 150 ECPA workflow in the "eVision Web Browser Management Tool": right-click the system and choose "Edit ECPA Streams". Running an untagged ECPA test means first creating "a remote loopback at the far end of the facility to be tested": [FSP 150CCf-825 manual (fccid.io)](https://fccid.io/ANATEL/00374-11-01746/Manual/94D53F27-C39A-42E9-9058-067C4323D029/PDF), [ADVA FSP 150CCf-825 manual (manualzz)](https://manualzz.com/doc/48656054/installation-and-operations-manual.book). This is the search summary of those manuals, not a direct fetch.
- An Adva FSP 150-GE11x Pro R8.5 QuickStart Guide and a GE11x r6.1 CLI Reference Guide circulate publicly on document-mirror sites: [manualzz QuickStart](https://manualzz.com/doc/48677308/fsp-150-ge11x-pro-r8.5-quickstart-guide), [pdfcoffee CLI reference](https://pdfcoffee.com/fsp-150cc-ge11x-r61-cli-reference-guide-2-pdf-free.html).
- Practitioner notes on reusing a used Adva FSP150 (page last modified 22/01/2026):
  - The older FSP 150C has web and serial access (9600 8N1). It is reset by interrupting boot on the serial console and running a factory-default command at the bootloader, after which vendor default credentials apply.
  - The FSP 150-GE102Pro is serial-only via USB mini at 57600 8N1. A "boot factorydefaults"-style command restored defaults, but the author could not confirm the resulting login.
  - The management Ethernet port lost connectivity after boot on the GE102Pro.
  - The platform runs Linux 3.14.
  - Source: [Rainsbrook wiki: adva-fsp150](https://www.rainsbrook.co.uk/wiki/doku.php?id=networking%3Aadva-fsp150). Passwords are deliberately omitted here.
- RAD MiNID, verbatim: "MiNID can be managed via the following interfaces: Web-based and menu-driven interface ... Command Line Interface (CLI) via secured Telnet (SSH), SNMPv2". The datasheet also states "RADview manages MiNID": [MiNID 2.6 datasheet](https://www.pulsesupply.com/images/pdf/rad/minid_2_6_ds_ga.pdf).
- RAD ETX-203AX: the datasheet text mentions a "terminal connected to the RS-232 port", Telnet, SNMP, SSH, RADIUS/TACACS+ and DHCP client, and lists "RADview-EMS" as the EMS: [ETX-203AX datasheet](https://bestdatasource.com/rad/data_sheets/etx-203ax.pdf).
- Accedian: the RFC-2544 test suite is configured and read from the device web UI under "SAT > RFC-2544 > Testsuite > Configuration" and "... > Reports": [Cisco/Accedian docs](https://docs.crossworkassurance.cisco.com/docs/using-the-rfc-2544-test-suite-sc).
- Adva FSP150 has a Centreon SNMP plugin, so counters can be polled with SNMP and no EMS: [Centreon Adva FSP150 SNMP](https://docs.centreon.com/pp/integrations/plugin-packs/procedures/network-adva-fsp150-snmp/).

### Inferences
- A paid EMS does not appear to be required for any of these to start a test and read the result locally. The main hidden cost is labor: learning each vendor's CLI and flow/EVC model, since the NID must be provisioned with a flow before a test stream can run.
- Buyers of used units should budget for a serial console cable. Adva uses RJ45 serial or USB-mini depending on model, and RAD uses RS-232.

### Gaps
- No source confirmed whether the GE114Pro's ECPA can be fully started and read from the local CLI in current firmware, as opposed to the web GUI. It is likely but not confirmed.
- The factory-reset procedure for RAD ETX-203AX/ETX-2i and Accedian units was not found.

## 4. Two-ended one-way mode (generator on one end, analyzer on the other)

### Takeaway
Only full NIDs generate. The smart SFPs examined (MiNID, OE Solutions/AimValley Smart SFP, VIAVI JMEP) are responders or loopbacks for RFC 2544/Y.1564. MiNID can generate only its own Layer-3 SAT. The documented workflows for Adva ECPA and Accedian's RFC-2544 suite loop traffic back from the far end, which gives round-trip loss, not per-direction loss. No source found documents a one-way generator-at-A, analyzer-at-B mode for any of these NIDs. The nearest documented one-way capability is Adva's "Y.1731 single- and dual-ended frame loss".

### Cited Findings
- MiNID, verbatim: "MiNID responds to RFC-2544 and Y.1564 service activation tests at wire speed. It can also initiate Layer-3 SAT with its own generator." Its compliance list: "RFC-2544 responder", "ITU-T Y.1564 responder", "L3 SAT generator". It also has "RFC-5357 TWAMP Light controller and responder": [MiNID 2.6 datasheet](https://www.pulsesupply.com/images/pdf/rad/minid_2_6_ds_ga.pdf).
- OE Solutions/AimValley Ethernet OAM Smart SFP, verbatim: "Service Activation Test Loopback for Y.1564 and RFC2544". Its test role is loopback, alongside Y.1731 frame-loss performance management: [smartsfp.com Ethernet OAM product brief](https://www.smartsfp.com/documents/Ethernet_OAM_productbrief.pdf).
- Accedian RFC-2544: "you must program the peer unit to have a manual loopback to match the test traffic, with a swapping action on the MAC addresses, IP addresses, and port numbers": [Cisco/Accedian docs](https://docs.crossworkassurance.cisco.com/docs/using-the-rfc-2544-test-suite-sc).
- Adva ECPA (older FSP 150 manuals): tests need a remote loopback at the far end: [FSP 150CCf-825 manual](https://fccid.io/ANATEL/00374-11-01746/Manual/94D53F27-C39A-42E9-9058-067C4323D029/PDF).
- The Adva GE100Pro supports "ITU-T Y.1731 single- and dual-ended frame loss" and "Synthetic frame loss and delay measurement": [Adtran GE100Pro datasheet](https://www.adtran-networks.com/-/media/adva-main-site/resources/data-sheets/pdfs/fsp-150-ge-100-pro-series.pdf).
- Ciena 3903 lists both "RFC 2544 Generator and Reflector" roles, up to 1GE: [Ciena 3903 datasheet](https://media.ciena.com/documents/3903_Platform_DS.pdf). A Ciena community thread is titled "RFC2544 Test - Static Reflector", which suggests reflector-based use: [Ciena community](https://my.ciena.com/CienaPortal/s/question/0D50z00005JK3ZpCAL/rfc2544-test-static-reflector).
- The ETX-203AX has a built-in "RFC-2544 wirespeed traffic generator and analyzer": [ETX-203AX datasheet](https://bestdatasource.com/rad/data_sheets/etx-203ax.pdf).

### Inferences
- A smart SFP pair cannot deliver two-ended, hardware-counted, line-rate one-way loss on its own. At best it is a far-end responder, which yields round-trip loss.
- A pair of identical NIDs, each with a generator and an analyzer, could in principle give per-direction results. Each end would generate toward the other, with the far analyzer counting in hardware and the results read at each end. Whether the analyzer accepts a stream from a peer generator (rather than its own looped stream) is not documented in the sources found. Test this on the bench before buying in quantity.
- Adva's dual-ended Y.1731 frame loss is one-way loss counted on service frames per direction. Run alongside an ECPA stream or other load, it may give per-direction hardware counts. This is an inference and was not validated.
- Round-trip loop tests cannot tell which direction dropped the frames. That is the same one-end limitation the current btest script documents.

### Gaps
- No source confirms a one-way (generator A to analyzer B) mode for Adva ECPA, RAD ETX Y.1564 or Accedian SAT. The terms "RFC 2544 generator + analyzer" and "responder" appear, but their one-way semantics are not documented in anything fetched.
- 64 B line-rate support was not confirmed for any specific NID. Datasheets say "wire speed" / "wirespeed" without naming frame sizes.

## 5. Practical reports from small ISPs/WISPs buying used NIDs

### Takeaway
No first-hand Reddit, WISPA or NANOG report was retrieved on buying used NIDs for turn-up testing. The NANOG archive mirror was down, and Reddit threads did not surface in search.

### Cited Findings
- NANOG threads on cheap RFC 2544/EtherSAM loopback appliances surfaced in search, but the mirror returned "Unable to connect to backend" for every post: [NANOG 194747](https://diswww.mit.edu/charon/nanog/194747), [NANOG 194761](https://diswww.mit.edu/charon/nanog/194761). The search engine's summary of those threads, which could not be verified, said:
  - Posters recommended Y.1564 over RFC 2544 for turn-up.
  - They named VeEX, Viavi and EXFO as makers of "low cost handhelds" that do RFC 2544.
  - One operator paired VeEX handhelds with a VeEX loopback device.
  - One poster asked about cost-effective multi-port rack RFC2544/EtherSAM loopback appliances as the far end for field testers.
- Community material on reusing used Adva gear exists (the Rainsbrook wiki on getting into and resetting used FSP150s), but it covers access, not testing: [Rainsbrook wiki](https://www.rainsbrook.co.uk/wiki/doku.php?id=networking%3Aadva-fsp150).

### Inferences
- The steady supply of $30-75 GE114Pro units, including one "Best Offer accepted" at $35.99, suggests carriers are decommissioning them in volume. Parts availability is not a blocker, while know-how probably is.

### Gaps
- No first-hand WISP or small-ISP account of what worked or what was painful. A targeted manual search of r/wisp, r/networking and the WISPA forums is still needed. The NANOG thread content should be re-fetched when the archive is back, or taken from mailman.nanog.org.

## 6. TRex DIY box (bench reference only)

### Takeaway
TRex runs on commodity x86 with an Intel 82599/X520, X710/XXV710 or Mellanox ConnectX-4 Lx/5. The NICs cost $15-70 used. Cisco's reference platform is a dual-socket server with 4 DRAM channels, and hardware per-stream loss/latency stats depend on the NIC. A cheap SFF desktop is plausible for 1-10G but is not a documented reference configuration.

### Cited Findings
- The TRex manual's low-end reference is a UCS C220 Mx: 2x E5-2620, 32 GB across 8 banks, "it's important to have 4 DRAM channels. Fewer channels will impose a performance issue." The OS is 64-bit CentOS/RHEL 7.6+. It quotes throughput of about 29.7 Gb per core under standard conditions: [TRex book (GitHub asciidoc)](https://github.com/cisco-system-traffic-generator/trex-core/blob/master/doc/trex_book.asciidoc).
- The supported NIC list includes Intel I350 (1G), 82599/X520 (10G), X710 (10G), XL710 (40G), XXV710 (25G), Mellanox ConnectX-4/Lx and ConnectX-5/6 (Mellanox requires OFED 5.2+), Napatech and Cisco VIC: [TRex manual](https://trex-tgn.cisco.com/trex/doc/trex_manual.html), [DeepWiki summary of trex-core system requirements](https://deepwiki.com/cisco-system-traffic-generator/trex-core/2.1-system-requirements).
- An aggregator states "2-3 cores and 4GB memory" as the minimum: [DeepWiki: System Requirements](https://deepwiki.com/cisco-system-traffic-generator/trex-core/2.1-system-requirements). This is not a primary source.
- Hardware per-stream stats: one summary says the X710 is "preferred support for per-stream stats in hardware" ([search summary of TRex manual](https://trex-tgn.cisco.com/trex/doc/trex_manual.html)). A fetch-tool summary of the TRex book instead marked X710 as "No" and 82599/XL710/XXV710/ConnectX-5 as "Yes" ([TRex book](https://github.com/cisco-system-traffic-generator/trex-core/blob/master/doc/trex_book.asciidoc)). These conflict. The TRex book's NIC table should be checked directly.
- Virtual NICs can bridge TRex to unsupported NICs, at a performance cost: [TRex manual](https://trex-tgn.cisco.com/trex/doc/trex_manual.html).
- Parts: X520-DA2 about $15-30 used and ConnectX-4 Lx about $40-70 used (section 1). The 2026 self-hosting guide covering TRex, MoonGen and Pktgen: [pistack.xyz guide (2026-05-04)](https://www.pistack.xyz/posts/2026-05-04-self-hosted-network-traffic-generation-trex-moongen-pktgen-guide/).

### Inferences
- ESTIMATE of the parts list:
  - A used SFF office PC with a full-height or low-profile PCIe x8/x16 slot, 4+ cores and 8-16 GB RAM (price not sourced here).
  - An X520-DA2 ($15-30) or ConnectX-4 Lx ($40-70).
  - Two SFP+ DACs or optics.
  - A low-profile bracket for SFF cases.
- A 1G test of the MikroTik and NID bench is far below the documented per-core capacity, so SFF hardware is likely sufficient for 1G at 64 B (1.488 Mpps). 10G at 64 B (14.88 Mpps per direction) on one desktop with dual-channel memory is not assured by the docs.
- TRex counts loss at its own receive port. With both ports on one box it measures one-way loss per direction through the device under test in hardware or DPDK counters. It is a bench reference, not a field tool for two distant ends.

### Gaps
- No sourced 2026 price for a suitable used SFF PC.
- The authoritative current per-NIC hardware flow-stats table is unconfirmed because of the conflict above.
- Whether current TRex releases support recent Ubuntu or Rocky rather than CentOS 7 was not confirmed from a primary source.
