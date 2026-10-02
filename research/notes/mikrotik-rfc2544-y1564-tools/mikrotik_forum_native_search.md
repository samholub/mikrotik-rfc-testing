# MikroTik forum, native Discourse search: addendum

Scope: 25 threads surfaced by forum.mikrotik.com's own search and not read by the
original research. Every post was fetched in full as JSON (`/t/<id>.json`, plus
`/t/<id>/posts.json?post_ids[]=` for threads over 20 posts) on 2026-09-30 and read
verbatim, not through a summarizer. Quotes are exact apart from whitespace.

"Staff" below uses the Discourse metadata. `group=MIkroTik-Staff` marks MikroTik
employees (only normis and uldis in this set). `staff=True` without that group means
a forum moderator, who may or may not work for MikroTik. janisk is listed as MikroTik
staff in the earlier notes (t=61922) but carries no flag in the migrated forum.

## Changes to the report's conclusions

None of the four conclusions is reversed. Three are reinforced and one gets a small
refinement:

1. **No public RFC 2544 / Y.1564 script.** Confirmed. Nobody in these 25 threads
   posts a script or a reflector config. Three direct "how do I do RFC 2544 with
   MikroTik" questions (2014, 2014, 2017) got either no answer or a pointer to
   external testers or the traffic-generator performance wiki.
2. **Traffic-generator loss is TX minus RX on the generating router.** Confirmed by a
   2017 user's `stats stream print detail` output, where lost = tx − rx exactly
   (73,223 − 44,137 = 29,086). **Nothing in these threads shows two generators
   measuring one-way loss.** The two threads that asked how to use traffic-generator
   between two routers (83624, 83623) got no answer. The only multi-hop question
   (138374) confirms the packets have to come back to the sender.
3. **Stats scriptability is undocumented.** Refined, not overturned. The `running`
   flag can be read in a script (`:put [/tool traffic-generator get running]` →
   `true`, 2021). Nobody shows reading the stats counters from a script. A 2025 request
   to export days of stats went unanswered, and a 2017 request notes the records
   carry only a sequence number, no timestamp, with no log topic.
4. **No MikroTik reflector/loopback.** Confirmed, and the gap is older than the
   report says. The reflector request dates from **2010** (two threads by FIPTech,
   zero replies). The same year MikroTik staff said of 802.3ah, the OAM standard
   that includes remote loopback, "currently we don't have any plans". **One new
   route not in the report:** a 2017 post suggests third-party "smart SFPs" that do
   Y.1564/RFC 2544/OAM inside the module. That hardware would sit in a MikroTik SFP
   cage and bypass RouterOS entirely. It is unverified and not MikroTik's own.

Also new, from a single sample (an inference, not stated anywhere): the traffic
generator's `jitter` field looks like **lat-max − lat-min**, not RFC 3550 jitter
(2.6 ms − 12.1 µs = 2.588 ms, printed as "2.59ms").

## Per-thread notes

### 40999 - RFC2544 reflector deamon
https://forum.mikrotik.com/t/40999 - 2010-09-22, 1 post (FIPTech), no replies, no staff.
- Feature request for RouterOS 5.0: "It would be very nice if we could have a simple
  rfc2544 reflector inside version 5.0 final."
- "Btest server is not usefull for this as it is not compatible with RFC2544 hardware
  testers." Suggests scapy or "a home made packet reflector deamon, this can be as
  small as hundred lines of C code."
- **Flag:** the earliest reflector request found, and no config was ever posted.
  Unanswered after 16 years.

### 38092 - Loopback for RFC2544 testing (2010)
https://forum.mikrotik.com/t/38092 - 2010-05-30, 1 post (FIPTech), no replies, no staff.
- "RFC2544 reflecting work by swapping MAC and IP addresses, sending back the same
  data to the originator for analysis. Is there is way to do this inside router OS at
  wire speed ?"
- The 2019 thread 129123 reuses this text word for word.

### 129123 - Loopback for RFC2544 testing (2019)
https://forum.mikrotik.com/t/129123 - 2019-04-02 to 2024-07-24, 4 posts, no staff.
- This is the same thread the report already cites as viewtopic t=147223. Nothing new.
- matejm (2024): "this is literally only result i get. So i think this feature is not
  existing. Maybe it could be done with mirroring,?"
- rplant (2024): "For generic case, perhaps not. (maybe a container?) But for a single
  source ip sending data, you could probably use a dst-nat and src-nat pair of rules,
  to send the traffic back." That is IP-level and goes through the CPU. It is not a MAC swap.

### 111431 - RFC2544 test
https://forum.mikrotik.com/t/111431 - 2017-08-18, 1 post (marcin21), no replies.
- Asks whether RFC 2544 can be done with traffic-generator, "not using dedicated
  hardware", because the customer's tester "shows some lost packets". Unanswered.

### 75532 - RFC2544
https://forum.mikrotik.com/t/75532 - 2014-03-23/24, 3 posts. janisk (MikroTik, per the earlier notes) replied.
- The asker needs RFC 2544 results to sell last-mile service to a carrier and wants
  something cheaper than JDSU.
- janisk replied with only the wiki link `Manual:Performance_Testing_with_Traffic_Generator`.
- JorgeAmaral (Trainer): "Search for veex mx100e+ ... Half the price of an Jdsu, but still expensive."
- Compare janisk's 2012 remark in 60310, which says the same wiki is not an RFC test.

### 78782 - MPLS and RFC 2544
https://forum.mikrotik.com/t/78782 - 2014-07-07/08, 8 posts. Moderators mrz and ste replied (mrz is known as MikroTik support; ste unverified).
- A real RFC 2544 run with an **EXFO FTB-1** through an RB750 MPLS/VPLS link.
  Results: 64 B 16.9, 128 B 30.6, 256 B 64.0, 512 B 78.9, 1024 B 98.7, 1280 B 99.38,
  1518 B 100.00 Mbit/s.
- mrz: "This is normal, you will never get the same BW with small packets. Look at
  CPU usage and you will see why." The asker reported "Cpu usage is low".
- ste: RB750 fastpath figures apply "only to LSR. Using RB750 as LER will give lower
  numbers and using it additional as VPLS endpoint will cost another cpu cycle."
- hedele: a customer who tests small frames would reject this; ISPs argue for IMIX or 512 B.
- Relevance: the small-frame ceiling on MikroTik devices under test, measured by a
  real tester. This supports the report's CPU-bound framing.

### 147692 - Getting the status of the traffic-generator
https://forum.mikrotik.com/t/147692 - 2021-03-16, 3 posts, no staff (Jotne answered).
- `/tool traffic-generator get running` prints nothing at the CLI. Wrapped in `:put`
  it returns `true`. `:local status [/tool traffic-generator get running]` works in a script.
- **Scriptability evidence:** the run state can be read. Nothing covers the stats counters.

### 181016 - How to export stats from traffic generator
https://forum.mikrotik.com/t/181016 - 2025-01-03, 1 post (barku), no replies.
- Running traffic-generator for 2-3 days and wants to export "transmit rate, receive
  rate, latency, jitter". Unanswered. No export method is known in the forum.

### 106107 - Feature request: Time Stamp on Traffic Generator Stats Records
https://forum.mikrotik.com/t/106107 - 2017-02-10, 1 post (MarcusH), no replies.
- Shows real stats output:
  `/tool traffic-generator stats> stream print detail`
  `0 seq=1 id=1 tx-packet=73 223 ... tx-rate=149.9Mbps rx-packet=44 137 ... rx-rate=90.3Mbps rx-bad-csum=0 lost-packet=29 086 ... lost-rate=59.5Mbps lat-min="12.1us" lat-avg="1.01ms" lat-max="2.6ms" jitter="2.59ms"`
- "As of right now there is only a sequence number." "I tried to figure out if there
  is a log topic that logs traffic-generator stats records but I could not find anything."
- **Flags:** (a) lost-packet = tx-packet − rx-packet exactly, on the generating router.
  (b) Stats are `print`-able records with named fields, so `print as-value` or `get`
  might work, but nobody demonstrates it. (c) jitter 2.59 ms ≈ lat-max − lat-min. That
  suggests a range, not RFC 3550 interarrival jitter. This is inferred from one sample.

### 84371 / 84341 - jitter with traffic generator
https://forum.mikrotik.com/t/84371 - 2015-01-09, 1 post, no replies.
https://forum.mikrotik.com/t/84341 - 2015-01-08 to 2018-09-11, 4 posts, no staff.
- Both ask how traffic-generator computes jitter and how it relates to
  `stats latency-distribution`. Unanswered.
- Muqatil (Trainer) suggests `/tool traceroute`, which "calculates the standard
  deviation of the latency, which is the jitter you are looking for."
- jjhorta (2018) asks about the measurement's precision across CPU architectures. Unanswered.

### 83624 - Test 2 routers using traffic generator, is possible?
https://forum.mikrotik.com/t/83624 - 2014-12-10, 1 post, no replies.
- Asks how to test bandwidth between two routers with traffic-generator. Unanswered.
  **Gives no evidence on two-generator one-way loss.**

### 83623 - Simply testing bandwidth with traffic generator
https://forum.mikrotik.com/t/83623 - 2014-12-10/16, 2 posts (the asker plus a bump), no replies.
- "a lot of forum users say that bandwith test is obsolete so they invite to use
  Traffic generator" but the asker can't make it work between a PPPoE server and
  client. Unanswered.

### 138374 - Can traffic generator be used over more than 1 hop?
https://forum.mikrotik.com/t/138374 - 2020-04-09, 3 posts, no staff.
- A->B works by setting src=B, dst=A so "B will take the packets and send them straight
  back". For A->B->C: "If I set the destination to C, yes the packets get there but C
  never sends them back so its useless for round-trip performance testing".
- The only suggestion was a tunnel from A to C. The asker rejected it because it
  changes forwarding.
- Confirms the report: the generator's loss needs a return path to itself. Nobody
  suggests running a second generator on C to count RX.

### 130621 - Btest, Traffic generator - Testing bandwidth of the link
https://forum.mikrotik.com/t/130621 - 2019-06-02, 1 post, no replies.
- "with new FW Btest always load CPU to 100% on both sites and it limit the test".
  Anecdotal support for the repo's "overloaded generator" finding. Unanswered.

### 131945 - Testing for packetloss between DC
https://forum.mikrotik.com/t/131945 - 2019-07-30, 3 posts, no staff.
- A 2.1 Gbps DC-to-DC circuit (ROS 6.45.1). A generator on a CCR1036 "bouncing off
  another at 5gbps" through a CRS317 showed loss "not even testing over the circuit".
  The config is a quick `mbps=5000`, `packet-size=1500` stream.
- The only reply: use PCs with iperf. The asker can't, because the ends are 3 h by
  road and 4 h by air apart.
- Illustrates the report's point: the loss can't be pinned to the switch, the far
  box or the generator.

### 150220 - Robust 24/7 traffic generation
https://forum.mikrotik.com/t/150220 - 2021-07-05, 1 post, no replies.
- The user's observations: "Traffic Generator seems to bypass queues". It "injects
  outbound packets to some strange point of interface (for some reason it requires
  outer MAC layer even if packets are injected into ipip tunnel)". It ran "well for
  several days" over site-to-site VPN. Btest "seems to get stuck if the server
  temporarily disconnects".
- Relevance: if the generator bypasses queues, it cannot test a shaper on the
  generating router itself. This is a user claim and unverified.

### 134034 - CRS305 traffic generator 10Gbps and self loopback on port
https://forum.mikrotik.com/t/134034 - 2019-10-18, 2 posts. doneware (Trainer) replied; no staff.
- The user wants a single-port self-loopback test on a CRS305. They get about
  1300 Mbps, and the system hangs when an SFP is inserted. Their full config is posted.
- doneware: "traffic generator essentially a packet generator that runs on the CPU.
  CRS305 is mainly a switch ... CRS305 will happily switch the frames but falls short
  when the CPU has to process/generate packets".
- doneware: "i've used once a CCR1072 to test a 100GE card on an ASR9k, by driving
  8x10GE ports on one device. it can really generate 80Gbps traffic."
- No switch-chip generation or hardware loopback. Confirms the report.

### 126264 - Traffic Generator >1Gbps
https://forum.mikrotik.com/t/126264 - 2018-12-27, 3 posts, no staff.
- The user wants to saturate a 2 Gbps radio link (2x1G ECMP) and can only get 1 Gbps
  on one port. Redmor: "Try to make a bandwidth test in UDP, you won't use single core
  like TCP." Unresolved.

### 121309 - Traffic generator settings for test against iperf3
https://forum.mikrotik.com/t/121309 - 2018-07-12, 1 post, no replies.
- Asks for a template to test against an iperf3 server. Unanswered, and no interop
  config is posted.

### 113295 - Understanding Mikrotik's definition of "Throughput"
https://forum.mikrotik.com/t/113295 - 2017-10-20, 6 posts. ZeroByte (moderator) replied.
- Paternot quotes the product page footnote: "All tests are done with Xena Networks
  specialized test equipment (XenaBay),and done according to RFC2544 (Xena2544)".
  This is already in the earlier notes.
- ZeroByte: MikroTik figures count one-way forwarding and can exceed a single
  port's rate.

### 60310 - RouterBOARD testing procedures
https://forum.mikrotik.com/t/60310 - 2012-10-12 to 2018-04-23, 34 posts. normis
(MikroTik-Staff) and janisk replied.
- normis announces the wiki `Manual:Performance_Testing_with_Traffic_Generator`
  (RB1100AHx2 example). normis: "I didn't write it".
- vicl: "I hope that's not the procedure you use to report your 'rfc2544 thoughput numbers'."
- **janisk (2012-10-26):** "no, this is only for users who want to test their routers
  and do some number crunching. RFC test is done one professional testing equipment
  other way, as you say - there would not be any reason to run them if they are not
  comparable."
- **Flag:** MikroTik itself says the traffic-generator method is not an RFC test.
  That supports the report. It conflicts mildly with janisk pointing an RFC 2544
  seeker to the same wiki in 2014 (75532).
- The rest of the thread is off topic: CPE setup, PCI card failures, DDoS screenshots.

### 262173 - What the heck is up with switch policers on CRS3XX hardware?
https://forum.mikrotik.com/t/262173 - 2025-06-26/27, 22 posts. chechito (moderator) replied.
- An ISP wants CRS305/309/310 as CPE with port policers. On ROS 7.19.2/7.20beta, a
  CRS310 port ingress limit of 1100 Mbps gave "ingress throughput that ranges from 38
  to 60 Mbps"; a switch-rule policer at 1100 Mbps gave "about 100 Mbps". The same
  policer on a Juniper EX2300 was fine.
- chechito tested an ingress ACL rate on a CRS317 (7.20b4) with traffic-generator and
  it "worked OK, only tested up to 900mbps". He later concedes the generator "is
  stateless, not a good representation of real world traffic".
- The asker, on RFC 2544: "I could fire up a hardware traffic generator as well but
  I'd prefer not to since RFC2544 or BERT tests aren't stateful and I don't consider
  them to be a good representation of real world traffic."
- Relevance to acceptance testing: a circuit policed by a CRS3xx switch chip could
  pass a constant-rate UDP test while TCP collapses. This is tangential; no RFC 2544
  config is posted.

### 40250 - IEEE 802.3ah / 802.1ag
https://forum.mikrotik.com/t/40250 - 2010-08-25 to 2023-02-09, 23 posts. uldis (MikroTik-Staff) replied.
- An Austrian ISP wants a MikroTik demarcation device with 802.3ah ("remote
  loopback") and 802.1ag.
- **uldis (2010-08-31): "currently we don't have any plans. And currently you are the
  only one who asked about such features."**
- FIPTech (2010) asks for EtherSAM (Y.156sam): "Actually only EXFO has EtherSAM testing".
- About 15 +1s follow through 2023, asking for 802.3ah, 802.1ag, Y.1731, E-LMI and CFM,
  with no further staff reply. grin (2012) asks for "RFC2544 measurement features" and
  points to the Linux dot1ag-utils. LaZyLion (2023): "We have spent an incredible
  amount of money on Ciena switches for OAM".
- **Flag:** confirms that no standards-based (802.3ah) loopback exists. The only
  staff answer is from 2010.

### 6185 - Mikrotik bandwidth test software; using iperf?
https://forum.mikrotik.com/t/6185 - 2006-04-11 to 2018-07-26, 22 posts. Only
normis's #2 (2006, about iperf) is staff. Relevant posts only:
- stephend (2009): "BTEST does not report latency, jitter or packet loss like IPERF
  does." That was true then and is outdated now, since btest reports `lost-packets`.
- cieplik206 (Trainer, 2011): "Never measure device using device itself ... traffic
  generator uses CPU cycles that could be used to transmit data".
- doush (2011): "MT bandwidth test now is not compatible with anything."
- FIPTech (2011): "RFC 2544 is crap when you are in need of precise measurements for
  VoIP or Video quality ... EtherSAM (ITU-T Y.1564) ... is only available on expensive
  hardware testers."
- **FIPTech (2017-03-21): "A solution to add EtherSam (Y.1564), RFC2544 and OAM
  management capability would be to use smart SFPs on Mikrotik SFP enabled routers."**
  Links: aimvalley.com (Ethernet OAM smart SFP) and oesolutions.com (smartSFP).
  **New hardware-reflector route, not in the report.** It is unverified: nobody
  reports trying one in a MikroTik cage, and the vendor pages were not checked here.
- No post discusses btest accuracy or the meaning of `lost-packets`.

## Gaps

- Nothing here settles whether a generator on router B counts RX for a stream sent
  one way from router A's generator. It would need a bench test: matching packet
  template and stream id on both ends, then compare B's `stats stream` rx-packet with
  A's tx-packet.
- Nobody demonstrates `/tool traffic-generator stats stream print as-value` or `get`
  from a script. It is untested.
- The smart-SFP vendors' current products and their reflector modes
  (MAC swap / RFC 2544 / Y.1564 / TWAMP) were not checked.
