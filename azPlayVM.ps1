#fix os location
if ($psISE)
{
    $scriptPath = Split-Path -Path $psISE.CurrentFile.FullPath
    cd $scriptPath
}
else
{
    cd $global:PSScriptRoot
}

#import
    . .\azConnect.ps1
    . .\azStartStopRestart.ps1
    . .\azViewVMs.ps1

#parameters
    function script:parameters(){
        $script:vmList = @()
        $script:storageSwitchYN = @()
        $script:runOpt = Read-Host "Start, Stop or Restart?"

        #storageType = Premium_LRS, StandardSSD_LRS, Standard_LRS
            If ($runOpt.ToLower() -eq "start") {
                $script:storageType = "Premium_LRS"  
            }
            ElseIf ($runOpt.ToLower() -eq "stop"){
                $script:storageType = "Standard_LRS"
            }

        Do{
            $vmName = Read-Host "Type the name of the VM or 'n' for No"
            if ($vmName.ToLower() -ne "n"){
                $script:vmList += $vmName
                $script:storageSwitchYN += Read-Host "Do you want to switch the Storage to " + $script:storageType + "? [y,n]"
            }
        }
        Until ($vmName.ToLower() -eq "n")
    }

#run
    function run(){
        $i = 0
        ForEach ($vmName in $vmList){
            $vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $vmName -status
            azRunVM $runOpt $storageSwitchYN[$i] $storageType $vm
            $i = $i + 1
        }
    }

#execution
    $ListVMsOpt = Read-Host "Do you want to list all VMs? [y/n]"
    if ($ListVMsOpt.ToLower() -eq "y") {
        #connect
            if ($connected) {
            }
            else{    #runs once per session
                azConnect
                $connected = $true
            }
        azViewVMs
        parameters
        run
    }
    elseif ($ListVMsOpt.ToLower() -eq "n") {
        parameters
        #connect
            if ($connected) {
            }
            else{    #runs once per session
                azConnect
                $connected = $true
            }
        run
    }
    else {
        Write-Host "wrong option"
    }