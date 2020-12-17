# Helpers

___
[<< Contents](/procfwk/contents) / [Functions](/procfwk/functions)

___

The Azure Functions App used by the framework contains the following internal classes that support the public functions with reuseable methods and clients to authenticate against external Azure resources in a common way.

Namespace: __mrpaulandrew.azure.procfwk.Helpers__.

___

## Body Requests

Raw HTTP Body requests are parsed, validated and represented as the following request types:

* [Pipeline Request](/procfwk/pipelinerequest)
* [Pipeline Run Request](/procfwk/pipelinerunrequest)



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


## InvalidRequestException

See [InvalidRequestException](/procfwk/invalidrequestexception) class.

___

