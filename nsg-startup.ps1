# My RG
$resourceGroup = "MyRG"
# VM that will be started after updating the NSG
$VMName = "MyVM"
# NSG Name
$NSGName = "MyNSG"
# Get my Public IP
$ip = (Invoke-RestMethod http://ipinfo.io/json | Select -exp ip) + "/32"
# Get NSG
$NSG = Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Name $NSGName
# Current IP in the RDP Rule
write-host "Current NSG RDP Rule IP is" $NSG.SecurityRules[0].SourceAddressPrefix 
write-host "Current External IP is" $IP 
# Updating to current external IP if different
if ($NSG.SecurityRules[0].SourceAddressPrefix -ne $ip) {
    Set-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG -Name $NSG.SecurityRules[0].Name -SourceAddressPrefix $ip -Protocol * -SourcePortRange * -DestinationPortRange 22 -Access Allow -DestinationAddressPrefix * -Priority 1000 -Direction Inbound
    Set-AzNetworkSecurityGroup -NetworkSecurityGroup $NSG 
}
# Start VM
$vm = Get-AzVM -ResourceGroupName $resourceGroup -Name $VMName -Status 
$PowerState = (get-culture).TextInfo.ToTitleCase(($vm.statuses)[1].code.split("/")[1])
if ($PowerState -eq "Deallocated"){
    $vmstatus = Start-AzVM -ResourceGroupName $resourceGroup -Name $VMName
}

