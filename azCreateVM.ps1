#fix os location
if ($psISE)
{
    $scriptPath = Split-Path -Path $psISE.CurrentFile.FullPath
    Set-Location -Path $scriptPath
}
else
{
    Set-Location -Path $global:PSScriptRoot
}

#import
    . .\azConnect.ps1
    . .\azUpdateNSG.ps1

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
    $subnetId = "/subscriptions/a20bbd82-35fa-4bde-b809-f7e466713330/resourceGroups/Common/providers/Microsoft.Network/virtualNetworks/EastUS2/subnets/"`
        + $subnetNames[$subnetOpt]
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
    $os_opt = Read-Host "Windows, Ubuntu, CentOS(beta), RHEL?"
    if ($os_opt.ToLower() -eq "windows") {
        $os_publisher = "MicrosoftWindowsDesktop"
        $os_offer = "Windows-10"
        $os_sku = "rs5-enterprise"
        $os_version = "latest"
        $vm = Set-AzureRmVMOperatingSystem -VM $vm -ComputerName $vmName -Windows -Credential $credential
    }
    elseif ($os_opt.ToLower() -eq "linux") {        
        $os_publisher = "Canonical"
        $os_offer = "UbuntuServer"
        $os_sku = "19.04"
        $os_version = "latest"
        $vm = Set-AzureRmVMOperatingSystem -VM $vm -ComputerName $vmName -Linux -Credential $credential
    }
    elseif ($os_opt.ToLower() -eq "centos") {        
        $os_publisher = "westernoceansoftwaresprivatelimited"
        $os_offer = "centos-7-6"
        $os_sku = "centos-7-6-server"
        $os_version = "latest"
        $vm = Set-AzureRmVMOperatingSystem -VM $vm -ComputerName $vmName -Linux -Credential $credential
    }
    elseif ($os_opt.ToLower() -eq "rhel") {        
        $os_publisher = "RedHat"
        $os_offer = "RHEL"
        $os_sku = "7.6"
        $os_version = "latest"
        $vm = Set-AzureRmVMOperatingSystem -VM $vm -ComputerName $vmName -Linux -Credential $credential
    }

    $vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName $os_publisher -Offer $os_offer -Skus $os_sku -Version $os_version
    $rg = New-AzureRmResourceGroup -name $vmName -Location $location
    write-output ("Resource Group '" + $rg.ResourceGroupName + "' has been created")
    do {
        try {
            $publicIp = New-AzureRmPublicIpAddress -Name ($vmName + "-ip") -ResourceGroupName $vmName `
                -AllocationMethod Dynamic -DomainNameLabel $dnsPrefix -Location $location -ErrorAction stop
            $failed = $false
        }
        catch {
            $failed = $true
            if ($_.Exception.StatusCode -eq 400){
                Write-Host $_.Exception.Message -ForegroundColor Yellow
                $dnsPrefix = Read-Host "Typer another DNS record"
            }
            else {
                Write-Host $_.Exception.Message -ForegroundColor Red
                break
            }
        }
    } while ($failed)
    write-output ("Public IP '" + $publicIp.Name + "' has been created")
    $nic = New-AzureRmNetworkInterface -Name $vmName -ResourceGroupName $vmName -Location $location -SubnetId $subnetId -PublicIpAddressId $publicIp.Id
    write-output ("Network Interface '" + $nic.Name + "' has been created")
    $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
    #$vm = Set-AzureRmVMCustomScriptExtension
    #$vm = Set-AzureRmVMDataDisk
    $vm = Set-AzureRmVMOSDisk -VM $vm -Name ($vmName + "_OsDisk") -StorageAccountType $diskTypes[$diskOpt] -CreateOption fromImage
    $vm = Set-AzureRmVMBootDiagnostics -VM $vm -Enable -ResourceGroupName $storageAccountDiagRG -StorageAccountName $storageAccountDiagName

#create VM
    write-output ("Creating VM '" + $vmName + "'")
    try {
        New-AzureRmVM -ResourceGroupName $vmName -Location $location -VM $vm
        write-output ("Virtual Machine '" + $vmName + "' has been created")
    }
    catch {            
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        Write-Host $_.Exception -ForegroundColor Yellow
        #if($_.Exception -eq ''){
            write-output ("Virtual Machine could not be created")
        #}
    }

#NSG fix
    azUpdateNSG