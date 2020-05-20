#Author - Stefan McTighe
#Created - 20/05/2020

<#Description
To create a single Virtual Distributed Port Group on an existing Distributed Switch.
This doesnt change the 
#>
#Load PowerCLI Modules
Set-Location "C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\"
.\Initialize-PowerCLIEnvironment.ps1

#Variables - Ammend!
$vCenter = "<vCenter Name or IP>"
$vDSName = "<Name of the vDS>"
$VDPG ="<Name of the vD PortGroup>"
$VLAN = "<VLAN ID>" #enter 0 if no VLAN Tag required
$Ports = "8" #Port allocation is Elastic by default which will increase the port count when the limit is reached by increments of 8
$LoadBalancing = "LoadBalanceLoadBased" #Based on Physical Nic Load, change as required

#Connect to vCenter
Connect-VIServer $vCenter -Credential (Get-Credential)

#Create Distributed Virtual Port Group.
Get-VDSwitch -Name $vDSName | New-VDPortGroup -Name $VDPG -VLanId $VLAN -NumPorts 8

#Set Route based on physcial NIC load
Get-VDswitch -Name $vDSName | Get-VDPortgroup $VDPG | Get-VDUplinkTeamingPolicy | Set-VDUplinkTeamingPolicy -LoadBalancingPolicy $LoadBalancing
