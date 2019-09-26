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
    Disable-AzureRmContextAutosave
    $contexts = Get-AzureRmContext -ListAvailable
    foreach ($context in $contexts){
        Remove-AzureRmContext -Name $context.name -Force
    }
    Disconnect-AzureRmAccount
    $contextFile = $scriptPath + ".\azContext.json"
    Import-AzureRmContext -path $contextFile #inserts full path
}
if($false){
    # in case of context issue run
    Connect-AzureRmAccount
    Save-AzureRmContext -path '.\azContext.json'
    Disconnect-AzureRmAccount
}
