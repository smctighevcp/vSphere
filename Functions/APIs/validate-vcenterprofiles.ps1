function Validate-vCenterProfiles {
    <#
    .SYNOPSIS
        Validate the vCenter Server Profiles against a target vCenter Server.
    .DESCRIPTION
        Validates the vCenter Server Profiles against a target vCenter Server.
    .PARAMETER vCenterFQDN
        The vCenter Server FQDN.
    .PARAMETER SessionID
        SesionID to authenticate with the vCenter Server.
    .PARAMETER jsonPath
        Path to the JSON configuration file to validate.
    .NOTES
        Tags: VMware, vCenter, Profiles, PowerCLI, API
        Author: Stephan McTighe
        Website: stephanmctighe.com
    .LINK
        https://github.com/smctighevcp
    .EXAMPLE
        PS C:\> Validate-vCenterProfiles -vCenterFQDN vcsa-02.domain.com -SessionID d84b95e370f1ed68b997f4affbe6feba -jsonPath C:\temp
        Validates the vCenter Server Profiles from the vCenter server vcsa-01.domain.com against vcsa-02.domain.com.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $SessionID,
        [Parameter(Mandatory)]
        [string] $vCenterFQDN,
        [Parameter(Mandatory)]
        [string] $jsonPath

    )
    Begin {
        $SessionHeaders = @{
            "vmware-api-session-id" = "$($SessionID)"
            "Content-type"          = "application/json"
        }
        $body = Convertto-json @{
            'config_spec' = Get-Content "$($jsonPath)\vcenter-profile-export.json"
        }
    }
    Process {
        try {
            $validate = Invoke-RestMethod -Method POST -Uri "https://$($vCenterFQDN)/api/appliance/infraprofile/configs?action=validate&vmw-task=true" -Headers $SessionHeaders -Body $body
            $validate
        } catch {
            Write-Host "An error occurred!" -ForegroundColor Red
            Write-Host $_ -ForegroundColor Red
        }
    }
}
