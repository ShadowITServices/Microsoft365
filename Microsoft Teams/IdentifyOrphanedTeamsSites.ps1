# Connect to Microsoft Teams
Connect-MicrosoftTeams

# Connect to SharePoint Online
Connect-SPOService -Url https://<MicrosoftTenantName>-admin.sharepoint.com

# Fetch all Teams
$teams = Get-Team

# Fetch all Teams SharePoint Sites
$teamSites = Get-SPOSite -Template "GROUP#0"

# Create an array to hold the orphaned sites
$orphanedSites = @()

# Check for orphaned sites
foreach ($site in $teamSites) {
    $team = $teams | Where-Object { $_.GroupId -eq $site.GroupId }
    if (-not $team) {
        Write-Host "Orphaned site found: $($site.Url)"
        $members = Get-TeamUser -GroupId $site.GroupId | Select-Object -ExpandProperty User

        # Join members into a single string
        $membersList = $members -join "; "

        $orphanedSites += New-Object PSObject -Property @{
            URL = $site.Url
            Owner = $site.Owner
            Created = $site.Created
            Members = $membersList
        }
    }
}

# Export to CSV
$orphanedSites | Export-Csv -Path "C:\Temp\OrphanedTeamsSitesWithMembers.csv" -NoTypeInformation