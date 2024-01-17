# Add the System.Web assembly to use HttpUtility
Add-Type -AssemblyName System.Web

# Define your Microsoft 365 credentials and API endpoints
$clientId = "d0441c79-c127-49d2-8c57-e387411f888d"
$clientSecret = "ATD8Q~gjXr32jIrrl8qXjPXSZnxI0B6lJ8nx3cmj"
$tenantId = "3557fda9-f76e-42ca-97d8-1e3b7093bcbd"
$tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$graphApiUrl = "https://graph.microsoft.com/v2.0/"

# Encode client ID and client secret
$clientIDEncoded = [System.Web.HttpUtility]::UrlEncode($clientId)
$client_SecretEncoded = [System.Web.HttpUtility]::UrlEncode($clientSecret)

# Define the scopes for Microsoft Graph API
$scopes = "https://graph.microsoft.com/.default"

# Create a token request body
$body = @{
    client_id     = $clientIDEncoded
    scope         = $scopes
    client_secret = $client_SecretEncoded
    grant_type    = "client_credentials"
}

# Get the access token
try {
    $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $body
    $accessToken = $response.access_token
} catch {
    Write-Error "Error obtaining access token: $_"
    exit
}

# Define the start date for the query (180 days ago)
$startDate = (Get-Date).AddDays(-180).ToString("yyyy-MM-dd")

# Define the query to get Teams and SharePoint sites activity
$query = "?$filter=lastActivityDateTime ge $startDate and resourceVisualization/containerType eq 'Site'"

# Get Teams and SharePoint sites activity data
try {
    $headers = @{Authorization = "Bearer $accessToken"}
    $activityData = Invoke-RestMethod -Uri ($graphApiUrl + "reports/getSharePointActivityUserCounts" + $query) -Headers $headers -Method Get
} catch {
    Write-Error "Error calling Graph API: $_"
    exit
}

# Filter out sites without activity
$sitesWithoutActivity = $activityData.value | Where-Object { $_.reportRefreshDate -eq $null }

# Display the results
$sitesWithoutActivity | Select-Object -Property Id, SiteDisplayName, SiteUrl, reportRefreshDate | Export-Csv -Path "C:\KWS\sitesWithoutActivity.csv" -NoTypeInformation
