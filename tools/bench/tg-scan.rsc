# Loss-vs-rate scan: fixed rates, repeated, one frame size. Runs on the generator.
# Needs :global tgStream, tgFrame (incl FCS), tgRates (pps list), tgReps, tgDur, tgTag, dpw.
# Same trial as tg-sweep.rsc; shows whether loss rises steadily with rate.
:global tgStream
:global tgFrame
:global tgRates
:global tgReps
:global tgDur
:global tgTag
:global dpw
:global cpuPk
:local sz ($tgFrame - 4)
:foreach pps in=$tgRates do={
    :for k from=1 to=$tgReps do={
        /tool traffic-generator stream set [find name=$tgStream] packet-size=$sz pps=$pps
        :do { /system ssh-exec address=192.168.78.2 user=admin password=$dpw command=":global cpuMax 0" } on-error={}
        :set cpuPk 0
        :local j [:execute {:global cpuPk; :for i from=1 to=400 do={:foreach c in=[/system resource cpu print as-value] do={:if (($c->"load") > $cpuPk) do={:set cpuPk ($c->"load")}}; :delay 500ms}}]
        :local r [/tool traffic-generator quick stream=$tgStream duration=$tgDur entries-to-show=255 as-value]
        :do { /system script job remove $j } on-error={}
        :local d "?"
        :do { :set d ([/system ssh-exec address=192.168.78.2 user=admin password=$dpw command=":global cpuMax; :put \$cpuMax" as-value]->"output") } on-error={}
        :local secs 0
        :foreach row in=$r do={ :if (($row->"seq") != "TOT") do={ :set secs ($secs + 1) } }
        :foreach row in=$r do={
            :if (($row->"seq") = "TOT") do={
                :local tx ($row->"tx-packet")
                :local lost ($tx - ($row->"rx-packet"))
                :if ($lost < 0) do={ :set lost 0 }
                :put ("SC $tgTag f=$tgFrame ask=$pps sent=" . ($tx / $secs) . " ppm=" . (($lost * 1000000) / $tx) . " cpu=$cpuPk/" . [:pick $d 0 ([:len $d] - 1)])
            }
        }
    }
}
