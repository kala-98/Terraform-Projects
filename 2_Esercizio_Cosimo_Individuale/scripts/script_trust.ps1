# Importa il modulo Active Directory
Import-Module ActiveDirectory

# Imposta i nomi dei domini
$dominio1 = "dom.net"
$dominio2 = "dom2.net"

Add-DnsServerConditionalForwarderZone -Name "<nomeDominio>" -ReplicationScope "Forest" -MasterServers "<ipv4>"

# Imposta le credenziali dell'amministratore di dominio per entrambi i domini
$credentialDom1 = New-Object System.Management.Automation.PSCredential("fsAdmin@dom.net", (ConvertTo-SecureString "1YPnA*FvPp#2an" -AsPlainText -Force))
$credentialDom2 = New-Object System.Management.Automation.PSCredential("fsAdmin@dom2.net", (ConvertTo-SecureString "1YPnA*FvPp#2an" -AsPlainText -Force))

# Crea il trust bidirezionale
New-ADTrust -SourceName $dominio2 -TargetName $dominio1 -TrustType Bidirectional -Direction Both -Verbose -Credential $credentialDom2
