. .\azLogin.ps1
#connect
    connect-to-azure

#parameters
    $azureRmVM = @()
    ForEach ($vm in Get-AzureRMVm){
        $obj = New-Object psobject -Property @{`
            "ResourceGroup" = $vm.ResourceGroupName;
            "Name" = $vm.Name;
            "Location" = $vm.Location;
            #"VmSize" = $vm.;
            #"OsType" = $vm.;
            #"Status" = Get-AzureRMVm -name $vm.Name -ResourceGroup $vm.ResourceGroupName -Status;
        }
        $azureRmVM += $obj | select ResourceGroup, Name, Location #, VmSize, OsType
    }
    $azureRmVM | ft
    
    #Get-AzureRMVm | ft #-Property ResourceGroupName, Name, VmSize, OsType, Status

    $vmList = @()
    Do{
        $vmName = Read-Host "Type the name of the VM or 'n' for No"
        if ($vmName -ne "n"){
            $vmList += $vmName
            $storageSwitchYN = Read-Host "Switch the Storage Option? [y,n]"
        }
    }
    Until ($vmName -eq "n")

#config
    $storageType = 'Premium_LRS'  # Premium_LRS, StandardSSD_LRS, Standard_LRS

#run
    ForEach ($vmName in $vmList){
        $vm = Get-AzureRMVm | Where {$_.Name -eq $vmName}
        If ($storageSwitchYN -eq "y"){
            $osDisk = $vm.storageprofile.osdisk.name
            $diskUpdateConfig = New-AzureRmDiskUpdateConfig -AccountType $storageType 
            Write-Output "Converting: $($osDisk) to $($storageType)"
            Update-AzureRmDisk -DiskUpdate $diskUpdateConfig -ResourceGroupName $vm.ResourceGroupName `
            -DiskName $osdisk

            $dataDisks = $vm.StorageProfile.DataDisks
            foreach ($disk in $dataDisks){
                $diskUpdateConfig = New-AzureRmDiskUpdateConfig -AccountType $storageType 
                Write-Output "Converting: $($disk.Name) to $($storageType)"
                Update-AzureRmDisk -DiskUpdate $diskUpdateConfig -ResourceGroupName $vm.ResourceGroupName `
                -DiskName $disk.Name
            }
        }
        $vmStatus = get-azurermvm -name $vm.name -Resourcegroupname $vm.resourcegroupname -status
        If ($vmStatus.Statuses[1].DisplayStatus -eq "VM deallocated"){
            Write-Output "Starting: $($vm.Name)"
            Start-AzureRMVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName
        }
    }