#connect to Azure
function azConnect{
    $contextFile = "azContext.json"
    $location = $psISE.CurrentFile.FullPath -replace $psISE.CurrentFile.DisplayName, $contextFile
    $PSScriptRoot # This is an automatic variable set to the current file's/module's directory

    Import-AzureRmContext -path $location.ToString()
}