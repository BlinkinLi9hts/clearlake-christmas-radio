# Clearlake Christmas Radio - Auto-Commit Watcher (resident tray "TSR")
# Run:  powershell -ExecutionPolicy Bypass -File clearlake-watch.ps1
# Stop: right-click the tray "C" -> Stop watcher, or Ctrl+C
#
# What it does: watches the repo, and a few seconds after any change it
# runs git add + commit, then push (if a remote is configured).
#
# NOTE (differs from the Maestromia watcher on purpose):
#   1. No "live in ~60s" deploy step - this project has no static host yet.
#      The watcher's job right now is auto-versioning the repo to git.
#      When the PWA lands (P3+) we can wire a real deploy hook here.
#   2. If no git remote/upstream is set yet, it commits LOCALLY and says so,
#      instead of throwing scary push failures.

$WatchDir = "C:\Projects\clearlake-christmas-radio"
$Debounce = 3

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Generate clearlake.ico on first run (16/32/48/256) --------------------
$IcoPath = "$WatchDir\clearlake.ico"
if (-not (Test-Path $IcoPath)) {
    try {
        $sizes  = @(16, 32, 48, 256)
        $stream = New-Object System.IO.MemoryStream
        $writer = New-Object System.IO.BinaryWriter($stream)
        $frames = @()
        foreach ($sz in $sizes) {
            $bmp = New-Object System.Drawing.Bitmap($sz, $sz)
            $g   = [System.Drawing.Graphics]::FromImage($bmp)
            $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
            $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
            $g.Clear([System.Drawing.Color]::FromArgb(18, 30, 22))
            $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(22, 40, 28))
            $g.FillRectangle($bgBrush, 0, 0, $sz, $sz)
            $bgBrush.Dispose()
            $fontSize = [Math]::Round($sz * 0.62)
            $font  = New-Object System.Drawing.Font("Arial", $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
            $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 169, 110))
            $sf    = New-Object System.Drawing.StringFormat
            $sf.Alignment     = [System.Drawing.StringAlignment]::Center
            $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
            $rect  = New-Object System.Drawing.RectangleF(0, 0, $sz, $sz)
            $g.DrawString("C", $font, $brush, $rect, $sf)
            $g.Dispose(); $font.Dispose(); $brush.Dispose()
            $ms = New-Object System.IO.MemoryStream
            $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
            $frames += @{ Size = $sz; Bytes = $ms.ToArray() }
            $ms.Dispose(); $bmp.Dispose()
        }
        $writer.Write([uint16]0); $writer.Write([uint16]1); $writer.Write([uint16]$frames.Count)
        $dataOffset = 6 + ($frames.Count * 16)
        foreach ($f in $frames) {
            $s = if ($f.Size -eq 256) { 0 } else { $f.Size }
            $writer.Write([byte]$s); $writer.Write([byte]$s); $writer.Write([byte]0); $writer.Write([byte]0)
            $writer.Write([uint16]1); $writer.Write([uint16]32)
            $writer.Write([uint32]$f.Bytes.Length); $writer.Write([uint32]$dataOffset)
            $dataOffset += $f.Bytes.Length
        }
        foreach ($f in $frames) { $writer.Write($f.Bytes) }
        $writer.Flush()
        [System.IO.File]::WriteAllBytes($IcoPath, $stream.ToArray())
        $stream.Dispose(); $writer.Dispose()
        Write-Host "Generated clearlake.ico"
    } catch {
        Write-Host "Could not generate .ico: $_"
    }
}

# --- Tray icon bitmaps (festive states) ------------------------------------
function New-TrayIcon([string]$label, [System.Drawing.Color]$bg, [System.Drawing.Color]$fg) {
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear($bg)
    $font  = New-Object System.Drawing.Font("Arial", 8, [System.Drawing.FontStyle]::Bold)
    $brush = New-Object System.Drawing.SolidBrush($fg)
    $sf    = New-Object System.Drawing.StringFormat
    $sf.Alignment     = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $rect  = New-Object System.Drawing.RectangleF(0, 0, 16, 16)
    $g.DrawString($label, $font, $brush, $rect, $sf)
    $g.Dispose(); $font.Dispose(); $brush.Dispose()
    return [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
}

$iconIdle  = New-TrayIcon "C" ([System.Drawing.Color]::FromArgb(18, 40, 26))   ([System.Drawing.Color]::FromArgb(200, 169, 110))  # evergreen / gold
$iconBusy  = New-TrayIcon "C" ([System.Drawing.Color]::FromArgb(170, 50, 50))  ([System.Drawing.Color]::FromArgb(255, 245, 235))  # holly red
$iconError = New-TrayIcon "C" ([System.Drawing.Color]::FromArgb(200, 40, 40))  ([System.Drawing.Color]::FromArgb(255, 235, 120))  # alarm red / gold

$tray         = New-Object System.Windows.Forms.NotifyIcon
$tray.Icon    = $iconIdle
$tray.Visible = $true
$tray.Text    = "Clearlake Christmas Radio - idle"

# --- Context menu ----------------------------------------------------------
$menu = New-Object System.Windows.Forms.ContextMenuStrip

$miStatus = New-Object System.Windows.Forms.ToolStripMenuItem
$miStatus.Text = "Watching $WatchDir"; $miStatus.Enabled = $false
$menu.Items.Add($miStatus) | Out-Null

$menu.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator)) | Out-Null

$miLast = New-Object System.Windows.Forms.ToolStripMenuItem
$miLast.Text = "No commits yet"; $miLast.Enabled = $false
$menu.Items.Add($miLast) | Out-Null

$miCount = New-Object System.Windows.Forms.ToolStripMenuItem
$miCount.Text = "Commits this session: 0"; $miCount.Enabled = $false
$menu.Items.Add($miCount) | Out-Null

$menu.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator)) | Out-Null

$miExplorer = New-Object System.Windows.Forms.ToolStripMenuItem
$miExplorer.Text = "Open project folder"
$miExplorer.add_Click({ Start-Process "explorer.exe" $WatchDir })
$menu.Items.Add($miExplorer) | Out-Null

$menu.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator)) | Out-Null

$miStop = New-Object System.Windows.Forms.ToolStripMenuItem
$miStop.Text = "Stop watcher"
$miStop.add_Click({
    $tray.Visible = $false; $tray.Dispose()
    [System.Windows.Forms.Application]::Exit(); exit
})
$menu.Items.Add($miStop) | Out-Null

$tray.ContextMenuStrip = $menu
$tray.add_DoubleClick({ Start-Process "explorer.exe" $WatchDir })

function Set-TrayState([string]$state, [string]$tip) {
    switch ($state) {
        "idle"  { $tray.Icon = $iconIdle;  $tray.Text = "Clearlake CR - $tip" }
        "busy"  { $tray.Icon = $iconBusy;  $tray.Text = "Clearlake CR - $tip" }
        "error" { $tray.Icon = $iconError; $tray.Text = "Clearlake CR - $tip" }
    }
}

function Show-Balloon([string]$title, [string]$msg, [string]$type = "Info") {
    $tipType = switch ($type) {
        "Error"   { [System.Windows.Forms.ToolTipIcon]::Error }
        "Warning" { [System.Windows.Forms.ToolTipIcon]::Warning }
        default   { [System.Windows.Forms.ToolTipIcon]::Info }
    }
    $tray.ShowBalloonTip(4000, $title, $msg, $tipType)
}

Set-Location $WatchDir

function Test-HasRemote {
    $r = git remote 2>$null
    return -not [string]::IsNullOrWhiteSpace(($r | Out-String))
}

function Get-Snapshot {
    Get-ChildItem -Path $WatchDir -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\(\.git|node_modules|dist|build|\.cache|media|library)\\' } |
        ForEach-Object { $_.FullName + "|" + $_.LastWriteTime.ToString() }
}

$script:commitCount = 0

function Push-Changes {
    Set-TrayState "busy" "committing..."
    [System.Windows.Forms.Application]::DoEvents()
    git add . 2>&1 | Out-Null
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $commitOut = git commit -m "auto: $ts" 2>&1
    if ($commitOut -match "nothing to commit") {
        Set-TrayState "idle" "idle - nothing to commit"
        return
    }
    $script:commitCount++
    $miCount.Text = "Commits this session: $script:commitCount"

    if (-not (Test-HasRemote)) {
        Set-TrayState "idle" "committed locally $ts"
        $miLast.Text = "Last commit (local): $ts"
        Show-Balloon "Committed locally" "No git remote set yet - commit saved, nothing pushed."
        return
    }

    $pushOut = git push 2>&1
    if ($LASTEXITCODE -eq 0) {
        Set-TrayState "idle" "pushed $ts"
        $miLast.Text = "Last push: $ts"
        Show-Balloon "Clearlake CR pushed" "Committed + pushed to git."
    } else {
        Set-TrayState "error" "push failed (committed locally)"
        $miLast.Text = "Push FAILED $ts (commit saved)"
        Show-Balloon "Push failed" (($pushOut | Out-String) + "`nCommit is saved locally.") "Warning"
    }
}

# --- Startup ---------------------------------------------------------------
Show-Balloon "Clearlake Christmas Radio watcher started" "Watching for changes. Right-click the C for options."
Set-TrayState "idle" "idle"

$prev       = Get-Snapshot
$dirty      = $false
$lastChange = [datetime]::MinValue

$timer          = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.add_Tick({
    $curr    = Get-Snapshot
    $added   = $curr | Where-Object { $prev -notcontains $_ }
    $removed = $prev | Where-Object { $curr -notcontains $_ }
    if ($added -or $removed) {
        $script:prev       = $curr
        $script:dirty      = $true
        $script:lastChange = [datetime]::Now
        Set-TrayState "busy" "change detected..."
    }
    if ($script:dirty -and ([datetime]::Now - $script:lastChange).TotalSeconds -ge $Debounce) {
        $script:dirty = $false
        Push-Changes
    }
})
$timer.Start()
[System.Windows.Forms.Application]::Run()
