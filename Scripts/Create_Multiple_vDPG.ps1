#Load PowerCLI Modules
Import-module VMware.PowerCLI

###################### Variables - Ammend! #####################
$vCenter = "<vCenter FQDN or IP>"
$vDSName = "vDS Switch Name"
$VDPGS =@(
            [pscustomobject]@{PG='<PortGroup Name>';VLANID='<VLAN ID>'}#enter 0 for VLANID if no VLAN Tag required
            [pscustomobject]@{PG='<PortGroup Name>';VLANID='<VLAN ID>'}#enter 0 for VLANID if no VLAN Tag required
            [pscustomobject]@{PG='<PortGroup Name>';VLANID='<VLAN ID>'}#enter 0 for VLANID if no VLAN Tag required
            )
$Ports = "8" #Port allocation is Elastic by default which will increase the port count when the limit is reached by increments of 8
$LoadBalancing = "LoadBalanceLoadBased" #Based on Physical Nic Load, change as required (LoadBalanceLoadBased, LoadBalanceIP, LoadBalanceSrcMac, LoadBalanceSrcId, ExplicitFailover)
$ActiveUP = "Uplink 1" #Modify as required
$StandUp = "Uplink 2" #Modify as required
$UnusedUP = "Uplink 3" #Modify as required

################################################################

#Connect to vCenter
Connect-VIServer $vCenter -Credential (Get-Credential) -force

#Create Distributed Virtual Port Group.
ForEach ($VDPG in $VDPGS) 
                        {Get-VDSwitch -Name $vDSName | New-VDPortGroup -Name $VDPG.PG -VLanId $VDPG.VLANID -NumPorts 8
                        #Set Load Balancing option
                        Get-VDswitch -Name $vDSName | Get-VDPortgroup $VDPG.PG | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy $LoadBalancing -ActiveUplinkPort $ActiveUP -StandbyUplinkPort $StandUp -UnusedUplinkPort $UnusedUP
        }
