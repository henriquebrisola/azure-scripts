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
    if ($connected) {
    }
    else{    #runs once per session
        azConnect
        $connected = $true
    }

#parameters
    $vmName = Read-Host "Type the name of the VM"
    $subnetNames = @("Private", "Public")
    $subnetOpt = 0
    $subnetId = "/subscriptions/a20bbd82-35fa-4bde-b809-f7e466713330/resourceGroups/Common/providers/Microsoft.Network/virtualNetworks/EastUS2/subnets/"`        + $subnetNames[$subnetOpt]
    $location = "eastus2"
    $vNetName = "EastUS2"
    $vmSize = "Standard_" + "D2s_v3"
    #$osImages = @("Win2016Datacenter", "Win10", "UbuntuLTS", "Win2008R2SP1", "Win2012Datacenter","Win2012R2Datacenter", "RHEL", "SLES", "CoreOS", "Debian", "openSUSE-Leap", "CentOS")
    #$osOpt = 0
    if ($credential) {
    }
    else{
        write-output "Type the credentials for the vm"
        $credential = Get-Credential
    }
    $storageAccountDiagName = "eastus2hdd"
    $storageAccountDiagRG = "common"
    $dnsPrefix = $vmName.ToLower()
    $diskTypes = @("Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "UltraSSD_LRS")
    $diskOpt = 0

#create VM config
    $vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
    $vm = Set-AzureRmVMOperatingSystem -VM $vm -ComputerName $vmName -Windows -Credential $credential
    $vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-Datacenter" -Version "latest"
    $rg = New-AzureRmResourceGroup -name $vmName -Location $location
    write-output ("Resource Group named '" + $rg.ResourceGroupName + "' has been created")
    do {
        try {
            $publicIp = New-AzureRmPublicIpAddress -Name ($vmName + "-ip") -ResourceGroupName $vmName `                -AllocationMethod Dynamic -DomainNameLabel $dnsPrefix -Location $location -ErrorAction stop
            $failed = $false
        }
        catch {
            $failed = $true
            Write-Host $_.Exception.Message -ForegroundColor Yellow
            $dnsPrefix = Read-Host "Digite um prefixo de DNS"
        }
    } while ($failed)
    write-output ("Public IP named '" + $publicIp.Name + "' has been created")
    $nic = New-AzureRmNetworkInterface -Name $vmName -ResourceGroupName $vmName -Location $location -SubnetId $subnetId -PublicIpAddressId $publicIp.Id
    write-output ("Network Interface named '" + $nic.Name + "' has been created")
    $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
    #$vm = Set-AzureRmVMCustomScriptExtension
    #$vm = Set-AzureRmVMDataDisk
    $vm = Set-AzureRmVMOSDisk -VM $vm -Name ($vmName + "_OsDisk") -StorageAccountType $diskTypes[$diskOpt] -CreateOption fromImage
    $vm = Set-AzureRmVMBootDiagnostics -VM $vm -Enable -ResourceGroupName $storageAccountDiagRG -StorageAccountName $storageAccountDiagName

#create VM
    write-output ("Creating VM '" + $vmName)
    $newVM = New-AzureRmVM -ResourceGroupName $vmName -Location $location -VM $vm -Verbose
    write-output ("Virtual Machine named '" + $vmName + "' has been created")