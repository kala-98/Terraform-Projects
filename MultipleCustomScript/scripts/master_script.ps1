[CmdletBinding()]

param 
( 
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$nomeStorage,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$nomeContainer,

    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$nomeFile,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$url,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$output
)


Invoke-WebRequest -Uri $url -OutFile $output

if (Test-Path $output) {
    Start-Process powershell.exe -ArgumentList "-File $output"
    Get-Date > "C:\\Temp\\DataRegistrata.txt"
} else {
    Write-Output $nomeFile + "_" + $url + "_" + $output > "C:\\Temp\\Errore.txt"
}
