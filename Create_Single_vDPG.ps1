#Load PowerCLI Modules
Import-module VMware.PowerCLI

###################### Variables - Ammend! #####################
$vCenter = "<vCenter FQDN or IP>"
$vDSName = "vDS Switch Name"
$VDPG ="<PortGroup Name>"
$VLAN = "<VLAN ID>" #enter 0 if no VLAN Tag required
$Ports = "8" #Port allocation is Elastic by default which will increase the port count when the limit is reached by increments of 8
$LoadBalancing = "LoadBalanceLoadBased" #Based on Physical Nic Load, change as required (LoadBalanceLoadBased, LoadBalanceIP, LoadBalanceSrcMac, LoadBalanceSrcId, ExplicitFailover)

################################################################

#Connect to vCenter
Connect-VIServer $vCenter -Credential (Get-Credential) -force

#Create Distributed Virtual Port Group.
Get-VDSwitch -Name $vDSName | New-VDPortGroup -Name $VDPG -VLanId $VLAN -NumPorts 8

#Set Load Balancing option
Get-VDswitch -Name $vDSName | Get-VDPortgroup $VDPG | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy $LoadBalancing
