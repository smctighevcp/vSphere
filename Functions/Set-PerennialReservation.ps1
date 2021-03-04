function Set-PerennialReservation {
    <#
    .SYNOPSIS
        Set Perennial Reservations on RDM Disks per vSphere Cluster.
    .DESCRIPTION
        Sets Perennial Reservations on RDM Disks on a specified vSphere Cluster.  Requires connection to at least one vCenter Server (Connect-VIServer).
    .PARAMETER Cluster
        The vSphere Cluster you wish to target.  This can also be passed via the pipeline using Get-Cluster to target multiple.
    .PARAMETER CanonicalName
        The CanonicalName you wish to target.
    .PARAMETER Export
        Flag to export data to csv rather than printing onscreen.
    .NOTES
        Tags: VMware, vSphere, RDM, PowerCLI, Perennial
        Author: Stephan McTighe
        Website: stephanmctighe.com
    .LINK
        https://github.com/smctighevcp
    .EXAMPLE
        PS C:\> Set-PerennialReservation -Cluster cluster1
        Sets the perennial reservation flag to 'True' for every RDM on every host within the specified cluster.
    .EXAMPLE
        PS C:\> Set-PerennialReservation -Cluster cluster1 -Export
        Sets the perennial reservation flag to 'True' for every RDM on every host within the specified cluster and exports the output to CSV.
    .EXAMPLE
        PS C:\> Get-Cluster | Set-PerennialReservation
        Sets the perennial reservation flag to 'True' for every RDM on every host within every cluster that is piped in from Get-Cluster.
    .EXAMPLE
        PS C:\> Set-PerennialReservation -Cluster cluster1 -CanonicalName naa.1234456abcdefg
        Sets the perennial reservation flag to 'True' for a specific RDM on every host within the specified cluster.
    .EXAMPLE
        PS C:\> Set-PerennialReservation -Cluster cluster1 -CanonicalName naa.1234456abcdefg, naa.78954trewq
        Sets the perennial reservation flag to 'True' for multiple specified RDM's on every host within the specified cluster.
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
        if ($global:defaultviserver -ne $null) {
            Write-Output "INFO: Connected to $(($global:defaultviserver).Name) as $(($global:defaultviserver).User)"
        } else {
            Write-Output "ERROR: Not connected to vCenter or host server...Exiting..."
            Break
        }
    }
    Process {
        $Result = @()
        $VMHosts = Get-cluster $cluster | get-vmhost
        if ($CanonicalName) {
            $RDMs = $CanonicalName
        } else {
            $RDMs = Get-cluster $cluster | Get-VM | Get-HardDisk -DiskType "RawPhysical", "RawVirtual" | Select-Object -ExpandProperty ScsiCanonicalName | Sort-Object -Unique
        }
        foreach ($VMHost in $VMHosts) {
            $esxcli = Get-EsxCli -VMHost $VMHost -V2
            foreach ($Canonical in $RDMs) {
                $State = $esxcli.storage.core.device.list.invoke(@{device = $($Canonical) }) | Select-Object -ExpandProperty IsPerenniallyReserved
                $object = [pscustomobject]@{
                    VMHost        = $VMHost.name
                    Canonical     = $Canonical
                    OriginalState = $State
                }
                If ($State -eq "false") {
                    $setconfig = @{
                        sharedclusterwide   = $true
                        device              = $Canonical
                        perenniallyreserved = $true
                    }
                    $esxcli.storage.core.device.setconfig.invoke($setconfig) > $null
                    $FinalState = $esxcli.storage.core.device.list.invoke(@{device = $Canonical }) | Select-Object -ExpandProperty IsPerenniallyReserved
                    Add-Member -InputObject $object -NotePropertyName IsPerenniallyReserved -NotePropertyValue $FinalState
                    if ($Exportpath) {
                        $Result += $object
                    } Else {
                        $object
                    }
                } Else {
                    Write-Output "Perennial reservation already set for "$Canonical" on "$VMHost"..."
                }
            }
        }
        if ($Exportpath) {
            if ($Result -ne "") {
                $Result | Sort-Object -Property VMHost | Export-Csv (Join-Path $ExportPath "SetPerennialReservations.csv")
                Write-Output ("Exported as CSV to specified directory as {0}" -f (Join-Path $ExportPath "SetPerennialReservations.csv"))
            } Else {
                Write-Output "No RMDs detected or perennial reservation already set, nothing outputed..."
            }
        }
    }
}

