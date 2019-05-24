#import
    . .\azConnect.ps1
    . .\azRunVM.ps1
    . .\azViewVMs.ps1

#connect
    azConnect

#select
    azViewVMs
        
#parameters
    $vmList = @()
    $storageSwitchYN = @()
    $runOpt = Read-Host "Start, Stop or Restart?"
    Do{
        $vmName = Read-Host "Type the name of the VM or 'n' for No"
        if ($vmName -ne "n"){
            $vmList += Get-AzureRmVM -Name $vmName -ResourceGroupName $vmName -status
            $storageSwitchYN += Read-Host "Switch the Storage Option? [y,n]"
        }
    }
    Until ($vmName -eq "n")

    $storageType = 'Premium_LRS'  # Premium_LRS, StandardSSD_LRS, Standard_LRS

#run
    $i = 0
    ForEach ($vm in $vmList){
        azRunVM $runOpt $storageSwitchYN[$i] $vm[$i]
        $i = $i + 1
    }