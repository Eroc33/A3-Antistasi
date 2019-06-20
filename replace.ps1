param (
    [Parameter(Mandatory=$True)][string]$File,
    [Parameter(Mandatory=$False)][string]$Find,
    [Parameter(Mandatory=$False)][string]$Replace
)
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False

if ($Find -eq [string]::Empty){
    $Find = Read-Host -Prompt 'Find'
}

if ($Replace -eq [string]::Empty){
    $Replace = Read-Host -Prompt 'Replace'
}

$Find = '\b'+$Find+'\b'

$Content = (Get-Content -Encoding ASCII $File)

if(!($Content -Match $Find)){
    #nothing to replace so leave
    exit
}

if($Content -Match ('\b' + $Replace + '\b')){
    Write-Host "Replacement $Replace for $Find exists in source"
    exit
}

(Get-Content -Encoding ASCII $File) -Replace $Find,$Replace | Out-File -Encoding ASCII $File