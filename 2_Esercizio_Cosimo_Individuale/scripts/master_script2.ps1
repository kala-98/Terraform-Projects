[CmdletBinding()]

param 
( 
    # Installazione AD e creazione dominio
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$url,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$output,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$Domain_DNSName,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$Domain_NETBIOSName,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$SafeModeAdministratorPassword,

    # Script per la creazione dell'organizzazione
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$url2,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$output2,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$Dom1,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$Dom2,

    # Per recuperare il file csv per lo script sopra
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$url3,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [String]$output3
)

Set-TimeZone -Id "W. Europe Standard Time"

Invoke-WebRequest -Uri $url -OutFile $output

if (Test-Path $output) {
    Start-Process powershell.exe -ArgumentList "-File $output", "-Domain_DNSName $Domain_DNSName", "-Domain_NETBIOSName $Domain_NETBIOSName", "-SafeModeAdministratorPassword $SafeModeAdministratorPassword"
    Get-Date > "C:\\Temp\\DataRegistrata_install_ad.txt"
} else {
    Write-Output "Errore" > "C:\\Temp\\Errore_install_ad.txt"
}

######################################################################################

Invoke-WebRequest -Uri $url2 -OutFile $output2
Invoke-WebRequest -Uri $url3 -OutFile $output3

# if ((Test-Path $output2) -and (Test-Path $output3)) {
#     #Start-Process powershell.exe -ArgumentList "-File $output2", "-Dom1 $Dom1", "-Dom2 $Dom2", "-nomeFileCSV $output3"

#     # Crea una nuova attività pianificata per eseguire lo script al riavvio
#     $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File '$output2' -Dom1 '$Dom1' -Dom2 '$Dom2' -nomeFileCSV '$output3'"
#     $trigger = New-ScheduledTaskTrigger -AtStartup
#     $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
#     Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "CreaOrganizzazioneAD" -Principal $principal

#     Get-Date > "C:\\Temp\\DataRegistrata_create_org.txt"
# } else {
#     Write-Output "Errore" > "C:\\Temp\\Errore_create_org.txt"
# }

Add-DnsServerConditionalForwarderZone -Name "dom.net" -ReplicationScope "Forest" -MasterServers "10.0.0.4"
