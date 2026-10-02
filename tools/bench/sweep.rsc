# Bench sweep: clean out/back rate precision. Needs :global bpw, sweepSpeeds, sweepSizes, sweepTag, sweepDur.
:global bpw
:global sweepSpeeds
:global sweepSizes
:global sweepTag
:global sweepDur
:foreach sp in=$sweepSpeeds do={
    :foreach sz in=$sweepSizes do={
        :global tb (((($sz * $sp * 1000000) / ($sz + 38)) * 99 / 100) / 8 * 8)
        :local s 0
        :local n 0
        :local tx 0
        :local rx 0
        :local lc 0
        :local rc 0
        /tool/bandwidth-test address=192.168.78.2 user=admin password=$bpw protocol=udp direction=both \
            local-udp-tx-size=$sz remote-udp-tx-size=$sz duration=$sweepDur connection-count=20 \
            local-tx-speed=$tb remote-tx-speed=$tb do={
            :set s ($s + $"lost-packets")
            :set n ($n + 1)
            :set tx $"tx-total-average"
            :set rx $"rx-total-average"
            :if ($"local-cpu-load" > $lc) do={ :set lc $"local-cpu-load" }
            :if ($"remote-cpu-load" > $rc) do={ :set rc $"remote-cpu-load" }
        }
        :local ap ($tb / ($sz * 8))
        :local m (($sz - 28) * 8)
        :put ("SW $sweepTag sp=$sp sz=$sz asked=$ap fwd10k=" . ((($tx / $m) * 10000) / $ap) . " back10k=" . ((($rx / $m) * 10000) / $ap) . " lost=$s cb=$n cpu=$lc/$rc")
        /system script environment remove [find name="tb"]
        :delay 2s
    }
}
