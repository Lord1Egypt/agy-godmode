# agy-godmode Windows installer
# PowerShell 7+ required
# Usage: .\install.ps1

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$HomeDir    = $env:USERPROFILE
$SkillsDir  = "$HomeDir\.gemini\skills"
$AgyConfig  = "$HomeDir\.gemini\antigravity-cli\settings.json"
$GeminiSrc  = "$ScriptDir\GEMINI.md"
$GeminiDst  = "$HomeDir\GEMINI.md"

# ── Step 1: GEMINI.md ─────────────────────────────────────────────────────────
Write-Host "[1/4] Installing GEMINI.md to $HomeDir..."
Copy-Item $GeminiSrc $GeminiDst -Force
Write-Host "      Done — $GeminiDst"

# ── Step 2: Skills ────────────────────────────────────────────────────────────
Write-Host "[2/4] Installing skill files to $SkillsDir..."
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
Copy-Item "$ScriptDir\skills\*.md" $SkillsDir -Force
$count = (Get-ChildItem "$ScriptDir\skills\*.md").Count
Write-Host "      Done — $count skill files installed"

# ── Step 3: Inject systemPrompt into settings.json ───────────────────────────
Write-Host "[3/4] Injecting GEMINI.md into agy settings (systemPrompt)..."
New-Item -ItemType Directory -Force -Path (Split-Path $AgyConfig) | Out-Null

$content = Get-Content $GeminiSrc -Raw -Encoding UTF8

if (Test-Path $AgyConfig) {
    $raw      = Get-Content $AgyConfig -Raw -Encoding UTF8
    $settings = $raw | ConvertFrom-Json
    # Add or overwrite systemPrompt, preserve all other keys
    if ($settings.PSObject.Properties["systemPrompt"]) {
        $settings.systemPrompt = $content
    } else {
        $settings | Add-Member -NotePropertyName "systemPrompt" -NotePropertyValue $content
    }
    Write-Host "      Merged into existing settings.json"
} else {
    $settings = [PSCustomObject]@{ systemPrompt = $content }
    Write-Host "      Created new settings.json"
}

$settings | ConvertTo-Json -Depth 10 -Compress:$false | Set-Content $AgyConfig -Encoding UTF8
Write-Host "      Done — $('{0:N0}' -f (Get-Item $AgyConfig).Length) bytes written"

# ── Step 4: Verify ────────────────────────────────────────────────────────────
Write-Host "[4/4] Verifying..."
Write-Host "      GEMINI.md : $((Get-Content $GeminiDst).Count) lines"
Write-Host "      settings  : $((Get-Item $AgyConfig).Length) bytes"
Write-Host "      Skills    :"
Get-ChildItem $SkillsDir -Filter "*.md" | ForEach-Object { Write-Host "        - $($_.Name)" }

Write-Host ""
Write-Host "Setup complete. GEMINI.md loads automatically on every agy session."
Write-Host "Load a skill in any prompt: @~/.gemini/skills/rust.md <your task>"
