#run VM
    function azRunVM {
        #start, stop, restart  #Switch disk type[y,n/Y,N] $Storage Type       #VMs       
        param([string]$runOpt, [char]$switchDisk, [string]$storageType, $vm)
          
            #start VM
            If ($runOpt -eq "start"){
                azStorageSwitch $switchDisk $storageType $vm
                azStartStopRestartVM $runOpt $vm
            }
            #stop VM
            ElseIf ($runOpt -eq "stop"){
                azStartStopRestartVM $runOpt $vm
                azStorageSwitch $switchDisk $storageType $vm
            }
            #Restart VM
            ElseIf ($runOpt -eq "restart"){
                azStartStopRestartVM $runOpt $vm
            }                
    }

#start, Stop or Restart VM
    function azStartStopRestartVM {
        param([string]$runOpt, $vm)
        #$vmStatus = Get-AzureRmVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -status
        #If ($vmStatus.Statuses[1].DisplayStatus -eq "VM deallocated"){
            If ($runOpt -eq "start"){
                Write-Output "Starting: $($vm.Name)"
                Start-AzureRmVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName
                $result = "started"
            }
            ElseIf ($runOpt -eq "stop"){
                Write-Output "Stopping: $($vm.Name)"
                Stop-AzureRmVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -force
                $result = "stopped"
            }
            ElseIf ($runOpt -eq "restart"){
                Write-Output "Restarting: $($vm.Name)"
                Restart-AzureRmVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName
                $result = "restarted"
            }
            return $result
        #}
    }


#storage switch
    function azStorageSwitch{
        param ([char]$switchDisk, [string]$storageType, $vm)
        If ($switchDisk -eq "y"){
            foreach($disk in $vm.Disks){
                $diskUpdateConfig = New-AzureRmDiskUpdateConfig -AccountType $storageType 
                Write-Output "Converting: $($disk.Name) to $($storageType)"
                Update-AzureRmDisk -DiskUpdate $diskUpdateConfig -ResourceGroupName $vm.ResourceGroupName -DiskName $disk.Name
            }
            
            #$osDisk = $vm.storageprofile.osdisk.name
            #$diskUpdateConfig = New-AzureRmDiskUpdateConfig -AccountType $storageType 
            #Write-Output "Converting: $($osDisk) to $($storageType)"
            #Update-AzureRmDisk -DiskUpdate $diskUpdateConfig -ResourceGroupName $vm.ResourceGroupName -DiskName $osdisk
            #
            #$dataDisks = $vm.StorageProfile.DataDisks
            #foreach ($disk in $dataDisks){
            #    $diskUpdateConfig = New-AzureRmDiskUpdateConfig -AccountType $storageType 
            #    Write-Output "Converting: $($disk.Name) to $($storageType)"
            #    Update-AzureRmDisk -DiskUpdate $diskUpdateConfig -ResourceGroupName $vm.ResourceGroupName -DiskName $disk.Name
            #}
        }
    }

