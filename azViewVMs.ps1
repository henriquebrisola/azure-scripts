function azViewVMs {
    $azureRmVM = @()
    ForEach ($vm in Get-AzureRMVm){
        $obj = New-Object psobject -Property @{`
            "ResourceGroup" = $vm.ResourceGroupName;
            "Name" = $vm.Name;
            "Location" = $vm.Location;
            "VmSize" = (Get-AzureRMVm -name $vm.Name -ResourceGroup $vm.ResourceGroupName).HardwareProfile.VmSize;
            "OsType" = (Get-AzureRMVm -name $vm.Name -ResourceGroup $vm.ResourceGroupName).StorageProfile.osDisk.osType;
            "Status" = (Get-AzureRMVm -name $vm.Name -ResourceGroup $vm.ResourceGroupName -Status).Statuses[1].DisplayStatus
        }
        $azureRmVM += $obj | Select-Object ResourceGroup, Name, Location, VmSize, OsType, Status
    }
    $azureRmVM | Format-Table
}