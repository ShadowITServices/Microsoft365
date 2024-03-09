## Automatically Exclude BreakGlass Group From Conditional Access ##

Having your break glass accounts be part of an exclusion group which is EXCLUDED from conditional access policy is a pivotal piece to your Zero Trust Identity plane, for two simple reasons. This allows the identity team to gain access back into a tenant if someone were to configure a mistake and break AuthZAuthN to the tenant. As well as if a threat actor has taken over and removed the exclusions from the policies. You are at mercy of the recurrence and I would suggest this run, every 1-5m in corporate orgs.

## Deploy the logic app

1 - [AutoCAPExclude](httpsgithub.comShadowITServicesMicrosoft365MicrosoftTenantManagementAutoExcludeBreakGlassAccountsfromConditionalAccess.json). Copy the RAW contents and upload into the template of the logic app.

2 - In Azure, natigave to 'Deploy A Custom Template' and chose 'Build your own template in the editor'

3 - On the screen, copy the contents from step #1 and PASTE into the table, replacing all data.

![](https://github.com/ShadowITServices/blob/main/Microsoft365/Documentation/Images/uploadtemplate.png)

4 - Hit Save and deploy.

## Pre-Configuration of the AutoCAPExclude Logic App

1 - Turn on Managed Identity on the logic app.

2 - On the Parameters Tab of the logic app, Enter the objectID of your Exclusion Group.

3 - Save changes on the logic app.

## Open Azure PowerShell via the browser & Paste the below code

```

$miObjectID = $null
Write-Host Looking for Managed Identity with default prefix names of the Logic App...
$miObjectIDs = @()
$miObjectIDs = (Get-AzureADServicePrincipal -SearchString AutoCapExclude).ObjectId
if ($miObjectIDs -eq $null) {
   $miObjectIDs = Read-Host -Prompt Enter ObjectId of Managed Identity (from Logic App)
}

# The app ID of the Microsoft Graph API where we want to assign the permissions
$appId = 00000003-0000-0000-c000-000000000000
$permissionsToAdd = @(policy.Read.All,Policy.ReadWrite.ConditionalAccess,mail.send)
$app = Get-AzureADServicePrincipal -Filter AppId eq '$appId'

foreach ($miObjectID in $miObjectIDs) {
    foreach ($permission in $permissionsToAdd) {
    Write-Host $permission
    $role = $app.AppRoles  where Value -Like $permission  Select-Object -First 1
    New-AzureADServiceAppRoleAssignment -Id $role.Id -ObjectId $miObjectID -PrincipalId $miObjectID -ResourceId $app.ObjectId
    }
}
```

## Post-Configuration of the AutoCAPExclude Logic App

1. Set your recurrencr of the logic app. Suggested 1-5m.

![](httpsgithub.comShadowITServicesMicrosoft365DocumentationImagesautocaprecur.png)

2. Configure your endpoint based off what graph environment you are working with.

![](httpsgithub.comShadowITServicesMicrosoft365DocumentationImagesautocapgetcond.png)

Graph endpoints for Step2 are below

```
Commercial URL = httpsgraph.microsoft.comv1.0identityconditionalAccesspolicies
Commercial Audience = httpsgraph.microsoft.com

GCC URL = httpsgraph.microsoft.comv1.0identityconditionalAccesspolicies
GCC Audience = httpsgraph.microsoft.com

GCCH URI = httpsgraph.microsoft.usv1.0identityconditionalAccesspolicies
GCCH Audience = httpsgraph.microsoft.us
```

3. Configure the SEND MAIL (POST) and what graph endpoint you need to use. 
The first arrow can and should be a DL email. The second arrow can and should be another DL of one or more.

![](httpsgithub.comShadowITServicesMicrosoft365DocumentationImagesautocapgetcond.png)

Graph endpoints for Step3 are below

```
Commercial URL = httpsgraph.microsoft.comv1.0usersEMAILADDRESSsendmail
Commercial Audience = httpsgraph.microsoft.com

GCC URL = httpsgraph.microsoft.comv1.0usersEMAILADDRESSsendmail
GCC Audience = httpsgraph.microsoft.com

GCCH URI = httpsgraph.microsoft.usv1.0usersEMAILADDRESSsendmail
GCCH Audience = httpsgraph.microsoft.us
```

## Run logic app and test (make sure the exclusion group is not part of a conditional access to test)

Excluded group now added to the CAP

![](httpsgithub.comShadowITServicesMicrosoft365DocumentationImagesautocapproof.png)

Email sent to DLs in the logic app

![](httpsgithub.comShadowITServicesMicrosoft365DocumentationImagessendemailproof.png)

## Monitoring & Alerting of the automation

1. On the logic app, click  Diagnostic Settings and send to the preferred Log Analytics Workspace.

2. Create an Azure Monitor or Sentinel Analytical Rule based off kQL log below

```
AzureDiagnostics
 where resource_workflowName_s == AutoCAPExclude
 sort by TimeGenerated asc
 where status_s == Failed
 distinct startTime_t, resource_workflowName_s, status_s, resource_actionName_s
```
