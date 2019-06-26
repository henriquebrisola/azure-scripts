function azUpdateNSG{
                  #RDP, SSH
    param([string]$ruleName)

        $nsgname = "PrivateSubnetEastUS2"
        $RGname = "Common"
        $myIP = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content

        $nsg = Get-AzureRmNetworkSecurityGroup -Name $nsgname -ResourceGroupName $RGname
        $nsgConfig = $nsg | Get-AzureRmNetworkSecurityRuleConfig -Name $ruleName
        $nsgConfig = Set-AzureRmNetworkSecurityRuleConfig -Name $ruleName -NetworkSecurityGroup $nsg -SourceAddressPrefix $myIP -Protocol $nsgConfig.Protocol `
            -Access $nsgConfig.Access -Direction $nsgConfig.Direction -SourcePortRange $nsgConfig.SourcePortRange -DestinationPortRange $nsgConfig.DestinationPortRange `
            -DestinationAddressPrefix $nsgConfig.DestinationAddressPrefix -Priority $nsgConfig.Priority
        Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $nsg
}