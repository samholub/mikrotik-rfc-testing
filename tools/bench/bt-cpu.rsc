# Does btest's cpu-load report the busiest core or the average? Runs on the generator (BENCH-NEW).
# btest to the DUT over ether2. While it runs: a background job keeps this router's peak per-core load
# and peak overall cpu-load; the DUT's t-cpu scheduler keeps the same there (cpuMax, cpuAll).
# Needs :global bCases ("conns,direction,size,bps" strings), bpw, dpw.
:global bCases
:global bpw
:global dpw
:global gCore
:global gAll
:foreach c in=$bCases do={
    :local a [:toarray $c]
    :global spd [:tonum ($a->3)]
    :set gCore 0
    :set gAll 0
    /system ssh-exec address=192.168.78.2 user=admin password=$dpw command=":global cpuMax 0; :global cpuAll 0"
    :local j [:execute {:global gCore; :global gAll; :for i from=1 to=60 do={:foreach x in=[/system resource cpu print as-value] do={:if (($x->"load") > $gCore) do={:set gCore ($x->"load")}}; :local t [/system resource get cpu-load]; :if ($t > $gAll) do={:set gAll $t}; :delay 500ms}}]
    :local lc 0
    :local rc 0
    /tool bandwidth-test address=192.168.78.2 user=admin password=$bpw protocol=udp direction=($a->1) \
        connection-count=[:tonum ($a->0)] local-udp-tx-size=[:tonum ($a->2)] remote-udp-tx-size=[:tonum ($a->2)] \
        local-tx-speed=$spd remote-tx-speed=$spd duration=15s do={
        :if ($"local-cpu-load" > $lc) do={ :set lc $"local-cpu-load" }
        :if ($"remote-cpu-load" > $rc) do={ :set rc $"remote-cpu-load" }
    }
    :do { /system script job remove $j } on-error={}
    :local d ([/system ssh-exec address=192.168.78.2 user=admin password=$dpw command=":global cpuMax; :global cpuAll; :put (\$cpuMax . \"/\" . \$cpuAll)" as-value]->"output")
    :put ("CPU case=$c btest-local=$lc gen-core=$gCore gen-all=$gAll")
    :put ("    btest-remote=$rc dut-core/all=" . [:pick $d 0 ([:len $d] - 1)])
    /system script environment remove [find name=spd]
    :delay 3s
}
