param(
  [Parameter(Mandatory)][string]$CmdFile,
  [int]$Timeout = 120,
  [string]$Log = ''
)
# Drives BENCH-NEW's serial console on COM3. Password from $env:BENCHPW only;
# {PW} in a command is replaced at send time and the password is redacted from output.
# Line forms:
#   text              send, wait for a RouterOS prompt "] >"
#   @regex@text       send, wait for regex (for /terminal/ask and ssh prompts)
#   #WAIT n           sleep n seconds
#   #TIMEOUT n        per-command timeout from here on
$ErrorActionPreference = 'Stop'
$pw = $env:BENCHPW
if (-not $pw) { $pw = [Environment]::GetEnvironmentVariable('BENCHPW', 'User') }
$p = New-Object System.IO.Ports.SerialPort 'COM3',115200,'None',8,'One'
$p.ReadTimeout = 200; $p.WriteTimeout = 20000; $p.Open()
$buf = New-Object System.Text.StringBuilder
function Pump { try { [void]$buf.Append($p.ReadExisting()) } catch {} }
function WaitFor([string]$rx, [int]$secs) {
  $end = (Get-Date).AddSeconds($secs)
  while ((Get-Date) -lt $end) { Pump; if ($buf.ToString() -match $rx) { return $true }; Start-Sleep -Milliseconds 250 }
  return $false
}
function Emit {
  $out = $buf.ToString() -replace "`e\[[0-9;?]*[A-Za-z]",'' -replace "`r",''
  # The console redraws a long line in pieces, so redact any 5+ char run of the password too.
  if ($pw) {
    for ($n = $pw.Length; $n -ge [Math]::Min(5, $pw.Length); $n--) {
      for ($i = 0; $i + $n -le $pw.Length; $i++) { $out = $out.Replace($pw.Substring($i, $n), '***') }
    }
  }
  Write-Output $out
  if ($Log) { Add-Content -Path $Log -Value $out -Encoding utf8 }
  [void]$buf.Clear()
}
function SendSlow([string]$s) {
  # 256-byte slices: the RouterOS line editor drops input when flooded.
  for ($i = 0; $i -lt $s.Length; $i += 256) {
    $p.Write($s.Substring($i, [Math]::Min(256, $s.Length - $i))); Start-Sleep -Milliseconds 60; Pump
  }
}
$prompt = '\] >\s*$'
$p.Write("`r"); Start-Sleep 1; Pump
if ($buf.ToString() -notmatch $prompt) {
  if ($buf.ToString() -notmatch 'Login:\s*$') { $p.Write("`r"); [void](WaitFor 'Login:\s*$' 10) }
  $p.Write("admin+ct200w`r"); [void](WaitFor 'Password:\s*$' 10)
  $p.Write("$pw`r")
  if (-not (WaitFor $prompt 30)) { $p.Write("`r"); [void](WaitFor $prompt 10) }
}
[void]$buf.Clear()
foreach ($line in Get-Content $CmdFile) {
  if ($line -match '^#WAIT (\d+)') { Start-Sleep ([int]$Matches[1]); continue }
  if ($line -match '^#TIMEOUT (\d+)') { $Timeout = [int]$Matches[1]; continue }
  if ($line.Trim() -eq '' -or $line.StartsWith('#')) { continue }
  $wait = $prompt; $text = $line
  if ($line -match '^@(.*?)@(.*)$') { $wait = $Matches[1]; $text = $Matches[2] }
  $text = $text.Replace('{PW}', $pw)
  SendSlow "$text`r"
  Start-Sleep -Milliseconds 300
  if (-not (WaitFor $wait $Timeout)) { [void]$buf.Append("`n<<TIMEOUT waiting for /$wait/>>`n") }
  Emit
}
$p.Close()
