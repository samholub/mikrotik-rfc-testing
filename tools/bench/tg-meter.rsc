# Meter check: what each RouterOS counter counts per packet. Runs on the generator.
# One traffic-generator stream (the only enabled one) out ether3 to the DUT's ether3, ~5 s.
# Reads, at both ends: /interface bytes+packets, ethernet driver bytes+packets, switch-chip bytes+unicast,
# and monitor-traffic bits/s per packet/s mid-run. Prints bytes per packet for each.
# The DUT computes its own ratios (long ssh-exec output lines wrap and break parsing).
# Needs :global mStream, mSizes (packet-size list), mPps, mTag, dpw.
:global mStream
:global mSizes
:global mPps
:global mTag
:global dpw
:local dutSnap ":global mi [/interface get ether3]; :global me [/interface ethernet get ether3]"
:local dutDelta ":global mi; :global me; :local i [/interface get ether3]; :local e [/interface ethernet get ether3]; :local p ((\$i->\"rx-packet\") - (\$mi->\"rx-packet\")); :put (\"pkts=\" . \$p . \" if=\" . (((\$i->\"rx-byte\") - (\$mi->\"rx-byte\")) / \$p) . \" drv=\" . (((\$e->\"driver-rx-byte\") - (\$me->\"driver-rx-byte\")) / ((\$e->\"driver-rx-packet\") - (\$me->\"driver-rx-packet\"))) . \" sw=\" . (((\$e->\"rx-bytes\") - (\$me->\"rx-bytes\")) / ((\$e->\"rx-unicast\") - (\$me->\"rx-unicast\"))))"
:local dutMon ":local m [/interface monitor-traffic ether3 once as-value]; :put (\" mon=\" . ((\$m->\"rx-bits-per-second\") / (\$m->\"rx-packets-per-second\") / 8) . \" monpps=\" . (\$m->\"rx-packets-per-second\"))"
:foreach sz in=$mSizes do={
    /tool traffic-generator stream set [find name=$mStream] packet-size=$sz pps=$mPps
    :local i0 [/interface get ether3]; :local e0 [/interface ethernet get ether3]
    /system ssh-exec address=192.168.78.2 user=admin password=$dpw command=$dutSnap
    /tool traffic-generator start
    :delay 3s
    :local gm [/interface monitor-traffic ether3 once as-value]
    :local dm ([/system ssh-exec address=192.168.78.2 user=admin password=$dpw command=$dutMon as-value]->"output")
    :delay 2s
    /tool traffic-generator stop
    :delay 2s
    :local i1 [/interface get ether3]; :local e1 [/interface ethernet get ether3]
    :local dd ([/system ssh-exec address=192.168.78.2 user=admin password=$dpw command=$dutDelta as-value]->"output")
    :local gp (($i1->"tx-packet") - ($i0->"tx-packet"))
    :put ("M $mTag size=$sz gen: pkts=$gp if=" . ((($i1->"tx-byte") - ($i0->"tx-byte")) / $gp) . " drv=" . ((($e1->"driver-tx-byte") - ($e0->"driver-tx-byte")) / (($e1->"driver-tx-packet") - ($e0->"driver-tx-packet"))) . " sw=" . ((($e1->"tx-bytes") - ($e0->"tx-bytes")) / (($e1->"tx-unicast") - ($e0->"tx-unicast"))) . " mon=" . (($gm->"tx-bits-per-second") / ($gm->"tx-packets-per-second") / 8))
    :put ("  dut: " . [:pick $dd 0 ([:len $dd] - 1)] . [:pick $dm 0 ([:len $dm] - 1)])
}
