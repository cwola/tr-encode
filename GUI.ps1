Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$translator = (Join-Path $PSScriptRoot "tr_encode.ps1")
# @see https://learn.microsoft.com/en-US/dotnet/api/system.text.encoding?view=net-7.0#list-of-encodings
# よく使うもののみを指定可能としておく
$encoding = @{
    'UTF-7' = 'utf-7'
    'UTF-8' = 'utf-8'
    'UTF-16' = 'utf-16'
    'UTF-32' = 'utf-32'
    'Unicode (Big endian)' = 'unicodeFFFE'
    'Unicode (UTF-32 Big endian)' = 'utf-32BE'
    'ISO-2022-JP' = 'iso-2022-jp'
    'ISO-2022-JP (JIS-1 バイトカタカナを許可)' = 'csISO2022JP'
    'SHIFT-JIS' = 'shift_jis'
    'EUC-JP' = 'euc-jp'
    'Mac日本語' = 'x-mac-japanese'
    'US-ASCII' = 'us-ascii'
    'IBM EBCDIC (日本語カタカナ)' = 'IBM290'
    'IBM037 IBM EBCDIC (米国-カナダ)' = 'IBM037'
    'IBM500 IBM EBCDIC (インターナショナル)' = 'IBM500'
}
$userProfile = (Join-Path $PSScriptRoot "userProfile\") + $env:USERNAME + '.json'
$userProfileEncoding = 'UTF8'
$profiles = @{}

$userProfileDir = Split-Path -parent $userProfile
if (!(Test-Path "${userProfileDir}")) {
    new-item -Path $userProfileDir -Type directory > $null
}
if (!(Test-Path "${userProfile}")) {
    $profiles.InitialDirectory = $Home
} else {
    $profiles = (Get-Content -Path "${userProfile}" -Encoding "${userProfileEncoding}" -Raw | ConvertFrom-Json)
}
$profiles.User = @{
    'ClientName' = $env:CLIENTNAME
    'ComputerName' = $env:COMPUTERNAME
    'UserName' = $env:USERNAME
}
$profiles.LastExecuteTime = (Get-Date -UFormat "%Y/%m/%d %H:%M:%S")


# FORM
$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(750,460)
$form.StartPosition = 'CenterScreen'
$form.Text = 'tr_encode'

### 入力ファイル
    # LABEL
    $labelIn = New-Object System.Windows.Forms.Label
    $labelIn.Location = '10,10'
    $labelIn.Size = '170,20'
    $labelIn.Text = '入力ファイルを指定してください'

    # BUTTON
    $selectInputFile = New-Object System.Windows.Forms.Button
    $selectInputFile.Location = New-Object System.Drawing.Point(180,6)
    $selectInputFile.Size = New-Object System.Drawing.Size(80,20)
    $selectInputFile.Text = 'ファイル選択'

    # FIELD
    $inputFile = New-Object System.Windows.Forms.TextBox
    $inputFile.Location = New-Object System.Drawing.Point(10,30)
    $inputFile.Size = New-Object System.Drawing.Size(650,10)

    # DIALOG
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.InitialDirectory = $profiles.InitialDirectory
    $dialog.Title = 'ファイル選択ダイアログ'

### 入力ファイルエンコーディング
    # LABEL
    $labelFromEnc = New-Object System.Windows.Forms.Label
    $labelFromEnc.Location = '10,60'
    $labelFromEnc.Size = '250,20'
    $labelFromEnc.Text = '入力ファイルのエンコーディングを指定してください'

    # PULL-DOWN
    $fromEncoding = New-Object System.Windows.Forms.Combobox
    $fromEncoding.Location = New-Object System.Drawing.Point(10,80)
    $fromEncoding.Size = New-Object System.Drawing.Size(300,30)
    $fromEncoding.DropDownStyle = 'DropDown'
    $fromEncoding.FlatStyle = 'standard'
    $fromEncoding.BackColor = '#ffffff'
    $fromEncoding.ForeColor = 'black'
    $fromEncoding.Text = 'UTF-8'
    $fromEncoding.Items.AddRange($encoding.Keys)

### 出力ファイル
    # LABEL
    $labelOut = New-Object System.Windows.Forms.Label
    $labelOut.Location = '10,130'
    $labelOut.Size = '170,20'
    $labelOut.Text = '出力ファイルを指定してください'

    # FIELD
    $outputFile = New-Object System.Windows.Forms.TextBox
    $outputFile.Location = New-Object System.Drawing.Point(10,150)
    $outputFile.Size = New-Object System.Drawing.Size(650,10)

### 出力ファイルエンコーディング
    # LABEL
    $labelToEnc = New-Object System.Windows.Forms.Label
    $labelToEnc.Location = '10,180'
    $labelToEnc.Size = '250,20'
    $labelToEnc.Text = '出力ファイルのエンコーディングを指定してください'

    # PULL-DOWN
    $toEncoding = New-Object System.Windows.Forms.Combobox
    $toEncoding.Location = New-Object System.Drawing.Point(10,200)
    $toEncoding.Size = New-Object System.Drawing.Size(300,30)
    $toEncoding.DropDownStyle = 'DropDown'
    $toEncoding.FlatStyle = 'standard'
    $toEncoding.BackColor = '#ffffff'
    $toEncoding.ForeColor = 'black'
    $toEncoding.Text = 'UTF-8'
    $toEncoding.Items.AddRange($encoding.Keys)

### 実行ボタン
    # BUTTON
    $execute = New-Object System.Windows.Forms.Button
    $execute.Location = New-Object System.Drawing.Point(10,250)
    $execute.Size = New-Object System.Drawing.Size(80,30)
    $execute.Text = '変換'

### onclick
    # 入力ファイル選択ダイアログ
    $onClick = {
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $inputFile.Text = $dialog.FileName
            $parentPath = (Split-Path -parent $inputFile.Text)

            $profiles.InitialDirectory = $parentPath
            $dialog.InitialDirectory = $profiles.InitialDirectory
            if ($outputFile.Text -eq '') {
                $outputFile.Text = $parentPath + '\out.o'
            }
        }
    }
    $selectInputFile.Add_Click($onClick)

    # 実行ボタン
    $onClick = {
        . $translator $inputFile.Text $encoding[$fromEncoding.Text] $outputFile.Text $encoding[$toEncoding.Text]
        $rc = $lastExitCode
        if ($rc -eq 0) {
            (new-Object -comobject wscript.shell).popup('正常終了 ( ' + $rc + ' ) : 変換完了')
        } else {
            (new-Object -comobject wscript.shell).popup('異常終了 ( ' + $rc + ' ) : 変換失敗')
        }
    }
    $execute.Add_Click($onClick)

### closing
    # FORM
    $closing = {
        $profiles | ConvertTo-Json | Set-Content -Path $userProfile -Encoding $userProfileEncoding
    }
    $form.Add_Closing($closing)

### render
    $form.Controls.AddRange(@(
        $labelIn,
        $selectInputFile,
        $inputFile,
        $labelFromEnc,
        $fromEncoding,

        $labelOut,
        $outputFile,
        $labelToEnc,
        $toEncoding,

        $execute
    ))
    $form.ShowDialog()
