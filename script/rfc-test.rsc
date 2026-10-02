# RFC test: both directions at line rate, frame-size sweep. RouterOS 7 only. RUNBOOK.md explains every line.
# ---- CONFIGURATION ----
:local testUser "btest"       ;# login when picking a DC from the list
:local testPass "CHANGE_ME"
:local dcToSiteUser "admin"   ;# login when an IP is typed; its password is asked
:local briefSecs 10
:local extendedSecs 60
# btest streams, pinned: pps does not compare across stream counts.
:local connCount 20
# SLA in hundredths of a percent: 10 = 0.10%.
:local slaLimit 10
:local slaLabel "0.10"
# IP packet sizes. Each is an 18 B-larger Ethernet frame: 70, 128 ... 1500 B.
:local packetSizes {52; 110; 238; 494; 1006; 1482}
# Verdict thresholds, from bench results/btest-bench/bench-rb4011-20260925-*.txt:
# clean rates read 98.5-100.2% (10 s trials lowest); an overloaded router
# reads 100% CPU.
:local minArrivedPct 95
:local cpuLimit 90

:local servers {
    "Example DC 1"="192.0.2.10";
    "Example DC 2"="198.51.100.10"
}
# -----------------------

:local padL do={
    :local t [:tostr $v]
    :while ([:len $t] < $w) do={ :set t (" " . $t) }
    :return $t
}
:local padR do={
    :local t [:tostr $v]
    :while ([:len $t] < $w) do={ :set t ($t . " ") }
    :return $t
}
# Scaled integer to text. dec 2 for hundredths, 3 for thousandths. The fraction
# is zero-padded: 20021 kbps must read 20.021, not 20.21.
:local fmt do={
    :local d 100
    :if ($dec = 3) do={ :set d 1000 }
    :local f [:tostr (($v % $d) + $d)]
    :return ([:tostr ($v / $d)] . "." . [:pick $f 1 [:len $f]])
}

:put "===== RFC test ====="
:put ""
:put "Test length: 1 = Brief ($briefSecs s per size), 2 = Extended ($extendedSecs s per size)"
:local modeRaw [/terminal/ask prompt="Length (1 or 2, ENTER for Brief): "]
:local testSecs $briefSecs
:local modeName "Brief"
:if ($modeRaw = "2") do={
    :set testSecs $extendedSecs
    :set modeName "Extended"
} else={
    :if (([:len $modeRaw] > 0) && ($modeRaw != "1")) do={ :put "Not 1 or 2: $modeRaw. Exiting."; :error "Invalid length" }
}
:local testDuration [:totime $testSecs]

:put ""
:put "Enter test speed in Mbps. Digits only - 20, not 20M."
:local speedRaw [/terminal/ask prompt="Speed (Mbps): "]
:local circuitSpeedMbps [:tonum $speedRaw]
# nil would make the throttle 0, which btest reads as no throttle: line rate.
:if ([:typeof $circuitSpeedMbps] != "num") do={ :put "Not a number: $speedRaw. Exiting."; :error "Invalid speed" }
:if (($circuitSpeedMbps < 1) || ($circuitSpeedMbps > 100000)) do={ :put "$circuitSpeedMbps Mbps is outside 1-100000. Exiting."; :error "Invalid speed" }

:put ""
:put "Select target server:"
:local idx 1
:foreach name,ip in=$servers do={
    :put "  $idx. $name ($ip)"
    :set idx ($idx + 1)
}
:local rawPick [/terminal/ask prompt="Server (1-$($idx - 1)), or type an IP address: "]
:local targetIP ""
:local targetName ""
:if ([:typeof [:find $rawPick "."]] != "nil") do={
    :set targetIP $rawPick
    :set targetName $rawPick
    :set testUser $dcToSiteUser
    :set testPass [/terminal/ask prompt="Password for '$dcToSiteUser' on $targetIP: "]
    :if ([:len $testPass] = 0) do={ :put "No password entered. Exiting."; :error "No password" }
} else={
    :local pick [:tonum $rawPick]
    :set idx 1
    :foreach name,ip in=$servers do={
        :if ($idx = $pick) do={
            :set targetIP $ip
            :set targetName "$name ($ip)"
        }
        :set idx ($idx + 1)
    }
}
:if ($targetIP = "") do={ :put "Invalid server selection. Exiting."; :error "Invalid server selection" }

:put ""
:put "Frame sizes:"
:set idx 1
:foreach s in=$packetSizes do={
    :put "  $idx. $($s + 18) B"
    :set idx ($idx + 1)
}
:local pktChoice [/terminal/ask prompt="Sizes (ENTER for all, or e.g. 1,3,5): "]
:local selectedSizes [:toarray ""]
:if ([:len $pktChoice] = 0) do={
    :set selectedSizes $packetSizes
} else={
    # An index off the list stops the run: dropping it silently printed a
    # summary that looked complete.
    :foreach tok in=[:toarray $pktChoice] do={
        :local ci [:tonum $tok]
        :if (([:typeof $ci] != "num") || ($ci < 1) || ($ci > [:len $packetSizes])) do={
            :put "No size $tok on the list - pick 1 to $[:len $packetSizes]. Exiting."
            :error "Invalid size"
        }
        :set selectedSizes ($selectedSizes, ($packetSizes->($ci - 1)))
    }
}

# No date in the block: router clocks are often unset.
:local myName [/system/identity/get name]
# tx-queue-drop on every port, resolved once.
:local qList [:toarray ""]
:foreach e in=[/interface/ethernet/find] do={ :set qList ($qList, [/interface/find name=[/interface/ethernet/get $e name]]) }

:put ""
:put "Starting $modeName test | $circuitSpeedMbps Mbps | $testSecs s per size"
:put "Target: $targetName"

:local aF [:toarray ""]
:local aL [:toarray ""]
:local aS [:toarray ""]
:local aP [:toarray ""]
:local aW [:toarray ""]
:local aB [:toarray ""]
:local aC [:toarray ""]
:local aV [:toarray ""]

:foreach size in=$selectedSizes do={
    # On the wire: packet + 14 header + 4 FCS + 20 preamble and gap.
    :local wireSize ($size + 38)
    :local frame ($size + 18)
    # The throttle is metered on the IP packet. 99% margin, whole bytes.
    # A :global, because a :local loses its integer type in the btest argument.
    :global targetBps (((($size * $circuitSpeedMbps * 1000000) / $wireSize) * 99 / 100) / 8 * 8)
    :local askedPps ($targetBps / ($size * 8))
    # Against ROS 7 both averages count the UDP payload (size - 28), and
    # tx-total-average is what the FAR END received. See results/btest-bench/ for the bench.
    :local meter (($size - 28) * 8)
    :put ""
    :put "Running $frame B ..."

    :local totalLost 0
    :local txAvg 0
    :local rxAvg 0
    :local maxLocalCpu 0
    :local maxRemoteCpu 0
    :local maxCore 0
    :local connSeen 0
    :local latMax 0
    :local latSum 0
    :local latN 0
    :local btStatus ""
    :local ran 0
    :local qBefore [:toarray ""]
    :foreach q in=$qList do={ :set qBefore ($qBefore, [/interface/get $q tx-queue-drop]) }

    /tool/bandwidth-test address=$targetIP user=$testUser password=$testPass \
        protocol=udp direction=both local-udp-tx-size=$size remote-udp-tx-size=$size \
        duration=$testDuration connection-count=$connCount \
        local-tx-speed=$targetBps remote-tx-speed=$targetBps do={
        :set btStatus $status
        :if (($status = "running") || ($status = "done testing")) do={ :set ran 1 }
        # lost-packets is a per-interval delta, so it is summed. It counts only
        # what THIS router failed to receive.
        :set totalLost ($totalLost + $"lost-packets")
        :set txAvg $"tx-total-average"
        :set rxAvg $"rx-total-average"
        :local lc $"local-cpu-load"
        :if ($lc > $maxLocalCpu) do={ :set maxLocalCpu $lc }
        :local rc $"remote-cpu-load"
        :if ($rc > $maxRemoteCpu) do={ :set maxRemoteCpu $rc }
        # btest's CPU figures are all-core averages; one pinned core hides in them.
        :foreach c in=[/system/resource/cpu/print as-value] do={ :if (($c->"load") > $maxCore) do={ :set maxCore ($c->"load") } }
        :set connSeen $"connection-count"
        # Latency under load, one ping per callback.
        :local pv [/ping $targetIP count=1 as-value]
        :local pt [:tostr ($pv->"time")]
        :if ([:len $pt] > 14) do={
            :local us ([:tonum [:pick $pt 6 8]] * 1000000 + [:tonum [:pick $pt 9 15]])
            :set latN ($latN + 1)
            :set latSum ($latSum + $us)
            :if ($us > $latMax) do={ :set latMax $us }
        }
    }
    /system script environment remove targetBps
    # A failed login or blocked port still calls do={}, with zero rates.
    :if ($ran = 0) do={
        :put ""
        :put ("--- $frame B frame | $circuitSpeedMbps Mbps | $modeName ---")
        :put ("  Test    : $myName -> $targetIP")
        :put ("  Result  : NO TEST - btest: $btStatus")
        :put ("  ! Nothing was measured. Check the address, the login, and that")
        :put ("  ! bandwidth-server is on at the far end, then re-run.")
        :log warning ("rfc $frame B no test: $btStatus")
        :error "btest did not run"
    }

    # Named per port: drops on a port the test does not use are not the circuit.
    :local myDrops ""
    :local qi 0
    :foreach q in=$qList do={
        :local dq ([/interface/get $q tx-queue-drop] - ($qBefore->$qi))
        :if ($dq > 0) do={
            :if ([:len $myDrops] > 0) do={ :set myDrops ($myDrops . ",") }
            :set myDrops ($myDrops . " " . [/interface/get $q name] . " " . $dq)
        }
        :set qi ($qi + 1)
    }

    :local outPps ($txAvg / $meter)
    :local backPps ($rxAvg / $meter)
    :local outPct 0
    :local backPct 0
    :if ($askedPps > 0) do={
        :set outPct (($outPps * 100) / $askedPps)
        :set backPct (($backPps * 100) / $askedPps)
    }
    # The loss sum covers every second but the first, which is connecting.
    :local sent ($askedPps * ($testSecs - 1))
    # Judged in ppm so 0.1099% cannot pass a 0.10% SLA.
    :local lossPpm 0
    :if ($sent > 0) do={ :set lossPpm (($totalLost * 1000000) / $sent) }
    :local loss100 ($lossPpm / 100)
    :local cpuMax $maxLocalCpu
    :if ($maxRemoteCpu > $cpuMax) do={ :set cpuMax $maxRemoteCpu }
    :if ($maxCore > $cpuMax) do={ :set cpuMax $maxCore }

    :local vd "PASS"
    :if (($lossPpm > ($slaLimit * 100)) || ($outPct < $minArrivedPct) || ($backPct < $minArrivedPct)) do={ :set vd "FAIL" }
    # A router at its limit also loses packets itself (bench: 1.9% on a clean
    # link at 100% CPU), so a FAIL there may not be the circuit.
    :if (($vd = "FAIL") && ($cpuMax >= $cpuLimit)) do={ :set vd "INCONCLUSIVE" }

    :local latS "no replies"
    :if ($latN > 0) do={ :set latS ([$fmt v=(($latSum / $latN) / 10) dec=2] . " avg, " . [$fmt v=($latMax / 10) dec=2] . " max ms") }
    :put ""
    :put ("--- $frame B frame | $circuitSpeedMbps Mbps | $modeName ---")
    :put ("  Test    : $myName -> $targetIP")
    :put ("  Arrived : far end got $outPct% | $backPct% came back")
    :put ("  Rate    : " . [$fmt v=(($outPps * $wireSize * 8) / 1000) dec=3] . " Mbps out | " . [$fmt v=(($backPps * $wireSize * 8) / 1000) dec=3] . " Mbps back (L1)")
    :put ("  Lost    : $totalLost of $sent coming back (" . [$fmt v=$loss100 dec=2] . "%), SLA $slaLabel%")
    :put ("  CPU     : this router $maxLocalCpu% (busiest core $maxCore%) | far end $maxRemoteCpu%")
    :put ("  Latency : $latS")
    :put ("  Note    : loss is counted coming back; outbound only for big loss")
    # A ROS 6 far end counts on the IP packet: Out% reads size/(size-28), 216% at 70 B.
    :if ($outPct > 110) do={ :put ("  Note    : far end looks like ROS 6 - Out% is not meaningful") }
    :put ("  Result  : $vd")
    :if ($vd != "PASS") do={
        :if ($outPct < $minArrivedPct) do={ :put ("  ! Only $outPct% arrived at the far end") }
        :if ($backPct < $minArrivedPct) do={ :put ("  ! Only $backPct% came back") }
        :if ($lossPpm > ($slaLimit * 100)) do={ :put ("  ! Loss coming back is over the SLA") }
    }
    :if ($vd = "FAIL") do={ :put ("  ! Confirm from the other end before escalating") }
    :if ($vd = "INCONCLUSIVE") do={
        :put ("  ! A router reached $cpuMax% CPU - that can cause this loss.")
        :put ("  ! Lower the speed or skip the small frames, then re-run")
    }
    :if ([:len $myDrops] > 0) do={ :put ("  ! This router dropped frames in its own queues:$myDrops") }
    :if ($connSeen != $connCount) do={ :put ("  ! btest used $connSeen streams, not $connCount") }
    :log info ("rfc $frame B lost=$totalLost of $sent out=$outPct back=$backPct cpu=$maxLocalCpu/$maxCore/$maxRemoteCpu $vd")

    :set aF ($aF, $frame)
    :set aL ($aL, $totalLost)
    :set aS ($aS, $sent)
    :set aP ($aP, $loss100)
    :set aW ($aW, $outPct)
    :set aB ($aB, $backPct)
    :set aC ($aC, $cpuMax)
    :set aV ($aV, $vd)
    :delay 3s
}

:put ""
:put "==========================================================================="
:put ("  SUMMARY | $myName -> $targetIP | $circuitSpeedMbps Mbps | $modeName")
:put "==========================================================================="
:put ("  " . [$padR v="Frame" w=8] . [$padL v="Lost" w=8] . [$padL v="Sent" w=11] . [$padL v="Loss%" w=8] . [$padL v="Out%" w=6] . [$padL v="Back%" w=7] . [$padL v="CPU%" w=6] . [$padL v="Result" w=14])
:local nPass 0
:local nFail 0
:local nInc 0
:local passLost 0
:local passSent 0
:for i from=0 to=([:len $aF] - 1) do={
    :local vd ($aV->$i)
    :if ($vd = "PASS") do={
        :set nPass ($nPass + 1)
        :set passLost ($passLost + ($aL->$i))
        :set passSent ($passSent + ($aS->$i))
    }
    :if ($vd = "FAIL") do={ :set nFail ($nFail + 1) }
    :if ($vd = "INCONCLUSIVE") do={ :set nInc ($nInc + 1) }
    :put ("  " . [$padR v=(($aF->$i) . " B") w=8] . [$padL v=($aL->$i) w=8] . [$padL v=($aS->$i) w=11] . [$padL v=[$fmt v=($aP->$i) dec=2] w=8] . [$padL v=($aW->$i) w=6] . [$padL v=($aB->$i) w=7] . [$padL v=($aC->$i) w=6] . [$padL v=$vd w=14])
}
:put "---------------------------------------------------------------------------"
:if ($nPass > 0) do={
    :local ap 0
    :if ($passSent > 0) do={ :set ap (($passLost * 10000) / $passSent) }
    :put ("  PASS: $nPass size(s), $passLost lost of $passSent = " . [$fmt v=$ap dec=2] . "% (SLA $slaLabel%)")
}
:if ($nFail > 0) do={
    :put "  FAIL: $nFail size(s). Confirm by running the same test FROM $targetIP"
    :put "  before escalating. Escalate only what both ends agree on."
}
:if ($nInc > 0) do={
    :put "  INCONCLUSIVE: $nInc size(s). A router hit its CPU limit, so the loss"
    :put "  may not be the circuit. Not a pass. Lower the speed and re-run."
}
:put "  Loss is counted coming back. Outbound is only checked for big loss"
:put "  (under $minArrivedPct% arriving). To judge outbound at the SLA, run from $targetIP."
:put "==========================================================================="
