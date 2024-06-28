Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Trim clip'
$form.Size = New-Object System.Drawing.Size(280, 200)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 1
$form.MinimizeBox = 0
$form.MaximizeBox = 0

$inputx = 2
$inputy = 25
$inputw = 40
$inputh = 30
$inputnumpadding = 5
$inputpunctpadding = 3
$punctw = 6
$puncth = 20

$endy = $inputy + $inputh - $inputnumpadding
$timey = $endy + $inputh - $inputnumpadding

$fileDir = $null
$filePath = $null
$fileName = $null
$fileExt = $null

$startTime = $null
$endTime = $null

#InitialDirectory = 'D:\Videos\OBS Archive\unwatched'
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = 'D:\Videos\OBS Archive\unwatched'
    Filter           = 'All files (*.*)|*.*|Videos (*.mp4;*.mkv)|*.mp4;*.mkv'
    FilterIndex      = 2
    RestoreDirectory = $True
}

function Update-Time-Label {
    #Write-Host ":D"
    
    $Script:startTime = "00:$($mins.Text):$($secs.Text).$($msecs.Text)"
    $Script:endTime = "00:$($emins.Text):$($esecs.Text).$($emsecs.Text)"

    $timeLabel.Text = "$($mins.Text)m:$($secs.Text)s.$($msecs.Text)ms - $($emins.Text)m:$($esecs.Text)s.$($emsecs.Text)ms"
}

function Open-Video {
    if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $FileBrowser.InitialDirectory = $null

        $Script:filePath = $FileBrowser.FileName #Gets or sets a string containing the file name selected in the file dialog box.
        $Script:fileName = $FileBrowser.SafeFileName #Gets the file name and extension for the file selected in the dialog box. The file name does not include the path.
        $Script:fileDir = Split-Path -Path $Script:filePath -Parent
        $Script:fileExt = [System.IO.Path]::GetExtension($Script:filePath)

        $browseLabel.Text = $fileName

        #Write-Host $fileName
    }
}

function Edit-Video {
    if ([System.IO.File]::Exists($Script:filePath)) {
        #Write-Host "trim clip"

        $outputPath = "$($Script:fileDir)\Trim $($Script:fileName)"

        Write-Host $Script:startTime
        Write-Host $Script:endTime
        
        #below reencodes but creates a keyframe at start position and is lossless so its better
        #ffmpeg -ss $Script:startTime -i $filePath -to $Script:endTime -c:v libx265 -c:a copy -x265-params lossless=1 -async 1 -map_metadata -1 -map 0:a -map 0:v -metadata:s:a:0 title="full_mix" -metadata:s:a:1 title="desktop_audio" -metadata:s:a:2 title="game_audio" -metadata:s:a:3 title="discord_audio" -metadata:s:a:4 title="mic_audio" -metadata:s:a:5 title="mic_audio_no_filter" $outputPath
        ffmpeg -ss $Script:startTime -i $filePath -to $Script:endTime -c:v copy -c:a copy -async 1 -map_metadata -1 -map 0:a -map 0:v -metadata:s:a:0 title="full_mix" -metadata:s:a:1 title="desktop_audio" -metadata:s:a:2 title="game_audio" -metadata:s:a:3 title="discord_audio" -metadata:s:a:4 title="mic_audio" -metadata:s:a:5 title="mic_audio_no_filter" $outputPath

        Write-Host "Trimmed!"
    }
}

function Clear-Video {
    #Write-Host "clear clip"

    $browseLabel.Text = 'No selection'

    $Script:fileDir = $null
    $Script:filePath = $null
    $Script:fileName = $null
}

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(2, $($timey + $puncth - $inputpunctpadding))
$browseButton.Size = New-Object System.Drawing.Size(60, 20)
$browseButton.Text = 'Browse'
$browseButton.Add_Click({ Open-Video })
$form.Controls.Add($browseButton)

$browseLabel = New-Object System.Windows.Forms.Label 
$browseLabel.Location = New-Object System.Drawing.Point(2, $($timey + 20 + $puncth))
$browseLabel.Size = New-Object System.Drawing.Size(280, 13)
$browseLabel.Text = 'No selection'
$browseLabel.AutoEllipsis = $True
$form.Controls.Add($browseLabel)

$trimButton = New-Object System.Windows.Forms.Button
$trimButton.Location = New-Object System.Drawing.Point(70, $($timey + $puncth - $inputpunctpadding))
$trimButton.Size = New-Object System.Drawing.Size(60, 20)
$trimButton.Text = 'Trim'
$trimButton.Add_Click({ Edit-Video })
$form.Controls.Add($trimButton)

$clearButton = New-Object System.Windows.Forms.Button
$clearButton.Location = New-Object System.Drawing.Point(2, $($timey + 36 + $puncth))
$clearButton.Size = New-Object System.Drawing.Size(45, 18)
$clearButton.Text = 'Clear'
$clearButton.Add_Click({ Clear-Video })
$form.Controls.Add($clearButton)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(200, 137)
$okButton.Size = New-Object System.Drawing.Size(60, 20)
$okButton.Text = 'Close'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$label = New-Object System.Windows.Forms.Label 
$label.Location = New-Object System.Drawing.Point(2, 2)
$label.Size = New-Object System.Drawing.Size(280, 20)
$label.Text = 'Enter a timeframe(mm:ss.ms):'
$form.Controls.Add($label)

$startLabel = New-Object System.Windows.Forms.Label 
$startLabel.Location = New-Object System.Drawing.Point(2, $($inputy + $inputpunctpadding))
$startLabel.AutoSize = $True
$startLabel.Text = 'Start:'
$form.Controls.Add($startLabel)

$endLabel = New-Object System.Windows.Forms.Label 
$endLabel.Location = New-Object System.Drawing.Point(2, $($endy + $inputpunctpadding))
$endLabel.AutoSize = $True
$endLabel.Text = 'End:'
$form.Controls.Add($endLabel)


#start time elements
$minsx = $inputx + $startLabel.Width
$mins = New-Object System.Windows.Forms.NumericUpDown 
$mins.Location = New-Object System.Drawing.Point($minsx, $inputy)
$mins.Size = New-Object System.Drawing.Size($inputw, $inputh)
$mins.Minimum = 0
$mins.Maximum = 59
$mins.InterceptArrowKeys = $False
$mins.Add_TextChanged({ Update-Time-Label })
$form.Controls.Add($mins)

$secsx = $minsx + $inputw + $inputnumpadding
$secs = New-Object System.Windows.Forms.NumericUpDown 
$secs.Location = New-Object System.Drawing.Point($secsx, $inputy)
$secs.Size = New-Object System.Drawing.Size($inputw, $inputh)
$secs.Minimum = 0
$secs.Maximum = 59
$secs.InterceptArrowKeys = $False
$secs.Add_TextChanged({ Update-Time-Label })
$form.Controls.Add($secs)

$msecsx = $secsx + $inputw + $inputnumpadding
$msecs = New-Object System.Windows.Forms.NumericUpDown 
$msecs.Location = New-Object System.Drawing.Point($msecsx, $inputy)
$msecs.Size = New-Object System.Drawing.Size($($inputw + $inputnumpadding), $inputh)
$msecs.Minimum = 0
$msecs.Maximum = 999
$msecs.InterceptArrowKeys = $False
$msecs.Add_TextChanged({ Update-Time-Label })
$form.Controls.Add($msecs)

$mtsx = $minsx + $inputw - $inputpunctpadding
$minstosecs = New-Object System.Windows.Forms.Label 
$minstosecs.Location = New-Object System.Drawing.Point($mtsx, $($inputy + 1))
$minstosecs.Size = New-Object System.Drawing.Size($punctw, $puncth)
$minstosecs.Text = ':'
$minstosecs.Font = [System.Drawing.Font]::new("Arial", 11, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($minstosecs)

$stmsx = $secsx + $inputw - $inputpunctpadding
$secstomsecs = New-Object System.Windows.Forms.Label 
$secstomsecs.Location = New-Object System.Drawing.Point($stmsx, $($inputy + 1))
$secstomsecs.Size = New-Object System.Drawing.Size($punctw, $puncth)
$secstomsecs.Text = '.'
$secstomsecs.Font = [System.Drawing.Font]::new("Arial", 11, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($secstomsecs)


$timeLabel = New-Object System.Windows.Forms.Label
$timeLabel.Location = New-Object System.Drawing.Point(2, $timey)
$timeLabel.AutoSize = $True
$timeLabel.Text = "$($mins.Text):$($secs.Text).$($msecs.Text) - $($emins.Text):$($esecs.Text).$($emsecs.Text)"
$timeLabel.Font = [System.Drawing.Font]::new("DefaultFont", 8, [System.Drawing.FontStyle]::Regular)
$form.Controls.Add($timeLabel)

#end time elements
$eminsx = $inputx + $startLabel.Width
$emins = New-Object System.Windows.Forms.NumericUpDown 
$emins.Location = New-Object System.Drawing.Point($eminsx, $endy)
$emins.Size = New-Object System.Drawing.Size($inputw, $inputh)
$emins.Minimum = 0
$emins.Maximum = 59
$emins.InterceptArrowKeys = $False
$emins.Add_TextChanged({ Update-Time-Label })
$form.Controls.Add($emins)

$esecsx = $eminsx + $inputw + $inputnumpadding
$esecs = New-Object System.Windows.Forms.NumericUpDown 
$esecs.Location = New-Object System.Drawing.Point($esecsx, $endy)
$esecs.Size = New-Object System.Drawing.Size($inputw, $inputh)
$esecs.Minimum = 0
$esecs.Maximum = 59
$esecs.InterceptArrowKeys = $False
$esecs.Add_TextChanged({ Update-Time-Label })
$form.Controls.Add($esecs)

$emsecsx = $esecsx + $inputw + $inputnumpadding
$emsecs = New-Object System.Windows.Forms.NumericUpDown 
$emsecs.Location = New-Object System.Drawing.Point($emsecsx, $endy)
$emsecs.Size = New-Object System.Drawing.Size($($inputw + $inputnumpadding), $inputh)
$emsecs.Minimum = 0
$emsecs.Maximum = 999
$emsecs.InterceptArrowKeys = $False
$emsecs.Add_TextChanged({ Update-Time-Label })
$form.Controls.Add($emsecs)

$emtsx = $eminsx + $inputw - $inputpunctpadding
$eminstosecs = New-Object System.Windows.Forms.Label 
$eminstosecs.Location = New-Object System.Drawing.Point($emtsx, $($endy + 1))
$eminstosecs.Size = New-Object System.Drawing.Size($punctw, $puncth)
$eminstosecs.Text = ':'
$eminstosecs.Font = [System.Drawing.Font]::new("Arial", 11, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($eminstosecs)

$estmsx = $esecsx + $inputw - $inputpunctpadding
$esecstomsecs = New-Object System.Windows.Forms.Label 
$esecstomsecs.Location = New-Object System.Drawing.Point($estmsx, $($endy + 1))
$esecstomsecs.Size = New-Object System.Drawing.Size($punctw, $puncth)
$esecstomsecs.Text = '.'
$esecstomsecs.Font = [System.Drawing.Font]::new("Arial", 11, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($esecstomsecs)


Update-Time-Label

#$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $x = $fileName
    $x
}

