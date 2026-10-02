# Smart SFPs (SFP NIDs / test-engine SFPs) in MikroTik RouterOS SFP/SFP+ cages: compatibility and gotchas

Scope note: researched 2026-09-30. "Documented" = vendor documentation. "Anecdote" = forum post. "Inference" = my reasoning and is listed only under Inferences. Several vendor datasheets (RAD MiNID PDF, Accedian Nano PDF, Skylight SFP-compute PDF, VIAVI Fusion JMEP brochure) could not be text-extracted: the fetch tool returned binary and the PDFs use encoded fonts. Facts from them come only from HTML reseller mirrors or search snippets, and are marked as such.

## 1. Power: what MikroTik SFP/SFP+ cages supply, and high-power modules

### Takeaway
MikroTik does not publish a per-cage power figure for any of the models in question. But MikroTik documents that "all the current MikroTik devices with an SFP+ cage support the S+RJ10", which averages 2.7 W, with per-device limits on how many can run at once. So the SFP+ cages on the RB4011, RB5009, CCR2004, CCR2116 and CRS3xx carry at least about 2.5-2.7 W each, subject to those block limits. 1G smart SFPs are specified at about 1.2-1.75 W, well inside that. The 1G-only SFP cage on the hEX S has no documented power figure, and it is the least-characterised host.

### Cited Findings
- MikroTik S+RJ10 (10GBASE-T SFP+): "The average power consumption of the transceiver is 2.7 W (10GBASE-T, 30 m link)"; "the transceiver itself can heat up to 90 C"; "All the current MikroTik devices with an SFP+ cage support the S+RJ10 module". MikroTik recommends leaving an optical module or an empty cage between S+RJ10s, and "one S+RJ10 transceiver per 4xSFP+ cage block". — [MikroTik: S+RJ10 general guidance](https://help.mikrotik.com/docs/spaces/ROS/pages/240156916/S+RJ10+general+guidance)
- Search-result summaries of MikroTik's product listing give the S+RJ10 as "2.4W max" at 10GBASE-T over 30 m. This conflicts with the 2.7 W *average* above. — [getic.com S+RJ10 listing](https://www.getic.com/product/sfp-s-plus-rj10-module); versus [MikroTik S+RJ10 guidance](https://help.mikrotik.com/docs/spaces/ROS/pages/240156916/S+RJ10+general+guidance)
- Per-device S+RJ10 limits, which are the only power-budget statements MikroTik publishes:
  - CRS305-1G-4S+: "supports up to 2 simultaneous S+RJ10 modules".
  - CRS309-1G-8S+: "supports up to 4 simultaneous S+RJ10 modules", and "We do not recommend using S+RJ10 in passive cooling devices without additional cooling".
  - CRS317-1G-16S+: "power controller supports up to 10 simultaneous S+RJ10 modules".
  - CCR2004-1G-12S+2XS: "supports up to 6 simultaneous S+RJ10 modules".
  - Source: [MikroTik wired interface compatibility](https://help.mikrotik.com/docs/spaces/ROS/pages/220233794/MikroTik+wired+interface+compatibility)
- The same compatibility table, as summarised by the fetch tool, marks S+RJ10 "+" (supported) for the RB4011, RB5009, CCR2004-16G-2S+, CCR2116-12G-4S+ and CRS326. It marks the S+RJ10 "-" (not supported) for the hEX S and the hEX S (2025). The hEX S (2025) SFP "supports up to 2.5G rate, manual speed setting required to work". — [MikroTik wired interface compatibility](https://help.mikrotik.com/docs/spaces/ROS/pages/220233794/MikroTik+wired+interface+compatibility). Caveat: this was read through an AI page summariser. It also reported the RB4011 as supporting "all" 1G modules, which contradicts the RB4011 manual below. Verify the table rows by eye before relying on them.
- RB4011 manual: "SFP+ port accepts SFP and SFP+ modules." "The RB4011 does not support passive DAC modules, 1GB copper SFP modules and SFP GPON modules." "The power consumption under maximum load can reach 33 W." No per-cage power figure is given. — [MikroTik RB4011iGS+RM user manual](https://help.mikrotik.com/docs/pages/viewpage.action?pageId=33849352)
- CRS305-1G-4S+IN: 10 W at maximum load with fiber modules, and up to 18 W with all-RJ10 copper modules. That delta implies about 2 W per module in excess of fiber. — [search summary of the MikroTik CRS305 manual](https://help.mikrotik.com/docs/spaces/UM/pages/17498183/CRS305-1G-4S+IN) (the page itself was not fetched)
- Anecdote (2022): asked for the RB4011 SFP power budget for a 3.3 V/700 mA (2.3 W) VDSL2 SFP, a forum user said that is fine because the 2.4 W S+RJ10 is officially supported, but "the RB4011 in general is a bit picky with SFP support. Especially for 'exotic' ones … It might work without problems, it might work with issues or not at all." No MikroTik answer was posted. — [forum t/155705](https://forum.mikrotik.com/t/155705)
- Anecdote (2014, pre-S+RJ10): "an SFP+ port can deliver about 2 watts" and "Common SFP+ ports may support as high as 1.5W while 10GBase-T consumes as more as 4~5W". These are generic claims, not MikroTik-specific, and are superseded by MikroTik's S+RJ10 support. — [forum t/76941](https://forum.mikrotik.com/t/76941)
- Anecdote (June-July 2026): an ONU-type SFP (Tsuhan THMPRS-3511-10A) in a hEX S (2025) on ROS 7.23 works when hot-plugged or after a soft reboot, but boot-loops the router on a cold power-up. `/interface ethernet disable sfp1` does not help. The user measured under 0.25 W … at 24 V (current draw never reached their 1 A limiter) and concluded it was not a supply issue. Unresolved; referred to MikroTik support. — [forum t/271297](https://forum.mikrotik.com/t/271297)
- Anecdote: 20+ FS GPON-ONU-34-20BI ONU sticks in MikroTik hosts "bricked on the first hot summer day". This concerns heat in processor-bearing SFPs. — [forum t/183022](https://forum.mikrotik.com/t/183022) (search blurb only; thread not read in full)
- RouterOS has `sfp-shutdown-temperature`: "The temperature in Celsius at which the interface will be temporarily turned off due to too high detected SFP module temperature" (default 95 °C for SFP/SFP+/SFP28). — [MikroTik: Ethernet](https://help.mikrotik.com/docs/spaces/ROS/pages/8323191/Ethernet)
- Smart-SFP power figures:
  - RAD MiNID: "Max 1.4W (not including SFP)". It is a sleeve that hosts a standard optical SFP. — [bestdatasource MiNID page (RAD reseller mirror)](https://bestdatasource.com/rad2/minid.php). A search snippet of the RAD datasheet gives 1.2 W max for the sleeve (1.68 W including a standard 10 km SFP) and 3.5 W for the standalone version. — [RAD MiNID datasheet (itfor.co.jp mirror)](https://www.itfor.co.jp/it-infra/telecom-carrier/rad/RAD_PDF/MiNID.pdf) (snippet only; the two mirrors disagree slightly)
  - Accedian NanoNID: 1.5 W typical, 1.75 W max (industrial case). — search snippet of [Accedian Nano datasheet](https://accedian.com/wp-content/uploads/2016/01/Accedian-Nano-Datasheet-2-pages-2016-1Q.pdf) (now redirects to Cisco; not independently read)
  - Cisco Assurance SFP (ex-Accedian): 1.75 W (S1G-SX/LH), 2.6-3.0 W (S10G models), 3.0 W (copper variant). — [Cisco Assurance SFP data sheet](https://www.cisco.com/c/en/us/products/collateral/interfaces-modules/transceiver-modules/accedian-sfp-compute-sensor-ds.html)
  - A module-maker blog says smart SFPs typically draw 1.5-3.5 W and that host ports "must support ≥3W optics under full load". This is a vendor marketing blog, not a standard. — [LINK-PP: Smart SFP with OAM/IP](https://www.link-pp.com/resources/technical-specs/smart-sfp-oam-ip/)

### Inferences
- A 1G smart SFP (MiNID about 1.2-1.7 W, NanoNID 1.75 W max, Cisco Assurance 1G 1.75 W) is within what every listed SFP+ cage already powers for the 2.7 W S+RJ10. Raw power is unlikely to be the blocker on the RB4011, RB5009, CCR2004, CCR2116 or CRS3xx.
- 10G smart SFP+ modules (Cisco Assurance S10G at 2.6-3.0 W) are at or slightly above the S+RJ10 envelope. Treat them like an S+RJ10: one per cage block, with an empty or optical neighbour. They are marginal on fanless CRS305/CRS309.
- The hEX S (RB760iGS) and hEX S (2025) are the riskiest hosts. The SFP cage power is undocumented, MikroTik does not list the S+RJ10 for them, and there is a live 2026 cold-boot boot-loop report with an ONU-type SFP on the 2025 model. Do not choose the hEX S as the host for a pilot.
- Heat matters more than watts for FPGA/CPU SFPs in fanless or dense MikroTik chassis. The GPON-stick failures and S+RJ10 spacing guidance point the same way.

### Gaps
- No MikroTik document states a per-cage power limit (in W or mA) for any model. Searches tried: "MikroTik SFP port maximum power consumption module watts"; forum searches "sfp power budget" (HTTP 429), "sfp current limit", "SFP power consumption", "sfp 2W", "sfp 1.5W", "high power sfp". The only direct question (t/155705) got a user answer, not MikroTik's.
- The SFF-8472 "power level" declaration: I found nothing on whether RouterOS reads or enforces SFF-8472 power level 2/3 (the host enabling a module's high-power mode). No MikroTik documentation mentions it.
- I could not read the MiNID, Nano, Skylight or VIAVI JMEP PDFs to confirm power and host-side electrical interface first-hand.

## 2. Host interaction: management traffic, and what RouterOS needs

### Takeaway
Smart SFPs are inline and manage themselves in-band, usually on a management VLAN plus their own MAC/IP (RAD: either side; Accedian: VLAN 4001 with Ethertype 0x88fc discovery). On RouterOS this looks like the existing, widely used GPON-stick practice: a VLAN interface on the SFP port with an IP in the module's subnet (plus NAT if managed from the LAN). One documented RouterOS trap applies: with no line-side signal (RX LOS), RouterOS shows the port as no-link and you cannot reach the module unless `sfp-ignore-rx-los=yes` is set. That setting was broken on the hEX S until a 2026 fix.

### Cited Findings
- RAD MiNID management:
  - "VLAN-based inband management, via the hosted SFP or the MSA edge connector" (that is, from the line side or the host side), giving "a separate management channel from the host device".
  - "Out-of-band management and software configuration can also be done from any Ethernet port in the host device."
  - Access by web, CLI/Telnet, and "Zero Touch Provisioning" via "standard DHCP client functionality".
  - Source: [bestdatasource MiNID page (RAD mirror)](https://bestdatasource.com/rad2/minid.php)
- A search snippet of the RAD datasheet adds more on MiNID management. It "is equipped with two MAC addresses (one for management and one for services)". It can be managed in "Layer 2 untagged environment as well as VLAN and double VLAN tagged environments". It "can be managed without a dedicated IP address, by loaning the IP address of the hosting device". — [RAD MiNID datasheet (rlcomunicaciones mirror)](https://www.rlcomunicaciones.com/docs/rad/fo/MiNID.pdf) (snippet only)
- Accedian/Cisco "Plug and Go":
  - Discovery uses "multicast frames with the Accedian Ethertype (0x88fc)". A beaconer unit transmits, and remote units answer with advertisement frames.
  - "remote units are managed in-band (VLAN 4001)".
  - The factory default management IP is "192.168.1.254".
  - "no configuration is required for remote units when DHCP, Auto or Auto Static mode" is selected.
  - Source: [Cisco Crosswork Assurance: Plug and Go application note](https://docs.crossworkassurance.cisco.com/docs/plug-and-go-application-note-140)
- Cisco Assurance SFP: DHCP enabled for discovery, and "LLDP is enabled by default". Management is via "Cisco Crosswork Assurance" and "Cisco Assurance Module Dock or with network commands", and the module is "Fully integrated with Cisco Crosswork Assurance". — [Cisco Assurance SFP data sheet](https://www.cisco.com/c/en/us/products/collateral/interfaces-modules/transceiver-modules/accedian-sfp-compute-sensor-ds.html)
- RouterOS analogue, GPON ONU sticks with their own IP. Anecdotes:
  - The standard recipe to reach the stick's web UI is to put an IP on the SFP interface in the stick's subnet and masquerade, or add the SFP interface to the WAN interface list under defconf. — [forum t/178110](https://forum.mikrotik.com/t/178110) (RB5009, ROS 7.15.3)
  - A Zyxel PMG3000 stick on sfp-sfpplus1 managed at 10.10.1.1. — [forum t/268031](https://forum.mikrotik.com/t/268031) (blurb)
- RX LOS trap:
  - With no fiber attached, a hEX S showed `status: no-link` and `sfp-rx-loss: yes` for a Zyxel GPON SFP, and "RouterOS doesn't allow accessing the SFP's web interface".
  - "RouterOS 7.15 introduces the new setting sfp-ignore-rx-los".
  - On the hEX S the setting did not stick. MikroTik support confirmed the bug (ticket SUP-162428, August 2024), and it was still broken in 7.20beta4.
  - Source: [forum t/175620](https://forum.mikrotik.com/t/175620)
- Changelog blurbs show the hEX S fix: "sfp - fixed sfp-ignore-rx-loss parameter for RB760iGS" appears in the 7.20.8 long-term and 7.21.2 stable release threads, and "…for RB960PGS" in 7.22rc. — [forum t/268265 (7.20.8)](https://forum.mikrotik.com/t/268265); [t/268156 (7.21.2)](https://forum.mikrotik.com/t/268156); [t/268400 (7.22rc)](https://forum.mikrotik.com/t/268400) (search blurbs)
- A 2024 forum answer recommends `sfp-ignore-rx-los=yes` to let auto-negotiation proceed with a 10Gtek ASF-GE-T copper SFP on ROS after 7.12. — [forum t/174766](https://forum.mikrotik.com/t/174766) (blurb)
- Anecdote (SwOS, not RouterOS): a CSS610 dropped DHCP offers arriving through a Raisecom GPON ONU SFP+ even with the port trusted for DHCP snooping. — [forum t/171350](https://forum.mikrotik.com/t/171350) (blurb)
- RB4011's SFP+ is wired to the Annapurna AL21400 SoC, not a switch chip. This anecdote cites MikroTik's block diagram. — [forum t/131675 #4](https://forum.mikrotik.com/t/131675)

### Inferences
- For a RAD-type module, the minimum RouterOS configuration is:
  - `/interface vlan add interface=sfp-sfpplus1 vlan-id=<mgmt VLAN>`
  - an IP address on that VLAN interface in the module's subnet
  - optionally NAT or a route if a NOC host must reach the module
  - `sfp-ignore-rx-los=yes`, so the module stays reachable when the far end is dark
  None of this changes the data path, but it is a router configuration change. The repo's rule is that the test script must not change configuration, so this belongs in a documented one-time install step, not in the script.
- Accedian/Cisco modules assume Accedian discovery (Ethertype 0x88fc beacons, VLAN 4001) and an Accedian/Cisco controller, the beaconer or Skylight/Crosswork. RouterOS has no such controller. You would need a VLAN 4001 interface and static or local IP mode, plus Accedian-side tooling to run sessions. This is a licensing and ecosystem issue, not an electrical one.
- The switch chip (RB5009, CCR2004-1G-12S+2XS, CRS3xx) will not drop frames just because they come from the module's own MAC. Frames tagged with a management VLAN on a bridged SFP port are subject to bridge VLAN filtering if it is enabled, so the management VLAN must be allowed or the port left unbridged. I found no report of hardware offload interfering with smart-SFP OAM frames. Slow-protocol and OAM Ethertypes are normally switched or forwarded by the MikroTik bridge, but this is unverified.
- Because the modules sit between the MikroTik MAC and the carrier, a module reflector or loopback loops the carrier's traffic, not the router's. The per-direction counts come from the modules, not RouterOS. That is exactly what makes the RouterOS host's own shortcomings (btest CPU, software counters) irrelevant to the measurement.

### Gaps
- No MikroTik-specific report of configuring any smart SFP's management VLAN. Everything above is by analogy with GPON sticks.
- No vendor document I could read states the smart SFP's host-side electrical mode, 1000BASE-X or SGMII. This matters for the RB4011; see section 5.

## 3. I2C/EEPROM, DDM, and vendor lock

### Takeaway
MikroTik documents no vendor lock: any MSA-compliant module "should be compatible". RouterOS reads DDM (vendor name, voltage, bias, TX/RX power, temperature, EEPROM hex) but silently shows nothing if the EEPROM checksum is bad. Smart SFPs of this class manage themselves over the Ethernet data path, not host I2C, so RouterOS's lack of host-side smart-SFP awareness should not matter. That last point is inferred from vendor descriptions, not tested.

### Cited Findings
- "MikroTik devices and SFP, SFP+, SFP28, QSFP+, QSFP28 and QSFP56-DD modules do not have any restrictions for other vendor equipment"; "as long as the other vendor modules and devices comply with transceiver multi-source agreement (MSA) they should be compatible with MikroTik". — [MikroTik wired interface compatibility](https://help.mikrotik.com/docs/spaces/ROS/pages/220233794/MikroTik+wired+interface+compatibility)
- RouterOS monitor fields: sfp-vendor-name, sfp-supply-voltage, sfp-tx-bias-current, sfp-tx-power, sfp-rx-power, sfp-temperature, and eeprom (hex dump). "Modules with bad EEPROM checksum do not output any EEPROM information to the ethernet monitor, which will also mean that the sfp DDM monitor does not work for such modules." — [MikroTik: Ethernet](https://help.mikrotik.com/docs/spaces/ROS/pages/8323191/Ethernet)
- RouterOS SFP knobs: `sfp-rate-select` (high/low, default high), `sfp-shutdown-temperature`, `sfp-ignore-rx-los` (from 7.15). — [MikroTik: Ethernet](https://help.mikrotik.com/docs/spaces/ROS/pages/8323191/Ethernet); [forum t/175620](https://forum.mikrotik.com/t/175620)
- MiNID "transparently relays Digital Diagnostics Monitoring (DDM) information from DDM-enabled optical SFPs to the hosting device". — [bestdatasource MiNID page](https://bestdatasource.com/rad2/minid.php)
- Cisco Assurance SFP: "Digital Optical Monitoring (DOM) functions according to industry standard SFF-8472". It "may work directly as unsupported transceivers" on Cisco platforms not yet certified. — [Cisco Assurance SFP data sheet](https://www.cisco.com/c/en/us/products/collateral/interfaces-modules/transceiver-modules/accedian-sfp-compute-sensor-ds.html)
- A GPON stick in a hEX S populated the full RouterOS monitor: vendor ZYXEL, sfp-type, connector SC, link length 20 km. The anecdote shows RouterOS reads EEPROMs from processor-bearing SFPs. — [forum t/175620](https://forum.mikrotik.com/t/175620)
- Anecdote: an RB4011 showed "all the normal information in the SFP screen and a link OK" for a module whose data path was not working. The reply: "What you see in SFP status is likely read out of DDC port and that's out-of-band … it's just RB4011 that can't communicate with local SFP module." — [forum t/139158 #8](https://forum.mikrotik.com/t/139158)

### Inferences
- RouterOS should read a smart SFP's A0h/A2h pages like any module. DDM passthrough (MiNID) should appear in `/interface ethernet monitor`. A good DDM readout does not prove the data path works (t/139158).
- The management approaches documented for the smart SFPs above (in-band VLAN, DHCP, Ethertype discovery) do not rely on the host driving vendor-specific I2C pages. Nothing suggests these modules need a host feature RouterOS lacks. This is not verified against any vendor host-requirements list, because none was found.

### Gaps
- No vendor-published "host requirements" list for MiNID, NanoNID, Cisco Assurance SFP, OE Solutions/AimValley smart SFPs or VIAVI JMEP was readable. The HTML pages say only "Plugs easily into SFP ports of switches and routers" (RAD), "leverage standard SFP/SFP+ Ethernet ports on routers, switches and optical transport gear" and "draw their power from existing ports" (OE/AimValley, [smartsfp.com](https://www.smartsfp.com/about-smart-sfp/)). The Cisco Assurance datasheet defers to the Cisco TMG compatibility matrix.

## 4. Reports of smart SFPs in MikroTik, Ubiquiti or other white-box hosts

### Takeaway
Negative result. I found no report, from any source searched, of RAD MiNID, Accedian NanoNID/Cisco Assurance SFP, OE Solutions/AimValley smart SFP or VIAVI JMEP being used in a MikroTik, Ubiquiti or other white-box host. The only MikroTik forum mentions are 2011/2017 feature requests and the one suggestion already known (t/6185). The nearest real evidence is years of GPON-ONU-stick use, which are also processor-bearing, self-managed SFPs. It shows such modules generally work in MikroTik cages, with model-specific exceptions (RB4011) and quirks (RX LOS, speed forcing, cold boot).

### Cited Findings
- t/6185 (thread started 2006) includes the post "A solution to add EtherSam (Y.1564), RFC2544 and OAM management capability would be to use smart SFPs on Mikrotik SFP enabled routers" with an AimValley Ethernet-OAM smart SFP link. It is a suggestion, not a report. Earlier posts in the same thread (2009-2011) ask for RFC2544/Y.1564 on RouterOS and say "for precise QOS measurements, hardware testers are the only way to go". — [forum t/6185](https://forum.mikrotik.com/t/6185)
- MikroTik forum feature requests: "Request: Y.1731 Performance Monitoring" (2014, [t/83838](https://forum.mikrotik.com/t/83838)), "RFC2544 reflector deamon" (2010, [t/40999](https://forum.mikrotik.com/t/40999)), and 802.3ah/802.1ag/Y.1731 (2010, [t/40250](https://forum.mikrotik.com/t/40250)). These show RouterOS has no native Y.1731/TWAMP/RFC2544 reflector, which is why an SFP-borne one is attractive. The TWAMP search hit only 2026 wish-list posts in release threads.
- "No Mikrotiks support dumb GPON SFPs, it is possible to use smart GPON SFPs which contain a processor … however the SFP interfaces on some Mikrotiks are fussy as to what they will support." — [forum t/153195 #2](https://forum.mikrotik.com/t/153195) (tdw, 2021)
- A forum post (tdw, 2019) explains that MikroTik cages "should support anything which presents a 1.25Gb 8b/10b 1000BaseX, 1.25Gb 8b/10b SGMII or 10.3125Gb 64b/66b PCS". — [forum t/131675 #13](https://forum.mikrotik.com/t/131675)
- Anecdote: a 2012 forum thread lists a RouterOS btest server as "not compatible with RFC2544 hardware testers". — [t/40999](https://forum.mikrotik.com/t/40999) (blurb)

### Searches tried (all negative for smart-SFP-in-MikroTik reports)
- MikroTik forum search API: "smart sfp" (hits are GPON sticks plus t/6185), "MiNID" (only miniDLNA hits), "Accedian" (1 hit, a blog link in the public btest-server thread t/94863), "smartSFP" (1 hit, not relevant), "ETX-1p" (0 posts), "intelligent sfp" (GPON), "sfp NID" (carrier NIDs on copper), "sfp loopback" and "loopback SFP module" (none relevant), "Y.1731", "TWAMP", "RFC2544 hardware", "RAD sfp". Some queries returned HTTP 429 and were retried with pacing.
- Web: "reddit smart SFP OR MiNID OR Accedian nano mikrotik OR ubiquiti OR white box" (no relevant hits; old NANOG archive pages were unreachable); "Accedian Nano SFP NID user guide host port requirements SGMII OR 1000Base-X"; "smart SFP host auto-negotiation SGMII interoperability"; "OE Solutions smartSFP host requirements".

### Inferences
- The owner would be doing something nobody has documented publicly on MikroTik. A two-module bench trial on the existing RB4011 pair is the only way to establish it. Cold-boot, RX-LOS/management reachability, forced-1G and heat checks are the obvious acceptance items.

### Gaps
- Reddit was not searched directly (web search only). I did not search the WISPA list or the Ubiquiti community forum directly. I did not look for vendor interop lists (RAD/Cisco TMG) that might list non-carrier hosts.

## 5. Speed and negotiation: 1G smart SFPs in dual-rate SFP+ cages, and copper-side modules

### Takeaway
1G optical modules work in MikroTik SFP+ cages, but MikroTik documents that they need auto-negotiation off and the speed forced to 1G full duplex. The RB4011 is documented as not supporting 1G copper SFPs, GPON SFPs or passive DAC. A smart SFP that presents SGMII to the host (typical of RJ45/copper-side variants) is therefore a real risk on the RB4011. A 1000BASE-X optical smart SFP is the safer choice. The hEX S (2025) SFP is 2.5G-capable but needs manual speed.

### Cited Findings
- For 1G optical in SFP+ ports: configure "auto-negotiation disabled", speed 1G, and "full-duplex". For 10G/25G optics, "Additional SFP Rate Select setting must be configured to avoid data corruption" (`sfp-rate-select=low`). The S+RJ10 must be used "only in 10G SFP+ ports with auto-negotiation enabled; forced link speeds and configurable link speed advertisements are not supported". — [MikroTik wired interface compatibility](https://help.mikrotik.com/docs/spaces/ROS/pages/220233794/MikroTik+wired+interface+compatibility)
- SFP auto-negotiation on RouterOS "does not involve the exchange of advertised capabilities". Where it fails, RouterOS says "module auto-initialization failed, try forced-mode". — [MikroTik: Ethernet](https://help.mikrotik.com/docs/spaces/ROS/pages/8323191/Ethernet)
- RB4011: "does not support passive DAC modules, 1GB copper SFP modules and SFP GPON modules". — [MikroTik RB4011iGS+RM manual](https://help.mikrotik.com/docs/pages/viewpage.action?pageId=33849352)
- Anecdote: a Huawei MA5671A GPON stick works in an RB2011 SFP (Atheros AR8327 switch) but not in the RB4011 SFP+ (Annapurna SoC). — [forum t/131675](https://forum.mikrotik.com/t/131675)
- Anecdote: an FS GE-BX 1G module worked in a hEX S but not an RB4011 (DDM and link OK, no traffic) until the right ROS version and a forced 1G speed. "The latest beta does not enforce 1GB if you set it manually". — [forum t/139158](https://forum.mikrotik.com/t/139158) (2020, ROS 6.46/6.47beta)
- Anecdote: "Some SFPs only works with auto-nego disabled and 1Gbps." — [forum t/152905](https://forum.mikrotik.com/t/152905) (blurb)
- hEX S (2025): "device SFP supports up to 2.5G rate, manual speed setting required to work", and S+RJ10 is not supported. A user reports the MikroTik S+RJ10 would not link even at forced 2.5G. — [MikroTik wired interface compatibility](https://help.mikrotik.com/docs/spaces/ROS/pages/220233794/MikroTik+wired+interface+compatibility); [forum t/265320](https://forum.mikrotik.com/t/265320)
- A 2020 feature request, still unanswered by MikroTik in the thread, asks for HSGMII (2.5G) on SFP cages, including CCR2004. — [forum t/142864](https://forum.mikrotik.com/t/142864)
- Smart-SFP line and host sides:
  - MiNID comes in FE and GE variants, as a sleeve hosting a standard optical SFP, or with UTP (RJ-45) and combo ports. — [bestdatasource MiNID page](https://bestdatasource.com/rad2/minid.php)
  - NanoNID is compliant with "SFP form factor and RJ45 10/100/1000 Ethernet standards", and there is a separate 10G "ANT". — [Fastech NanoNID/ANT](https://www.fastech-india.com/nanonid-ant/); [BusinessWire launch 2012](https://www.businesswire.com/news/home/20121018005941/en/Accedian-Launches-NanoNID%E2%84%A2--World%E2%80%99s-Compact-Service-Assurance)
  - The Cisco Smart SFP (TDM-over-packet family) sends packets "via electrical Gigabit Ethernet interface towards and from the hosting system". — [Cisco Smart SFP data sheet](https://www.cisco.com/c/en/us/products/collateral/interfaces-modules/transceiver-modules/smart-sfp-ds.html)

### Inferences
- On the RB4011 bench, use a 1000BASE-X *optical* smart SFP, or a MiNID sleeve hosting a standard 1G optic, with auto-negotiation off and speed 1G-baseX forced. Avoid copper/RJ45-line smart SFPs on the RB4011, because they almost certainly present SGMII, the same class as the unsupported "1GB copper SFP modules".
- For a 10G circuit, a 10G smart SFP+ (Cisco Assurance S10G or Accedian ANT) would need `sfp-rate-select=low` per MikroTik guidance if it is optical. It sits at the S+RJ10 power envelope (section 1).
- Forcing speed on the MikroTik port is a router configuration change. Record it in the runbook/install step, not the script.

### Gaps
- No readable vendor statement of each smart SFP's host-side mode (1000BASE-X vs SGMII, and whether the host side auto-negotiates). This is the single most important unknown for the RB4011, and it is answerable only from the vendor install guides or a bench test.
- No data on 100M (FE) smart SFPs in MikroTik SFP+ cages. The MiNID FE variants would likely not link in 1G/10G-only SFP+ cages, but I found no source.

## 6. Test capability relevant to the goal (hardware-counted per-direction loss)

### Takeaway
The candidate modules do offer hardware, per-direction loss measurement: Y.1731 LM/SLM, TWAMP, and line-rate reflection/generation. Several depend on a vendor controller or licence to originate tests. A pair of modules on a MikroTik host would need one of them, or an external test set, to act as the initiator.

### Cited Findings
- MiNID:
  - "ITU-T Y.1731 for loss, delay, and delay variation measurements".
  - "IEEE-802.1ag (CFM) for continuity check, loopback, and link trace".
  - "MiNID responds to RFC-2544 service validation tests", that is, it acts as a reflector.
  - "in-service loopbacks, performance monitoring".
  - Source: [bestdatasource MiNID page](https://bestdatasource.com/rad2/minid.php)
- NanoNID:
  - "Full line-rate loopback support for popular third-party test sets".
  - "RFC-2544 (Generation and Reflection) & Y.1564 (Reflection and Generation)".
  - "TWAMP Lite (RFC-5357)–Reflection and NFV-Based Initiation".
  - Source: [Fastech NanoNID/ANT](https://www.fastech-india.com/nanonid-ant/)
- Cisco Assurance SFP:
  - "TWAMP reflector @ line rate".
  - "RFC2544 generation and reflection" and "Y.1564 generation and reflection".
  - ETH-DM, ETH-LB and SLM.
  - It is "Fully integrated with Cisco Crosswork Assurance".
  - Source: [Cisco Assurance SFP data sheet](https://www.cisco.com/c/en/us/products/collateral/interfaces-modules/transceiver-modules/accedian-sfp-compute-sensor-ds.html)
- OE Solutions/AimValley IP OAM smart SFP: L2/L3/L4 activation testing to RFC2544/Y.1564. — [OE Solutions and AimValley IP OAM Smart SFP](https://oesolutions.com/blog/oe-solutions-and-aimvalley-to-introduce-ip-oam-smart-sfp/) (search snippet); [AimValley Smart SFP](https://www.aimvalley.com/products/smart-sfp/)

### Inferences
- A reflector-only arrangement (MiNID responding to RFC 2544) gives round-trip loss, not per-direction. Per-direction needs Y.1731 LM/SLM between two MEPs, a one-way-capable generator/analyser pair, or TWAMP with sequence numbers. Check each module's licensing for the initiator role before buying. Cisco Assurance SFPs appear to expect Crosswork, and Accedian units expect a beaconer/Skylight.

### Gaps
- Licensing and controller requirements to *originate* Y.1731 SLM or Y.1564 from a standalone module (no Crosswork/Skylight, no RAD RADview) were not found.
