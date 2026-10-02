param([Parameter(Mandatory)][string]$Src, [Parameter(Mandatory)][string]$Name, [Parameter(Mandatory)][string]$Out)
# Builds a console command file that recreates $Src as /system script $Name, 700 source chars per line.
$t = [IO.File]::ReadAllText($Src) -replace "`r`n", "`n"
$esc = { param($s) $s.Replace('\','\\').Replace('"','\"').Replace('$','\$').Replace('?','\?').Replace("`t",'\t').Replace("`n",'\n') }
$lines = @('@\] >\s*$@', '#TIMEOUT 30', "/system script remove [find name=$Name]", "/system script add name=$Name source=`"`"")
for ($i = 0; $i -lt $t.Length; $i += 700) {
  $chunk = & $esc $t.Substring($i, [Math]::Min(700, $t.Length - $i))
  $lines += "/system script set $Name source=([/system script get $Name source] . `"$chunk`")"
}
$lines += ":put (`"LEN `" . [:len [/system script get $Name source]] . `" EXPECT $($t.Length)`")"
$lines | Set-Content -Path $Out -Encoding ascii
