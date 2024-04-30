[CmdletBinding()]

param 
( 
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$Domain,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$ipServer,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$username,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$password  
)

$dns = Get-DnsClient | Where-Object {$_.InterfaceAlias -eq "Ethernet"}
$dnsAddress= Get-DnsClientServerAddress -InterfaceIndex $dns.InterfaceIndex -AddressFamily IPv4
Set-DnsClientServerAddress -InterfaceIndex $dns.InterfaceIndex -ServerAddresses ($ipServer, $dnsAddress.ServerAddresses)

$dc = $Domain # Dominio su cui effetuare la Join
$pw = $password | ConvertTo-SecureString -asPlainText –Force # password dell'amministratore di dominio
$usr = "$domain\$username"
$creds = New-Object System.Management.Automation.PSCredential($usr,$pw)
Add-Computer -DomainName $Domain -Credential $creds -restart -force -verbose 
