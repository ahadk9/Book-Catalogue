# ============================================
# POWERSHELL 7 - ENHANCED DEVELOPER PROFILE
# ============================================
# Optimized for PS7 with Predictive IntelliSense
# Theme: Catppuccin Mocha (aesthetic & professional)
# Modern CLI Tools: eza, fd, rg, fzf, zoxide, bat, delta, jq, duf

# DEBUG: Profile timing (uncomment to diagnose)
# $global:ProfileTimer = [System.Diagnostics.Stopwatch]::StartNew()
# function Time-Section($name) { Write-Host "$name: $($global:ProfileTimer.ElapsedMilliseconds)ms" -ForegroundColor Yellow }

# ============================================
# PATH SETUP - WINGET PACKAGES (OPTIMIZED)
# ============================================
# Cache PATH setup to avoid slow startup (runs once per session)
$wingetLinks = "$env:LOCALAPPDATA\Microsoft\WinGet\Links"

# Add winget links directory (fastest method)
if (Test-Path $wingetLinks) {
    if ($env:Path -notlike "*$wingetLinks*") {
        $env:Path = "$wingetLinks;$env:Path"
    }
}

# Add eza from WinGet Packages (for VS Code terminals)
$ezaPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\eza-community.eza_Microsoft.Winget.Source_8wekyb3d8bbwe"
if ((Test-Path $ezaPath) -and ($env:Path -notlike "*$ezaPath*")) {
    $env:Path = "$ezaPath;$env:Path"
}

# Add zoxide from WinGet Packages (for VS Code terminals)
$zoxidePath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\ajeetdsouza.zoxide_Microsoft.Winget.Source_8wekyb3d8bbwe"
if ((Test-Path $zoxidePath) -and ($env:Path -notlike "*$zoxidePath*")) {
    $env:Path = "$zoxidePath;$env:Path"
}

# Add bat from WinGet Packages (for VS Code terminals) - includes versioned subfolder
$batBasePath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\sharkdp.bat_Microsoft.Winget.Source_8wekyb3d8bbwe"
$batExe = Get-ChildItem $batBasePath -Filter "bat.exe" -Recurse -EA 0 | Select-Object -First 1
if ($batExe -and ($env:Path -notlike "*$($batExe.DirectoryName)*")) {
    $env:Path = "$($batExe.DirectoryName);$env:Path"
}

# Add fd from WinGet Packages (for VS Code terminals) - includes versioned subfolder
$fdBasePath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\sharkdp.fd_Microsoft.Winget.Source_8wekyb3d8bbwe"
$fdExe = Get-ChildItem $fdBasePath -Filter "fd.exe" -Recurse -EA 0 | Select-Object -First 1
if ($fdExe -and ($env:Path -notlike "*$($fdExe.DirectoryName)*")) {
    $env:Path = "$($fdExe.DirectoryName);$env:Path"
}

# Skip expensive tool path search - assume tools are in winget links
# If tools not found, they'll fail gracefully when used

# Add HTTPie if available (quick check)
$httpiePath = "$env:LOCALAPPDATA\Programs\HTTPie"
if ((Test-Path $httpiePath) -and ($env:Path -notlike "*$httpiePath*")) {
    $env:Path = "$httpiePath;$env:Path"
}

# Add Python Scripts (for pylsp, black, etc. - needed by Kate LSP)
$pyScriptsPath = "$env:LOCALAPPDATA\Packages\PythonSoftwareFoundation.Python.3.13_qbz5n2kfra8p0\LocalCache\local-packages\Python313\Scripts"
if ((Test-Path $pyScriptsPath) -and ($env:Path -notlike "*$pyScriptsPath*")) {
    $env:Path = "$pyScriptsPath;$env:Path"
}

# ============================================
# OH MY POSH - BEAUTIFUL PROMPT (CACHED)
# ============================================
# Cache oh-my-posh init output to speed up startup (regenerate if theme changes)
$themePath = "$HOME\Documents\PowerShell\catppuccin.omp.json"
$ompCache = "$HOME\Documents\PowerShell\.omp-cache.ps1"

if (Test-Path $themePath) {
    # Regenerate cache if theme is newer than cache or cache doesn't exist
    if (-not (Test-Path $ompCache) -or (Get-Item $themePath).LastWriteTime -gt (Get-Item $ompCache).LastWriteTime) {
        oh-my-posh init pwsh --config $themePath | Out-File $ompCache -Encoding utf8
    }
    # Load from cache (much faster than running oh-my-posh init every time)
    . $ompCache
}

# ============================================
# TERMINAL-ICONS (Lazy Load - load on first ls only)
# ============================================
$global:IconsLoaded = $false
function Load-Icons-Once {
    if (-not $global:IconsLoaded) {
        Import-Module Terminal-Icons -ErrorAction SilentlyContinue
        # Small delay to let terminal recognize format updates
        Start-Sleep -Milliseconds 100
        $global:IconsLoaded = $true
    }
}

# ============================================
# PSREADLINE - SMART COMPLETIONS (Plugin First!)
# ============================================
# Import CompletionPredictor for smart predictions (only if not already loaded)
if (-not (Get-Module CompletionPredictor)) {
    Import-Module CompletionPredictor -ErrorAction SilentlyContinue
}

# Default: Use ONLY Plugin source (CompletionPredictor) - no history cluttering completions!
# This makes [Completion] entries appear FIRST (and only) for file/dir commands
Set-PSReadLineOption -PredictionSource Plugin -PredictionViewStyle ListView -EditMode Windows -BellStyle None

# TAB = Immediately show directory/file completions (bypasses predictions)
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Commands that should show ONLY completions (Plugin), not history
$global:CompletionOnlyCommands = @(
    'cd', 'Set-Location', 'Push-Location', 'mkcd',  # Navigation
    'bat', 'bat.exe', 'cat', 'catp', 'catr',        # File viewing
    'code', 'code-insiders', 'ci', 'npp', 'notepad', 'edit', 'vim', 'vi', 'nano',  # Editors
    'rm', 'rmrf', 'Remove-Item', 'del',             # File operations
    'cp', 'Copy-Item', 'mv', 'Move-Item',           # File operations
    'Get-Content', 'Set-Content', 'Out-File'        # File content
)

# Dynamic prediction source switching based on current command
Set-PSReadLineKeyHandler -Chord ' ' -ScriptBlock {
    # Get current line
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    
    # Check if command is in CompletionOnly list
    $cmd = ($line -split '\s+')[0]
    
    if ($global:CompletionOnlyCommands -contains $cmd) {
        # Switch to Plugin only (completions only, no history)
        Set-PSReadLineOption -PredictionSource Plugin
    } else {
        # Use both history and plugin for other commands
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    }
    
    # Insert the space
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
}

# Reset to Plugin on Enter (for next command)
Set-PSReadLineKeyHandler -Chord Enter -ScriptBlock {
    Set-PSReadLineOption -PredictionSource Plugin
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# Also exclude these from history predictions (backup)
Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $line = $line.TrimStart()
    # Save to history file but exclude from predictions for these patterns
    if ($line -match '^(cd|bat|cat|catp|catr|code|code-insiders|ci|Set-Location|Push-Location|npp|notepad|mkcd|rm|rmrf|cp|mv)\s') {
        return 'MemoryOnly'  # Add to current session history, not file (less clutter)
    }
    return $true
}

# ============================================
# FILE/DIR ARGUMENT COMPLETERS (IMMEDIATE for cd, bat)
# ============================================
# Register completers immediately for critical commands
# cd completer - shows only directories
Register-ArgumentCompleter -Native -CommandName cd -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    
    $searchPath = if ($wordToComplete) { "$wordToComplete*" } else { "*" }
    
    Get-ChildItem -Path $searchPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $name = if ($_.Name -match '\s') { "'$($_.Name)'" } else { $_.Name }
        [System.Management.Automation.CompletionResult]::new(
            $name,
            "📁 $($_.Name)",
            'ParameterValue',
            $_.FullName
        )
    }
}

# bat/cat completer - shows files primarily (dirs for navigation)
Register-ArgumentCompleter -Native -CommandName bat, bat.exe, cat -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    
    $searchPath = if ($wordToComplete) { "$wordToComplete*" } else { "*" }
    
    # Files first (primary use case), then directories for navigation
    $files = @(Get-ChildItem -Path $searchPath -File -ErrorAction SilentlyContinue)
    $dirs = @(Get-ChildItem -Path $searchPath -Directory -ErrorAction SilentlyContinue)
    
    foreach ($item in $files) {
        $name = if ($item.Name -match '\s') { "'$($item.Name)'" } else { $item.Name }
        [System.Management.Automation.CompletionResult]::new(
            ".\$name",
            "📄 $($item.Name)",
            'ParameterValue',
            $item.FullName
        )
    }
    
    foreach ($item in $dirs) {
        $name = if ($item.Name -match '\s') { "'$($item.Name)'" } else { $item.Name }
        [System.Management.Automation.CompletionResult]::new(
            ".\$name\",
            "📁 $($item.Name)/",
            'ParameterValue',
            $item.FullName
        )
    }
}

# Additional completers registered in background
$global:CompletersRegistered = $false

function Register-Completers {
    if ($global:CompletersRegistered) { return }
    
    # cd completer - shows only directories (fast)
    Register-ArgumentCompleter -CommandName cd, Set-Location, Push-Location -ParameterName Path -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        
        $searchPath = if ($wordToComplete) { "$wordToComplete*" } else { "*" }
        
        # Fast: No sorting, direct output
        Get-ChildItem -Path $searchPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $name = if ($_.Name -match '\s') { "'$($_.Name)'" } else { $_.Name }
            [System.Management.Automation.CompletionResult]::new(
                $name,
                "📁 $($_.Name)",
                'ParameterValue',
                $_.FullName
            )
        }
    }

    # File viewer completers (bat, cat, code, etc.) - shows files and dirs (fast)
    Register-ArgumentCompleter -CommandName bat, cat, catr, catp, Get-Content, code, notepad, npp, head, tail, tailf, Get-Head, Get-Tail -ParameterName Path -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        
        $searchPath = if ($wordToComplete) { "$wordToComplete*" } else { "*" }
        
        # Files first for file viewers
        $files = @(Get-ChildItem -Path $searchPath -File -ErrorAction SilentlyContinue)
        $dirs = @(Get-ChildItem -Path $searchPath -Directory -ErrorAction SilentlyContinue)
        
        # Output files first
        foreach ($item in $files) {
            $name = if ($item.Name -match '\s') { "'$($item.Name)'" } else { $item.Name }
            [System.Management.Automation.CompletionResult]::new(
                $name,
                "📄 $($item.Name)",
                'ParameterValue',
                $item.FullName
            )
        }
        
        # Then directories for navigation
        foreach ($item in $dirs) {
            $name = if ($item.Name -match '\s') { "'$($item.Name)'" } else { $item.Name }
            [System.Management.Automation.CompletionResult]::new(
                $name,
                "📁 $($item.Name)",
                'ParameterValue',
                $item.FullName
            )
        }
    }

    # Native completion for bat.exe (first positional argument) - fast
    Register-ArgumentCompleter -Native -CommandName bat, bat.exe -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        
        $searchPath = if ($wordToComplete) { "$wordToComplete*" } else { "*" }
        
        # Files first, then directories
        $files = @(Get-ChildItem -Path $searchPath -File -ErrorAction SilentlyContinue)
        $dirs = @(Get-ChildItem -Path $searchPath -Directory -ErrorAction SilentlyContinue)
        
        foreach ($item in $files) {
            $name = if ($item.Name -match '\s') { "'$($item.Name)'" } else { $item.Name }
            [System.Management.Automation.CompletionResult]::new(
                $name,
                "📄 $($item.Name)",
                'ParameterValue',
                $item.FullName
            )
        }
        
        foreach ($item in $dirs) {
            $name = if ($item.Name -match '\s') { "'$($item.Name)'" } else { $item.Name }
            [System.Management.Automation.CompletionResult]::new(
                $name,
                "📁 $($item.Name)",
                'ParameterValue',
                $item.FullName
            )
        }
    }
    
    # u command completer (url shortcuts)
    Register-ArgumentCompleter -CommandName u -ParameterName Alias -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        
        $configFile = "$env:USERPROFILE\Desktop\url-shortcuts.txt"
        $suggestions = @()
        
        if (Test-Path $configFile) {
            Get-Content $configFile | ForEach-Object {
                $line = $_.Trim()
                if ($line -and -not $line.StartsWith('#') -and $line -match '^([^=]+)=') {
                    $suggestions += $matches[1].Trim()
                }
            }
        }
        
        $suggestions | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new(
                $_,
                $_,
                'ParameterValue',
                $_
            )
        }
    }
    
    $global:CompletersRegistered = $true
}

# Defer completer registration to run after 100ms (async, non-blocking)
$timer = New-Object System.Timers.Timer
$timer.Interval = 100
$timer.AutoReset = $false
Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {
    Register-Completers
} | Out-Null
$timer.Start()

# ============================================
# HELPER FUNCTIONS
# ============================================
function fix-icons {
    Write-Host "`n🔧 Terminal Icons Troubleshooting" -ForegroundColor Cyan
    Write-Host ("═" * 60) -ForegroundColor DarkGray
    
    # Check if Terminal-Icons is loaded
    $iconsModule = Get-Module Terminal-Icons
    if ($iconsModule) {
        Write-Host "✅ Terminal-Icons module is loaded" -ForegroundColor Green
    } else {
        Write-Host "❌ Terminal-Icons module not loaded" -ForegroundColor Red
        Write-Host "   Run 'll' or 'ls' to trigger loading" -ForegroundColor Yellow
    }
    
    Write-Host "`n📝 VS Code Terminal Icon Fix:" -ForegroundColor Cyan
    Write-Host "   1. Install a Nerd Font:" -ForegroundColor Yellow
    Write-Host "      Download from: " -NoNewline -ForegroundColor White
    Write-Host "https://www.nerdfonts.com/" -ForegroundColor Blue
    Write-Host "      Recommended: CaskaydiaCove Nerd Font" -ForegroundColor DarkGray
    Write-Host "`n   2. Configure VS Code:" -ForegroundColor Yellow
    Write-Host "      - Press Ctrl+, (Settings)" -ForegroundColor White
    Write-Host "      - Search: " -NoNewline -ForegroundColor White
    Write-Host "terminal.integrated.fontFamily" -ForegroundColor Cyan
    Write-Host "      - Set value: " -NoNewline -ForegroundColor White
    Write-Host "'CaskaydiaCove Nerd Font Mono'" -ForegroundColor Green
    Write-Host "`n   3. Restart terminal (Ctrl+Shift+`)" -ForegroundColor Yellow
    
    Write-Host "`n💡 Windows Terminal works because it's already configured" -ForegroundColor DarkGray
    Write-Host "   Check: Settings > Defaults > Appearance > Font face`n" -ForegroundColor DarkGray
}

# ============================================
# LINUX-LIKE ALIASES (Modern Rust Tools)
# ============================================
# Load icons on profile start for ls/ll (faster first-use)
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# eza - modern ls replacement with icons
function ls { eza --icons --group-directories-first @args }
function ll { eza -la --icons --git --group-directories-first @args }
function la { eza -la --group-directories-first @args }  # Fast mode - no icons
function l { eza --icons --group-directories-first @args }  # Just names + icons, clean
function lt { eza --tree --level=2 @args }
function lta { eza --tree --level=2 -a @args }
function ltl { eza --tree --level=3 @args }

# Note: 'g' is now used for Google search (see URL SHORTCUTS section)
# Use 'git' directly or create 'gi' alias if needed
Set-Alias touch New-Item

# ripgrep - blazing fast grep replacement
Set-Alias grep rg
function rga { rg --hidden --no-ignore @args }

Set-Alias which Get-Command
Set-Alias open Start-Process
Set-Alias sudo gsudo
Set-Alias less more
Set-Alias head Get-Head
Set-Alias tail Get-Tail
Set-Alias wc Measure-Object
Set-Alias uniq Get-Unique

# duf - modern disk usage replacement
Set-Alias df duf

# ============================================
# LINUX COMMANDS IMPLEMENTATION
# ============================================
function Get-Head { param($Path, $n=10) Get-Content $Path -Head $n }
function Get-Tail { param($Path, $n=10) Get-Content $Path -Tail $n }
function tailf($Path) { Get-Content $Path -Tail 20 -Wait }

# ============================================
# BAT - SYNTAX HIGHLIGHTING (cat replacement)
# ============================================
# Using 'bat' from sharkdp - a cat clone with wings
# Supports 200+ languages with proper syntax highlighting
# Theme: Catppuccin Mocha

# Set bat config via environment  
$env:BAT_THEME = "Catppuccin Mocha"
$env:BAT_STYLE = "numbers,changes,header,grid"

# Use bat directly from PATH (assume it's available)
$Global:BatExe = 'bat.exe'

# cat -> bat with syntax highlighting (no paging)
function cat {
    param([Parameter(Position=0)][string]$Path, [Parameter(ValueFromRemainingArguments)]$Rest)
    if ($Global:BatExe -and $Path) {
        & $Global:BatExe --paging=never $Path @Rest
    } elseif ($Path) {
        Get-Content $Path @Rest
    }
}

# catp -> bat with paging (like less with colors)
function catp {
    param([Parameter(Position=0)][string]$Path, [Parameter(ValueFromRemainingArguments)]$Rest)
    if ($Global:BatExe -and $Path) {
        & $Global:BatExe $Path @Rest
    } elseif ($Path) {
        Get-Content $Path @Rest | Out-Host -Paging
    }
}

# Raw cat without highlighting
function catr { Get-Content @args }

function cp { Copy-Item @args }
function mv { Move-Item @args }
function rm { Remove-Item @args }
function rmrf($path) { Remove-Item $path -Recurse -Force -EA 0 }
function mkdir { New-Item -ItemType Directory @args }
function pwd { (Get-Location).Path }
function whoami { $env:USERNAME }
function hostname { $env:COMPUTERNAME }
function dfold { Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{N='Used(GB)';E={[math]::Round($_.Used/1GB,2)}}, @{N='Free(GB)';E={[math]::Round($_.Free/1GB,2)}} }  # Old df - kept as backup
function du($path=".") { "{0:N2} MB" -f ((Get-ChildItem $path -Recurse -EA 0 | Measure-Object Length -Sum).Sum / 1MB) }
function free { Get-CimInstance Win32_OperatingSystem | Select-Object @{N='Total(GB)';E={[math]::Round($_.TotalVisibleMemorySize/1MB,2)}}, @{N='Free(GB)';E={[math]::Round($_.FreePhysicalMemory/1MB,2)}} }
function uptime { (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime }
function uname { "$env:OS $env:PROCESSOR_ARCHITECTURE - PowerShell $($PSVersionTable.PSVersion)" }
function history { Get-History }
function export($name, $value) { [Environment]::SetEnvironmentVariable($name, $value, "User") }
function unset($name) { Remove-Item "Env:$name" -EA 0 }
function printenv { Get-ChildItem Env: }
function source($file) { . $file }
function alias { Get-Alias }
function type($cmd) { (Get-Command $cmd).Definition }

# ============================================
# NAVIGATION
# ============================================
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function ..... { Set-Location ..\..\..\.. }
function home { Set-Location $HOME }
function desk { Set-Location "$HOME\Desktop" }
function docs { Set-Location "$HOME\Documents" }
function dl { Set-Location "$HOME\Downloads" }
function dev { Set-Location "$HOME\Documents" }
function root { Set-Location \ }
function back { Set-Location - }
function cdf { Set-Location (Get-ChildItem -Directory | fzf) }

# Bookmarks (see PRODUCTIVITY ENHANCEMENTS section for full bm implementation)

# ============================================
# FILE OPERATIONS (eza powered)
# ============================================
function lf { eza -l --icons --only-files @args }           # List files only
function ld { eza -lD --icons @args }                       # List directories only
function lh { eza -la --icons | rg "^\." }                  # List hidden files
function lS { eza -l --icons --sort=size --reverse @args }  # Sort by size (largest first)
function lm { eza -l --icons --sort=modified @args }        # Sort by modified time
function lr { eza -lR --icons --level=2 @args }             # Recursive list (2 levels)
function mkcd($name) { mkdir $name; Set-Location $name }
function sizeof($path) { "{0:N2} MB" -f ((Get-ChildItem $path -Recurse -EA 0 | Measure-Object Length -Sum).Sum / 1MB) }
function tree { eza --tree --icons --level=3 @args }        # Modern tree with icons
function treedir { Get-ChildItem -Recurse -Directory | ForEach-Object { $indent = "  " * ($_.FullName.Split('\').Count - (Get-Location).Path.Split('\').Count); "$indent$($_.Name)" } }
function count { (Get-ChildItem -Recurse -File -EA 0).Count }
function newest($n=5) { Get-ChildItem -File | Sort-Object LastWriteTime -Descending | Select-Object -First $n }
function oldest($n=5) { Get-ChildItem -File | Sort-Object LastWriteTime | Select-Object -First $n }
function largest($n=5) { Get-ChildItem -File -Recurse -EA 0 | Sort-Object Length -Descending | Select-Object -First $n Name, @{N='Size(MB)';E={[math]::Round($_.Length/1MB,2)}} }
function empty { Get-ChildItem -Recurse -File -EA 0 | Where-Object { $_.Length -eq 0 } }
function dupes { Get-ChildItem -File -Recurse | Group-Object Length | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Group } }
function compress($name, $files) { Compress-Archive -Path $files -DestinationPath "$name.zip" }
function backup($file) { Copy-Item $file "$file.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')" }

# ============================================
# GIT SHORTCUTS (Essential 20)
# ============================================
# Status & Stage
function gs { git status -sb }
function ga { git add . }
function gaa { git add -A }

# Commit
function gc($m) { git commit -m $m }
function gca($m) { git commit -am $m }
function gwip { git add -A; git commit -m "WIP" }
function gundo { git reset --soft HEAD~1 }

# Push & Pull
function gp { git push }
function gpl { git pull }
function gpu { git push -u origin (git branch --show-current) }

# Diff & Log
function gd { git diff }
function gds { git diff --staged }
function gl { git log --oneline --graph -15 }

# Branches
function gb { git branch -a }
function gco($b) { git checkout $b }
function gcb($b) { git checkout -b $b }
function gm($b) { git merge $b }

# Stash
function gst { git stash }
function gstp { git stash pop }

# ============================================
# SEARCH & FIND (fd - blazing fast find)
# ============================================
function ff { fd --glob @args }                             # Find files/dirs by glob pattern (e.g., ff *.py)
function ffd { fd --type d --glob @args }                   # Find directories only
function fff { fd --type f --glob @args }                   # Find files only  
function ffa { fd --hidden --no-ignore --glob @args }       # Find all including hidden
function ffrx { fd @args }                                  # Find using regex pattern
function fgrep { rg @args }                                 # Search file contents (ripgrep)
function fhere($t) { rg $t . --max-depth 1 }                # Search in current dir only
function fext($ext) { fd --extension $ext }                 # Find by extension (e.g., fext py)
function fsize($mb) { fd --type f --size "+${mb}m" }        # Find files larger than X MB
function fmod($days) { fd --type f --changed-within "${days}d" }  # Modified within X days
function frep($find, $replace, $ext="*") { Get-ChildItem -Recurse -Filter "*.$ext" -File | ForEach-Object { (Get-Content $_.FullName) -replace $find, $replace | Set-Content $_.FullName } }

# ============================================
# PYTHON & DEV
# ============================================
function py { python @args }
function py3 { python @args }
function pip3 { pip @args }
function pipu { pip install --upgrade pip }
function pipout { pip list --outdated }
function pipup { pip install --upgrade @args }
function venv { python -m venv venv }
function venv3 { python -m venv .venv }
function activate { 
    if (Test-Path ".\venv\Scripts\Activate.ps1") { .\venv\Scripts\Activate.ps1 }
    elseif (Test-Path ".\.venv\Scripts\Activate.ps1") { .\.venv\Scripts\Activate.ps1 }
    else { Write-Host "No venv found!" -ForegroundColor Red }
}
function pipfreeze { pip freeze > requirements.txt; Write-Host "requirements.txt created!" -ForegroundColor Green }
function pipreq { pip install -r requirements.txt }
function serve($p=8000) { python -m http.server $p }
function jsonf { python -m json.tool }
function pytest { python -m pytest @args }
function pytestv { python -m pytest -v @args }
function pytestc { python -m pytest --cov @args }
function lint { python -m pylint @args }
function black { python -m black @args }
function mypy { python -m mypy @args }

# FastAPI
function uvrun { uvicorn main:app --reload }
function uvrun2($f) { uvicorn ${f}:app --reload }
function uvprod { uvicorn main:app --host 0.0.0.0 --port 8000 }
function fastinit { 
    pip install fastapi uvicorn
    @"
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Hello World"}
"@ | Set-Content main.py
    Write-Host "FastAPI project initialized! Run: uvrun" -ForegroundColor Green
}

# Django
function djrun { python manage.py runserver }
function djmig { python manage.py migrate }
function djmake { python manage.py makemigrations }
function djshell { python manage.py shell }
function djsuper { python manage.py createsuperuser }
function djtest { python manage.py test }

# Flask
function flrun { flask run --reload }
function flinit {
    pip install flask
    @"
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return {'message': 'Hello World'}

if __name__ == '__main__':
    app.run(debug=True)
"@ | Set-Content app.py
    Write-Host "Flask project initialized! Run: flrun" -ForegroundColor Green
}

# ============================================
# AI/ML FRAMEWORKS (AutoGen, AG2, LangChain)
# ============================================
function aginit {
    pip install pyautogen
    @"
import autogen

config_list = [{"model": "gpt-4", "api_key": "your-api-key"}]

assistant = autogen.AssistantAgent("assistant", llm_config={"config_list": config_list})
user_proxy = autogen.UserProxyAgent("user_proxy", code_execution_config={"work_dir": "coding"})

# user_proxy.initiate_chat(assistant, message="Hello!")
"@ | Set-Content autogen_app.py
    Write-Host "AutoGen project initialized!" -ForegroundColor Green
}

function ag2init {
    pip install ag2
    Write-Host "AG2 installed! Import with: from ag2 import ..." -ForegroundColor Green
}

function lcinit {
    pip install langchain langchain-openai
    Write-Host "LangChain installed!" -ForegroundColor Green
}

function ollamainit {
    pip install ollama
    Write-Host "Ollama Python SDK installed!" -ForegroundColor Green
}

# ============================================
# REACT / NEXT.JS / FRONTEND
# ============================================
function cra($name) { npx create-react-app $name; Set-Location $name }
function vite($name) { npm create vite@latest $name; Set-Location $name; npm install }
function nextinit($name) { npx create-next-app@latest $name; Set-Location $name }
function remixinit($name) { npx create-remix@latest $name }
function astro($name) { npm create astro@latest $name }

# React dev
function reactdev { npm run dev }
function reactbuild { npm run build }
function reactstart { npm start }
function reactlint { npm run lint }
function reacttest { npm test }

# Tailwind
function tailwindinit {
    npm install -D tailwindcss postcss autoprefixer
    npx tailwindcss init -p
    Write-Host "Tailwind CSS initialized!" -ForegroundColor Green
}

# ============================================
# DATABASE & ORM
# ============================================
# SQLAlchemy / Alembic
function alembinit { alembic init alembic }
function alembrev($msg) { alembic revision --autogenerate -m $msg }
function alembup { alembic upgrade head }
function alembdown { alembic downgrade -1 }
function alembhist { alembic history }

# Prisma
function prismainit { npx prisma init }
function prismadb { npx prisma db push }
function prismagen { npx prisma generate }
function prismamig($name) { npx prisma migrate dev --name $name }
function prismastudio { npx prisma studio }

# PostgreSQL
function pgstart { pg_ctl start }
function pgstop { pg_ctl stop }
function pgstatus { pg_ctl status }

# Redis
function rediscli { redis-cli }

# Node/NPM/Yarn/PNPM
function ni { npm install }
function nis { npm install --save @args }
function nid { npm install --save-dev @args }
function nig { npm install -g @args }
function nu { npm update }
function nun { npm uninstall @args }
function nr { npm run @args }
function nrd { npm run dev }
function nrs { npm run start }
function nrb { npm run build }
function nrt { npm run test }
function nrl { npm run lint }
function yi { yarn install }
function ya { yarn add @args }
function yad { yarn add -D @args }
function yr { yarn @args }
function pi { pnpm install }
function pa { pnpm add @args }
function pr { pnpm @args }
function nodeinit { npm init -y; Write-Host "package.json created!" -ForegroundColor Green }

# Docker
function dk { docker @args }
function dkps { docker ps }
function dkpsa { docker ps -a }
function dki { docker images }
function dkrm { docker rm @args }
function dkrmi { docker rmi @args }
function dkstop { docker stop $(docker ps -q) }
function dkprune { docker system prune -af }
function dklogs($c) { docker logs -f $c }
function dkexec($c) { docker exec -it $c /bin/bash }
function dksh($c) { docker exec -it $c /bin/sh }
function dkbuild($t) { docker build -t $t . }
function dkrun($i) { docker run -it $i }
function dkc { docker-compose @args }
function dkcu { docker-compose up -d }
function dkcd { docker-compose down }
function dkcl { docker-compose logs -f }
function dkcb { docker-compose build }
function dkcr { docker-compose restart }

# Kubernetes
function k { kubectl @args }
function kgp { kubectl get pods }
function kgs { kubectl get services }
function kgd { kubectl get deployments }
function kgn { kubectl get nodes }
function kga { kubectl get all }
function kd($r) { kubectl describe $r }
function kl($p) { kubectl logs -f $p }
function ke($p) { kubectl exec -it $p -- /bin/bash }
function kaf { kubectl apply -f @args }
function kdf { kubectl delete -f @args }
function kctx { kubectl config current-context }
function kns { kubectl config set-context --current --namespace=@args }

# ============================================
# CODE EDITING & IDE
# ============================================
# Kate - KDE Advanced Text Editor (runs in background, doesn't block terminal)
$kate = "kate"
$marktext = "$env:LOCALAPPDATA\Programs\marktext\MarkText.exe"

# Helper to open Kate without blocking terminal
# Opens a blank document if no arguments provided
function Open-Kate {
    if ($args.Count -eq 0) {
        # Open Kate with a new blank document
        Start-Process $kate -WindowStyle Normal
    } else {
        Start-Process $kate -ArgumentList @args -WindowStyle Normal
    }
}

# Universal editor shortcuts (all point to Kate)
# All open a blank document when called without arguments
function gedit { Open-Kate @args }
function kate { Open-Kate @args }
function kwrite { Open-Kate @args }
function np { Open-Kate @args }
function edit { Open-Kate @args }
function e { Open-Kate @args }
function vim { Open-Kate @args }
function vi { Open-Kate @args }
function nano { Open-Kate @args }
function npp { Open-Kate @args }  # Legacy alias

# MarkText for markdown preview
function mdp { 
    param($file)
    if ($file) {
        if (-not $file.EndsWith('.md')) { $file = "$file.md" }
        if (-not (Test-Path $file)) { "# $file" | Set-Content $file }
        Start-Process $marktext -ArgumentList (Resolve-Path $file).Path
    } else { Start-Process $marktext }
}
function preview { mdp @args }
function mark { mdp @args }

# md command - create/open markdown files in MarkText
function md { 
    param($file)
    if ($file) {
        if (-not $file.EndsWith('.md')) { $file = "$file.md" }
        if (-not (Test-Path $file)) { 
            "" | Set-Content $file 
            Write-Host "✨ Created: " -NoNewline -ForegroundColor Green
            Write-Host $file -ForegroundColor Cyan
        } else {
            Write-Host "📄 Opening: " -NoNewline -ForegroundColor Cyan
            Write-Host $file -ForegroundColor White
        }
        Start-Process $marktext -ArgumentList (Resolve-Path $file).Path
    } else { 
        Start-Process $marktext 
    }
}

# VS Code
function c. { code . }
function code. { code . }
function ci. { code-insiders . }
function ci { code-insiders @args }

# Quick file creation (opens in Kate without blocking)
function new($file) { "" | Set-Content $file; Open-Kate $file }
function newpy($name) { "" | Set-Content "$name.py"; Open-Kate "$name.py" }
function newjs($name) { "" | Set-Content "$name.js"; Open-Kate "$name.js" }
function newhtml($name) { "" | Set-Content "$name.html"; Open-Kate "$name.html" }
function newcss($name) { "" | Set-Content "$name.css"; Open-Kate "$name.css" }
function newjson($name) { "{}" | Set-Content "$name.json"; Open-Kate "$name.json" }
function newmd($name) { "# $name" | Set-Content "$name.md"; Open-Kate "$name.md" }

function exp { explorer . }
function here { explorer . }

# ============================================
# SYSTEM UTILITIES
# ============================================
function pubip { (Invoke-RestMethod "https://api.ipify.org") }
function localip { (Get-NetIPAddress -AddressFamily IPv4 | Where-Object InterfaceAlias -notlike "*Loopback*").IPAddress }
function flushdns { Clear-DnsClientCache; Write-Host "DNS flushed!" -ForegroundColor Green }
function hosts { notepad C:\Windows\System32\drivers\etc\hosts }
function path { $env:PATH -split ';' }
function envs { Get-ChildItem Env: | Sort-Object Name }
function sysinfo { Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer, CsProcessors, CsTotalPhysicalMemory }
function cpuinfo { Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed }
function gpuinfo { Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion }
function raminfo { Get-CimInstance Win32_PhysicalMemory | Select-Object Capacity, Speed }
function diskinfo { Get-CimInstance Win32_DiskDrive | Select-Object Model, Size }
function batinfo { Get-CimInstance Win32_Battery | Select-Object EstimatedChargeRemaining, BatteryStatus }

# Process management
function pgrep($n) { Get-Process *$n* -EA 0 }
function pkill($n) { Get-Process *$n* -EA 0 | Stop-Process -Force }
function ports { Get-NetTCPConnection | Where-Object State -eq 'Listen' | Select-Object LocalPort, OwningProcess, @{N='Process';E={(Get-Process -Id $_.OwningProcess -EA 0).Name}} | Sort-Object LocalPort }
function killport($p) { 
    $proc = Get-NetTCPConnection -LocalPort $p -EA 0 | Select-Object -First 1
    if ($proc) { Stop-Process -Id $proc.OwningProcess -Force; Write-Host "Killed process on port $p" -ForegroundColor Green }
    else { Write-Host "No process found on port $p" -ForegroundColor Yellow }
}

# port <name> - Show ports used by a process
function port {
    param($name)
    if (-not $name) {
        Write-Host "Usage: port <process_name>" -ForegroundColor Yellow
        Write-Host "Example: port python, port chrome, port node" -ForegroundColor DarkGray
        return
    }
    $procs = Get-Process *$name* -EA 0
    if (-not $procs) { Write-Host "No process matching '$name' found" -ForegroundColor Red; return }
    
    Write-Host "`n  PORTS USED BY '$name'" -ForegroundColor Cyan
    Write-Host "  $('=' * 50)" -ForegroundColor DarkGray
    
    foreach ($proc in $procs) {
        $connections = Get-NetTCPConnection -OwningProcess $proc.Id -EA 0
        if ($connections) {
            Write-Host "`n  $($proc.Name) (PID: $($proc.Id))" -ForegroundColor Green
            Write-Host "  CPU: $([math]::Round($proc.CPU, 2))s | Memory: $([math]::Round($proc.WorkingSet64/1MB, 2)) MB" -ForegroundColor DarkGray
            $connections | ForEach-Object {
                $state = $_.State
                $color = switch ($state) { 'Listen' { 'Yellow' } 'Established' { 'Green' } default { 'White' } }
                Write-Host "    :$($_.LocalPort) -> $($_.RemoteAddress):$($_.RemotePort) [$state]" -ForegroundColor $color
            }
        }
    }
    Write-Host ""
}

# htop - Process viewer
function htop {
    param($filter)
    
    $cpu = (Get-CimInstance Win32_Processor).LoadPercentage
    if (-not $cpu) { $cpu = 0 }
    $mem = Get-CimInstance Win32_OperatingSystem
    $memUsed = [math]::Round(($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory) / 1MB, 1)
    $memTotal = [math]::Round($mem.TotalVisibleMemorySize / 1MB, 1)
    $memPct = [math]::Round(($memUsed / $memTotal) * 100, 0)
    $uptime = (Get-Date) - $mem.LastBootUpTime
    
    Write-Host ""
    Write-Host "  htop - " -NoNewline -ForegroundColor Cyan
    Write-Host "$(Get-Date -Format 'HH:mm:ss')" -NoNewline -ForegroundColor White
    Write-Host " | Uptime: $([math]::Floor($uptime.TotalHours))h $($uptime.Minutes)m | PS7" -ForegroundColor DarkGray
    
    $cpuFill = [math]::Floor($cpu / 5)
    $memFill = [math]::Floor($memPct / 5)
    $cpuBar = ('#' * $cpuFill) + ('-' * (20 - $cpuFill))
    $memBar = ('#' * $memFill) + ('-' * (20 - $memFill))
    $cpuColor = if ($cpu -gt 80) { 'Red' } elseif ($cpu -gt 50) { 'Yellow' } else { 'Green' }
    $memColor = if ($memPct -gt 80) { 'Red' } elseif ($memPct -gt 50) { 'Yellow' } else { 'Green' }
    
    Write-Host "  CPU [" -NoNewline; Write-Host $cpuBar -NoNewline -ForegroundColor $cpuColor; Write-Host "] $cpu%"
    Write-Host "  MEM [" -NoNewline; Write-Host $memBar -NoNewline -ForegroundColor $memColor; Write-Host "] $memUsed/$memTotal GB ($memPct%)"
    Write-Host ("  " + ("-" * 70)) -ForegroundColor DarkGray
    
    if ($filter) {
        Write-Host "  Filter: " -NoNewline -ForegroundColor Yellow
        Write-Host "*$filter*" -ForegroundColor Cyan
    }
    
    Write-Host ("  {0,6} {1,-25} {2,10} {3,10} {4,8} {5,10}" -f "PID", "NAME", "CPU(s)", "MEM(MB)", "HANDLES", "STATUS") -ForegroundColor DarkCyan
    Write-Host ("  " + ("-" * 70)) -ForegroundColor DarkGray
    
    $procs = if ($filter) {
        Get-Process *$filter* -EA 0 | Sort-Object CPU -Descending | Select-Object -First 20
    } else {
        Get-Process | Sort-Object CPU -Descending | Select-Object -First 20
    }
    
    foreach ($p in $procs) {
        $cpuVal = [math]::Round($p.CPU, 1)
        $memVal = [math]::Round($p.WorkingSet64 / 1MB, 1)
        $pName = if ($p.Name.Length -gt 25) { $p.Name.Substring(0, 22) + "..." } else { $p.Name }
        $status = if ($p.Responding) { "Running" } else { "Hung" }
        $statusColor = if ($p.Responding) { "Green" } else { "Red" }
        
        Write-Host ("  {0,6} {1,-25} {2,10} {3,10} {4,8} " -f $p.Id, $pName, $cpuVal, $memVal, $p.HandleCount) -NoNewline
        Write-Host $status -ForegroundColor $statusColor
    }
    Write-Host ""
}

function htopw { param($filter) while ($true) { Clear-Host; htop $filter; Write-Host "  Ctrl+C to exit | Refreshing..." -ForegroundColor DarkGray; Start-Sleep 2 } }
function top { Get-Process | Sort-Object CPU -Descending | Select-Object -First 15 Id, Name, @{N='CPU(s)';E={[math]::Round($_.CPU,1)}}, @{N='Mem(MB)';E={[math]::Round($_.WorkingSet64/1MB,1)}} | Format-Table -AutoSize }

# Network
function pingg($h) { Test-Connection $h -Count 4 }
function speedtest { python -m speedtest }
function myports { Get-NetTCPConnection | Where-Object State -eq 'Listen' | Select-Object LocalPort, OwningProcess }
function openurls { Get-NetTCPConnection | Where-Object State -eq 'Established' | Select-Object RemoteAddress, RemotePort }

# ============================================
# MODERN NETWORK TOOLS (dog, httpie)
# ============================================
# dog - DNS lookup (modern dig replacement)
function dns { dog @args }                                  # DNS lookup (e.g., dns google.com)
function dnsa { dog @args A }                               # A record
function dnsaaaa { dog @args AAAA }                         # AAAA record (IPv6)
function dnsmx { dog @args MX }                             # MX record (mail)
function dnstxt { dog @args TXT }                           # TXT record
function dnsns { dog @args NS }                             # NS record (nameservers)
function dnscname { dog @args CNAME }                       # CNAME record
function dnsall { dog @args ANY }                           # All records
function dnsshort { dog @args --short }                     # Short output

# HTTPie - modern curl/wget replacement (via python -m httpie)
function GET { python -m httpie GET @args }                 # HTTP GET request
function POST { python -m httpie POST @args }               # HTTP POST request
function PUT { python -m httpie PUT @args }                 # HTTP PUT request
function DELETE { python -m httpie DELETE @args }           # HTTP DELETE request
function PATCH { python -m httpie PATCH @args }             # HTTP PATCH request
function HEAD { python -m httpie HEAD @args }               # HTTP HEAD request
function api { python -m httpie @args }                     # Generic HTTP request
function apij { python -m httpie --json @args }             # JSON request
function apif { python -m httpie --form @args }             # Form request
function apisave { python -m httpie --download @args }      # Download file
function apihead { python -m httpie --headers @args }       # Show headers only

# ============================================
# PROCS - Modern ps replacement
# ============================================
Set-Alias ps procs                                          # Replace ps with procs
function psa { procs --tree @args }                         # Process tree
function psw { procs --watch @args }                        # Watch processes
function psk { procs --sortd cpu @args }                    # Sort by CPU desc
function psm { procs --sortd mem @args }                    # Sort by memory desc
function psg { procs --or @args }                           # Search/grep processes
function pst { procs --tree @args }                         # Tree view

# ============================================
# CLIPBOARD & TEXT
# ============================================
function clip { Set-Clipboard @args }
function paste { Get-Clipboard }
function copypath { (Get-Location).Path | Set-Clipboard; Write-Host "Path copied!" -ForegroundColor Green }
function copyfile($f) { Get-Content $f | Set-Clipboard; Write-Host "File content copied!" -ForegroundColor Green }
function uuid { [guid]::NewGuid().ToString() }
function uuidcopy { $u = [guid]::NewGuid().ToString(); $u | Set-Clipboard; Write-Host $u -ForegroundColor Cyan }
function randstr($len=16) { -join ((65..90) + (97..122) + (48..57) | Get-Random -Count $len | ForEach-Object {[char]$_}) }
function md5($file) { (Get-FileHash $file -Algorithm MD5).Hash }
function sha256($file) { (Get-FileHash $file -Algorithm SHA256).Hash }
function base64e($text) { [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($text)) }
function base64d($text) { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($text)) }
function urlencode($text) { [System.Web.HttpUtility]::UrlEncode($text) }
function urldecode($text) { [System.Web.HttpUtility]::UrlDecode($text) }

# ============================================
# JSON & DATA
# ============================================
function json { $input | ConvertFrom-Json }
function tojson { $input | ConvertTo-Json -Depth 10 }
function prettyjson($file) { Get-Content $file | ConvertFrom-Json | ConvertTo-Json -Depth 10 }
function csv { Import-Csv @args }
function tocsv { $input | Export-Csv -NoTypeInformation @args }

# ============================================
# PROJECT SCAFFOLDING
# ============================================
function newproject($name) {
    New-Item -ItemType Directory $name
    Set-Location $name
    python -m venv venv
    "# $name" | Set-Content README.md
    "" | Set-Content requirements.txt
    "" | Set-Content .gitignore
    Write-Host "Python project '$name' created!" -ForegroundColor Green
}

function newnode($name) {
    New-Item -ItemType Directory $name
    Set-Location $name
    npm init -y
    "node_modules/`n.env" | Set-Content .gitignore
    Write-Host "Node project '$name' created!" -ForegroundColor Green
}

function newgit {
    git init
    @"
node_modules/
venv/
.venv/
__pycache__/
.env
.env.local
.vscode/
.idea/
.DS_Store
Thumbs.db
"@ | Set-Content .gitignore
    git add .
    git commit -m "Initial commit"
    Write-Host "Git repository initialized!" -ForegroundColor Green
}

# ============================================
# PROFILE MANAGEMENT
# ============================================
function editprofile { code $PROFILE }
function reloadprofile { . $PROFILE }
function profilepath { $PROFILE }
function backupprofile { Copy-Item $PROFILE "$PROFILE.bak.$(Get-Date -Format 'yyyyMMdd')" }

# ============================================
# UTILITIES
# ============================================
function weather($c="") { 
    try { 
        Invoke-RestMethod "wttr.in/$c?format=3" -TimeoutSec 10 
    } catch { 
        Write-Host "wttr.in unavailable. Try: curl wttr.in/$c" -ForegroundColor Yellow
    }
}
function weatherfull($c="") { 
    try { 
        Invoke-RestMethod "wttr.in/$c" -TimeoutSec 15 
    } catch { 
        Write-Host "wttr.in unavailable" -ForegroundColor Yellow
    }
}
function cht($cmd) { Invoke-RestMethod "cheat.sh/$cmd" }  # cheat.sh online lookup
function cls { Clear-Host }
function c { Clear-Host }
function q { exit }
function now { Get-Date -Format "yyyy-MM-dd HH:mm:ss" }
function today { Get-Date -Format "yyyy-MM-dd" }
function epoch { [int][double]::Parse((Get-Date -UFormat %s)) }
function fromepoch($e) { [DateTimeOffset]::FromUnixTimeSeconds($e).DateTime }
function timer($s=60) { 
    if (-not $s) { Write-Host "Usage: timer <seconds>  (e.g., timer 30)" -ForegroundColor Yellow; return }
    Write-Host "Timer started for $s seconds..." -ForegroundColor Cyan
    Start-Sleep $s
    [Console]::Beep(1000, 500)
    Write-Host "Timer done!" -ForegroundColor Green 
}
function stopwatch { $sw = [System.Diagnostics.Stopwatch]::StartNew(); Read-Host "Press Enter to stop"; $sw.Stop(); Write-Host "Elapsed: $($sw.Elapsed)" }
function calc { python -c "print($args)" }
function math { python -c "from math import *; print($args)" }
function matrix { $Host.UI.RawUI.ForegroundColor = 'Green'; while($true) { -join (1..80 | ForEach-Object { [char](Get-Random -Min 33 -Max 126) }); Start-Sleep -Milliseconds 50 } }
function quote { (Invoke-RestMethod "https://api.quotable.io/random").content }
function joke { (Invoke-RestMethod "https://official-joke-api.appspot.com/random_joke") | ForEach-Object { "$($_.setup)`n$($_.punchline)" } }

# LeetCode Problem of the Day
function potd {
    Write-Host "🔍 Fetching LeetCode Problem of the Day..." -ForegroundColor Cyan
    
    try {
        $query = '{ "query": "{ activeDailyCodingChallengeQuestion { link question { title difficulty } } }" }'
        $response = Invoke-RestMethod -Uri "https://leetcode.com/graphql" `
            -Method POST `
            -ContentType "application/json" `
            -Body $query
        
        $link = $response.data.activeDailyCodingChallengeQuestion.link
        $title = $response.data.activeDailyCodingChallengeQuestion.question.title
        $difficulty = $response.data.activeDailyCodingChallengeQuestion.question.difficulty
        $fullUrl = "https://leetcode.com$link"
        
        Write-Host ""
        Write-Host "📝 Title: " -NoNewline -ForegroundColor Green
        Write-Host $title -ForegroundColor White
        Write-Host "⚡ Difficulty: " -NoNewline -ForegroundColor Yellow
        
        $diffColor = switch ($difficulty) {
            "Easy" { "Green" }
            "Medium" { "Yellow" }
            "Hard" { "Red" }
            default { "White" }
        }
        Write-Host $difficulty -ForegroundColor $diffColor
        Write-Host "🔗 URL: " -NoNewline -ForegroundColor Cyan
        Write-Host $fullUrl -ForegroundColor Blue
        Write-Host ""
        Write-Host "🚀 Opening in browser..." -ForegroundColor Green
        
        Start-Process $fullUrl
    }
    catch {
        Write-Host "❌ Failed to fetch LeetCode POTD" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor DarkRed
    }
}

# ============================================
# PS7 EXCLUSIVE FEATURES
# ============================================

# Parallel file search (PS7 ForEach-Object -Parallel)
function fpar($pattern, $path=".") {
    Get-ChildItem $path -Recurse -File -EA 0 | ForEach-Object -Parallel {
        if (Select-String -Path $_.FullName -Pattern $using:pattern -Quiet) {
            $_.FullName
        }
    } -ThrottleLimit 10
}

# Parallel file operations
function cppar($source, $dest) {
    Get-ChildItem $source -File | ForEach-Object -Parallel {
        Copy-Item $_.FullName -Destination $using:dest
    } -ThrottleLimit 5
    Write-Host "Parallel copy complete!" -ForegroundColor Green
}

# Quick web requests with better error handling (PS7 pipeline chains)
function fetch($url) { 
    try { Invoke-RestMethod $url } 
    catch { Write-Host "Error: $_" -ForegroundColor Red }
}

# Get JSON from API with null-coalescing (PS7)
function api($url) {
    $result = Invoke-RestMethod $url -ErrorAction SilentlyContinue
    $result ?? "No response"
}

# Conditional operations using ternary (PS7)
function isadmin { ($env:USERNAME -eq "Administrator") ? "Admin" : "User" }

# Smart directory size with parallel processing
function dupar($path=".") {
    $size = Get-ChildItem $path -Recurse -File -EA 0 | ForEach-Object -Parallel {
        $_.Length
    } -ThrottleLimit 10 | Measure-Object -Sum
    "{0:N2} MB" -f ($size.Sum / 1MB)
}

# Find large files in parallel
function findlarge($mb=100, $path=".") {
    Get-ChildItem $path -Recurse -File -EA 0 | ForEach-Object -Parallel {
        if ($_.Length -gt ($using:mb * 1MB)) {
            [PSCustomObject]@{
                Name = $_.Name
                Size = "{0:N2} MB" -f ($_.Length / 1MB)
                Path = $_.FullName
            }
        }
    } -ThrottleLimit 10
}

# System info one-liner (PS7 null-coalescing)
function sysquick {
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $mem = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 1)
    $memTotal = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    Write-Host "CPU: $($cpu.Name ?? 'Unknown')" -ForegroundColor Cyan
    Write-Host "RAM: $mem / $memTotal GB" -ForegroundColor Green
    Write-Host "OS:  $($os.Caption)" -ForegroundColor Yellow
}

# Watch command output (like Linux watch)
function watch {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Command,
        [int]$Interval = 2
    )
    while ($true) {
        Clear-Host
        Write-Host "Every ${Interval}s: " -NoNewline -ForegroundColor DarkGray
        Write-Host $Command -ForegroundColor Cyan
        Write-Host ("─" * 50) -ForegroundColor DarkGray
        & $Command
        Write-Host "`nPress Ctrl+C to exit" -ForegroundColor DarkGray
        Start-Sleep $Interval
    }
}

# Quick benchmark
function benchmark {
    param([scriptblock]$Command, [int]$Iterations = 5)
    $times = 1..$Iterations | ForEach-Object {
        (Measure-Command { & $Command }).TotalMilliseconds
    }
    $avg = ($times | Measure-Object -Average).Average
    Write-Host "Iterations: $Iterations" -ForegroundColor Cyan
    Write-Host "Average: $([math]::Round($avg, 2))ms" -ForegroundColor Green
    Write-Host "Min: $([math]::Round(($times | Measure-Object -Minimum).Minimum, 2))ms" -ForegroundColor Yellow
    Write-Host "Max: $([math]::Round(($times | Measure-Object -Maximum).Maximum, 2))ms" -ForegroundColor Red
}

# Quick HTTP server with error handling
function httpserve($port=8080) {
    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add("http://localhost:$port/")
    try {
        $listener.Start()
        Write-Host "Server running at http://localhost:$port" -ForegroundColor Green
        Write-Host "Press Ctrl+C to stop" -ForegroundColor DarkGray
        while ($listener.IsListening) {
            $context = $listener.GetContext()
            $response = $context.Response
            $content = [System.Text.Encoding]::UTF8.GetBytes("<h1>Hello from PowerShell 7!</h1>")
            $response.OutputStream.Write($content, 0, $content.Length)
            $response.Close()
            Write-Host "Request: $($context.Request.Url)" -ForegroundColor Cyan
        }
    } finally {
        $listener.Stop()
    }
}

# ============================================
# DEVELOPER UTILITIES
# ============================================

# Quick .env file management
function envload($file=".env") {
    if (Test-Path $file) {
        Get-Content $file | ForEach-Object {
            if ($_ -match '^([^#][^=]+)=(.*)$') {
                [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), "Process")
            }
        }
        Write-Host "Loaded $file" -ForegroundColor Green
    } else { Write-Host ".env not found" -ForegroundColor Red }
}

function envshow { Get-ChildItem Env: | Where-Object { $_.Name -notmatch 'PATH|PSModule' } | Sort-Object Name | Format-Table -AutoSize }

# Quick project info
function projinfo {
    Write-Host "`n  PROJECT INFO" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────" -ForegroundColor DarkGray
    if (Test-Path "package.json") {
        $pkg = Get-Content "package.json" | ConvertFrom-Json
        Write-Host "  📦 $($pkg.name) v$($pkg.version)" -ForegroundColor Green
        Write-Host "  📝 $($pkg.description)" -ForegroundColor DarkGray
    }
    if (Test-Path "pyproject.toml") { Write-Host "  🐍 Python project (pyproject.toml)" -ForegroundColor Blue }
    if (Test-Path "requirements.txt") { Write-Host "  🐍 Python project (requirements.txt)" -ForegroundColor Blue }
    if (Test-Path "Cargo.toml") { Write-Host "  🦀 Rust project" -ForegroundColor Yellow }
    if (Test-Path "go.mod") { Write-Host "  🐹 Go project" -ForegroundColor Cyan }
    if (Test-Path ".git") { Write-Host "  📂 Git: $(git branch --show-current)" -ForegroundColor Magenta }
    if (Test-Path "docker-compose.yml") { Write-Host "  🐳 Docker Compose" -ForegroundColor Blue }
    if (Test-Path "Dockerfile") { Write-Host "  🐳 Dockerfile" -ForegroundColor Blue }
    Write-Host ""
}

# Quick dependency check
function deps {
    Write-Host "`n  DEPENDENCIES" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────" -ForegroundColor DarkGray
    if (Test-Path "package.json") {
        $pkg = Get-Content "package.json" | ConvertFrom-Json
        $depCount = ($pkg.dependencies.PSObject.Properties | Measure-Object).Count
        $devCount = ($pkg.devDependencies.PSObject.Properties | Measure-Object).Count
        Write-Host "  npm: $depCount deps, $devCount devDeps" -ForegroundColor Green
    }
    if (Test-Path "requirements.txt") {
        $count = (Get-Content "requirements.txt" | Where-Object { $_ -and $_ -notmatch '^#' }).Count
        Write-Host "  pip: $count packages" -ForegroundColor Blue
    }
    Write-Host ""
}

# Open project in browser (detect common ports)
function openbrowser($port) {
    if ($port) { Start-Process "http://localhost:$port" }
    else {
        $ports = @(3000, 5000, 8000, 8080, 4200, 5173)
        foreach ($p in $ports) {
            if (Get-NetTCPConnection -LocalPort $p -State Listen -EA 0) {
                Start-Process "http://localhost:$p"
                Write-Host "Opened http://localhost:$p" -ForegroundColor Green
                return
            }
        }
        Write-Host "No dev server found on common ports" -ForegroundColor Yellow
    }
}
Set-Alias ob openbrowser

# Kill dev servers
function killdevs {
    $ports = @(3000, 5000, 8000, 8080, 4200, 5173, 3001)
    foreach ($p in $ports) {
        $conn = Get-NetTCPConnection -LocalPort $p -State Listen -EA 0
        if ($conn) {
            Stop-Process -Id $conn.OwningProcess -Force -EA 0
            Write-Host "Killed process on :$p" -ForegroundColor Yellow
        }
    }
}

# Quick localhost tunnel (using localhost.run)
function tunnel($port=3000) {
    Write-Host "Creating tunnel for localhost:$port..." -ForegroundColor Cyan
    ssh -R 80:localhost:$port localhost.run
}

# ============================================
# QUICK HELP COMMANDS
# ============================================
function dev {
    $commands = @"

  ╭──────────────────────────────────────────────────────────────╮
  │                    DEVELOPER COMMANDS                        │
  ├──────────────────────────────────────────────────────────────┤
  │  PYTHON / FastAPI / Flask                                    │
  │    fastinit    Create FastAPI project                        │
  │    flaskinit   Create Flask project                          │
  │    venv        Create/activate virtualenv                    │
  │    pipi        pip install                                   │
  │    pipf        pip freeze > requirements.txt                 │
  │    pytest      Run tests       │  uvicorn    Run ASGI server │
  ├──────────────────────────────────────────────────────────────┤
  │  AI / ML FRAMEWORKS                                          │
  │    aginit      AutoGen project    │  ag2init    AG2 project  │
  │    lcinit      LangChain project  │  ollamainit Ollama setup │
  ├──────────────────────────────────────────────────────────────┤
  │  REACT / FRONTEND                                            │
  │    cra         Create React App   │  vite      Vite project  │
  │    nextinit    Next.js project    │  remixinit Remix project │
  │    astro       Astro project      │  tailwindinit  Tailwind  │
  │    reactdev    npm run dev        │  reactbuild npm run build│
  ├──────────────────────────────────────────────────────────────┤
  │  DATABASE / ORM                                              │
  │    alembinit   Init Alembic       │  prismainit Init Prisma  │
  │    alembup     Upgrade DB         │  prismamig  Run migration│
  │    prismastudio Open Prisma GUI                              │
  ├──────────────────────────────────────────────────────────────┤
  │  GIT (40+ shortcuts)                                         │
  │    gs  status  │  ga  add   │  gc   commit │  gp  push      │
  │    gl  log     │  gd  diff  │  gco  checkout│  gb  branch   │
  │    gcm main    │  gpl pull  │  gst  stash   │  gm  merge    │
  ├──────────────────────────────────────────────────────────────┤
  │  UTILITIES                                                   │
  │    projinfo    Show project info  │  deps      Dependencies  │
  │    ob          Open in browser    │  killdevs  Kill servers  │
  │    envload     Load .env file     │  portmon   Port monitor  │
  │    htop        Process monitor    │  tunnel    Localhost URL │
  ╰──────────────────────────────────────────────────────────────╯

  Type 'cheat' for full cheatsheet  │  'shortcuts' for keys

"@
    Write-Host $commands -ForegroundColor Cyan
}

function shortcuts {
    $keys = @"

  ╭────────────────────────────────────────────────────────────╮
  │                   KEYBOARD SHORTCUTS                       │
  ├────────────────────────────────────────────────────────────┤
  │  Ctrl+Space   Accept suggestion   │  F2  Toggle list view  │
  │  Ctrl+F       Accept next word    │  Tab  Menu complete    │
  │  ↑/↓          History search      │  Ctrl+L  Clear screen  │
  │  Ctrl+Z/Y     Undo/Redo          │  Ctrl+D  Delete/Exit   │
  │  Ctrl+←/→     Word navigation     │  Alt+D   Delete word   │
  │  Ctrl+U       Delete to start     │  Ctrl+K  Delete to end │
  ╰────────────────────────────────────────────────────────────╯

"@
    Write-Host $keys -ForegroundColor Magenta
}

# ============================================
# MODERN CLI TOOLS INITIALIZATION
# ============================================
# EXTERNAL TOOLS CONFIGURATION (Instant Setup)
# ============================================
# Assume tools exist - lazy check on first use (much faster)

# Zoxide - smart cd (check on first use)
function global:z { 
    param([string[]]$Path)
    if ($Path.Count -eq 0) { Set-Location ~ }
    else { 
        $result = zoxide query @Path 2>$null
        if ($result) { Set-Location $result }
    }
}
function global:zi { 
    $result = zoxide query -i 2>$null
    if ($result) { Set-Location $result }
}

# fzf + delta + jq - set env vars immediately (no checks)
$env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --inline-info --color=bg+:#313244,bg:#1e1e2e,fg:#cdd6f4,hl:#f38ba8'
$env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git'
$env:GIT_PAGER = 'delta'
$env:DELTA_FEATURES = '+side-by-side'

# jq functions (will fail gracefully if jq not installed)
function jqp { $input | jq '.' }
function jqk { $input | jq 'keys' }
function jqf($filter) { $input | jq $filter }

# ============================================
# FZF ENHANCED FUNCTIONS
# ============================================
# Interactive file finder with preview
function fzfp { fd --type f | fzf --preview 'bat --color=always --style=numbers {}' }

# Interactive directory jump
function fzfd { Set-Location (fd --type d | fzf --preview 'eza -la --icons --color=always {}') }

# Interactive git log browser
function fzglog { git log --oneline | fzf --preview 'git show --color=always {1}' | ForEach-Object { ($_ -split ' ')[0] } }

# Interactive git branch switcher
function fzgbr { git branch --all | fzf | ForEach-Object { git checkout $_.Trim() -replace 'remotes/origin/', '' } }

# Interactive process killer
function fzkill { Get-Process | ForEach-Object { "$($_.Id) $($_.ProcessName)" } | fzf --multi | ForEach-Object { Stop-Process -Id ($_ -split ' ')[0] -Force } }

# Interactive ripgrep search with preview
function frg { 
    $result = rg --line-number --no-heading . | fzf --delimiter ':' --preview 'bat --color=always --highlight-line {2} {1}' --preview-window '+{2}-/2'
    if ($result) {
        $parts = $result -split ':'
        code --goto "$($parts[0]):$($parts[1])"
    }
}

# ============================================
# URL SHORTCUTS - Quick Browser Launcher
# ============================================
# Config file: Desktop\url-shortcuts.txt
# Commands: u <alias>, g <query>, yt <query>, urls (manage)

$Global:UrlConfigFile = "$env:USERPROFILE\Desktop\url-shortcuts.txt"

# Initialize config file if not exists
if (-not (Test-Path $Global:UrlConfigFile)) {
    @"
# URL Shortcuts - Format: alias=url
# Lines starting with # are comments
# Use with: u <alias>, gs <alias> <query>

github=https://github.com
reddit=https://www.reddit.com
stackoverflow=https://stackoverflow.com
leetcode=https://leetcode.com
py=https://docs.python.org/3
fastapi=https://fastapi.tiangolo.com
mdn=https://developer.mozilla.org
npm=https://www.npmjs.com
pypi=https://pypi.org
"@ | Set-Content $Global:UrlConfigFile
}

# Interactive URL Manager
function urls {
    param(
        [Parameter(Position=0)][string]$Action = '',
        [Parameter(Position=1)][string]$Alias = '',
        [Parameter(Position=2)][string]$Url = ''
    )
    
    # Load shortcuts
    $shortcuts = [ordered]@{}
    if (Test-Path $Global:UrlConfigFile) {
        Get-Content $Global:UrlConfigFile | ForEach-Object {
            $line = $_.Trim()
            if ($line -and -not $line.StartsWith('#') -and $line -match '^([^=]+)=(.+)$') {
                $shortcuts[$matches[1].Trim()] = $matches[2].Trim()
            }
        }
    }
    
    switch ($Action.ToLower()) {
        'add' {
            if (-not $Alias -or -not $Url) {
                Write-Host "❌ Usage: " -NoNewline -ForegroundColor Red
                Write-Host "urls add <alias> <url>" -ForegroundColor Yellow
                Write-Host "   Example: urls add gh https://github.com" -ForegroundColor DarkGray
                return
            }
            # Auto-add https if missing
            if ($Url -notmatch '^https?://') { $Url = "https://$Url" }
            
            if ($shortcuts.Contains($Alias)) {
                Write-Host "⚠️  '$Alias' already exists. Use 'urls edit $Alias <url>' to update." -ForegroundColor Yellow
                return
            }
            "$Alias=$Url" | Add-Content $Global:UrlConfigFile
            Write-Host "✅ Added: " -NoNewline -ForegroundColor Green
            Write-Host $Alias -NoNewline -ForegroundColor Cyan
            Write-Host " → " -NoNewline -ForegroundColor DarkGray
            Write-Host $Url -ForegroundColor White
        }
        'edit' {
            if (-not $Alias -or -not $Url) {
                Write-Host "❌ Usage: " -NoNewline -ForegroundColor Red
                Write-Host "urls edit <alias> <new-url>" -ForegroundColor Yellow
                return
            }
            if ($Url -notmatch '^https?://') { $Url = "https://$Url" }
            
            if (-not $shortcuts.Contains($Alias)) {
                Write-Host "❌ '$Alias' not found. Use 'urls add' to create it." -ForegroundColor Red
                return
            }
            # Rewrite file with updated entry
            $newContent = Get-Content $Global:UrlConfigFile | ForEach-Object {
                if ($_ -match "^$Alias=") { "$Alias=$Url" } else { $_ }
            }
            $newContent | Set-Content $Global:UrlConfigFile
            Write-Host "✅ Updated: " -NoNewline -ForegroundColor Green
            Write-Host $Alias -NoNewline -ForegroundColor Cyan
            Write-Host " → " -NoNewline -ForegroundColor DarkGray
            Write-Host $Url -ForegroundColor White
        }
        'rm' {
            if (-not $Alias) {
                Write-Host "❌ Usage: " -NoNewline -ForegroundColor Red
                Write-Host "urls rm <alias>" -ForegroundColor Yellow
                return
            }
            if (-not $shortcuts.Contains($Alias)) {
                Write-Host "❌ '$Alias' not found" -ForegroundColor Red
                return
            }
            $newContent = Get-Content $Global:UrlConfigFile | Where-Object { $_ -notmatch "^$Alias=" }
            $newContent | Set-Content $Global:UrlConfigFile
            Write-Host "🗑️  Removed: " -NoNewline -ForegroundColor Yellow
            Write-Host $Alias -ForegroundColor Cyan
        }
        'list' {
            Write-Host ""
            Write-Host "  🔗 URL SHORTCUTS" -ForegroundColor Cyan
            Write-Host "  ─────────────────────────────────────────" -ForegroundColor DarkGray
            if ($shortcuts.Count -eq 0) {
                Write-Host "  (no shortcuts yet)" -ForegroundColor DarkGray
            } else {
                $shortcuts.GetEnumerator() | ForEach-Object {
                    Write-Host "  " -NoNewline
                    Write-Host $_.Key.PadRight(15) -NoNewline -ForegroundColor Green
                    Write-Host "→ " -NoNewline -ForegroundColor DarkGray
                    Write-Host $_.Value -ForegroundColor White
                }
            }
            Write-Host ""
        }
        default {
            # Interactive menu
            Write-Host ""
            Write-Host "  🔗 URL SHORTCUTS MANAGER" -ForegroundColor Cyan
            Write-Host "  ─────────────────────────────────────────" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  Current shortcuts ($($shortcuts.Count)):" -ForegroundColor Yellow
            if ($shortcuts.Count -gt 0) {
                $shortcuts.GetEnumerator() | ForEach-Object {
                    Write-Host "    " -NoNewline
                    Write-Host $_.Key.PadRight(12) -NoNewline -ForegroundColor Green
                    Write-Host $_.Value -ForegroundColor DarkGray
                }
            } else {
                Write-Host "    (none)" -ForegroundColor DarkGray
            }
            Write-Host ""
            Write-Host "  Commands:" -ForegroundColor Yellow
            Write-Host "    urls add <alias> <url>    " -NoNewline -ForegroundColor Cyan
            Write-Host "Add new shortcut" -ForegroundColor DarkGray
            Write-Host "    urls edit <alias> <url>   " -NoNewline -ForegroundColor Cyan
            Write-Host "Edit existing" -ForegroundColor DarkGray
            Write-Host "    urls rm <alias>           " -NoNewline -ForegroundColor Cyan
            Write-Host "Remove shortcut" -ForegroundColor DarkGray
            Write-Host "    urls list                 " -NoNewline -ForegroundColor Cyan
            Write-Host "List all shortcuts" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  Usage:" -ForegroundColor Yellow
            Write-Host "    u leetcode                " -NoNewline -ForegroundColor Green
            Write-Host "→ Open leetcode.com" -ForegroundColor DarkGray
            Write-Host "    u reddit search term      " -NoNewline -ForegroundColor Green
            Write-Host "→ Search within Reddit" -ForegroundColor DarkGray
            Write-Host "    g rust tutorials          " -NoNewline -ForegroundColor Green
            Write-Host "→ Google search" -ForegroundColor DarkGray
            Write-Host "    gw reddit llms            " -NoNewline -ForegroundColor Green
            Write-Host "→ Google site:reddit.com llms" -ForegroundColor DarkGray
            Write-Host "    yt lofi music             " -NoNewline -ForegroundColor Green
            Write-Host "→ YouTube search" -ForegroundColor DarkGray
            Write-Host ""
        }
    }
}

# Google search - standalone command
function g {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Query)
    if ($Query) {
        $searchQuery = ($Query -join ' ')
        $encodedQuery = [System.Web.HttpUtility]::UrlEncode($searchQuery)
        $targetUrl = "https://www.google.com/search?q=$encodedQuery"
        Write-Host "🔍 Searching Google: " -NoNewline -ForegroundColor Cyan
        Write-Host $searchQuery -ForegroundColor White
    } else {
        $targetUrl = "https://www.google.com"
        Write-Host "🌐 Opening Google" -ForegroundColor Cyan
    }
    Start-Process $targetUrl
}

# Google site-specific search - uses URL shortcuts (gw = google within)
function gw {
    param(
        [Parameter(Position=0, Mandatory=$true)][string]$Site,
        [Parameter(Position=1, ValueFromRemainingArguments=$true)][string[]]$Query
    )
    
    if (-not $Query) {
        Write-Host "❌ Usage: " -NoNewline -ForegroundColor Red
        Write-Host "gw <site-alias> <search query>" -ForegroundColor Yellow
        Write-Host "   Example: gw reddit llm agents" -ForegroundColor DarkGray
        Write-Host "   Example: gw py async await" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "💡 Add sites with: " -NoNewline -ForegroundColor DarkGray
        Write-Host "urls add py https://docs.python.org/3" -ForegroundColor Cyan
        return
    }
    
    # Load shortcuts to find the site URL
    $siteUrl = $null
    if (Test-Path $Global:UrlConfigFile) {
        Get-Content $Global:UrlConfigFile | ForEach-Object {
            $line = $_.Trim()
            if ($line -and -not $line.StartsWith('#') -and $line -match '^([^=]+)=(.+)$') {
                if ($matches[1].Trim() -eq $Site) {
                    $siteUrl = $matches[2].Trim()
                }
            }
        }
    }
    
    # Extract domain from URL or use Site as-is
    if ($siteUrl) {
        $domain = $siteUrl -replace '^https?://(www\.)?', '' -replace '/.*$', ''
    } else {
        # Treat as domain directly (e.g., gs docs.python.org async)
        $domain = $Site -replace '^https?://(www\.)?', '' -replace '/.*$', ''
        # Auto-add .com if no TLD
        if ($domain -notmatch '\.') { $domain = "$domain.com" }
    }
    
    $searchQuery = ($Query -join ' ')
    $fullQuery = "site:$domain $searchQuery"
    $encodedQuery = [System.Web.HttpUtility]::UrlEncode($fullQuery)
    $targetUrl = "https://www.google.com/search?q=$encodedQuery"
    
    Write-Host "🔍 " -NoNewline -ForegroundColor Cyan
    Write-Host "site:$domain " -NoNewline -ForegroundColor Yellow
    Write-Host $searchQuery -ForegroundColor White
    Start-Process $targetUrl
}

# YouTube search - standalone command
function yt {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Query)
    if ($Query) {
        $searchQuery = ($Query -join ' ')
        $encodedQuery = [System.Web.HttpUtility]::UrlEncode($searchQuery)
        $targetUrl = "https://www.youtube.com/results?search_query=$encodedQuery"
        Write-Host "🎥 Searching YouTube: " -NoNewline -ForegroundColor Red
        Write-Host $searchQuery -ForegroundColor White
    } else {
        $targetUrl = "https://www.youtube.com"
        Write-Host "🎥 Opening YouTube" -ForegroundColor Red
    }
    Start-Process $targetUrl
}

# URL shortcuts - main command (renamed from url to u)
function u {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Alias,
        
        [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
        [string[]]$Query
    )
    
    # Load custom shortcuts
    $shortcuts = @{}
    if (Test-Path $Global:UrlConfigFile) {
        Get-Content $Global:UrlConfigFile | ForEach-Object {
            $line = $_.Trim()
            if ($line -and -not $line.StartsWith('#')) {
                if ($line -match '^([^=]+)=(.+)$') {
                    $shortcuts[$matches[1].Trim()] = $matches[2].Trim()
                }
            }
        }
    }
    
    # Check if it's a direct URL (contains . and starts with www or http)
    if ($Alias -match '^(https?://|www\.)') {
        $targetUrl = if ($Alias -notmatch '^https?://') { "https://$Alias" } else { $Alias }
        Write-Host "🌐 Opening: " -NoNewline -ForegroundColor Green
        Write-Host $targetUrl -ForegroundColor White
        Start-Process $targetUrl
        return
    }
    
    # Check if shortcut exists
    if ($shortcuts.ContainsKey($Alias)) {
        $baseUrl = $shortcuts[$Alias]
        
        # If query provided, try to search within the site
        if ($Query) {
            $searchQuery = ($Query -join ' ')
            $encodedQuery = [System.Web.HttpUtility]::UrlEncode($searchQuery)
            
            # Smart search URL patterns for popular sites
            $targetUrl = switch -Regex ($baseUrl) {
                'reddit\.com' { "$baseUrl/search/?q=$encodedQuery" }
                'github\.com' { "$baseUrl/search?q=$encodedQuery" }
                'stackoverflow\.com' { "$baseUrl/search?q=$encodedQuery" }
                'youtube\.com' { "https://www.youtube.com/results?search_query=$encodedQuery" }
                'twitter\.com' { "https://twitter.com/search?q=$encodedQuery" }
                'linkedin\.com' { "https://www.linkedin.com/search/results/all/?keywords=$encodedQuery" }
                'npmjs\.com' { "https://www.npmjs.com/search?q=$encodedQuery" }
                'pypi\.org' { "https://pypi.org/search/?q=$encodedQuery" }
                default { "$baseUrl/search?q=$encodedQuery" }
            }
            
            Write-Host "🔍 Searching " -NoNewline -ForegroundColor Cyan
            Write-Host $Alias -NoNewline -ForegroundColor Yellow
            Write-Host " for: " -NoNewline -ForegroundColor Cyan
            Write-Host $searchQuery -ForegroundColor White
        } else {
            $targetUrl = $baseUrl
            Write-Host "🚀 Opening: " -NoNewline -ForegroundColor Green
            Write-Host $Alias -NoNewline -ForegroundColor Cyan
            Write-Host " → " -NoNewline -ForegroundColor DarkGray
            Write-Host $targetUrl -ForegroundColor White
        }
        Start-Process $targetUrl
        return
    }
    
    # If not found, try auto-constructing URL with www.{alias}.com
    if ($Alias -notmatch '\s' -and $Alias -match '^[a-zA-Z0-9-]+$') {
        $targetUrl = "https://www.$Alias.com"
        Write-Host "🌐 Trying: " -NoNewline -ForegroundColor Yellow
        Write-Host $targetUrl -ForegroundColor White
        Write-Host "💡 Save it? Run: " -NoNewline -ForegroundColor DarkGray
        Write-Host "urls add $Alias $targetUrl" -ForegroundColor Cyan
        Start-Process $targetUrl
        return
    }
    
    # Not found and can't auto-construct
    Write-Host "❌ Alias '$Alias' not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Available shortcuts:" -ForegroundColor Yellow
    $shortcuts.GetEnumerator() | Sort-Object Name | ForEach-Object {
        Write-Host "  " -NoNewline
        Write-Host $_.Name.PadRight(15) -NoNewline -ForegroundColor Cyan
        Write-Host "→ " -NoNewline -ForegroundColor DarkGray
        Write-Host $_.Value -ForegroundColor White
    }
    Write-Host ""
    Write-Host "💡 Examples: " -ForegroundColor DarkGray
    Write-Host "   g <query>                 " -NoNewline -ForegroundColor Green
    Write-Host "# Search Google" -ForegroundColor DarkGray
    Write-Host "   yt <query>                " -NoNewline -ForegroundColor Green
    Write-Host "# Search YouTube" -ForegroundColor DarkGray
    Write-Host "   u reddit search term      " -NoNewline -ForegroundColor Green
    Write-Host "# Search in Reddit" -ForegroundColor DarkGray
    Write-Host "   u leetcode                " -NoNewline -ForegroundColor Green
    Write-Host "# Opens www.leetcode.com" -ForegroundColor DarkGray
    Write-Host "   u www.example.com         " -NoNewline -ForegroundColor Green
    Write-Host "# Direct URL" -ForegroundColor DarkGray
}

# ============================================
# PRODUCTIVITY ENHANCEMENTS
# ============================================

# Quick directory bookmarks (faster than typing long paths)
$global:Bookmarks = @{
    'docs' = "$HOME\Documents"
    'dl' = "$HOME\Downloads"
    'desk' = "$HOME\Desktop"
    'code' = "$HOME\Documents"
    'backend' = "$HOME\Documents\FASTAPI FINAL\BACKEND"
    'mas' = "$HOME\Documents\FASTAPI FINAL\BACKEND\Multi-Agent-System"
}

function bm {
    param([string]$Name)
    if (-not $Name) {
        Write-Host "📚 Available Bookmarks:" -ForegroundColor Cyan
        $global:Bookmarks.GetEnumerator() | Sort-Object Name | ForEach-Object {
            Write-Host "  " -NoNewline
            Write-Host $_.Name.PadRight(10) -NoNewline -ForegroundColor Green
            Write-Host "→ " -NoNewline -ForegroundColor DarkGray
            Write-Host $_.Value -ForegroundColor White
        }
        Write-Host "`n💡 Usage: " -NoNewline -ForegroundColor Yellow
        Write-Host "bm <name>" -ForegroundColor Cyan
        Write-Host "💡 Add: " -NoNewline -ForegroundColor Yellow
        Write-Host "`$global:Bookmarks['name'] = 'path'" -ForegroundColor Cyan
        return
    }
    if ($global:Bookmarks.ContainsKey($Name)) {
        Set-Location $global:Bookmarks[$Name]
        Write-Host "📂 " -NoNewline -ForegroundColor Cyan
        Write-Host $Name -NoNewline -ForegroundColor Green
        Write-Host " → " -NoNewline -ForegroundColor DarkGray
        Write-Host $global:Bookmarks[$Name] -ForegroundColor White
    } else {
        Write-Host "❌ Bookmark '$Name' not found" -ForegroundColor Red
    }
}
Set-Alias go bm  # Alias: go <name> = bm <name>
function bms { $global:Bookmarks.GetEnumerator() | Sort-Object Name | ForEach-Object { Write-Host "$($_.Key): $($_.Value)" } }

# Extract any archive (zip, tar, gz, etc.)
function extract {
    param([string]$File)
    if (-not (Test-Path $File)) {
        Write-Host "❌ File not found: $File" -ForegroundColor Red
        return
    }
    $File = Resolve-Path $File
    Write-Host "📦 Extracting: " -NoNewline -ForegroundColor Cyan
    Write-Host $File -ForegroundColor White
    
    switch -Regex ($File) {
        '\.zip$' { Expand-Archive -Path $File -DestinationPath . }
        '\.tar\.gz$|\.tgz$' { tar -xzf $File }
        '\.tar$' { tar -xf $File }
        '\.gz$' { gzip -d $File }
        '\.7z$' { 7z x $File }
        default { Write-Host "❌ Unsupported format" -ForegroundColor Red }
    }
}

# Quick note taking (appends to daily note file)
function note {
    param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Text)
    $noteFile = "$HOME\Desktop\notes-$(Get-Date -Format 'yyyy-MM-dd').txt"
    if (-not $Text) {
        if (Test-Path $noteFile) {
            Write-Host "📝 Today's notes:" -ForegroundColor Cyan
            Get-Content $noteFile
        } else {
            Write-Host "📝 No notes yet. Usage: note <your note>" -ForegroundColor Yellow
        }
        return
    }
    $timestamp = Get-Date -Format 'HH:mm'
    "[$timestamp] $($Text -join ' ')" | Add-Content $noteFile
    Write-Host "✅ Note saved to: " -NoNewline -ForegroundColor Green
    Write-Host $noteFile -ForegroundColor White
}

# Profile reload (faster than restarting terminal)
function reload {
    Write-Host "🔄 Reloading profile..." -ForegroundColor Cyan
    . $PROFILE
    Write-Host "✅ Profile reloaded!" -ForegroundColor Green
}

# Profile performance check
function profile-bench {
    Write-Host "⏱️  Benchmarking profile startup..." -ForegroundColor Cyan
    $noProfile = (Measure-Command { & pwsh -NoProfile -Command "exit" }).TotalMilliseconds
    $withProfile = (Measure-Command { & pwsh -Command "exit" }).TotalMilliseconds
    $overhead = $withProfile - $noProfile
    
    Write-Host ""
    Write-Host "  No Profile:    " -NoNewline -ForegroundColor DarkGray
    Write-Host "$([math]::Round($noProfile))ms" -ForegroundColor White
    Write-Host "  With Profile:  " -NoNewline -ForegroundColor DarkGray
    Write-Host "$([math]::Round($withProfile))ms" -ForegroundColor White
    Write-Host "  Overhead:      " -NoNewline -ForegroundColor DarkGray
    
    if ($overhead -lt 1000) {
        Write-Host "$([math]::Round($overhead))ms" -ForegroundColor Green
        Write-Host "  ✅ Fast startup!" -ForegroundColor Green
    } elseif ($overhead -lt 3000) {
        Write-Host "$([math]::Round($overhead))ms" -ForegroundColor Yellow
        Write-Host "  ⚠️  Moderate startup time" -ForegroundColor Yellow
    } else {
        Write-Host "$([math]::Round($overhead))ms" -ForegroundColor Red
        Write-Host "  ❌ Slow startup - consider optimization" -ForegroundColor Red
    }
    Write-Host ""
}

# ============================================
# EXTERNAL MODULES / SCRIPTS
# ============================================
# Load external tools (modular design for cleaner profile)
$externalScripts = @(
    "$HOME\Documents\PowerShell\blob-tools.ps1",     # Azure Blob tools
    "$HOME\Documents\PowerShell\todo-system.ps1",    # Todo system
    "$HOME\Documents\PowerShell\cheat-system.ps1"    # Cheat system
)
foreach ($script in $externalScripts) {
    if (Test-Path $script) { . $script }
}

# ============================================
# VIZ - MULTI-AGENT VISUALIZER
# ============================================
# Quick launcher for the Multi-Agent Workflow Visualizer
$script:VIZ_DIR = "$HOME\Desktop\Visualizer\final"
$script:VIZ_BACKEND_PORT = 8765
$script:VIZ_FRONTEND_PORT = 5173

function viz {
    <#
    .SYNOPSIS
    Multi-Agent Workflow Visualizer CLI
    
    .EXAMPLE
    viz                         # Start and open dashboard
    viz -e exec_id              # Open specific execution
    viz -w workflow_id          # Open specific workflow  
    viz start                   # Start servers only
    viz stop                    # Stop servers
    viz status                  # Check status
    viz api                     # Open API docs
    #>
    param(
        [Parameter(Position = 0)]
        [string]$Command,
        [Alias('e', 'exec')][string]$ExecutionId,
        [Alias('w', 'wf')][string]$WorkflowId,
        [switch]$NoBrowser
    )
    
    $backendUrl = "http://localhost:$script:VIZ_BACKEND_PORT"
    $frontendUrl = "http://localhost:$script:VIZ_FRONTEND_PORT"
    
    function Test-VizPort { param([int]$Port) 
        $null -ne (Get-NetTCPConnection -LocalPort $Port -State Listen -EA 0) 
    }
    
    function Stop-VizPort { param([int]$Port)
        $conn = Get-NetTCPConnection -LocalPort $Port -State Listen -EA 0
        if ($conn) { Stop-Process -Id $conn.OwningProcess -Force -EA 0; return $true }
        return $false
    }
    
    function Start-VizServers {
        $backendRunning = Test-VizPort $script:VIZ_BACKEND_PORT
        $frontendRunning = Test-VizPort $script:VIZ_FRONTEND_PORT
        
        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Magenta
        Write-Host "  ║  MULTI-AGENT VISUALIZER                  ║" -ForegroundColor Magenta
        Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Magenta
        Write-Host ""
        
        if ($backendRunning -and $frontendRunning) {
            Write-Host "  ✓ Already running!" -ForegroundColor Green
        } else {
            if (-not $backendRunning) {
                Write-Host "  Starting backend..." -ForegroundColor Cyan -NoNewline
                Start-Process cmd -ArgumentList "/c", "cd /d `"$script:VIZ_DIR\backend`" && python app.py" -WindowStyle Minimized
                Start-Sleep -Seconds 3
                Write-Host " ✓" -ForegroundColor Green
            }
            if (-not $frontendRunning) {
                Write-Host "  Starting frontend..." -ForegroundColor Cyan -NoNewline
                Start-Process cmd -ArgumentList "/c", "cd /d `"$script:VIZ_DIR\frontend`" && npm run dev" -WindowStyle Minimized
                Start-Sleep -Seconds 3
                Write-Host " ✓" -ForegroundColor Green
            }
        }
        
        Write-Host ""
        Write-Host "  Frontend: " -NoNewline; Write-Host $frontendUrl -ForegroundColor Cyan
        Write-Host "  Backend:  " -NoNewline; Write-Host $backendUrl -ForegroundColor DarkGray
        Write-Host ""
    }
    
    # Handle -e (execution) flag
    if ($ExecutionId) {
        Start-VizServers
        $url = "$frontendUrl/executions/$ExecutionId"
        Write-Host "  → Opening execution: " -NoNewline; Write-Host $ExecutionId -ForegroundColor Yellow
        Start-Process $url
        return
    }
    
    # Handle -w (workflow) flag
    if ($WorkflowId) {
        Start-VizServers
        $url = "$frontendUrl/workflows/$WorkflowId"
        Write-Host "  → Opening workflow: " -NoNewline; Write-Host $WorkflowId -ForegroundColor Yellow
        Start-Process $url
        return
    }
    
    # Handle commands
    switch ($Command) {
        'start' { Start-VizServers }
        'stop' {
            Write-Host "  Stopping servers..." -ForegroundColor Yellow
            if (Stop-VizPort $script:VIZ_BACKEND_PORT) { Write-Host "  ✓ Backend stopped" -ForegroundColor Green }
            if (Stop-VizPort $script:VIZ_FRONTEND_PORT) { Write-Host "  ✓ Frontend stopped" -ForegroundColor Green }
        }
        'restart' {
            viz stop; Start-Sleep -Seconds 2; viz start
        }
        'status' {
            Write-Host ""
            Write-Host "  Backend  (${script:VIZ_BACKEND_PORT}): " -NoNewline
            if (Test-VizPort $script:VIZ_BACKEND_PORT) { Write-Host "● Running" -ForegroundColor Green } else { Write-Host "○ Stopped" -ForegroundColor Red }
            Write-Host "  Frontend (${script:VIZ_FRONTEND_PORT}): " -NoNewline
            if (Test-VizPort $script:VIZ_FRONTEND_PORT) { Write-Host "● Running" -ForegroundColor Green } else { Write-Host "○ Stopped" -ForegroundColor Red }
            Write-Host ""
        }
        'api' {
            Start-VizServers
            Start-Process "$backendUrl/docs"
        }
        'help' {
            Write-Host ""
            Write-Host "  VIZ - Multi-Agent Visualizer" -ForegroundColor Magenta
            Write-Host "  ────────────────────────────" -ForegroundColor DarkGray
            Write-Host "  viz                    Open dashboard" -ForegroundColor White
            Write-Host "  viz -e <exec_id>       Open execution" -ForegroundColor White
            Write-Host "  viz -w <workflow_id>   Open workflow" -ForegroundColor White
            Write-Host "  viz start|stop|status  Server control" -ForegroundColor White
            Write-Host "  viz api                API docs" -ForegroundColor White
            Write-Host ""
        }
        default {
            Start-VizServers
            if (-not $NoBrowser) { Start-Process $frontendUrl }
        }
    }
}

# Tab completion for viz command
Register-ArgumentCompleter -CommandName viz -ParameterName Command -ScriptBlock {
    param($cmd, $param, $word)
    @('start', 'stop', 'status', 'restart', 'api', 'help') | Where-Object { $_ -like "$word*" }
}

# ============================================
# BACKGROUND INITIALIZATION (Deferred)
# ============================================
# Start background job to load heavy operations after prompt is ready
$null = Start-Job -ScriptBlock {
    # Pre-compile regex patterns, warm up caches, etc.
    $null = [regex]::new('test')
} | Out-Null
