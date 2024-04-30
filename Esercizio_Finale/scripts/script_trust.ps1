
# Aggiunge il record DNS nel conditional forwarder
Add-DnsServerConditionalForwarderZone -Name "<nomeDominio>" -ReplicationScope "Forest" -MasterServers "<ipv4>"

# Configurazione del trust (non funziona al momento)
$strRemoteForest = "dom.net"
$strRemoteAdmin = "dom.net\fsAdmin"
$strRemoteAdminPassword = "1YPnA*FvPp#2an"
$remoteContext = New-Object -TypeName "System.DirectoryServices.ActiveDirectory.DirectoryContext" -ArgumentList @( "Forest", $strRemoteForest, $strRemoteAdmin, $strRemoteAdminPassword)
try {
        $remoteForest = [System.DirectoryServices.ActiveDirectory.Forest]::getForest($remoteContext)
        Write-Host "GetRemoteForest: Succeeded for domain $($remoteForest)"

    }
catch {
        Write-Warning "GetRemoteForest: Failed:`n`tError: $($($_.Exception).Message)"
    }
Write-Host "Connected to Remote forest: $($remoteForest.Name)"
#$localforest=[System.DirectoryServices.ActiveDirectory.Forest]::getCurrentForest()
$localContext = New-Object -TypeName "System.DirectoryServices.ActiveDirectory.DirectoryContext" -ArgumentList @( "Forest")
$localforest = [System.DirectoryServices.ActiveDirectory.Forest]::getForest($localContext)

Write-Host "Connected to Local forest: $($localforest.Name)"
try {
        $localForest.CreateTrustRelationship($remoteForest,"Bidirectional")
        Write-Host "CreateTrustRelationship: Succeeded for domain $($remoteForest)"
    }
catch {
        Write-Warning "CreateTrustRelationship: Failed for domain $($remoteForest)`n`tError: $($($_.Exception).Message)"
    } 
