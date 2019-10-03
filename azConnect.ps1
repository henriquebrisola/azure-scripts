#fix os location
if ($psISE)
{
    $scriptPath = Split-Path -Path $psISE.CurrentFile.FullPath
}
else
{
    $scriptPath = $PSScriptRoot
}

#connect to Azure
function azConnect{
    $contexts = Get-AzureRmContext -ListAvailable
    if ($contexts){
        Clear-AzureRmContext
    }    
    Disable-AzureRmContextAutosave -Scope Process
    #Disconnect-AzureRmAccount
    $contextFile = $scriptPath + "\azContext.json"
    Import-AzureRmContext -path $contextFile #inserts full path
    Set-AzureRmContext -SubscriptionName 'Pessoal'
}
if($false){
    # in case of context issue run
    Connect-AzureRmAccount
    Save-AzureRmContext -path '.\azContext.json'
    Disconnect-AzureRmAccount
}
