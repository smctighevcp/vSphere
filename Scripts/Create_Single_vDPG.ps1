#Load PowerCLI Modules
Import-module VMware.PowerCLI

###################### Variables - Ammend! #####################
$vCenter = "vcsa02.lab.local"
$vDSName = "vDS_Static_Guest"
$VDPG ="NewPortGroup"
$VLAN = "0" #enter 0 if no VLAN Tag required
$Ports = "8" #Port allocation is Elastic by default which will increase the port count when the limit is reached by increments of 8
$LoadBalancing = "LoadBalanceLoadBased" #Based on Physical Nic Load, change as required (LoadBalanceLoadBased, LoadBalanceIP, LoadBalanceSrcMac, LoadBalanceSrcId, ExplicitFailover)
$ActiveUP = "Uplink 1" #Modify as required
$StandUp = "Uplink 2" #Modify as required
$UnusedUP = "Uplink 3" #Modify as required

################################################################

#Connect to vCenter
Connect-VIServer $vCenter -Credential (Get-Credential) -force

#Create Distributed Virtual Port Group.
Get-VDSwitch -Name $vDSName | New-VDPortGroup -Name $VDPG -VLanId $VLAN -NumPorts 8

#Set Load Balancing option
Get-VDswitch -Name $vDSName | Get-VDPortgroup $VDPG | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy $LoadBalancing -ActiveUplinkPort $ActiveUP -StandbyUplinkPort $StandUp -UnusedUplinkPort $UnusedUP
