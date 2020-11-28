<#
    .SYNOPSIS
        Apply vCenter object permissions based on Tags.
    .DESCRIPTION
        Used to apply and remove permissions to vCenter Objects using the New-VIPermission and Remove-VIPermission Commandlets based on the tags assigned to that object.
        Requires PowerCLI.
        Can be used directly or via a scheduled job.
    .NOTES
        Tags: VMware, vCenter, ESXi, Permissions, PowerCLI, Tags
        Author: Stephan McTighe
        Website: stephanmctighe.com
    #>

#Load PowerCLI Modules
Import-module VMware.PowerCLI

#New-VICredentialStoreItem -host "vcsa01.lab.local" -user "administrator@vsphere.local" -password "**********" -file C:\Users\administrator
#Get the Credentials
$creds = Get-VICredentialStoreItem -file  C:\Users\Peppa\OneDrive\Documents\Lab\smt-lab-vcsa-01.creds
 
#Connect to vCenter
Connect-VIServer -Server $creds.host -User $creds.User -Password $creds.Password -Force

#Tags
$dbaT = "Support Team/DBA_Team"
$storT = "Support Team/Storage_Team"
$eucT = "Support Team/EUC_Team"
$operT = "Support Team/Operations_Team"

#Active Directory Groups
$dbaG = "smt-lab\dba_admins"
$storG ="smt-lab\storage_admins"
$eucG = "smt-lab\euc_admins"
$OperG = "smt-lab\operations_users"

#Roles
$dbaR = "DBA VM Administrator"
$storR = "Storage VM Administrator"
$eucR = "End User VM Administrator"
$OperR = "Operations Users"


$VMs = Get-VM

ForEach ($VM in $VMs) {

        $TAGS = Get-TagAssignment -Entity $VM | Select @{l='SupportTeam';e={('{0}/{1}' -f $_.tag.category, $_.tag.name)}}, Entity

                                If ($TAGS.SupportTeam -contains $dbaT)  {New-VIPermission -Principal $dbaG -Role $dbaR -Entity $vm.name} Else {Get-VIPermission -Entity $vm.Name -Principal $dbaG | Remove-VIPermission -Confirm:$false}
                                If ($TAGS.SupportTeam -contains $storT) {New-VIPermission -Principal $storG -Role $storR -Entity $vm.Name} Else {Get-VIPermission -Entity $vm.Name -Principal $storG | Remove-VIPermission -Confirm:$false}
                                If ($TAGS.SupportTeam -contains $eucT) {New-VIPermission -Principal $eucG -Role $eucR -Entity $vm.Name}  Else {Get-VIPermission -Entity $vm.Name -Principal $eucG | Remove-VIPermission -Confirm:$false}
                                If ($TAGS.SupportTeam -contains $operT) {New-VIPermission -Principal $OperG -Role $OperR -Entity $vm.Name}  Else {Get-VIPermission -Entity $vm.Name -Principal $OperG | Remove-VIPermission -Confirm:$false}
                        }