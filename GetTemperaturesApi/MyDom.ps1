# Source: https://stackoverflow.com/a/43317244
<#
    chmod 400 equivalent
#>
$path = ".\aws-ec2-key.pem"
# Reset to remove explict permissions
icacls.exe $path /reset
# Give current user explicit read-permission
icacls.exe $path /GRANT:R "$($env:USERNAME):(R)"
# Disable inheritance and remove inherited permissions
icacls.exe $path /inheritance:r

<# 
    If you prefer to do it from UI

    select .pem file -> right click -> properties
    Security > Advanced > Disable inheritance
    Remove all Users
    Add > Select a principal
    In "Enter the object name to select" type your Windows username > ok
    Give all permissions > ok > apply
#>