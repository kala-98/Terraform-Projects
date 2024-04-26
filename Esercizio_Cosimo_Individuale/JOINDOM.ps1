$dns = Get-DnsClient | Where-Object {$_.InterfaceAlias -eq "Ethernet"}
$dnsAddress= Get-DnsClientServerAddress -InterfaceIndex $dns.InterfaceIndex -AddressFamily IPv4
Set-DnsClientServerAddress -InterfaceIndex $dns.InterfaceIndex -ServerAddresses ("10.10.0.4",$dnsAddress.ServerAddresses)

$dc = "dom.it" # Dominio su cui effetuare la Join
$pw = "P@ssw0rd1234" | ConvertTo-SecureString -asPlainText –Force # password dell'amministratore di dominio
#utente Amministratore
$usr = "$dc\fsAdmin"
$creds = New-Object System.Management.Automation.PSCredential($usr,$pw)
Add-Computer -DomainName $dc -Credential $creds -restart -force -verbose 
