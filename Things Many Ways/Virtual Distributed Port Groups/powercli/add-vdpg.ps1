$vDSName = "vDS-Workload-Networks"
$Ports = "8" #Port allocation is Elastic by default which will increase the port count when the limit is reached by increments of 8
$LoadBalancing = "LoadBalanceLoadBased" #Based on Physical Nic Load, change as required (LoadBalanceLoadBased, LoadBalanceIP, LoadBalanceSrcMac, LoadBalanceSrcId, ExplicitFailover)
$ActiveUP = "Uplink 1", "Uplink 2" #Modify as required

$VDPGS = @(
    [pscustomobject]@{PG = 'dvPG-Guest-VM-1'; VLANID = '20' }
    [pscustomobject]@{PG = 'dvPG-Guest-VM-2'; VLANID = '21' }
    [pscustomobject]@{PG = 'dvPG-Secure-VM-1'; VLANID = '25' }
)

#Create Distributed Virtual Port Group.
ForEach ($VDPG in $VDPGS) {
    Get-VDSwitch -Name $vDSName | New-VDPortGroup -Name $VDPG.PG -VLanId $VDPG.VLANID -NumPorts $Ports
    #Set Load Balancing option
    Get-VDswitch -Name $vDSName | Get-VDPortgroup $VDPG.PG | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy $LoadBalancing -ActiveUplinkPort $ActiveUP
}
