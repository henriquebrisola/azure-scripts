function azUpdateNSG{
    $ruleNames = @("RDP", "SSH")
    $nsgname = "PrivateSubnetEastUS2"
    $RGname = "Common"
    $myIP = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content

    foreach ($ruleName in $ruleNames){
        $nsg = Get-AzureRmNetworkSecurityGroup -Name $nsgname -ResourceGroupName $RGname
        $nsgConfig = $nsg | Get-AzureRmNetworkSecurityRuleConfig -Name $ruleName
        $nsgConfig = Set-AzureRmNetworkSecurityRuleConfig -Name $ruleName -NetworkSecurityGroup $nsg -SourceAddressPrefix $myIP -Protocol $nsgConfig.Protocol `
            -Access $nsgConfig.Access -Direction $nsgConfig.Direction -SourcePortRange $nsgConfig.SourcePortRange -DestinationPortRange $nsgConfig.DestinationPortRange `
            -DestinationAddressPrefix $nsgConfig.DestinationAddressPrefix -Priority $nsgConfig.Priority
        $setNSG = Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $nsg
        $msg = "NSG update for $ruleName rule has " + $setNSG.ProvisioningState.ToLower()
        Write-Host $msg -ForegroundColor Green
    }
}