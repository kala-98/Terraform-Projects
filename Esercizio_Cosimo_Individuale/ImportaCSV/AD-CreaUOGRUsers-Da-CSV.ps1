#Get-Module -Name ActiveDirectory -ListAvailable #verifica se esiste il modulo
#Import-Module -Name ActiveDirectory  		#per usare un modulo bisogna importarlo
<# Nel Server: se non è istallato il modulo bisogna installarlo con
	Install-WindowsFeature -Name "RSAT-AD-PowerShell" -IncludeAllSubFeature
#>
<#
	Active Directory usa il protocollo LDAP (Lightweight Directory Access Protocol) per le interrogazioni, 
	gli oggetti sono identificati tramite (DN - Distinguish name) nome - valore e più oggetti sono separati da virgola.
	I contenitori Users e Computers sono indicati tramite CN.
	Esempio dominio: dc=miodominio, dc=it
	Esempio unità organizzativa: OU=IT
	Il DN completo per IT è: ou=IT,dc=miodominio,dc=it
	Esempio utente u01: cn=u01,dc=miodominio,dc=it,OU=IT
	In funzione delle esigenze compinare i vari DN.
    -----------------------------------------------------------------------------------------
New-ADOrganizationalUnit –Name IT  –Server Servizi.caserv.it –Path "DC=caserv,DC=it"
New-ADGroup -Name "Develop" -SamAccountName Develop -GroupCategory Security -GroupScope Global -DisplayName "Developers" -Path "OU=IT, DC=caserv,DC=it" -Descrizione "Team sviluppo software"
#>
<#
    Esempio di creazione Unità Organizzative, Gruppi e Utenti usando un file .csv
    Formato del File con intestazione e una riga di esempio:
    UO	              Gruppo	Nome   Cognome	email	    pwd	               Sam
    Direzione Generale	DG	    Alberto	Rossi	ar@vb3.it	xyz9876!AbGfil45	ar

TODO: gestire gli errori e generalizzare anche con creazione dinamica delle password.
#>

$Dom1 ="Dom" # mettere il proprio dominio
$Dom2 ="it"  # mettere il proprio dominio
$Path =""
Set-executionpolicy -executionpolicy unrestricted -Force
Import-Module ActiveDirectory
New-Item -ItemType Directory -Path C:\temp
cd C:\temp    # Cartella di lavoro
$ADUsers = Import-Csv .\Organizzazione.csv -Delimiter ";" 
$UOs = $(foreach ($xx in $ADUsers){
    $xx.UO 
}) | Sort-Object | Get-Unique

if ($UOs.Count -le 0) {
    Write-Output "Non ci sono UO nel file csv"
    Return -10
}
#creiamo le UO
foreach ($xUO in $UOs){
New-ADOrganizationalUnit –Name $xUO  –Path "DC=$Dom1,DC=$Dom2" 
}
#creiamo i gruppi
$Unici = $ADUsers | Select-Object -Property UO,Gruppo -Unique
foreach ($xxG in $Unici){
    $xOU = $xxG.UO
    $xGRO = $xxG.Gruppo
    $Path = "OU=$xOU,DC=$Dom1,DC=$Dom2"
 #verifichiamo se il gruppo esiste, se no lo creiamo.
    if (Get-ADGroup -Filter  {SamAccountName -eq '$xGRO' }) {
        Write-Warning "Il gruppo $xxG.Gruppo esiste già in Active Directory." 
}else {
   
    New-ADGroup -Name $xGRO -SamAccountName $XGRO -GroupCategory Security -GroupScope Global -DisplayName $xGRO -Path  $Path
    #-Descrizione "?????"
   
    Write-Host "Il gruppo $xxG.Gruppo è stato aggiunto all'UO $xxG.UO"
}
}
#Creiamo gli utenti e  aggiungiamoli ai gruppi
$az15=0
$ADUsers.Count
foreach($u in $ADUsers){
    $samAccountName = $u.Sam
    $Nome = '"' + $u.Nome + ' ' + $u.Cognome+'"'
    $xOU =$u.UO
    $xGRO = $u.Gruppo
    $Path = "OU=$xOU,DC=$Dom1,DC=$Dom2"

    New-ADUser -Name $samAccountName -SamAccountName $samAccountName `
    -UserPrincipalName $u.email -Path $Path `
    -AccountPassword(ConvertTo-SecureString $u.pwd -AsPlainText -Force) `
    -Enabled $true -CannotChangePassword  $true -DisplayName $nome

    Add-ADGroupMember $u.Gruppo $samAccountName;
   Write-Output "l'utente $samAccountName gruppo $u.Gruppo UO $u.UO è stato aggiunto"
}
   
    