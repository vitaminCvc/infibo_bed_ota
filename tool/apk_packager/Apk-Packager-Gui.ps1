[CmdletBinding()]
param(
    [switch]$SmokeTest,
    [switch]$SmokeBuild,
    [switch]$TestBuildAll,
    [string]$TestProjectRoot,
    [string]$TestFlutterExecutable,
    [string]$TestDestination,
    [string]$TestDefinitionsPath,
    [string]$TestSettingsPath,
    [string]$TestScreenshotPath
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'Editions.ps1')

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ($TestProjectRoot) { $projectRoot = $TestProjectRoot }
$worker = Join-Path $PSScriptRoot 'Build-InfiboApks.ps1'
$definitionsPath = if ($TestDefinitionsPath) { $TestDefinitionsPath } else { Join-Path $PSScriptRoot 'editions.json' }
$editions = @(Get-InfiboEditions -Path $definitionsPath)
$settingsPath = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'InfiboOtaApkPackager\destinations.json'
if ($TestSettingsPath) { $settingsPath = $TestSettingsPath }
$savedDestinations = @{}
if (Test-Path -LiteralPath $settingsPath -PathType Leaf) {
    try {
        $saved = Get-Content -LiteralPath $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($property in $saved.PSObject.Properties) {
            $savedDestinations[$property.Name] = [string]$property.Value
        }
    }
    catch {
        $savedDestinations = @{}
    }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Infibo OTA APK 打包工具'
$form.ClientSize = [System.Drawing.Size]::new(960, 690)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = [System.Drawing.Font]::new('Microsoft YaHei UI', 10)

$intro = New-Object System.Windows.Forms.Label
$intro.Text = '每个版本都可以单独设置保存目录。打包完成后，APK 会自动移到对应目录。'
$intro.Location = [System.Drawing.Point]::new(20, 16)
$intro.Size = [System.Drawing.Size]::new(920, 30)
$form.Controls.Add($intro)

$grid = New-Object System.Windows.Forms.DataGridView
$grid.Location = [System.Drawing.Point]::new(20, 50)
$grid.Size = [System.Drawing.Size]::new(920, 360)
$grid.AllowUserToAddRows = $false
$grid.AllowUserToDeleteRows = $false
$grid.AllowUserToResizeRows = $false
$grid.RowHeadersVisible = $false
$grid.MultiSelect = $false
$grid.SelectionMode = 'CellSelect'
$grid.RowTemplate.Height = 34
$grid.ColumnHeadersHeight = 32
$grid.AutoSizeColumnsMode = 'None'

$checkColumn = New-Object System.Windows.Forms.DataGridViewCheckBoxColumn
$checkColumn.HeaderText = '打包'
$checkColumn.Width = 55
[void]$grid.Columns.Add($checkColumn)
$nameColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$nameColumn.HeaderText = '版本'
# 为“印度老版（无自动加水）”预留完整显示空间。
$nameColumn.Width = 230
$nameColumn.ReadOnly = $true
[void]$grid.Columns.Add($nameColumn)
$pathColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$pathColumn.HeaderText = 'APK 保存目录（可直接输入）'
$pathColumn.Width = 530
[void]$grid.Columns.Add($pathColumn)
$browseColumn = New-Object System.Windows.Forms.DataGridViewButtonColumn
$browseColumn.HeaderText = '选目录'
$browseColumn.Width = 80
$browseColumn.ReadOnly = $true
[void]$grid.Columns.Add($browseColumn)

$defaultRoot = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'Downloads\Infibo_OTA_APK'
foreach ($item in $editions) {
    $path = if ($savedDestinations.ContainsKey($item.Id) -and $savedDestinations[$item.Id]) {
        $savedDestinations[$item.Id]
    } else {
        Join-Path $defaultRoot $item.Id
    }
    $index = $grid.Rows.Add($false, $item.Label, $path, '浏览...')
    $grid.Rows[$index].Tag = $item.Id
}
$grid.ClearSelection()
$grid.CurrentCell = $null
$form.Controls.Add($grid)

function Save-Destinations {
    if (($SmokeTest -or $SmokeBuild) -and -not $TestSettingsPath) { return }
    $values = @{}
    foreach ($row in $grid.Rows) {
        $values[[string]$row.Tag] = [string]$row.Cells[2].Value
    }
    $directory = Split-Path -Parent $settingsPath
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $values | ConvertTo-Json -Compress | Set-Content -LiteralPath $settingsPath -Encoding UTF8
}

$grid.Add_CurrentCellDirtyStateChanged({
    if ($grid.IsCurrentCellDirty) {
        [void]$grid.CommitEdit([System.Windows.Forms.DataGridViewDataErrorContexts]::Commit)
    }
})
$grid.Add_CellEndEdit({ Save-Destinations })
$grid.Add_CellContentClick({
    param($sender, $eventArgs)
    if ($eventArgs.RowIndex -lt 0 -or $eventArgs.ColumnIndex -ne 3) { return }
    $row = $grid.Rows[$eventArgs.RowIndex]
    $current = [string]$row.Cells[2].Value
    $picker = New-Object System.Windows.Forms.FolderBrowserDialog
    $picker.Description = "选择 $($row.Cells[1].Value) 的 APK 保存目录"
    $picker.ShowNewFolderButton = $true
    if (Test-Path -LiteralPath $current -PathType Container) {
        $picker.SelectedPath = $current
    }
    try {
        if ($picker.ShowDialog($form) -eq [System.Windows.Forms.DialogResult]::OK) {
            $row.Cells[2].Value = $picker.SelectedPath
            Save-Destinations
        }
    }
    finally {
        $picker.Dispose()
    }
})

$selectedButton = New-Object System.Windows.Forms.Button
$selectedButton.Text = '打包选中版本'
$selectedButton.Location = [System.Drawing.Point]::new(20, 425)
$selectedButton.Size = [System.Drawing.Size]::new(150, 38)
$form.Controls.Add($selectedButton)

$allButton = New-Object System.Windows.Forms.Button
$allButton.Text = '一键打包全部'
$allButton.Location = [System.Drawing.Point]::new(180, 425)
$allButton.Size = [System.Drawing.Size]::new(150, 38)
$form.Controls.Add($allButton)

$openButton = New-Object System.Windows.Forms.Button
$openButton.Text = '打开当前版本目录'
$openButton.Location = [System.Drawing.Point]::new(340, 425)
$openButton.Size = [System.Drawing.Size]::new(150, 38)
$openButton.Add_Click({
    $row = if ($grid.CurrentRow) { $grid.CurrentRow } else { $grid.Rows[0] }
    $destination = ([string]$row.Cells[2].Value).Trim()
    if (-not $destination) { return }
    if (-not (Test-Path -LiteralPath $destination -PathType Container)) {
        New-Item -ItemType Directory -Path $destination -Force | Out-Null
    }
    Start-Process -FilePath 'explorer.exe' -ArgumentList ('"' + $destination + '"')
})
$form.Controls.Add($openButton)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = '等待打包'
$statusLabel.Location = [System.Drawing.Point]::new(20, 480)
$statusLabel.Size = [System.Drawing.Size]::new(920, 27)
$form.Controls.Add($statusLabel)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Location = [System.Drawing.Point]::new(20, 510)
$logBox.Size = [System.Drawing.Size]::new(920, 160)
$logBox.Multiline = $true
$logBox.ScrollBars = 'Vertical'
$logBox.ReadOnly = $true
$logBox.WordWrap = $false
$logBox.Font = [System.Drawing.Font]::new('Consolas', 9)
$form.Controls.Add($logBox)

if ($SmokeTest) {
    if ($grid.Rows.Count -ne $editions.Count -or -not (Test-Path -LiteralPath $worker)) {
        throw 'GUI smoke check failed.'
    }
    if ($TestDestination -and [string]$grid.Rows[0].Cells[2].Value -ne $TestDestination) {
        throw 'GUI did not reload the saved destination.'
    }
    if ($TestScreenshotPath) {
        $form.Show()
        [System.Windows.Forms.Application]::DoEvents()
        $bitmap = [System.Drawing.Bitmap]::new($form.Width, $form.Height)
        try {
            $form.DrawToBitmap($bitmap, [System.Drawing.Rectangle]::new(0, 0, $form.Width, $form.Height))
            $bitmap.Save($TestScreenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        finally {
            $bitmap.Dispose()
        }
    }
    Write-Output "GUI smoke passed: $($editions.Count) editions"
    $form.Dispose()
    return
}

$script:buildProcess = $null
$script:logPath = $null
$script:errorPath = $null
$script:statusPath = $null
$script:configPath = $null
$script:lastLogLength = 0

function Read-SharedText([string]$path) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return '' }
    $stream = [System.IO.FileStream]::new($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    try {
        $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::UTF8)
        return $reader.ReadToEnd()
    }
    finally {
        $stream.Dispose()
    }
}

function Refresh-Log {
    $content = Read-SharedText $script:logPath
    if ($content.Length -lt $script:lastLogLength) { $script:lastLogLength = 0 }
    if ($content.Length -gt $script:lastLogLength) {
        $logBox.AppendText($content.Substring($script:lastLogLength))
        $script:lastLogLength = $content.Length
        $logBox.SelectionStart = $logBox.TextLength
        $logBox.ScrollToCaret()
    }
}

function Start-Build([bool]$buildAll) {
    if ($script:buildProcess -and -not $script:buildProcess.HasExited) { return }
    [void]$grid.EndEdit()
    $selectedIds = @()
    $destinations = @{}
    foreach ($row in $grid.Rows) {
        if ($buildAll -or $row.Cells[0].Value -eq $true) {
            $id = [string]$row.Tag
            $folder = ([string]$row.Cells[2].Value).Trim()
            if (-not $folder) {
                [void][System.Windows.Forms.MessageBox]::Show($form, "请先设置 $($row.Cells[1].Value) 的保存目录。", '提示')
                $grid.CurrentCell = $row.Cells[2]
                return
            }
            $destinations[$id] = $folder
            if (-not $buildAll) { $selectedIds += $id }
        }
    }
    if (-not $buildAll -and $selectedIds.Count -eq 0) {
        [void][System.Windows.Forms.MessageBox]::Show($form, '请先勾选至少一个版本。', '提示')
        return
    }
    try {
        Save-Destinations
    }
    catch {
        [void][System.Windows.Forms.MessageBox]::Show($form, '保存目录设置失败：' + $_.Exception.Message, '提示')
        return
    }

    $runId = [guid]::NewGuid().ToString('N')
    $script:configPath = Join-Path $env:TEMP "infibo-apk-$runId.json"
    $script:logPath = Join-Path $env:TEMP "infibo-apk-$runId.log"
    $script:errorPath = Join-Path $env:TEMP "infibo-apk-$runId.err.log"
    $script:statusPath = Join-Path $env:TEMP "infibo-apk-$runId.status"
    $script:lastLogLength = 0
    @{
        editions = $selectedIds
        all = $buildAll
        destinations = $destinations
        projectRoot = $projectRoot
        definitionsPath = $definitionsPath
        flutterExecutable = if ($TestFlutterExecutable) { $TestFlutterExecutable } else { 'flutter' }
        statusPath = $script:statusPath
    } | ConvertTo-Json -Depth 4 -Compress | Set-Content -LiteralPath $script:configPath -Encoding UTF8

    $logBox.Clear()
    $statusLabel.Text = if ($buildAll) { "正在打包全部 $($editions.Count) 个版本..." } else { "正在打包 $($selectedIds.Count) 个版本..." }
    $selectedButton.Enabled = $false
    $allButton.Enabled = $false
    $grid.Enabled = $false

    try {
        $hostPath = Join-Path $PSHOME 'powershell.exe'
        $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $worker + '" -ConfigPath "' + $script:configPath + '"'
        $script:buildProcess = Start-Process -FilePath $hostPath -ArgumentList $arguments -WorkingDirectory $projectRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput $script:logPath -RedirectStandardError $script:errorPath
        $timer.Start()
    }
    catch {
        $statusLabel.Text = '启动失败：' + $_.Exception.Message
        $selectedButton.Enabled = $true
        $allButton.Enabled = $true
        $grid.Enabled = $true
    }
}

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500
$timer.Add_Tick({
    try {
        Refresh-Log
        if ($script:buildProcess -and $script:buildProcess.HasExited) {
            Refresh-Log
            $errorText = Read-SharedText $script:errorPath
            if ($errorText) { $logBox.AppendText("`r`n" + $errorText) }
            $code = if (Test-Path -LiteralPath $script:statusPath -PathType Leaf) {
                (Get-Content -LiteralPath $script:statusPath -Raw).Trim()
            } else {
                'unknown'
            }
            $statusLabel.Text = if ($code -eq 0) { '打包完成，APK 已移到指定目录。' } else { "打包失败（退出码 $code），请看下方日志。" }
            $timer.Stop()
            $script:buildProcess.Dispose()
            $script:buildProcess = $null
            $selectedButton.Enabled = $true
            $allButton.Enabled = $true
            $grid.Enabled = $true
            Remove-Item -LiteralPath @($script:configPath, $script:logPath, $script:errorPath, $script:statusPath) -ErrorAction SilentlyContinue
        }
    }
    catch {
        $timer.Stop()
        $statusLabel.Text = '读取打包进度失败：' + $_.Exception.Message
    }
})

$selectedButton.Add_Click({ Start-Build $false })
$allButton.Add_Click({ Start-Build $true })
$form.Add_FormClosing({
    param($sender, $eventArgs)
    if ($script:buildProcess -and -not $script:buildProcess.HasExited) {
        [void][System.Windows.Forms.MessageBox]::Show($form, '正在打包。请等打包完成后再关闭窗口。', '提示')
        $eventArgs.Cancel = $true
    }
})
if ($SmokeBuild) {
    if (-not $TestProjectRoot -or -not $TestFlutterExecutable -or -not $TestDestination) {
        throw 'SmokeBuild requires test project, Flutter executable and destination.'
    }
    if ($TestBuildAll) {
        foreach ($row in $grid.Rows) {
            $row.Cells[2].Value = Join-Path $TestDestination ([string]$row.Tag)
        }
    } else {
        $grid.Rows[0].Cells[2].Value = $TestDestination
        $grid.Rows[0].Cells[0].Value = $true
    }
    $form.Show()
    [System.Windows.Forms.Application]::DoEvents()
    if ($TestBuildAll) { $allButton.PerformClick() } else { $selectedButton.PerformClick() }
    $deadline = (Get-Date).AddSeconds(20)
    while ($script:buildProcess -and (Get-Date) -lt $deadline) {
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 100
    }
    if ($script:buildProcess -or $statusLabel.Text -notlike '打包完成*') {
        throw "GUI build failed: $($statusLabel.Text) $($logBox.Text)"
    }
    Write-Output 'GUI build passed'
    $timer.Dispose()
    $form.Dispose()
    return
}
[void]$form.ShowDialog()
$timer.Dispose()
$form.Dispose()
