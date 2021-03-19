function Detach-StorageDevice {
    <#
    .SYNOPSIS
        Detaches a Storage Device from all hosts in a specified vSphere Cluster.
    .DESCRIPTION
        Detaches a specified Storage Device from all hosts in any specified vSphere Cluster(s). This is aimed at storage devices that arent already mounted.  This only detaches the storage from host.  Requires connection to at least one vCenter Server (Connect-VIServer).
    .PARAMETER Cluster
        The vSphere Cluster you wish to target.  This can also be passed via the pipeline using Get-Cluster to target multiple clusters.
    .PARAMETER CanonicalName
        The CanonicalName you wish to detach.
    .NOTES
        Tags: VMware, vSphere, RDM, PowerCLI, Detach, LUN
        Author: Stephan McTighe
        Website: stephanmctighe.com
    .LINK
        https://github.com/smctighevcp
    .EXAMPLE
        PS C:\> Detach-StorageDevice -Cluster cluster1 -CanonicalName naa.1234456abcdefg
        Detaches the specifed LUN from every host in the specifed cluster
    .EXAMPLE
        PS C:\> Detach-StorageDevice | Remove-RDMLun -CanonicalName naa.1234456abcdefg
        Detaches the specifed LUN from every host within every cluster that is piped in from Get-Cluster.
        #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [object[]] $Cluster,
        [Parameter(Mandatory)]
        [string[]] $CanonicalName
    )
    Begin {
        Write-Output "Checking for a connected vCenter Server..."
        if ($global:defaultviserver -ne $null) {
            Write-Output "Connected to $(($global:defaultviserver).Name) as $(($global:defaultviserver).User)"
        } else {
            Write-Output "ERROR: Not connected to vCenter or Host Server...Exiting..."
            Break
        }
    }
    Process {
        $VMHosts = Get-cluster $cluster | get-vmhost
        foreach ($VMHost in $VMHosts) { 
            foreach ($Canonical in $CanonicalName) {
                $storSys = Get-View $VMHost.Extensiondata.ConfigManager.StorageSystem
                Write-Output "Detaching LUNs $Canonical from $VMHost..."
                try {
                    $storSys.DetachScsiLun($Canonical)
                } catch {
                    Write-Output "LUN $Canonical on $VMHost possibly already detached, please check..."
                }

            }
        }
    }
}