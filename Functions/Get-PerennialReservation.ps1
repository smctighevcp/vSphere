function Get-PerennialReservation {
    <#
    .SYNOPSIS
        Get Perennial Reservations on RDM Disks per vSphere Cluster.
    .DESCRIPTION
        Lists Perennial Reservations on RDM Disks on a specified vSphere Cluster.  Requires connection to at least one vCenter Server (Connect-VIServer).
    .PARAMETER Cluster
        The vSphere Cluster you wish to target.  This can also be passed via the pipeline using Get-Cluster to target multiple.
    .PARAMETER CanonicalName
        The CanonicalName you wish to target.
    .PARAMETER ExportPath
        Flag to export data to csv rather than printing onscreen.
    .NOTES
        Tags: VMware, vSphere, RDM, PowerCLI, PerennialReservations
        Author: Stephan McTighe
        Website: stephanmctighe.com
    .LINK
        https://github.com/smctighevcp
    .EXAMPLE
        PS C:\> Get-PerennialReservation -Cluster cluster1
        Gets the perennial reservation status of every RDM on every host within the specified cluster.
    .EXAMPLE
        PS C:\> Get-PerennialReservation -Cluster cluster1 -ExportPath
        Gets the perennial reservation status of every RDM on every host within the specified cluster and exports the output to CSV.
    .EXAMPLE
        PS C:\> Get-Cluster | Get-PerennialReservation
        Gets the perennial reservation status of every RDM on every host within every cluster that is piped in from Get-Cluster.
    .EXAMPLE
        PS C:\> Get-PerennialReservation -Cluster cluster1 -CanonicalName naa.1234456abcdefg
        Gets the perennial reservation status of a specific RDM on every host within the specified cluster.
    .EXAMPLE
        PS C:\> Get-PerennialReservation -Cluster cluster1 -CanonicalName naa.1234456abcdefg, naa.12345qwert
        Gets the perennial reservation status of multiple specified RDM's on every host within the specified cluster.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [object[]] $Cluster,
        [string] $ExportPath,
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
        $getoutput = @()
        $VMHosts = Get-cluster $cluster | Get-VMhost
        if ($CanonicalName) {
            $RDMs = $CanonicalName
        } else {
            $RDMs = Get-cluster $cluster | Get-VM | Get-HardDisk -DiskType "RawPhysical", "RawVirtual" | Select-Object -ExpandProperty ScsiCanonicalName | Sort-Object -Unique
        }
        Write-Output "Getting Perennial Reservation details for RDMs on $Cluster..."
        foreach ($VMHost in $VMHosts) {
            $esxcli = Get-EsxCli -VMHost $VMHost -V2
            foreach ($Canonical in $RDMs) {
                $State = $esxcli.storage.core.device.list.invoke(@{device = $($Canonical) }) | Select-Object -ExpandProperty IsPerenniallyReserved
                $getobject = [pscustomobject]@{
                    VMHost                = $VMHost.name
                    Canonical             = $Canonical
                    IsPerenniallyReserved = $State
                }
                if ($Exportpath) {
                    $getoutput += $getobject
                } Else {
                    $getobject
                }
            }
        }
        if ($Exportpath) {
            if ($getoutput -ne "") {
                $getoutput | Sort-Object -Property VMHost | Export-Csv (Join-Path $ExportPath "GetPerennialReservations.csv")
                Write-Output ("Exported results as CSV to specified directory as {0}" -f (Join-Path $ExportPath "GetPerennialReservations.csv"))
            } else {
                Write-Output "No RMDs Detected, nothing outputed..."
            }
        }
    }
}