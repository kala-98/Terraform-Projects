[CmdletBinding()]

param 
( 
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$nomeStorage,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$nomeContainer,

    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$nomeFile,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$url,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$output,

    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$nomeFile2,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$url2,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$output2,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$Domain_DNSName,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$Domain_NETBIOSName,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$SafeModeAdministratorPassword
)


Invoke-WebRequest -Uri $url -OutFile $output

if (Test-Path $output) {
    Start-Process powershell.exe -ArgumentList "-File $output"
    Get-Date > "C:\\Temp\\DataRegistrata.txt"
} else {
    Write-Output $nomeFile + "_" + $url + "_" + $output > "C:\\Temp\\Errore.txt"
}


######################################################################################

Invoke-WebRequest -Uri $url2 -OutFile $output2

if (Test-Path $output2) {
    Start-Process powershell.exe -ArgumentList "-File $output2", "-Domain_DNSName $Domain_DNSName", "-Domain_NETBIOSName $Domain_NETBIOSName", "-SafeModeAdministratorPassword $SafeModeAdministratorPassword"
    Get-Date > "C:\\Temp\\DataRegistrata.txt"
} else {
    Write-Output $nomeFile + "_" + $url + "_" + $output2 > "C:\\Temp\\Errore.txt"
}