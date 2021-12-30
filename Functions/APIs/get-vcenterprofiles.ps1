function Get-vCenterProfiles {
    <#
    .SYNOPSIS
        Get the vCenter Server Profiles from a referenced vCenter Server.
    .DESCRIPTION
        Gets the vCenter Server Profiles from a referenced vCenter Server.
    .PARAMETER vCenterFQDN
        The vCenter Server FQDN.
    .PARAMETER SessionID
        Username for the vCenter Server with the required privelges.
    .NOTES
        Tags: VMware, vCenter, Profiles, PowerCLI, API
        Author: Stephan McTighe
        Website: stephanmctighe.com
    .LINK
        https://github.com/smctighevcp
    .EXAMPLE
        PS C:\> Get-vCenterProfiles -vCenterFQDN vcsa-01.domain.com -SessionID d84b95e370f1ed68b997f4affbe6feba
        Gets the vCenter Server Profiles from the vCenter server vcsa-01.domain.com.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [string] $SessionID,
        [Parameter(Mandatory)]
        [string] $vCenterFQDN

    )
    Begin {
        $SessionHeaders = @{'vmware-api-session-id' = "$($SessionID)"
        }
    }
    Process {
        try {
            Invoke-RestMethod -Method GET -Uri "https://$($vCenterFQDN)/api/appliance/infraprofile/configs" -Headers $SessionHeaders
        } catch {
            Write-Host "An error occurred!" -ForegroundColor Red
            if ($_.ErrorDetails -like "*Authentication required*") {
                Write-Host "Possible authentication issue, check username and password ... " -ForegroundColor Blue
            }
            Write-Host "Full error ... " -ForegroundColor Blue
            Write-Host $_.ErrorDetails -ForegroundColor Red
        }
    }
}
