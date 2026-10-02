# Bench tools

How the `results/btest-bench/bench-rb4011-*` runs were made. Two RB4011s, ether2 to ether2:
BENCH-NEW 192.168.78.1 and BENCH-712 192.168.78.2. A USB serial cable on COM3
goes to BENCH-NEW; BENCH-712 is reached by SSH from it over the test cable.

The admin password is never stored. Set it for the session only:

```powershell
$env:BENCHPW = '<password>'
```

If `BENCHPW` is not set in the session, `ros.ps1` reads it from the Windows user
environment. The password and any 5+ character piece of it are redacted from
output, because the console redraws long lines in pieces. Never put it on a long
command line; answer a prompt with `{PW}` instead.

| File | What it does |
|---|---|
| `ros.ps1` | Runs a command file on BENCH-NEW's console. One command per line; `@regex@text` sends text and waits for a prompt; `{PW}` is replaced with the password; the password is redacted from output. |
| `mk-upload.ps1` | Turns a `.rsc` into a command file that loads it as a router script. |
| `mk-case.ps1` | Writes one fault case: drop rules on, run script `r`, counters printed, rules off. |
| `sweep.rsc` | Clean-link sweep of the Out/Back rate figures. |

Typical run:

```powershell
# Upload the script with the btest password blanked (the typed-IP path doesn't use it)
(Get-Content ..\..\rfc-test.rsc -Raw) -replace ':local testPass "[^"]*"', ':local testPass "x"' | Set-Content r.rsc -NoNewline
.\mk-upload.ps1 -Src r.rsc -Name r -Out up.txt
.\ros.ps1 -CmdFile up.txt

# A case needs disabled rules named t-drop and t-dead on the receiving router's ether2 raw prerouting
.\mk-case.ps1 -Case clean -Out case.txt
.\ros.ps1 -CmdFile case.txt -Log case.log
```

Clean up afterwards: remove the `t-*` raw rules and the `r` script on both
routers.

## Capacity sweeps (results/rb4011-capacity/)

| File | What it does |
|---|---|
| `tg-probe.rsc` | One traffic-generator run per size at a fixed pps, with generator CPU and bytes per packet. |
| `tg-scan.rsc` | Loss at fixed rates, repeated (3 x 10 s by default). The method for every result after phase 1: loss is not monotonic in rate, so a binary search can land anywhere. |
| `tg-sweep.rsc` | Phase 1 only. Highest pps per frame size at < 0.1% loss: line-rate try, binary search, 60 s confirm. Reads DUT CPU via `/system ssh-exec` from a `t-cpu` scheduler on the DUT. |

Roles: BENCH-NEW generates (traffic-gen `quick` is refused over SSH on 7.20.7 by device-mode),
BENCH-712 is the DUT. Cables ether3-3, ether4-4, ether7-7. `packet-size` excludes FCS (64 B frame =
60). Use `entries-to-show=255` or `quick ... as-value` keeps only ~20 rows. Give a one-way flow
static bridge hosts on the DUT, or it floods and loads the DUT CPU.
Tunnels: traffic-gen finds its footer inside EoIP/VXLAN/VPLS, so the generator counts encapsulated
packets on its raw port without terminating the tunnel. Encrypted traffic hides it: for EoIP+IPsec,
bind a traffic-gen port to the generator's own EoIP interface (the generator then decrypts too).
`/system logging` takes no `comment=`; a queue-tree leaf needs `packet-mark=no-mark` to match anything.

`bt-cpu.rsc` compares btest's CPU figures with per-core loads at both ends
(`results/btest-bench/bench-rb4011-20261002-btest-cpu.txt`).

Meter checks (`results/rb4011-capacity/bench-rb4011-20261002-meter-layers.txt`): `tg-meter.rsc` reads every byte
counter at both ends for a traffic-gen stream; `bt-meter.rsc` does the same for UDP btest. Sniffer on the
DUT for structure: `memory-limit` is in bytes, and a capture started through `ssh-exec` stops when that
session closes, so start it inside an interactive SSH session.
