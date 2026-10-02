# Code repositories: RFC 2544 / Y.1564 testing on or against MikroTik RouterOS

Method: GitHub REST repository search (unauthenticated, 2026-09-30) for rfc2544 / rfc-2544 / y1564 / y.1564 / mikrotik btest / routeros bandwidth-test / mikrotik traffic generator / mikrotik speedtest / topic:rfc2544 / topic:y1564 / topic:btest, plus web searches for gists and GitLab. 23 candidate repos were shallow-cloned and read (source, not just READMEs). Star counts and last-push dates come from the GitHub API on 2026-09-30; "last commit" is `git log -1` on the default branch. Code search (which needs auth) was not available, so a repo whose name and description never mention btest or RFC 2544 could have been missed.

Headline: **No public repo or gist was found that does RFC 2544 or Y.1564 testing *with* MikroTik's own tools (`/tool/bandwidth-test` or `/tool/traffic-generator`).** Searches for "rfc2544 mikrotik" and "rfc2544 routeros" on GitHub returned 0 repos. What exists falls into four groups:
- simple btest throughput loggers (TCP, no frame sizes, no loss verdict)
- btest protocol reimplementations. These are the most useful here because they show how btest counts loss and bytes.
- one Python tool that generates `/tool traffic-generator` profiles, and its RouterOS syntax is invalid
- general RFC 2544 / Y.1564 generators. The only one with MikroTik integration is MoonGen's 2015 RFC 2544 framework, which configures a MikroTik DUT over SSH.

## Q1. RouterOS scripts or external tooling doing RFC 2544 / Y.1564 via /tool/bandwidth-test or /tool/traffic-generator

### Takeaway
Nothing public comes close to the user's script. Every RouterOS btest script found runs TCP (or UDP at the default size) and records average Mbps. None of them sweep frame sizes, sum `lost-packets`, apply a loss SLA, gate on CPU, or give a PASS/FAIL verdict. Several have unit or logic bugs. The only MikroTik-DUT RFC 2544 code is MoonGen's framework, which uses an external DPDK generator and only configures the MikroTik over SSH.

### Cited Findings

**RouterOS btest scripts (all throughput-only):**
- **ysoheilifar/Mikrotik-Bandwidth-Test**: author Yaser Soheilifar, 0 stars, last commit 2024-01-02, RouterOS Script, `vpn-bandwidth-test.rsc`.
  - What it does: loops over running interfaces named `vpn-*` and runs `/tool bandwidth-test ... duration=10s direction=both protocol=tcp connection-count=1 random-data=yes`. It records `tx-total-average/1000000` into a variable named `rxAvg` and `rx-total-average/1000000` into `txAvg`, so the labels are swapped relative to the local view. It bubble-sorts the interfaces by that number and sets route distances.
  - Defects: the final loop iterates `$iparray`, which is never defined (the script builds `ipdict2`), so the route-reordering step does nothing. The btest password is hard-coded in plaintext.
  - Measures: TCP throughput only. No loss, no frame size, no verdict.
  - Source: [repo](https://github.com/ysoheilifar/Mikrotik-Bandwidth-Test)
- **Cam-e-ron/Mikrotik-Bandwidth-Test**: 0 stars, last commit 2021-09-28, `BW-Test.TXT`.
  - What it does: a 30 s TCP receive test, then a 30 s TCP transmit test, appended to a file.
  - Unit error: it divides bps by 1,048,576 and labels the result "Mbps", so it reports Mibps and under-reads by about 4.6%.
  - Source: [repo](https://github.com/Cam-e-ron/Mikrotik-Bandwidth-Test)
- **bubnovd/RouterOS-scripts, `bandwidth test/btest-script`**: author Dmitry Bubnov, 62 stars, repo last pushed 2020-05-28, btest folder last changed 2018-10-16.
  - What it does: 5 s TCP transmit, then 5 s TCP receive, `tx-total-average / 1048576` labelled "Mbps" (the same Mibps unit error), appended to `isp-quality.txt`.
  - Source: [repo](https://github.com/bubnovd/RouterOS-scripts/blob/master/bandwidth%20test/btest-script)
- **nuruladewi/ansible-bw-test**: 0 stars, last commit 2024-11-20, Ansible (`routeros_command` over `network_cli`).
  - What it does: for each site in a CSV it runs `/tool bandwidth-test ... protocol=tcp direction=both duration=10s`. It regex-scrapes the last `tx-total-average`, `rx-total-average` and `status` from the CLI output into a CSV, with an optional email step.
  - Measures: TCP throughput only.
  - The CSVs committed to the repo contain per-site plaintext passwords.
  - Source: [repo](https://github.com/nuruladewi/ansible-bw-test)
- **hoboristi/prometheus-mikrotik-btest**: 0 stars, last commit 2026-09-10, Python. A Prometheus "probe" exporter that uses a hand-written RouterOS API client on port 8728.
  - What it does: runs `/tool/bandwidth-test =protocol=udp =direction=receive`, then a separate `=direction=transmit`, each `TEST_DURATION` s (default 10). It keeps the last non-zero `rx|tx-total-average` or `-10-second-average`, falling back to the peak `-current`.
  - What it ignores: `lost-packets` and CPU. It uses the default UDP size and does no frame-size sweep. The README says it requires disabling auth on the btest server.
  - Its docstring says "RouterOS v7".
  - Source: [repo](https://github.com/hoboristi/prometheus-mikrotik-btest)
- **dmcken/routeros_btest**: 0 stars, last commit 2024-11-10. Only a README and a PROTOCOL.md stub listing open questions. No code.
  - Source: [repo](https://github.com/dmcken/routeros_btest)
- **Public-server gist** (adinata-id, created 2021-09-10, updated 2026-03-27): only a public btest server address and credentials. No code.
  - Source: [gist](https://gist.github.com/adinata-id/77c788a96d1deaa3fcb8703633d12aa9)
- **Name matches that are not btest tools**:
  - cdhtlr/MikroTik-Speedtest (Go, 19 stars, last commit 2023-02-13) is a "MikroTik-terminal-friendly download speedtest", not btest. [repo](https://github.com/cdhtlr/MikroTik-Speedtest)
  - billchaison/btest_bot (2026-06-30) automates `btest.exe` "as a hacking tool". [repo](https://github.com/billchaison/btest_bot)

**The only /tool/traffic-generator automation found:**
- **DeusKZ/mikrotik_traffic_generator** ("PCAP Traffic Studio v2"): 0 stars, last commit 2026-04-25, Python/PySide6.
  - What it does: analyses a PCAP and emits replay profiles for TRex, MoonGen, pktgen-dpdk and "MikroTik Traffic Generator". It uploads and imports the `.rsc` over SSH (paramiko) and runs `/tool traffic-generator start/stop`.
  - The generated RouterOS lines are `/tool traffic-generator stream add packet-size=<avg> rate=<pps>pps src-address=... dst-address=... protocol=... src-port=... dst-port=...`.
  - That syntax is invalid. MikroTik's docs say a stream accepts only `disabled, mbps, name, num, packet-size, port, pps, tx-template`, and addressing belongs in a `packet-template` with `header-stack`, `ip-src`, `ip-dst`, `udp-src-port` and so on.
  - It is not RFC 2544 in any case: no loss, no latency, no search.
  - Sources: [repo](https://github.com/DeusKZ/mikrotik_traffic_generator); [MikroTik Traffic Generator docs](https://help.mikrotik.com/docs/spaces/ROS/pages/128221376/Traffic+Generator)
- MikroTik's traffic-generator quick mode itself reports LOST-PACKET, LOST-RATE and RX-OOO, plus latency distribution through `/tool traffic-generator stats latency-distribution`. No repo was found that scripts this into an RFC 2544 sweep. — [MikroTik docs](https://help.mikrotik.com/docs/spaces/ROS/pages/128221376/Traffic+Generator)

**RFC 2544 with MikroTik as the DUT (external generator):**
- **emmericp/MoonGen, `rfc2544/` directory**: 1,118 stars on the repo, repo last pushed 2025-11-30.
  - Age: the `rfc2544/` code dates from 2015. The history of `utils/ssh-mikrotik.lua` ends at a 2015-10-07 rename commit ("renamed to rfc2544; some report changes; freebsd ssh module"). Treat it as abandoned.
  - Language: Lua (LuaJIT on DPDK), with a C SNMP helper.
  - `master.lua`: frame sizes {64, 128, 256, 512, 1024, 1280, 1518}, default trial `--duration 10` s, default max loss rate `--mlr 0.001` (0.1%). It runs the throughput, latency, frame-loss and back-to-back benchmarks in turn.
  - `benchmarks/throughput.lua`: a binary search (`utils.binarySearch()`, init `0..maxLinkRate`). Each trial computes `lossRate = (spkts - rpkts) / spkts` from hardware TX/RX counters on the generator NICs and counts as valid if `lossRate <= maxLossRate`. It iterates until the step is below `rateThreshold`.
  - `utils/ssh-mikrotik.lua`: a DUT-config adapter that SSHes into RouterOS to add and remove IP addresses (`/ip address add|remove`), firewall drop rules (`/ip firewall filter add chain=forward ... action=drop`), routes (`/ip route add dst-address=... gateway=...`) and to count routes (`/ip route print count-only`).
  - In short, the MikroTik is only the forwarding DUT. MikroTik's own btest and traffic-generator are not used.
  - Sources: [ssh-mikrotik.lua](https://github.com/emmericp/MoonGen/blob/master/rfc2544/utils/ssh-mikrotik.lua); [MoonGen repo](https://github.com/emmericp/MoonGen)
- **TU Munich published RFC 2544 reports produced with that framework**, including a "Mikrotik Cloud Core Router CCR1036-8G-2S+" (Tilera Tile-Gx36 @ 1.2 GHz) with 25 firewall rules.
  - The summary retrieved lists 14.204 Mpps at 64 B and 0.813 Mpps at 1518 B, against a Linux Xeon router at 1.025 Mpps at 64 B. No test date is given.
  - Caution: two retrievals disagreed on the MikroTik's average latency at 1518 B (315.5 µs in the page fetch, 969.7 µs in a search snippet). Treat the latency figures as unverified.
  - Source: [TUM router-benchmarking](https://net.in.tum.de/pub/router-benchmarking/)

**No Y.1564 code tied to MikroTik:**
- GitHub repo search for "y1564" returned 2 repos and "y.1564" returned 3 relevant ones: MustardSeedNetworks/stem, Lay007/network-quality-assessment and wwtraveler/fastlane-rfc2544.
- None of the three mention MikroTik or RouterOS in code. Grepping stem, fastlane, Lay007 and vMark-node for mikrotik, routeros and btest found no hits.
- Source: GitHub search API results, 2026-09-30 (see Q4 for URLs).

### Inferences
- The user's script (frame-size sweep via `local-udp-tx-size`, summed `lost-packets`, 0.10% SLA, CPU >= 90% gate, NO TEST detection, per-direction verdict) appears to be the most complete public attempt at RFC 2544-style acceptance testing built on btest. None of the public scripts even read `lost-packets`.
- The Mibps-for-Mbps mistake (dividing by 1,048,576) shows up in two independent scripts (Cam-e-ron, bubnovd). It looks like a common copy-paste pattern in community btest scripts.
- MoonGen's defaults (10 s trials, 0.1% max loss, binary search on hardware counters) are the closest open-source analogue to the user's settings. Its loss comes from hardware port counters at both generator ports (TX minus RX). That is the kind of evidence this project ranks above software-counted loss.

### Gaps
- GitHub code search (for `bandwidth-test` together with `lost-packets` inside `.rsc` files) needs authentication and was not run. Repos that bury a btest script without naming it could be missed.
- No GitLab, Codeberg or Bitbucket repos surfaced in web searches for these terms. I found no reliable evidence that any exist.
- Could not confirm the TUM MikroTik latency figures, or which RouterOS version was tested.

## Q2. Open-source btest reimplementations: what they reveal about the protocol, loss counting and byte units

### Takeaway
There are at least eight reimplementations. **None of them uses btest for RFC 2544-style sweeps.** The closest is pewpewpacket, which has an RFC 2544 zero-loss binary search but only between two copies of itself, and whose btest server is TCP-only.

Together they explain the user's bench findings:
- `lost-packets` is computed by the *receiver* from gaps in a 4-byte sequence number and reset every interval.
- The per-second `07` status message carries the *peer's received byte count*, which is why `tx-total-average` reflects what the far end received.
- There is no loss field in the status message, so the router that starts a test cannot learn about loss on its outbound direction.

On byte units, the clones disagree: btest-opensource treats `tx-size` as the IP packet size (payload = size - 28), while btest-rs and centrs send `tx-size` bytes of UDP payload.

### Cited Findings

**Inventory (stars and dates as of 2026-09-30):**
- **samm-git/btest-opensource**: C (plus Perl `bserver.pl` / `bclient.pl`), 169 stars, last commit 2024-01-25. Protocol reverse-engineered with Wireshark against **RouterOS 6**. It supports only the legacy MD5 auth; EC-SRP5 (RouterOS >= 6.43) is "not yet supported". — [repo](https://github.com/samm-git/btest-opensource)
- **manawenuz/btest-rs**: Rust, 34 stars, last commit 2026-04-18. Server and client, TCP and UDP, EC-SRP5 and MD5, per-interval `lost` in its output and CSV. — [repo](https://github.com/manawenuz/btest-rs)
- **MikroWizard/MikroSpeed** (Rust, last commit 2026-08-13) vendors btest-rs as a MikroWizard addon. — [repo](https://github.com/MikroWizard/MikroSpeed)
- **manawenuz/btest-rs-android** (Kotlin) wraps btest-rs. — [repo](https://github.com/manawenuz/btest-rs-android)
- **jof/btest-rs**: Rust server, 4 stars, last commit 2026-02-22. TCP and UDP, "port + 256 client offset". — [repo](https://github.com/jof/btest-rs)
- **mdrobniu/blast**: Rust, 0 stars, last commit 2026-06-21. A multi-protocol tester (btest, iperf2/3, speedtest). Its `PROTOCOL.md` has the deepest reverse engineering found: Ghidra decompilation of `btest.exe` (RouterOS 7.7/7.8 era) and of the RouterOS 7.16.2 CHR image's `/nova/bin/btest` and `btest.ko`. — [PROTOCOL.md](https://github.com/mdrobniu/blast/blob/main/PROTOCOL.md)
- **tikoci/centrs**: TypeScript, 4 stars, last commit 2026-09-27. A multi-protocol RouterOS CLI with a `btest client|server`. Its README says both roles pass gated integration tests on CHR 7.23.1, including "UDP-transmit (with loss accounting)" and EC-SRP5. — [btest README](https://github.com/tikoci/centrs/blob/main/commands/btest/README.md)
- **awksedgreep/pewpewpacket**: Rust AF_XDP link tester, 0 stars, last commit 2026-08-16.
  - It has a MikroTik btest *server* that is TCP-only, no-auth, and does not yet send in-band status frames.
  - It also has an RFC 2544 mode (`pewpew tx --rfc2544 --rfc-max-pps ... --rfc-duration 3`) that binary-searches for the zero-loss rate using the receiver's reported loss.
  - The RFC 2544 mode works only between two pewpew instances, not over btest.
  - Source: [repo](https://github.com/awksedgreep/pewpewpacket)
- **kadosch/mikrotik_btest** (C, 10 stars, last commit 2012-12-15), **kadosch/mikrotik_btest_stub** (Python, 6 stars, 2012-04-30) and kadosch/mikrotik_btest_openwrt: an early client with `-m MTU` and `-d receive|send|both` options. **Abandoned; pre-EC-SRP5**, so it cannot authenticate to RouterOS >= 6.43. — [repo](https://github.com/kadosch/mikrotik_btest)

**Protocol facts relevant to the user's loss and unit findings (verified in source):**
- Control channel and command: TCP port 2000, server hello `01 00 00 00`, then a 16-byte command.
  - Fields: proto (01 TCP / 00 UDP), direction (01 tx / 02 rx / 03 both), random flag, tcp-connection-count, `remote-udp-tx-size` u16 LE, local size u16 LE, remote-tx-speed u32 LE, local-tx-speed u32 LE.
  - Speeds are in bits/s.
  - Sources: [btest-opensource README](https://github.com/samm-git/btest-opensource); [blast PROTOCOL.md](https://github.com/mdrobniu/blast/blob/main/PROTOCOL.md)
- About once a second each side sends a 12-byte `07` status message.
  - btest-rs documents it as `[0x07][cpu:1][pad:2][seq:4 LE][bytes_received:4 LE]`.
  - blast confirms that "The `07` heartbeat's `bytes` field is the peer's **actually-received** bytes for that ~1s interval - the ground truth for UDP loss (sent on our NIC vs received by the peer)". blast also saw bytes 1-3 not always zero; btest-rs parses the CPU from byte 1 (`0x80 | pct`).
  - The message has **no loss-count field**.
  - Sources: [btest-rs architecture.md](https://github.com/manawenuz/btest-rs/blob/main/docs/architecture.md); [blast PROTOCOL.md](https://github.com/mdrobniu/blast/blob/main/PROTOCOL.md)
- RouterOS firmware (7.16.2 CHR, decompiled by blast): the UDP data plane runs in the kernel module `btest.ko`.
  - For each datagram it writes a 4-byte big-endian sequence number (`packet_index + 2`) at the start of the UDP payload, then fills with random or zero bytes.
  - Stats reach userspace via ioctl as a 24-byte report.
  - UDP ports: the server sends a 2-byte base port on the control connection; data flows between `base` and `base+256+i`.
  - Source: [blast PROTOCOL.md §8](https://github.com/mdrobniu/blast/blob/main/PROTOCOL.md)
- Loss accounting in all three clones that implement it: the **receiver** computes gaps in the sequence number.
  - btest-opensource: `recvStats.lostPackets += thisSeq - lastSeq - 1`, skipping the first packet ("we often lose packets initially"). — [btest.c](https://github.com/samm-git/btest-opensource/blob/master/btest.c)
  - btest-rs: `if seq > expected { lost = seq - expected }`, and the counter is **swapped to 0 every status interval** (`rx_lost_packets.swap(0)`), so each report is a per-interval delta. — [client.rs](https://github.com/manawenuz/btest-rs/blob/main/src/client.rs)
  - centrs: the same (`if (seq > expected) this.rxLost += seq - expected`; `swapLost()` resets it each interval). It only counts when the local side is receiving (`dirs.shouldRx ? counters.swapLost() : 0`). — [btest-session.ts](https://github.com/tikoci/centrs/blob/main/src/protocols/btest-session.ts)
  - None of them counts out-of-order packets as recovered: a sequence number lower than expected is ignored rather than subtracted.
- Pacing and byte units, where the clones differ:
  - **btest-opensource** (reverse-engineered on ROS 6):
    - Allocates and sends `tx_size - 28` bytes of UDP payload.
    - Paces with `interval = 1e9 * tx_size * 8 / tx_speed`, that is on the IP-packet size.
    - Counts received bytes as `nBytes + 28`, adding the IP and UDP headers back.
    - Source: [btest.c](https://github.com/samm-git/btest-opensource/blob/master/btest.c)
  - **btest-rs** sends a `tx_size`-byte UDP payload, paces on `tx_size * 8`, and counts `rx_bytes += n` (payload only, no +28). — [client.rs](https://github.com/manawenuz/btest-rs/blob/main/src/client.rs); [bandwidth.rs](https://github.com/manawenuz/btest-rs/blob/main/src/bandwidth.rs)
  - **centrs** also sends `txSize`-byte datagrams (`encodeUdpPacket(0, ctx.txSize, ...)`), but enforces `MIN_UDP_TX_SIZE = 28`, mirroring RouterOS's `*-udp-tx-size` lower bound. — [btest.ts](https://github.com/tikoci/centrs/blob/main/src/btest.ts); [btest-session.ts](https://github.com/tikoci/centrs/blob/main/src/protocols/btest-session.ts)
- Behaviour copied from MikroTik:
  - Unlimited-speed adaptation: the sender resets its rate to 1.5x the peer-reported received bytes. btest-opensource has the comment "Set the outgoing speed to be twice the rate reported" but the code does `recvBytes*8*1.5`; btest-rs does `bytes_received*8*3/2`. — [btest.c](https://github.com/samm-git/btest-opensource/blob/master/btest.c); [client.rs](https://github.com/manawenuz/btest-rs/blob/main/src/client.rs)
  - Both clamp any inter-packet interval over 500 ms to 1 s ("Duplicate bug? in MT"). — [btest.c](https://github.com/samm-git/btest-opensource/blob/master/btest.c); [bandwidth.rs](https://github.com/manawenuz/btest-rs/blob/main/src/bandwidth.rs)
- Documented quirks:
  - btest-rs KNOWN_ISSUES: "UDP bidirectional through NAT will only show one direction — this is a btest protocol limitation", and a MikroTik client "speed adaptation staircase" in UDP send over 30-60 s that the C implementation shows too. — [btest-rs README](https://github.com/manawenuz/btest-rs); [KNOWN_ISSUES.md](https://github.com/manawenuz/btest-rs/blob/main/KNOWN_ISSUES.md)
  - blast: in multi-connection `both`, "conn 0 carries data in both directions, so there is no idle lane for `07`", which "leaves the peer's upload counter at 0". — [blast PROTOCOL.md §9](https://github.com/mdrobniu/blast/blob/main/PROTOCOL.md)

### Inferences
- **Why `lost-packets` only counts loss into the initiating router.** Loss is computed only by whichever end receives the sequenced stream, and the `07` message has no loss field, so the router that started the test never learns about outbound loss. This matches the user's bench result (direction=transmit with 9,323 forward drops summed 0), which fits the protocol as the clones implement it. The only outbound signal the initiator gets is the peer's received-byte count in `07`, which is exactly why the user's "far-end received" rate works as a shortfall detector.
- **Why summing `lost-packets` across callbacks is correct.** btest-rs and centrs both reset the lost counter each interval, which matches the user's 2026-09-18 finding that it is a per-interval delta.
- **Why the sum misses a few percent.** btest-opensource deliberately skips the first packet's gap, and any trailing packets after the last status tick are never reported. That is consistent with the user catching about 93% of true drops (the connecting second and the tail fall outside the callbacks). This is an inference from the clone code, not a verified property of RouterOS itself.
- **Byte units.** The user's bench found the throttle metered on the IP packet (`size`) and ROS 7 rates counted on the UDP payload (`size - 28`). btest-opensource (ROS 6 era) paces on `tx_size` and adds 28 back when counting, which matches the user's note that ROS 6 counted the IP packet. The Rust and TypeScript clones send `tx_size` bytes of *payload*, so a UDP frame-size sweep through them would put `size + 28` IP bytes on the wire rather than `size`. They should not be used for exact RFC 2544 frame sizes without checking first.
- If the user ever wanted independent or cross-check loss at both ends, the practical open-source option is a btest reimplementation acting as the server on a Linux host (btest-rs, jof/btest-rs or centrs). It could log per-interval loss for the direction the router cannot see. None ships this as a feature, and none produces RFC 2544 verdicts.

### Gaps
- No clone documents *which* byte count ROS 7 puts in the `07` message (payload vs IP). blast confirms only that it is the peer's actually-received bytes. The user's per-flow bench is still the only evidence on units for ROS 7.
- blast's 24-byte `btest.ko` stats report layout (which might contain a kernel-side lost counter) is not described in the notes.
- No reimplementation was found written in Go or Python beyond the 2012 Python stub (kadosch). GitHub searches for "btest server go" and "btest python mikrotik" returned nothing relevant.

## Q3. Projects automating /tool/traffic-generator for RFC 2544

### Takeaway
None found. The only project that drives `/tool/traffic-generator` from code (DeusKZ's PCAP Traffic Studio) replays PCAP-derived rates, not RFC 2544 trials, and emits stream syntax RouterOS does not accept.

### Cited Findings
- DeusKZ/mikrotik_traffic_generator writes `/tool traffic-generator stream add ... rate=<pps>pps src-address=... protocol=...` and starts it over SSH. — [mikrotik.py](https://github.com/DeusKZ/mikrotik_traffic_generator/blob/main/app/generators/mikrotik.py)
- Valid stream properties are `disabled, mbps, name, num, packet-size, port, pps, tx-template`; addressing and UDP ports live in `packet-template` (`header-stack`, `ip-src`, `ip-dst`, `udp-src-port`, `udp-dst-port`). Quick mode reports LOST-PACKET, LOST-RATE and RX-OOO, and latency distribution is available. — [MikroTik Traffic Generator docs](https://help.mikrotik.com/docs/spaces/ROS/pages/128221376/Traffic+Generator)
- A web search for "github mikrotik traffic-generator rfc2544 packet-template" surfaced only the MikroTik docs and wiki ("Performance Testing with Traffic Generator"), forum threads, and MoonGen's `ssh-mikrotik.lua`. There were no code repos scripting traffic-generator sweeps. — [MikroTik wiki: Performance Testing with Traffic Generator](https://wiki.mikrotik.com/wiki/Manual:Performance_Testing_with_Traffic_Generator)

### Inferences
- An RFC 2544 sweep on `/tool/traffic-generator` (packet-size loop, pps binary search on LOST-PACKET, latency from stats) would be new public work. Unlike btest, traffic-generator gives loss and latency for the traffic it sends and receives back on its own ports. That only fits a loopback or two-port-on-one-router topology, not a single-ended circuit test like the user's.

### Gaps
- Gists are poorly indexed by search engines, so a private-ish gist with a traffic-generator sweep could exist unseen.

## Q4. General open-source RFC 2544 / Y.1564 implementations, and any MikroTik use

### Takeaway
Several capable open-source RFC 2544 and Y.1564 generators exist. The main ones are MoonGen's rfc2544 framework, fastlane-rfc2544, MustardSeedNetworks "stem", pewpewpacket and a few AF_PACKET tools. Only MoonGen has MikroTik-specific code, which configures the DUT over SSH. All need Linux or DPDK hosts at the test points, so none replaces a router-only, single-ended btest script.

### Cited Findings
- **emmericp/MoonGen `rfc2544/`**: Lua/DPDK, 1,118 stars, rfc2544 code dates from 2015. Throughput (binary search), latency, frame loss and back-to-back. Frame sizes 64-1518 B, 10 s trials, 0.1% max loss by default. SSH DUT adapters for MikroTik and FreeBSD. LaTeX/TikZ reports. — [MoonGen repo](https://github.com/emmericp/MoonGen); [TUM reports](https://net.in.tum.de/pub/router-benchmarking/)
- **wwtraveler/fastlane-rfc2544**: Rust, 1 star, last commit 2026-06-03, MIT.
  - AF_XDP generator. Covers all four RFC 2544 core tests: throughput by binary search, latency histogram, frame-loss ratio, back-to-back burst escalation.
  - Also claims Y.1564 service configuration and service performance tests (`--y1564-cir`, `--y1564-eir`, FD, FDV, FLR in ppm, `--y1564-perf-mins`) and Y.1731. Frame sizes 64-1518 plus 9000.
  - No MikroTik references.
  - Source: [repo](https://github.com/wwtraveler/fastlane-rfc2544)
- **MustardSeedNetworks/stem**: Go plus a React UI, 0 stars, very active (last commit 2026-09-30), **BSL 1.1 licence** (source-available, not OSI open source).
  - Reflector (AF_PACKET/AF_XDP), RFC 2544 (throughput, latency, frame loss, back-to-back), Y.1564 / MEF 48/49 (config plus performance test), Y.1731, RFC 2889, RFC 6349.
  - No MikroTik references in code.
  - An open issue, #1412, says `stem test -t rfc2544_throughput` is refused at the default 64-byte frame because the CLI attaches a Y.1564 block to every step.
  - Sources: [repo](https://github.com/MustardSeedNetworks/stem); [issue #1412](https://github.com/MustardSeedNetworks/stem/issues/1412)
- **Smaller or older RFC 2544 repos**, none of which reference MikroTik. The robidev repo is an IEC 61850 testbench built on MoonGen, not MikroTik work.
  - [germanoa/rfc2544](https://github.com/germanoa/rfc2544) (C, 9 stars, 2014)
  - [robidev/moongen-rfc2544](https://github.com/robidev/moongen-rfc2544) (Lua, 8 stars, 2022)
  - [JasonW2022/rfc2544](https://github.com/JasonW2022/rfc2544) (C AF_PACKET/TPACKET_V3, "Juniper reflect mode compatible", 2026-04-28)
  - [v0l0dia/RFC2544-tests](https://github.com/v0l0dia/RFC2544-tests) (DPDK pktgen Lua, 2020)
  - [xenanetworks/open-automation-rfc-test-suites](https://github.com/xenanetworks/open-automation-rfc-test-suites) (Xena hardware)
  - [fominmal/auto-RFC2544](https://github.com/fominmal/auto-RFC2544) (IXIA API)
  - [dakotasnapshot/rfc2544-test](https://github.com/dakotasnapshot/rfc2544-test) (PowerShell + iperf3, "RFC 2544/6349")
  - [TWN-Systems/vyos-benchmarking](https://github.com/TWN-Systems/vyos-benchmarking) (VyOS, Ansible + iperf3)
- **xmas-ar/vMark-node**: Python "open source Ethernet software-based demarcation NID", 5 stars, 2025-06-23. It has TWAMP today; "RFC2544 Service Activation testing and reflector" is only on the roadmap. — [repo](https://github.com/xmas-ar/vMark-node)
- **Lay007/network-quality-assessment**: PHP, topic y1564. A design for FPGA/SFP-timestamped SLA probes. Its README says hardware timestamp accuracy "remain[s] unqualified" and only a synthetic demo is validated. — [repo](https://github.com/Lay007/network-quality-assessment)

### Inferences
- For a MikroTik circuit, an open RFC 2544 or Y.1564 tester would mean putting a Linux box (fastlane, stem, MoonGen, JasonW2022's tool) at one end and a reflector (stem's, or JasonW2022's Juniper-reflect mode) at the other. That is the standard two-box SAT setup, not something to run on the router. Loss from a generator's own TX/RX counters would be stronger evidence than btest's software count, in line with the evidence rules of this project (hardware and per-flow counters rank above software-counted loss).
- Many 2026 repos have 0-1 stars and very recent commits (fastlane, stem, pewpewpacket, Lay007). They are young, probably small-team or single-author projects, and their RFC and Y.1564 conformance claims were not independently validated here.

### Gaps
- I did not verify the "Go Master" and "ByteBlower (Python)" implementations that fastlane's README compares itself against; no URLs are given.
- I did not check TRex's built-in NDR benchmark (trex-core) for MikroTik use. GitHub searches for "trex rfc2544" and "ndr benchmark trex" returned 0 repos.

## Q5. Winbox / Dude / netinstall-adjacent tooling, Zabbix / LibreNMS templates claiming RFC 2544

### Takeaway
None found. MikroTik Zabbix templates on GitHub are SNMP or API monitoring templates. None runs btest or claims RFC 2544. A "librenms rfc2544" repo search returned 0.

### Cited Findings
- GitHub repo searches for "mikrotik zabbix bandwidth-test" and "librenms rfc2544" returned 0 results (GitHub search API, 2026-09-30).
- Web search found only generic MikroTik Zabbix templates, with no btest or RFC 2544 content in their descriptions:
  - [Prototype-X/zabbix-templates](https://github.com/Prototype-X/zabbix-templates)
  - [XaTTa6bl4/zabbix-mikrotik](https://github.com/XaTTa6bl4/zabbix-mikrotik)
  - [welbymcroberts/zabbix-mikrotik](https://github.com/welbymcroberts/zabbix-mikrotik)
  - [CBEPX/zabbix-templates-3](https://github.com/CBEPX/zabbix-templates-3)
  - Zabbix's official integrations: [Zabbix MikroTik integration](https://www.zabbix.com/integrations/mikrotik)
- The nearest monitoring integration is hoboristi/prometheus-mikrotik-btest (Prometheus, see Q1). It measures throughput only and makes no RFC 2544 claim. — [repo](https://github.com/hoboristi/prometheus-mikrotik-btest)
- MikroWizard/MikroSpeed puts a btest-rs server into the MikroWizard management platform for on-demand tests. It measures throughput and makes no RFC 2544 claim. — [repo](https://github.com/MikroWizard/MikroSpeed)

### Inferences
- There is no public monitoring integration that turns btest results into an SLA verdict. The user's PASS/FAIL/INCONCLUSIVE/NO TEST logic has no public counterpart.

### Gaps
- I did not open the Zabbix template XML files; the "no btest" conclusion rests on descriptions and search results.
- I did not search for Dude or netinstall tooling beyond general queries, and nothing relevant surfaced.
