[CmdletBinding()]

param 
( 
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$Dom1,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$Dom2,
	[Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$nomeFileCSV
)

# $Dom1 ="Dom" # mettere il proprio dominio
# $Dom2 ="it"  # mettere il proprio dominio
#$Path =""
Set-executionpolicy -executionpolicy unrestricted -Force
Import-Module ActiveDirectory
#New-Item -ItemType Directory -Path C:\temp
#cd C:\temp    # Cartella di lavoro
$ADUsers = Import-Csv .\$nomeFileCSV -Delimiter ";" 
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
    $Ruolo = $u.Ruolo

    New-ADUser -Name $samAccountName -SamAccountName $samAccountName `
    -UserPrincipalName $u.email -Path $Path `
    -AccountPassword(ConvertTo-SecureString $u.pwd -AsPlainText -Force) `
    -Enabled $true -CannotChangePassword  $true -DisplayName $nome -Description $Ruolo

    Add-ADGroupMember $u.Gruppo $samAccountName;
   Write-Output "l'utente $samAccountName gruppo $u.Gruppo UO $u.UO è stato aggiunto"
}
   
    