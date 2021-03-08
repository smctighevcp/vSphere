function Remove-PerennialReservation {
    <#
    .SYNOPSIS
        Remove Perennial Reservations on specified RDM Disks individually.
    .DESCRIPTION
        Removes Perennial Reservations on specified RDM Disks.  Requires connection to at least one vCenter Server (Connect-VIServer).
    .PARAMETER Cluster
        The vSphere Cluster you wish to target to remove a specific Perennial Reservation from.
    .PARAMETER CanonicalName
        The Canonical name (naa.) of the LUN or comma seperated list of LUNs you wish to remove the perennial reservation for.
    .NOTES
        Tags: VMware, vSphere, RDM, PowerCLI, Perennial
        Author: Stephan McTighe
        Website: stephanmctighe.com
    .LINK
        https://github.com/smctighevcp
    .EXAMPLE
        PS C:\> Remove-PerennialReservation -Cluster cluster1 -$CanonicalName naa.12345asdfg
        Removes the perennial reservation of a specific RDM on every host within the specified cluster.
    .EXAMPLE
        PS C:\> Remove-PerennialReservation -$Cluster cluster1 -$CanonicalName naa.12345asdfg, naa.67890hjkl
        Removes the perennial reservation of multiple specified RDM's on every host within the specified cluster.
    .EXAMPLE
        PS C:\> Remove-PerennialReservation -$Cluster cluster1 -$CanonicalName naa.12345asdfg, naa.67890hjkl -ExportPath C:\temp
        Removes the perennial reservation of multiple specified RDM's on every host within the specified cluster and exports the output to CSV.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object[]] $Cluster,
        [Parameter(Mandatory)]
        [string[]] $CanonicalName,
        [string] $Exportpath
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
        $removeoutput = @()
        $VMHosts = Get-cluster $cluster | get-vmhost
        $RDMs = $CanonicalName
        Write-Output "Getting perennial reservation results for specified RDMs on $Cluster..."
        foreach ($VMHost in $VMHosts) {
            $esxcli = Get-EsxCli -VMHost $VMHost -V2
            foreach ($Canonical in $RDMs) {
                $State = $esxcli.storage.core.device.list.invoke(@{device = $($Canonical) }) | Select-Object -ExpandProperty IsPerenniallyReserved
                $removeobject = [pscustomobject]@{
                    VMHost        = $VMHost.name
                    Canonical     = $Canonical
                    OriginalState = $State
                }
                $setconfig = @{
                    sharedclusterwide   = $true
                    device              = $Canonical
                    perenniallyreserved = $false
                }
                $esxcli.storage.core.device.setconfig.invoke($setconfig) > $null
                $FinalState = $esxcli.storage.core.device.list.invoke(@{device = $($Canonical) }) | Select-Object -ExpandProperty IsPerenniallyReserved
                Add-Member -InputObject $removeobject -NotePropertyName IsPerenniallyReserved -NotePropertyValue $FinalState

                if ($Exportpath) {
                    $removeoutput += $removeobject
                } Else {
                    $removeobject
                }
            }
        }
        if ($Exportpath) {
            if ($removeoutput -ne "") {
                $removeoutput | Sort-Object -Property VMHost | Export-Csv (Join-Path $ExportPath "RemovePerennialReservations.csv")
                Write-Output ("Exported results as CSV to specified directory as {0}" -f (Join-Path $ExportPath "RemovePerennialReservations.csv"))
            } else {
                Write-Output "Nothing outputed..."

            }
        }
    }
}

