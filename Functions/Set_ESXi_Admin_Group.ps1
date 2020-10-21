function Set-ESXiHostAdminGroup {
    <#
    .SYNOPSIS
        ESXi host administrator permissions .
    .DESCRIPTION
        Sets the ESXi host administrators group on a  via PowerCLI.
    .PARAMETER Group
        The Active Directory or Local ESXi Group name 
        Example - ActiveDirectory = <Domain Name>\<GroupName>
        Example - Local ESXi Group = <Group Name>
    .PARAMETER Target
        all = All connected hosts from current session.
        single = A singular host that needs to be specifed with the 'Entity' paramater.
.PARAMETER Entity
        The ESXi Host Name you wish to target.
        Requires the -Scope paramater to be set to 'single' 
    .NOTES
        Tags: VMware, ESXi, HostAdminGroup, PowerCLI
        Author: Stephan McTighe
        Website: stephanmctighe.com
    .LINK
        GitHub
    .EXAMPLE
        PS C:\> Set-ESXiHostAdminGroup -Scope all -Group "DomainName\admin_group"
        PS C:\> Set-ESXiHostAdminGroup -Scope single -Entity esxi01 -Group "ESXi_admin_group"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Group,
        [Parameter(Mandatory=$true)]
        [validateSet('all', 'single')] [String]$Target,
        [string]$Entity
    )

    begin {
        $Output = @()
            If($Target -eq "all"){
                $ESXi = Get-VMHost
            }
                    Else {
                        if ($Entity -eq ""){
                            Write-Host "ERROR: Provide Entity" -ForegroundColor Red
                        }
                            else {
                                $ESXi = $Entity
                            }
                    }
    }

    Process {

        foreach ($E in $ESXi){
            $Result = Get-AdvancedSetting -Entity $E -Name Config.HostAgent.plugins.hostsvc.esxAdminsGroup |`
            Set-AdvancedSetting -Value “$Group” -confirm:$false
            $object = New-Object -TypeName PSCustomObject -Property @{
                            ESXiHost = "$E"
                            PermissionGroup = $Result.Value
            
                    }
                    $Output += $object
        }

    }
    end {
                    $Output
    }
}