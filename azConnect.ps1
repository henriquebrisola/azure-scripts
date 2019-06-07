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
    $contextFile = $scriptPath + ".\azContext.json"
    Import-AzureRmContext -path $contextFile #insert full path
}