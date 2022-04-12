function Get-vCenterAPISessionID {
    <#
    .SYNOPSIS
        Get the API sessionID from a referenced vCenter Server.
    .DESCRIPTION
        Gets the API sessionID from a referenced vCenter Server for use with other API's for authentication.
    .PARAMETER vCenterFQDN
        The vCenter Server FQDN.
    .PARAMETER UserName
        Username for the vCenter Server with the required privelges.
    .PARAMETER Password
        Password for the vCenter Server with the required privelges.
    .NOTES
        Tags: VMware, vCenter, Profiles, PowerCLI, API
        Author: Stephan McTighe
        Website: stephanmctighe.com
    .LINK
        https://github.com/smctighevcp
    .EXAMPLE
        PS C:\> Get-vCenterAPISessionID -vCenterFQDN vcsa-01.domain.com -UserName administrator@vsphere.local -Password SecurePassword!
        Gets the API session ID from the vCenter server vcsa-01.domain.com.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $vCenterFQDN,
        [Parameter(Mandatory)]
        [string] $UserName,
        [Parameter(Mandatory)]
        [string] $Password
    )
    Begin {
        #Authentication
        $User = $UserName
        $Pass = $Password
        $Auth = $User + ":" + $Pass
        $Encoded = [System.Text.Encoding]::UTF8.GetBytes($Auth)
        $EncodedAuth = [System.Convert]::ToBase64String($Encoded)
        $Headers = @{"Authorization" = "Basic $($EncodedAuth)" }

    }
    Process {
        try {
            $Session = Invoke-RestMethod -Method POST -Uri "https://$($vCenterFQDN)/rest/com/vmware/cis/session" -Headers $Headers
            $SessionID = [pscustomobject]@{
                SessionID = $Session.value
            }
            Write-Output $SessionID
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
