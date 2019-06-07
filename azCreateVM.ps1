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

#connect
    $connected = 0
    if($connected -eq 0){ #runs once per session
        azConnect
    }
    $connected = 1

#parameters
    $vmName = Read-Host "Type the name of the VM"
    $subnetNames = @("Private", "Public")
    $subnetOpt = 0
    $location = "eastus2"
    $vNetName = "EastUS2"
    $vmSize = "Standard_" + "D2s_v3"
    $osImages = @("Win2016Datacenter", "Win10", "UbuntuLTS", "Win2008R2SP1", "Win2012Datacenter","Win2012R2Datacenter", "RHEL", "SLES", "CoreOS", "Debian", "openSUSE-Leap", "CentOS")
    $osOpt = 0

#create
    New-AzureRmVM -Name $vmName -ResourceGroupName $vmName `
    -Location $location -Size $vmSize -Image $osImages[$osOpt] `    -VirtualNetworkName $vNetName -SubnetName $subnetNames[$subnetOpt] -PublicIpAddressName ($vmName + "-ip") `
    -SecurityGroupName ($subnetNames[$subnetOpt] + "SubnetEastUS2")

    #issue, creating vnets, nic named the same vm's name, premium ssd disk, etc..
    

if(false){ #skips below
        
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

#storageType = Premium_LRS, StandardSSD_LRS, Standard_LRS
    If ($runOpt -eq "start") {
        $storageType = "Premium_LRS"  
    }
    ElseIf ($runOpt -eq "stop"){
        $storageType = "Standard_LRS"
    }

#run
    $i = 0
    ForEach ($vm in $vmList){
        azRunVM $runOpt $storageSwitchYN[$i] $storageType $vm[$i]
        $i = $i + 1
    }
    }