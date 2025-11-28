# ============================================
# 🚀 INTERACTIVE CLI CHEATSHEET
# ============================================
# Usage: cheat | cheat <category> | cheat -Search <term> | cheat -All
# Categories: files, search, nav, git, network, process, fzf, json, python, node, docker, azure

$script:CheatColors = @{
    Title = 'Cyan'; Category = 'Yellow'; Command = 'Green'
    Description = 'White'; Example = 'DarkGray'; Border = 'DarkCyan'; Highlight = 'Magenta'
}

$script:CheatData = @{
    'files' = @{
        Title = '📁 FILE OPERATIONS (eza, bat, fd)'
        Commands = @(
            @{ Cmd = 'ls'; Desc = 'List with icons'; Full = 'eza --icons --group-directories-first' }
            @{ Cmd = 'll'; Desc = 'Long list + git status'; Full = 'eza -la --icons --git' }
            @{ Cmd = 'la'; Desc = 'List all (no icons, fast)'; Full = 'eza -la' }
            @{ Cmd = 'lt'; Desc = 'Tree view (2 levels)'; Full = 'eza --tree --level=2' }
            @{ Cmd = 'tree'; Desc = 'Tree view (3 levels)'; Full = 'eza --tree --icons --level=3' }
            @{ Cmd = 'lf'; Desc = 'Files only'; Full = 'eza -l --only-files' }
            @{ Cmd = 'ld'; Desc = 'Directories only'; Full = 'eza -lD' }
            @{ Cmd = 'lS'; Desc = 'Sort by size'; Full = 'eza -l --sort=size --reverse' }
            @{ Cmd = 'cat'; Desc = 'View with syntax highlight'; Full = 'bat --style=auto' }
            @{ Cmd = 'mkcd'; Desc = 'Create & enter directory'; Full = 'mkdir + cd' }
        )
    }
    'search' = @{
        Title = '🔍 SEARCH & FIND (fd, ripgrep)'
        Commands = @(
            @{ Cmd = 'ff *.py'; Desc = 'Find by glob pattern'; Full = 'fd --glob <pattern>' }
            @{ Cmd = 'ffd'; Desc = 'Find directories only'; Full = 'fd --type d' }
            @{ Cmd = 'fff'; Desc = 'Find files only'; Full = 'fd --type f' }
            @{ Cmd = 'fext py'; Desc = 'Find by extension'; Full = 'fd --extension <ext>' }
            @{ Cmd = 'fmod 7'; Desc = 'Modified in N days'; Full = 'fd --changed-within' }
            @{ Cmd = 'grep TODO'; Desc = 'Search in files'; Full = 'rg <pattern>' }
            @{ Cmd = 'fhere'; Desc = 'Search current dir only'; Full = 'rg --max-depth 1' }
            @{ Cmd = 'frg'; Desc = 'Ripgrep + fzf + preview'; Full = 'rg | fzf + bat' }
        )
    }
    'nav' = @{
        Title = '🧭 NAVIGATION (zoxide)'
        Commands = @(
            @{ Cmd = 'z doc'; Desc = 'Smart jump to dir'; Full = 'zoxide query + cd' }
            @{ Cmd = 'zi'; Desc = 'Interactive dir picker'; Full = 'zoxide + fzf' }
            @{ Cmd = '..'; Desc = 'Up one level'; Full = 'cd ..' }
            @{ Cmd = '...'; Desc = 'Up two levels'; Full = 'cd ..\..' }
            @{ Cmd = 'home'; Desc = 'Go to home'; Full = 'cd $HOME' }
            @{ Cmd = 'docs'; Desc = 'Go to Documents'; Full = 'cd ~/Documents' }
            @{ Cmd = 'dl'; Desc = 'Go to Downloads'; Full = 'cd ~/Downloads' }
            @{ Cmd = 'cdf'; Desc = 'Fuzzy cd with fzf'; Full = 'Get-ChildItem | fzf' }
        )
    }
    'git' = @{
        Title = '🔀 GIT (20 essential commands)'
        Commands = @(
            @{ Cmd = 'gs'; Desc = 'Status (short)'; Full = 'git status -sb' }
            @{ Cmd = 'ga'; Desc = 'Add all'; Full = 'git add .' }
            @{ Cmd = 'gc "msg"'; Desc = 'Commit'; Full = 'git commit -m' }
            @{ Cmd = 'gca "msg"'; Desc = 'Add + Commit'; Full = 'git commit -am' }
            @{ Cmd = 'gp'; Desc = 'Push'; Full = 'git push' }
            @{ Cmd = 'gpl'; Desc = 'Pull'; Full = 'git pull' }
            @{ Cmd = 'gd'; Desc = 'Diff'; Full = 'git diff' }
            @{ Cmd = 'gds'; Desc = 'Diff staged'; Full = 'git diff --staged' }
            @{ Cmd = 'gl'; Desc = 'Log (15 lines)'; Full = 'git log --oneline -15' }
            @{ Cmd = 'gb'; Desc = 'Branches'; Full = 'git branch -a' }
            @{ Cmd = 'gco main'; Desc = 'Checkout'; Full = 'git checkout' }
            @{ Cmd = 'gcb feat'; Desc = 'Create branch'; Full = 'git checkout -b' }
            @{ Cmd = 'gst'; Desc = 'Stash'; Full = 'git stash' }
            @{ Cmd = 'gstp'; Desc = 'Stash pop'; Full = 'git stash pop' }
            @{ Cmd = 'gm main'; Desc = 'Merge'; Full = 'git merge' }
            @{ Cmd = 'gundo'; Desc = 'Undo last commit'; Full = 'git reset --soft HEAD~1' }
            @{ Cmd = 'gwip'; Desc = 'Quick WIP commit'; Full = 'git add -A; git commit -m WIP' }
            @{ Cmd = 'fzglog'; Desc = 'Interactive log'; Full = 'git log | fzf' }
            @{ Cmd = 'fzgbr'; Desc = 'Interactive branch'; Full = 'git branch | fzf' }
        )
    }
    'network' = @{
        Title = '🌐 NETWORK (dog, httpie)'
        Commands = @(
            @{ Cmd = 'dns google.com'; Desc = 'DNS lookup'; Full = 'dog <domain>' }
            @{ Cmd = 'dnsmx'; Desc = 'MX record (mail)'; Full = 'dog <domain> MX' }
            @{ Cmd = 'GET url'; Desc = 'HTTP GET'; Full = 'httpie GET' }
            @{ Cmd = 'POST url'; Desc = 'HTTP POST'; Full = 'httpie POST' }
            @{ Cmd = 'pubip'; Desc = 'Public IP'; Full = 'curl ifconfig.me' }
            @{ Cmd = 'localip'; Desc = 'Local IP'; Full = 'Get-NetIPAddress' }
            @{ Cmd = 'ports'; Desc = 'Listening ports'; Full = 'Get-NetTCPConnection' }
            @{ Cmd = 'killport 3000'; Desc = 'Kill port'; Full = 'Stop-Process on port' }
        )
    }
    'process' = @{
        Title = '📊 PROCESS & SYSTEM (procs, duf)'
        Commands = @(
            @{ Cmd = 'ps'; Desc = 'Process list'; Full = 'procs' }
            @{ Cmd = 'psa'; Desc = 'Process tree'; Full = 'procs --tree' }
            @{ Cmd = 'psk'; Desc = 'Sort by CPU'; Full = 'procs --sortd cpu' }
            @{ Cmd = 'psm'; Desc = 'Sort by memory'; Full = 'procs --sortd mem' }
            @{ Cmd = 'htop'; Desc = 'Process viewer'; Full = 'Custom htop' }
            @{ Cmd = 'df'; Desc = 'Disk usage'; Full = 'duf' }
            @{ Cmd = 'port python'; Desc = 'Ports by process'; Full = 'Get-NetTCPConnection' }
        )
    }
    'fzf' = @{
        Title = '🔮 FZF MAGIC'
        Commands = @(
            @{ Cmd = 'Ctrl+R'; Desc = 'Fuzzy history'; Full = 'PSFzf history' }
            @{ Cmd = 'Ctrl+T'; Desc = 'Fuzzy file finder'; Full = 'PSFzf files' }
            @{ Cmd = 'fzfp'; Desc = 'Files + preview'; Full = 'fd | fzf + bat' }
            @{ Cmd = 'fzfd'; Desc = 'Directories + preview'; Full = 'fd -t d | fzf' }
            @{ Cmd = 'fzkill'; Desc = 'Kill process'; Full = 'Get-Process | fzf' }
            @{ Cmd = 'cdf'; Desc = 'Fuzzy cd'; Full = 'dirs | fzf + cd' }
        )
    }
    'python' = @{
        Title = '🐍 PYTHON'
        Commands = @(
            @{ Cmd = 'py'; Desc = 'Run Python'; Full = 'python' }
            @{ Cmd = 'venv'; Desc = 'Create venv'; Full = 'python -m venv venv' }
            @{ Cmd = 'activate'; Desc = 'Activate venv'; Full = './venv/Scripts/Activate' }
            @{ Cmd = 'pipreq'; Desc = 'Install requirements'; Full = 'pip install -r requirements.txt' }
            @{ Cmd = 'pipfreeze'; Desc = 'Export requirements'; Full = 'pip freeze > requirements.txt' }
            @{ Cmd = 'uvrun'; Desc = 'FastAPI dev'; Full = 'uvicorn main:app --reload' }
            @{ Cmd = 'djrun'; Desc = 'Django dev'; Full = 'python manage.py runserver' }
            @{ Cmd = 'serve 8000'; Desc = 'HTTP server'; Full = 'python -m http.server' }
        )
    }
    'node' = @{
        Title = '📦 NODE.JS'
        Commands = @(
            @{ Cmd = 'ni'; Desc = 'npm install'; Full = 'npm install' }
            @{ Cmd = 'nrd'; Desc = 'npm run dev'; Full = 'npm run dev' }
            @{ Cmd = 'nrb'; Desc = 'npm run build'; Full = 'npm run build' }
            @{ Cmd = 'yi'; Desc = 'yarn install'; Full = 'yarn install' }
            @{ Cmd = 'pi'; Desc = 'pnpm install'; Full = 'pnpm install' }
        )
    }
    'docker' = @{
        Title = '🐳 DOCKER'
        Commands = @(
            @{ Cmd = 'dkps'; Desc = 'List containers'; Full = 'docker ps' }
            @{ Cmd = 'dki'; Desc = 'List images'; Full = 'docker images' }
            @{ Cmd = 'dkcu'; Desc = 'Compose up'; Full = 'docker-compose up -d' }
            @{ Cmd = 'dkcd'; Desc = 'Compose down'; Full = 'docker-compose down' }
            @{ Cmd = 'dklogs app'; Desc = 'Follow logs'; Full = 'docker logs -f' }
            @{ Cmd = 'dkexec app'; Desc = 'Exec into container'; Full = 'docker exec -it' }
            @{ Cmd = 'dkprune'; Desc = 'Clean up'; Full = 'docker system prune -af' }
        )
    }
    'azure' = @{
        Title = '☁️ AZURE TOOLS'
        Commands = @(
            @{ Cmd = 'blob <exec_id>'; Desc = 'Download blob folder'; Full = 'az storage blob download-batch' }
            @{ Cmd = 'blob <id> -l'; Desc = 'List blob contents (tree)'; Full = 'az storage blob list' }
            @{ Cmd = 'blob <id> -m'; Desc = 'View metadata.json'; Full = 'az storage blob download (to stdout)' }
            @{ Cmd = 'blob -Agent <id>'; Desc = 'List agent executions'; Full = 'az storage blob list (grouped)' }
            @{ Cmd = 'applog'; Desc = 'Stream app logs'; Full = 'az webapp log tail' }
            @{ Cmd = 'applog -e'; Desc = 'Stream errors only'; Full = 'az webapp log tail (filtered)' }
            @{ Cmd = 'applog -s'; Desc = 'App status'; Full = 'az webapp show' }
            @{ Cmd = 'applog -d'; Desc = 'Download logs'; Full = 'az webapp log download' }
        )
    }
    'editors' = @{
        Title = '✏️ EDITORS'
        Commands = @(
            @{ Cmd = 'kate file'; Desc = 'Open in Kate'; Full = 'Start-Process kate' }
            @{ Cmd = 'kate'; Desc = 'New blank document'; Full = 'Start-Process kate' }
            @{ Cmd = 'md file'; Desc = 'Create/open .md in MarkText'; Full = 'Creates if not exists' }
            @{ Cmd = 'code .'; Desc = 'VS Code here'; Full = 'code .' }
            @{ Cmd = 'ci .'; Desc = 'VS Code Insiders'; Full = 'code-insiders .' }
            @{ Cmd = 'new file.py'; Desc = 'Create + open file'; Full = 'touch + kate' }
        )
    }
    'urls' = @{
        Title = '🌐 URL SHORTCUTS & SEARCH'
        Commands = @(
            @{ Cmd = 'g search term'; Desc = 'Google search'; Full = 'google.com/search?q=...' }
            @{ Cmd = 'gw reddit llms'; Desc = 'Google within site'; Full = 'site:reddit.com llms' }
            @{ Cmd = 'gw py async'; Desc = 'Search in url shortcut'; Full = 'Uses urls config for domain' }
            @{ Cmd = 'yt video name'; Desc = 'YouTube search'; Full = 'youtube.com/results' }
            @{ Cmd = 'u leetcode'; Desc = 'Open site (.com)'; Full = 'www.leetcode.com' }
            @{ Cmd = 'u reddit term'; Desc = 'Search within site'; Full = 'reddit.com/search?q=term' }
            @{ Cmd = 'urls'; Desc = 'Manage URL shortcuts'; Full = 'Interactive manager' }
            @{ Cmd = 'urls add py docs.python.org'; Desc = 'Add shortcut'; Full = 'Saves to Desktop/url-shortcuts.txt' }
            @{ Cmd = 'urls edit py url'; Desc = 'Edit shortcut'; Full = 'Updates config file' }
            @{ Cmd = 'urls rm py'; Desc = 'Remove shortcut'; Full = 'Removes from config' }
            @{ Cmd = 'urls list'; Desc = 'List all shortcuts'; Full = 'Shows saved shortcuts' }
            @{ Cmd = 'potd'; Desc = 'LeetCode Problem of Day'; Full = 'GraphQL query + open' }
        )
    }
    'utils' = @{
        Title = '🛠️ UTILITIES'
        Commands = @(
            @{ Cmd = 'copypath'; Desc = 'Copy current path'; Full = 'pwd | Set-Clipboard' }
            @{ Cmd = 'uuid'; Desc = 'Generate UUID'; Full = '[guid]::NewGuid()' }
            @{ Cmd = 'base64e text'; Desc = 'Base64 encode'; Full = '[Convert]::ToBase64String' }
            @{ Cmd = 'now'; Desc = 'Current datetime'; Full = 'Get-Date' }
            @{ Cmd = 'timer 60'; Desc = 'Timer with beep'; Full = 'Start-Sleep + beep' }
            @{ Cmd = 'weather'; Desc = 'Current weather'; Full = 'wttr.in' }
            @{ Cmd = 'reload'; Desc = 'Reload profile'; Full = '. $PROFILE' }
            @{ Cmd = 'note msg'; Desc = 'Quick note (daily)'; Full = 'Append to ~/Desktop/notes-DATE.txt' }
            @{ Cmd = 'bm'; Desc = 'List bookmarks'; Full = '$global:Bookmarks' }
            @{ Cmd = 'bm name'; Desc = 'Go to bookmark'; Full = 'cd $global:Bookmarks[name]' }
            @{ Cmd = 'extract f.zip'; Desc = 'Extract archive'; Full = 'Expand-Archive / tar' }
        )
    }
    'json' = @{
        Title = '📋 JSON (jq)'
        Commands = @(
            @{ Cmd = 'jq .'; Desc = 'Pretty print JSON'; Full = 'jq .' }
            @{ Cmd = 'jq .key'; Desc = 'Get property'; Full = 'jq .key' }
            @{ Cmd = 'jq .key[]'; Desc = 'Iterate array'; Full = 'jq .key[]' }
            @{ Cmd = 'jq -r .key'; Desc = 'Raw output'; Full = 'jq -r .key' }
            @{ Cmd = 'jqf file.json'; Desc = 'Format file'; Full = 'jq . file.json' }
            @{ Cmd = 'jqc .'; Desc = 'Compact JSON'; Full = 'jq -c .' }
        )
    }
    'todo' = @{
        Title = '📋 TODO SYSTEM'
        Commands = @(
            @{ Cmd = 't'; Desc = 'List all todos'; Full = 'todo' }
            @{ Cmd = 't Task name'; Desc = 'Add new todo'; Full = 'todo "task"' }
            @{ Cmd = 't -p 1 Task'; Desc = 'Add priority 1 (critical)'; Full = 'todo -p 1 "task"' }
            @{ Cmd = 't -c work Task'; Desc = 'Add with category'; Full = 'todo -c work "task"' }
            @{ Cmd = 't -d tomorrow'; Desc = 'Add with due date'; Full = 'todo -d tomorrow "task"' }
            @{ Cmd = 't done 3'; Desc = 'Complete todo #3'; Full = 'todo done 3' }
            @{ Cmd = 't rm 5'; Desc = 'Remove todo #5'; Full = 'todo rm 5' }
            @{ Cmd = 't stats'; Desc = 'View statistics'; Full = 'todo stats' }
            @{ Cmd = 't today'; Desc = 'Due today'; Full = 'todo today' }
            @{ Cmd = 't -Help'; Desc = 'Full help'; Full = 'todo -Help' }
        )
    }
}

function cheat {
    param(
        [Parameter(Position=0)][string]$Category = '',
        [string]$Search = '',
        [switch]$List,
        [switch]$All
    )
    
    Write-Host ""
    Write-Host "  ╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor $script:CheatColors.Border
    Write-Host "  ║  🚀 POWERSHELL 7 CLI CHEATSHEET                                            ║" -ForegroundColor $script:CheatColors.Title
    Write-Host "  ╚════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor $script:CheatColors.Border
    Write-Host ""
    
    # List categories
    if ($List -or (-not $Category -and -not $Search -and -not $All)) {
        Write-Host "  📚 CATEGORIES:" -ForegroundColor $script:CheatColors.Category
        Write-Host "  ──────────────────────────────────────────" -ForegroundColor $script:CheatColors.Border
        $script:CheatData.Keys | Sort-Object | ForEach-Object {
            $count = $script:CheatData[$_].Commands.Count
            Write-Host "    " -NoNewline
            Write-Host $_.PadRight(12) -NoNewline -ForegroundColor $script:CheatColors.Command
            Write-Host "→ $($script:CheatData[$_].Title) " -NoNewline -ForegroundColor $script:CheatColors.Description
            Write-Host "($count)" -ForegroundColor $script:CheatColors.Example
        }
        Write-Host ""
        Write-Host "  💡 " -NoNewline -ForegroundColor $script:CheatColors.Highlight
        Write-Host "cheat git" -NoNewline -ForegroundColor $script:CheatColors.Command
        Write-Host " | " -NoNewline -ForegroundColor $script:CheatColors.Border
        Write-Host "cheat -Search dns" -NoNewline -ForegroundColor $script:CheatColors.Command
        Write-Host " | " -NoNewline -ForegroundColor $script:CheatColors.Border
        Write-Host "cheat -All" -ForegroundColor $script:CheatColors.Command
        Write-Host ""
        return
    }
    
    # Search
    if ($Search) {
        Write-Host "  🔍 SEARCH: '$Search'" -ForegroundColor $script:CheatColors.Highlight
        Write-Host "  ──────────────────────────────────────────" -ForegroundColor $script:CheatColors.Border
        $found = $false
        foreach ($cat in $script:CheatData.Keys | Sort-Object) {
            $matches = $script:CheatData[$cat].Commands | Where-Object { $_.Cmd -like "*$Search*" -or $_.Desc -like "*$Search*" -or $_.Full -like "*$Search*" }
            if ($matches) {
                $found = $true
                Write-Host "`n  $($script:CheatData[$cat].Title)" -ForegroundColor $script:CheatColors.Category
                foreach ($cmd in $matches) {
                    Write-Host "    " -NoNewline
                    Write-Host $cmd.Cmd.PadRight(18) -NoNewline -ForegroundColor $script:CheatColors.Command
                    Write-Host $cmd.Desc -ForegroundColor $script:CheatColors.Description
                }
            }
        }
        if (-not $found) { Write-Host "  ❌ No matches for '$Search'" -ForegroundColor Red }
        Write-Host ""
        return
    }
    
    # Show category or all
    $cats = if ($All) { $script:CheatData.Keys | Sort-Object } else { @($Category) }
    
    foreach ($cat in $cats) {
        if ($script:CheatData.ContainsKey($cat)) {
            $data = $script:CheatData[$cat]
            Write-Host "  $($data.Title)" -ForegroundColor $script:CheatColors.Category
            Write-Host "  ──────────────────────────────────────────" -ForegroundColor $script:CheatColors.Border
            foreach ($cmd in $data.Commands) {
                Write-Host "    " -NoNewline
                Write-Host $cmd.Cmd.PadRight(18) -NoNewline -ForegroundColor $script:CheatColors.Command
                Write-Host $cmd.Desc.PadRight(25) -NoNewline -ForegroundColor $script:CheatColors.Description
                Write-Host "→ $($cmd.Full)" -ForegroundColor $script:CheatColors.Example
            }
            Write-Host ""
        } else {
            Write-Host "  ❌ Category '$cat' not found. Use: cheat -List" -ForegroundColor Red
        }
    }
}

# Quick aliases
function h { cheat -List }
function helpme { cheat -List }
function commands { cheat -List }
