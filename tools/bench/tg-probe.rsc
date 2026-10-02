# Traffic-generator probe: one quick run per size at a fixed pps. Runs on the generator.
# Needs :global tgStream, tgPort (interface), tgSizes, tgPps, tgDur, tgTag.
:global tgStream
:global tgPort
:global tgSizes
:global tgPps
:global tgDur
:global tgTag
:global cpuPk
:foreach sz in=$tgSizes do={
    /tool traffic-generator stream set [find name=$tgStream] packet-size=$sz pps=$tgPps
    :local b0 [/interface get $tgPort tx-byte]
    :local p0 [/interface get $tgPort tx-packet]
    :set cpuPk 0
    :local j [:execute {:global cpuPk; :for i from=1 to=200 do={:foreach c in=[/system resource cpu print as-value] do={:if (($c->"load") > $cpuPk) do={:set cpuPk ($c->"load")}}; :delay 500ms}}]
    :local r [/tool traffic-generator quick stream=$tgStream duration=$tgDur measure-out-of-order=yes as-value]
    :do { /system script job remove $j } on-error={}
    :local b1 [/interface get $tgPort tx-byte]
    :local p1 [/interface get $tgPort tx-packet]
    :foreach row in=$r do={
        :if (($row->"seq") = "TOT") do={
            :local tx ($row->"tx-packet")
            :put ("PR $tgTag sz=$sz asked=$tgPps tx=$tx rx=" . ($row->"rx-packet") . " lost=" . ($row->"lost-packet"))
            :put ("   ooo=" . ($row->"rx-ooo") . " txpps=" . ($tx / $tgDur) . " cpu=$cpuPk bpp=" . (($b1 - $b0) / ($p1 - $p0)))
            :put ("   lat=" . ($row->"lat-min") . "/" . ($row->"lat-avg") . "/" . ($row->"lat-max") . " jit=" . ($row->"jitter"))
        }
    }
    :delay 2s
}
