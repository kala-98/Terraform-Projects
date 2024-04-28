# Definisci il nome dello script e il percorso
$scriptPath = "C:/Temp/script_create_org.ps1"

# Crea una nuova attività pianificata per eseguire lo script al riavvio
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $scriptPath"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "EseguiScriptAlRiavvio" -Principal $principal
