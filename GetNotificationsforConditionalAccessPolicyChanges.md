## Get notified off a Conditional Access Policy Change ##

Changes in the Conditional Access Policies can have a big impact and Conditional Access is responsible for granting and blocking access to cloud resources. By default, there is no option to get notified of CA policy changes. So, I decided to dig into the Audit logs and Graph API to get notifications, so you don’t have to log on to the Azure AD portal and check manually the log files. Also, you can inform the users without admin accounts like managers or a change manager so he/she can check if the change is registered and approved to execute.

In this Github Article, I use an Azure Logic App to receive the notifications in Teams, but this solution can also be built via a Power Automate Flow.

## Reference Materials & Constraints ##

This solution is adopting the Microsoft Conditional Access blade within Entra ID, therefore you will require one of the following licenses:

- Microsoft 365 Business Premium
- Microsoft 365 Frontline F1/F3
- Microsoft 365 Education A3/A5
- Microsoft 365 Enterprise E3/E5

Additionally, you will require the following Role Based Access - Cloud Application Administrator.

Microsoft Graph Requirements:

- AuditLog.Read.All
- Directory.Read.All

## What is Conditional Access? ##

Conditional Access brings signals together, to make decisions, and enforce organizational policies. Azure AD Conditional Access is at the heart of the new identity-driven control plane. Conditional Access policies at their simplest are if-then statements.
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/ConditionalAccess.png)

More information about Conditional Access can be found here -  https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview

## What is an Azure Logic App? ##

Azure Logic Apps is a cloud service that helps you schedule, automate, and orchestrate tasks, business processes, and workflows when you need to integrate apps, data, systems, and services across enterprises or organizations.

More information about Azure Logic Apps can be found here - https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-overview

## What are Adaptive Cards? ##

Adaptive Cards are platform-agnostic snippets of UI, authored in JSON, that apps and services can openly exchange. When delivered to a specific app, the JSON is transformed into a native UI that automatically adapts to its surroundings. It helps design and integrate lightweight UI for all major platforms and frameworks.
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/Adaptive-Cards.png)

More information about Adaptive cards can be found here - https://adaptivecards.io/#:~:text=Adaptive%20Cards%20are%20platform%2Dagnostic,all%20major%20platforms%20and%20frameworks.

## Create an App Registration in Entra ID ##

- Open https://azure.com/
- Click on **Azure Entra ID**
- Click on **App Registration** in the left menu (or use the following link https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps)
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/App-registration-Menu.png)
- Click on **+ New registration**
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/AppRegistrations-NewRegistration.png)
- Provide an App Registration Name (Conditional Access Notifications)
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/AppRegistrations.png)
- Click on the **Register** button, the app will be created and automatically opened.
- In the menu click on **API Permissions**
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/APIPermissions.png)
- Click on **+ Add a permission**
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/APIPermissions-Add.png)
- Select **Microsoft Graph** and select **Application Permissions**
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/ApplicationPermissions.png)
- Search and Add the following Permissions:
```
AuditLog.Read.All
Directory.Read.All
```
- Grant admin consent for your organization
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/GrantConsent.png)
- Once completed, you will see the status turn to green with ticks.
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/GrantConsent-Completed.png)
- In the menu click on **Certificates & Secrets**
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/Certificates-Menu.png)
- Click on **+ New Client secret**
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/Certificates-NewSecret.png)
- Set a **description** and the **expiry** of the secret and click on **Add**
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/AddClientSecret.png)
- Copy the value of the secret, the secret is needed for the flow.
- Go to the overview page and copy the **Client ID** and **Tenant ID**, those are also needed in the flow.
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/TenantInfo.png)

## Create a Teams Channel Webhook ##

- Open **Microsoft Teams**
- Click on **Teams** in the menu and select the correct team
- Click on the **3 bullets** behind a Teams channel
- Click on the **Manage Channel** option
- Click the **Settings** option in the top menu bar
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/TeamSettings.png)
- Click **Connectors** and select **Edit**
- In the new window, click **Add** for **Incoming Webhook**
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/IncomingWebhook-Add.png)
- Click **Add** once again in the new window
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/TeamsAdd-Confirmation.png)
- Provide the **Incoming Webhook** a name and change the image if you wish, then click **Create**.
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/WebhookConfig.png)
**Note:** This name will be displayed for every notification.
- A Webhook URL will automatically be created, copy this URL because it is needed in the flow.
- Click on **Done**
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/WebhookConfig-Confirm.png)

## Create an Azure Logic App for the Conditional Access Changes Notifications ##

**Note:** Rename every Azure Logic App action to match the screenshots!

- Open **https://portal.azure.com/**
- Search for **Logic Apps**
- Click on **+ Add**
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/LogicApps-Add.png)
- Select an existing **Resource Group** or create a new **Resource Group**
- Select the **Instance Type** (I have chosen for Consumption, but check the Azure Calculator - (https://azure.microsoft.com/en-us/pricing/calculator/) which option fits your environment)
- Select your region and click on **Review + Create**
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/LogicApp-Creation.png)
- Check the details on the **Review + Create** page and click on **Create**
- After the deployment is completed, go to your new Logic App via **Go to Resource** button
- Click **Edit** and we will configure the resource.
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/LogicApp-Edit.png)

**Note:** I have used a 1-hour interval in this blog.

![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/Logic-App-First-Step-Recurrence.png)
- The next four steps of the workflow are to initialize variables.

|                           | Initialize Audience Variable | Initialize TenantID Variable | Initialize ClientID Variable | Initialize Secret Variable |
|---------------------------|------------------------------|------------------------------|------------------------------|----------------------------|
| **Name**                  | Audience                     | ClientID                     | TenantID                     | Secret                     |
| **Type**                  | String                       | String                       | String                       | String                     |  
| **Value**                 | `https://graph.microsoft.com`| `{Paste your Tenant ID}`     | `{Paste your Client ID}`     | `{Paste your Secret}`      |

![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/Logic-App-Second-to-Fifth-initialize-Variable.png)

- The next step is to get the Conditional Access audit log events via an **HTTP** Get request

| Parameter            | Value                          |
|----------------------|--------------------------------|
| METHOD               | GET                            |
| Authentication Type  | Active Directory OAuth         |
| Tenant               | `@{variables('TenantID')}`     |
| Audience             | `@{variables('Audience')}`     |
| Client ID            | `@{variables('ClientID')}`     |
| Credential Type      | Secret                         |
| Secret               | `@{variables('Secret')}`       |

- URI:
```
https://graph.microsoft.com/beta/auditLogs/directoryAudits?$filter=%20activityDateTime%20gt%20@{formatDateTime(addMinutes(utcNow(),-5),'yyyy-MM-ddTHH:mm:ssZ')} and category eq 'Policy' and loggedByService eq 'Conditional Access'
```
- Now we have all the Conditional Access audit log events of the last 5 minutes we create a **for each** action with the following configuration.

![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/Logic-App-Step-Six-HTTP-Get-Auditlogs.png)

- Now we have to create a **for each** loop because it could happen that more Conditional access rules have been changed

```
Expression: body('HTTP_Get_-_Conditional_Access_Audit_Logs')?['value']
```
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/Logic-App-Step-Seven-For-Each.png)

- In the **for each** loop, we create a condition action because a Conditional Access policy can be changed by a user or an app.

```
Expression: empty(items('Apply_To_Each_Conditional_Access_Log_Event')?['initiatedBy']?['user']?['userPrincipalName'])
is equal to 
Expression: false
```
![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/Logic-App-Condition.png)
- In the Yes condition, we must create an **HTTP post** action
- Paste the copied webhook URL in the URI field
- The body of the **HTTP Post** action must be filled with the code of the **Adaptive card**

```json
{
  "attachments": [
    {
      "content": {
        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
        "body": [
          {
            "columns": [
              {
                "items": [
                  {
                    "text": "@{items('Apply_To_Each_Conditional_Access_Log_Event')?['loggedByService']} activity by @{items('Apply_To_Each_Conditional_Access_Log_Event')?['initiatedBy']?['user']?['userPrincipalName']}",
                    "type": "TextBlock",
                    "weight": "bolder",
                    "wrap": true
                  },
                  {
                    "isSubtle": true,
                    "spacing": "none",
                    "text": "@{formatDateTime(item()?['activityDateTime'], 'U')}",
                    "type": "TextBlock",
                    "wrap": true
                  }
                ],
                "type": "Column",
                "width": "stretch"
              }
            ],
            "type": "ColumnSet"
          },
          {
            "facts": [
              {
                "title": "Name:",
                "value": "@{item()?['targetResources'][0]?['displayName']}"
              },
              {
                "title": "Initiator:",
                "value": "@{items('Apply_To_Each_Conditional_Access_Log_Event')?['initiatedBy']?['user']?['userPrincipalName']}"
              },
              {
                "title": "Type:",
                "value": "@{items('Apply_To_Each_Conditional_Access_Log_Event')?['loggedByService']}"
              },
              {
                "title": "Timestamp:",
                "value": "@{items('Apply_To_Each_Conditional_Access_Log_Event')?['activityDateTime']}"
              },
              {
                "title": "Activity:",
                "value": "@{items('Apply_To_Each_Conditional_Access_Log_Event')?['activityDisplayName']}"
              }
            ],
            "type": "FactSet"
          }
        ],
        "msteams": {
          "width": "Full"
        },
        "type": "AdaptiveCard",
        "version": "1.5"
      },
      "contentType": "application/vnd.microsoft.card.adaptive",
      "contentUrl": null
    }
  ],
  "type": "message"
}
```

- In the **No** condition, we also create another **HTTP post**
- Paste again the webhook URL in the URI field
- The **body** of the **HTTP Post** action must be filled with the code of the **Adaptive card**

```json
{
  "attachments": [
    {
      "content": {
        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
        "body": [
          {
            "columns": [
              {
                "items": [
                  {
                    "text": "@{items('Apply_To_Each_Conditional_Access_Log_Event')?['loggedByService']} activity by App ID: @{items('Apply_To_Each_Conditional_Access_Log_Event')?['initiatedBy']?['app']?['appId']}",
                    "type": "TextBlock",
                    "weight": "bolder",
                    "wrap": true
                  },
                  {
                    "isSubtle": true,
                    "spacing": "none",
                    "text": "@{formatDateTime(item()?['activityDateTime'], 'U')}",
                    "type": "TextBlock",
                    "wrap": true
                  }
                ],
                "type": "Column",
                "width": "stretch"
              }
            ],
            "type": "ColumnSet"
          },
          {
            "facts": [
              {
                "title": "Name:",
                "value": "@{item()?['targetResources'][0]?['displayName']}"
              },
              {
                "title": "Initiator:",
                "value": "Application id : @{items('Apply_To_Each_Conditional_Access_Log_Event')?['initiatedBy']?['app']?['appId']}"
              },
              {
                "title": "Type:",
                "value": "@{items('Apply_To_Each_Conditional_Access_Log_Event')?['loggedByService']}"
              },
              {
                "title": "Timestamp:",
                "value": "@{items('Apply_To_Each_Conditional_Access_Log_Event')?['activityDateTime']}"
              },
              {
                "title": "Activity:",
                "value": "@{items('Apply_To_Each_Conditional_Access_Log_Event')?['activityDisplayName']}"
              }
            ],
            "type": "FactSet"
          }
        ],
        "msteams": {
          "width": "Full"
        },
        "type": "AdaptiveCard",
        "version": "1.5"
      },
      "contentType": "application/vnd.microsoft.card.adaptive",
      "contentUrl": null
    }
  ],
  "type": "message"
}
```
**Note:** More information about Adaptive cards designs can be found here: https://docs.microsoft.com/en-us/adaptive-cards/templating/

- Save the Logic App and Click on **Run Trigger**

![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/Save-and-Run-Trigger.png)

## Entire Azure Logic App Flow ##

![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/Logic-App-Entire-Flow-1030x794.png)

## Results ##

![](https://github.com/ShadowITServices/Microsoft365/blob/main/Documentation/Images/CAChangeNotificationviaTeams.png)
