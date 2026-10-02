# Capacity sweep: highest pps per frame size with loss under tgLimit ppm. Runs on the generator.
# Needs :global tgStream, tgFrames (true frame sizes incl FCS), tgDur, tgConf, tgMax (generator
# cap, pps), tgLimit (ppm, 1000 = 0.1%), tgTag, dpw (DUT password, session only).
# DUT needs scheduler t-cpu keeping :global cpuMax (peak per-core load).
:global tgStream
:global tgFrames
:global tgDur
:global tgConf
:global tgMax
:global tgLimit
:global tgTag
:global dpw
:global cpuPk
:local trial do={
    :global tgStream
    :global dpw
    :global cpuPk
    /tool traffic-generator stream set [find name=$tgStream] packet-size=$sz pps=$pps
    :do { /system ssh-exec address=192.168.78.2 user=admin password=$dpw command=":global cpuMax 0" } on-error={}
    :set cpuPk 0
    :local j [:execute {:global cpuPk; :for i from=1 to=400 do={:foreach c in=[/system resource cpu print as-value] do={:if (($c->"load") > $cpuPk) do={:set cpuPk ($c->"load")}}; :delay 500ms}}]
    :local r [/tool traffic-generator quick stream=$tgStream duration=$dur entries-to-show=255 measure-out-of-order=yes as-value]
    :do { /system script job remove $j } on-error={}
    :local d "?"
    :do { :set d ([/system ssh-exec address=192.168.78.2 user=admin password=$dpw command=":global cpuMax; :put \$cpuMax" as-value]->"output") } on-error={}
    :local res
    :local secs 0
    :foreach row in=$r do={ :if (($row->"seq") != "TOT") do={ :set secs ($secs + 1) } }
    :foreach row in=$r do={
        :if (($row->"seq") = "TOT") do={
            :local tx ($row->"tx-packet")
            :local lost ($tx - ($row->"rx-packet"))
            :if ($lost < 0) do={ :set lost 0 }
            :local sent ($tx / $secs)
            :set res {tx=$tx; sent=$sent; short=($sent < ($pps * 99 / 100)); lost=$lost; ppm=(($lost * 1000000) / $tx); ooo=($row->"rx-ooo"); lat=(($row->"lat-avg") . "/" . ($row->"lat-max")); jit=($row->"jitter"); gcpu=$cpuPk; dcpu=[:pick $d 0 ([:len $d] - 1)]}
        }
    }
    :put ("  t sz=$sz ask=$pps sent=" . ($res->"sent") . " lost=" . ($res->"lost") . " ppm=" . ($res->"ppm") . " cpu=" . ($res->"gcpu") . "/" . ($res->"dcpu") . " short=" . ($res->"short"))
    :set ($res->"pass") ((($res->"ppm") < $lim) && !($res->"short"))
    :return $res
}
:foreach f in=$tgFrames do={
    :local sz ($f - 4)
    :local line (1000000000 / (($f + 20) * 8))
    :local cap $line
    :if ($tgMax < $cap) do={ :set cap $tgMax }
    :local best $cap
    :local r [$trial sz=$sz pps=$cap dur=$tgDur lim=$tgLimit]
    :if (!($r->"pass")) do={
        :local lo 0
        :local hi $cap
        :while (($hi - $lo) > ($line / 100)) do={
            :local mid (($lo + $hi) / 2)
            :set r [$trial sz=$sz pps=$mid dur=$tgDur lim=$tgLimit]
            :if ($r->"pass") do={ :set lo $mid } else={ :set hi $mid }
        }
        :set best $lo
    }
    :local ok false
    :local n 0
    :while ((!$ok) && ($n < 4) && ($best > 0)) do={
        :set r [$trial sz=$sz pps=$best dur=$tgConf lim=$tgLimit]
        :if ($r->"pass") do={ :set ok true } else={ :set best ($best * 98 / 100); :set n ($n + 1) }
    }
    :local s ($r->"sent")
    :put ("CAP $tgTag f=$f pps=$s line%=" . ($s * 100 / $line) . " mbps=" . ($s * $f * 8 / 1000000) . " ok=$ok")
    :put ("    ppm=" . ($r->"ppm") . " ooo=" . ($r->"ooo") . " lat=" . ($r->"lat") . " jit=" . ($r->"jit") . " cpu=" . ($r->"gcpu") . "/" . ($r->"dcpu"))
}
