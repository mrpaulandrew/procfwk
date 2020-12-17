# Send Email

___
[<< Contents](/procfwk/contents) / [Functions](/procfwk/functions)

___

This function sits within the framework but is very generic and could easily be used by other Azure resources. It's purpose is simply to send an email when provided with all the required email parts.

The code is very simple and uses the System.Web.Mail library.

Namespace: __mrpaulandrew.azure.procfwk__.

## Body Request 

The Function expects the following things in the request body:

|Attribute|Mandatory|Value(s)|
|---|---|---|
|emailRecipients |No |String value of one or many email addresses separated by comma's. |
|emailCcRecipients |No |String value of one or many email addresses separated by comma's. |
|emailBccRecipients |No |String value of one or many email addresses separated by comma's. |
|emailSubject |Yes |String free text value. |
|emailBody |Yes |String free text value. |
|emailImportance |No |This uses the Mail.Priority values of High, Normal or Low. The default value is 'Normal' if not provided in the request. |

The following is an example of this content as a JSON snippet that could be provided to the function.

```json
{
"emailRecipients": "test.user1@adfprocfwk.com",
"emailCcRecipients": "test.user2@adfprocfwk.com",
"emailBccRecipients": "test.user3@adfprocfwk.com",
"emailSubject": "ADFprocfwk Alert: Wait 10 - Success",
"emailBody": "Wait 10 - Success",
"emailImportance": "Low"
}
```

## Body Validation

Request body validation will check for minimum values before establishing the mail client and message. The request must have:

* At least one type of recipient is needed. Either provided in the To, CC or BCC values. 
* An email subject.
* An email body.


## SMTP Details

To promote good practice and avoiding the need for the Function App to use an MSI to access Key Vault the the SMTP credentials and host information is stored in the Application Settings file local to the Azure Functions App. 

In the Visual Studio Solution the project 'local.settings.json' file has been excluded via the Git.Ignore file from the repository. However, a template file name 'template_local.settings.json' can be copied and used when publishing the Functions App or when debugging locally. Below is how this might look in your Visual Studio Solution with the actual local settings file being copied to the bin folder for every build. This is also supported via the Functions App publish screens if you want to edit the local and remote app settings.

![Local Setting File](https://mrpaulandrew.files.wordpress.com/2020/05/procfwk-function-app-settings.png)

Example of the local setting JSON file:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet",
    "AppSettingSmtpHost": "my.smtpservice.com",
    "AppSettingSmtpPort": 1234,
    "AppSettingSmtpUser": "AlertMailboxUser",
    "AppSettingSmtpPass": "Passw0rd123!",
    "AppSettingFromEmail": "noreply@adfprocfwk.com"
  }
}
```

## Logging

If running in debug mode log information provides outputs on the number of recipients included as To/CC/BCC for the send email operation.

___

