function Export-vCenterProfiles {
    <#
    .SYNOPSIS
        Export the vCenter Server Profiles from a referenced vCenter Server.
    .DESCRIPTION
        Exports the vCenter Server Profiles from a referenced vCenter Server.
    .PARAMETER vCenterFQDN
        The vCenter Server FQDN.
    .PARAMETER SessionID
        SesionID to authenticate with the vCenter Server.
    .PARAMETER ExportPath
        Path to export the JSON configuration to.
    .NOTES
        Tags: VMware, vCenter, Profiles, PowerCLI, API
        Author: Stephan McTighe
        Website: stephanmctighe.com
    .LINK
        https://github.com/smctighevcp
    .EXAMPLE
        PS C:\> Export-vCenterProfiles -vCenterFQDN vcsa-01.domain.com -SessionID d84b95e370f1ed68b997f4affbe6feba -ExportPath C:\temp
        Exports the vCenter Server Profiles from the vCenter server vcsa-01.domain.com.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [string] $SessionID,
        [Parameter(Mandatory)]
        [string] $vCenterFQDN,
        [Parameter(Mandatory)]
        [string] $ExportPath

    )
    Begin {
        $SessionHeaders = @{
            "vmware-api-session-id" = "$($SessionID)"
            "Content-type"          = "application/json"
        }
    }
    Process {
        try {
            $Export = Invoke-RestMethod -Method POST -Uri "https://$($vCenterFQDN)/api/appliance/infraprofile/configs?action=export" -Headers $SessionHeaders
            $Export | Out-File "$($ExportPath)\vcenter-profile-export.json"
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
