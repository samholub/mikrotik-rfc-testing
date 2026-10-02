# btest meter check: what btest's throttle and averages count, against interface counters at both ends.
# Runs on the generator: UDP btest, direction=transmit, to the DUT's ether3 address, 10 s per size, throttle
# set for 10000 pps if it meters the IP packet. Needs :global bSizes, bTarget, bpw, dpw; DUT ether3 addressed.
:global bSizes
:global bTarget
:global bpw
:global dpw
:local dutSnap ":global mi [/interface get ether3]; :global me [/interface ethernet get ether3]"
:local dutDelta ":global mi; :global me; :local i [/interface get ether3]; :local e [/interface ethernet get ether3]; :local p ((\$i->\"rx-packet\") - (\$mi->\"rx-packet\")); :put (\"pkts=\" . \$p . \" if=\" . (((\$i->\"rx-byte\") - (\$mi->\"rx-byte\")) / \$p) . \" drv=\" . (((\$e->\"driver-rx-byte\") - (\$me->\"driver-rx-byte\")) / ((\$e->\"driver-rx-packet\") - (\$me->\"driver-rx-packet\"))))"
:foreach sz in=$bSizes do={
    :global spd ($sz * 8 * 10000)
    :local i0 [/interface get ether3]
    /system ssh-exec address=192.168.78.2 user=admin password=$dpw command=$dutSnap
    :local tx 0
    :local n 0
    /tool bandwidth-test address=$bTarget user=admin password=$bpw protocol=udp direction=transmit local-udp-tx-size=$sz local-tx-speed=$spd duration=10s do={
        :set tx $"tx-total-average"
        :set n ($n + 1)
    }
    :delay 2s
    :local i1 [/interface get ether3]
    :local dd ([/system ssh-exec address=192.168.78.2 user=admin password=$dpw command=$dutDelta as-value]->"output")
    :local gp (($i1->"tx-packet") - ($i0->"tx-packet"))
    :put ("BT size=$sz throttle=$spd txavg=$tx cb=$n gen: pkts=$gp if=" . ((($i1->"tx-byte") - ($i0->"tx-byte")) / $gp))
    :put ("  dut: " . [:pick $dd 0 ([:len $dd] - 1)])
    /system script environment remove [find name=spd]
}
