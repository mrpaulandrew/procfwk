# Helpers

___
[<< Contents](/procfwk/contents) / [Functions](/procfwk/functions)

___

The Azure Functions App used by the framework contains the following internal classes that support the public functions with reuseable methods and clients to authenticate against external Azure resources in a common way.

This internal classes all live within the namespace __ADFprocfwk.Helpers__.

___

## Data Factory Client Class

Methods:

### CreateDataFactoryClient

* tenantId
* applicationId
* authenticationKey
* subscriptionId

__Returns:__ Microsoft.Azure.Management.DataFactory.DataFactoryManagementClient

__Role:__ this helper is used by the execute pipeline, check pipeline status and get error details function to authenticate against the target worker data factory at runtime before invoking pipeline operation requests.

__Exmaple Use:__
```csharp
using (var client = DataFactoryClient.CreateDataFactoryClient(tenantId, applicationId, 
    authenticationKey, subscriptionId))
{
    PipelineRun pipelineRun;

    pipelineRun = client.PipelineRuns.Get(resourceGroup, factoryName, runResponse.RunId);
}
```
___

## Synapse Client Class (coming soon)

Methods:

### CreateSynapseClient

__Returns:__ Microsoft.Azure.Management.Synapse.SynapseManagementClient

__Role:__ Coming Soon

__Example Use:__
```csharp
using var client = SynapseClient.CreateSynapseClient(tenantId, applicationId, authenticationKey, subscriptionId);
```
___

## Key Vault Client Class

Methods:

### GetSecretFromUri

* secretString or secretUri

__Returns:__ value

__Role:__ if the functions app needs to get a secret value from Azure Key Vault this methods wraps up the call to the respective key vault resource using the URL provided and authenticating against key vault using the [Function App MSI](/procfwk/functions).

__Example Use:__
```csharp
string authenticationKey = 
    KeyVaultClient.GetSecretFromUri(authenticationKey);
```
___

## SMTP Client Class

Methods:

### CreateSMTPClient

__Returns:__ System.Net.Mail.SmtpClient

__Role:__ creates a means of sending emails to an SMTP mailing service from the framework [send email](/procfwk/sendemail) function. The client wraps up the authentication details and host information so the public function can focus on constructing the email/content to be sent.

__Example Use:__
```csharp
using (var client = SMTPClient.CreateSMTPClient())
{
    MailAddress from = new MailAddress(SMTPClient.FromEmail);
    MailMessage mail = new MailMessage
    {
        From = from,
        IsBodyHtml = true,
        Subject = subject,
        Body = message
    };

    mail.To.Add(toAddress);
    mail.CC.Add(ccAddress);
    mail.Bcc.Add(bccAddress);
    
    client.Send(mail);
}
```
___

## Request Helper Class

Methods:

### CheckUri

* uriValue

__Returns:__ bool

__Role:__ provides a simple validation check for values passed to the public functions as part of the request body.

__Example Use:__
```csharp
if (RequestHelper.CheckUri(authenticationKey))
{
    log.LogInformation("Valid URL Provided");
}
```
___

### CheckGuid

* idValue

__Returns:__ bool

__Role:__ provides a simple validation check for values passed to the public functions as part of the request body.

__Example Use:__
```csharp
if (!RequestHelper.CheckGuid(applicationId))
{
    log.Error("Invalid GUID Provided.");
}
```
___