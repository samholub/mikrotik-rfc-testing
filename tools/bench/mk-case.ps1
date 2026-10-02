param([string]$Case, [string]$Mode = '1', [string]$Speed = '20', [string]$NewNth = '', [string]$FarNth = '',
      [switch]$NewDead, [switch]$FarDead, [switch]$FromFar, [string]$Out)
# One fault case for rfc-test.rsc (uploaded as script "r" on both routers; see README.md).
$sshIn = @('@(?i)(password:|yes/no[^\n]*)\s*$@/system ssh 192.168.78.2 user=admin+ct200w', '@BENCH-712\] >\s*$@{PW}')
$L = @('@\] >\s*$@', '#TIMEOUT 30')
$L += $sshIn
$L += '/ip firewall raw reset-counters [find comment~"^t-"]'
if ($FarNth) { $L += "/ip firewall raw set [find comment=`"t-drop`"] nth=$FarNth,1 disabled=no" }
if ($FarDead) { $L += '/ip firewall raw enable [find comment="t-dead"]' }
if (-not $FromFar) { $L += '@BENCH-NEW\] >\s*$@/quit' }
else {
  # stay on BENCH-712; set BENCH-NEW's rules is not needed for far-end cases
}
if (-not $FromFar) {
  $L += '/ip firewall raw reset-counters [find comment~"^t-"]'
  if ($NewNth) { $L += "/ip firewall raw set [find comment=`"t-drop`"] nth=$NewNth,1 disabled=no" }
  if ($NewDead) { $L += '/ip firewall raw enable [find comment="t-dead"]' }
}
$tgt = if ($FromFar) { '192.168.78.1' } else { '192.168.78.2' }
$me = if ($FromFar) { 'BENCH-712' } else { 'BENCH-NEW' }
$L += ":put `"=== CASE $Case ===`""
$L += '@Length \(1 or 2[^\n]*:@/system script run r'
$L += "@Speed \(Mbps\):@$Mode"
$L += "@IP address:@$Speed"
$L += "@ on $($tgt.Replace('.','\.')):@$tgt"
$L += '@Sizes \(ENTER[^\n]*:@{PW}'
$L += '#TIMEOUT 900'
$L += "@$me\] >\s*$@"
$L += '#TIMEOUT 30'
$L += '/ip firewall raw disable [find comment~"^t-d"]'
$L += ":put `"=== $me COUNTERS ===`""
$L += '/ip firewall raw print stats without-paging'
if ($FromFar) { $L += '@BENCH-NEW\] >\s*$@/quit'; $L += '/ip firewall raw disable [find comment~"^t-d"]' }
else {
  $L += $sshIn
  $L += '/ip firewall raw disable [find comment~"^t-d"]'
  $L += ':put "=== BENCH-712 COUNTERS ==="'
  $L += '/ip firewall raw print stats without-paging'
  $L += '@BENCH-NEW\] >\s*$@/quit'
}
$L | Set-Content -Path $Out -Encoding ascii
