# �X�N���v�g�t�@�C���̃p�����[�^
# �ϊ��Ώۃt�@�C�� - �ϊ��Ώۃt�@�C�����t���p�X�Ŏw��
# �ϊ��Ώۃt�@�C���̕����R�[�h - �ϊ��Ώۃt�@�C���̕����R�[�h���w��i�w�肷��l�͉��L @see �Q�Ɓj
# �ϊ���t�@�C���̏o�͐� - �ϊ���t�@�C���̏o�͐���t���p�X�Ŏw��
# �ϊ���t�@�C���̕����R�[�h - �ϊ���t�@�C���̕����R�[�h���w��i�w�肷��l�͉��L @see �Q�Ɓj
#
# �����R�[�h�̎w��l
# @see https://learn.microsoft.com/en-US/dotnet/api/system.text.encoding?view=net-7.0#list-of-encodings
#
param(
    [Parameter(Mandatory, HelpMessage='input file path (Full Path)')][string]$inFilePath,
    [Parameter(Mandatory, HelpMessage='encoding (from)')][string]$inFileEncoding,
    [Parameter(Mandatory, HelpMessage='output file path (Full Path)')][string]$outFilePath,
    [Parameter(Mandatory, HelpMessage='encoding (to)')][string]$outFileEncoding
)

###
function now([string]$format='%Y/%m/%d %H:%M:%S') {
    return Get-Date -UFormat "${format}"
}

function resolveRelativePath([string]$path) {
    if ($path.Substring(0, 2) -eq '.\') {
        return (Join-Path $PSScriptRoot $path.Substring(2))
    }
    return $path
}

function logging([string]$message) {
    Write-Output ('[' + $env:USERNAME + '] : ' + $message) | Add-Content $logFilePath -Encoding $logFileEncoding
}

function _exit([int16]$code, [string]$message='END') {
    logging "${message}"
    Exit $code
}


###
$logFilePath = (resolveRelativePath '.\log\tr_encode.log')
$logFileEncoding = 'UTF8'
$fromEncoding = [Text.Encoding]::GetEncoding($inFileEncoding)
$toEncoding = [Text.Encoding]::GetEncoding($outFileEncoding)

$n = now
logging ('START : ' + $n)

# �t�@�C���̑��݃`�F�b�N
if (!(Test-Path "${inFilePath}")) {
    $n = now
    logging ("ERROR : '${inFilePath}' does not found.")
    _exit 1 ('ABORTED (1) : ' + $n)
}

# �o�͐�f�B���N�g���̃`�F�b�N
$outputDir = Split-Path $outFilePath -parent
if (!(Test-Path "${outputDir}")) {
    $n = now
    logging ("ERROR : '${outputDir}' does not found.")
    _exit 1 ('ABORTED (1) : ' + $n)
}

# �ǂݍ���
logging ('READING')
logging (' -> File     : ' + $inFilePath)
logging (' -> Encoding : ' + $inFileEncoding)
$reader = New-Object IO.StreamReader($inFilePath, $fromEncoding)
$content = $reader.ReadToEnd()
$reader.Close()
logging ('COMPLETE')

# ��������
logging ('WRITING')
logging (' -> File     : ' + $outFilePath)
logging (' -> Encoding : ' + $outFileEncoding)
$writer = New-Object IO.StreamWriter($outFilePath, $false, $toEncoding)
$writer.Write($content)
$writer.Close()
logging ('COMPLETE')

$n = now
_exit 0 ('END : ' + $n)
