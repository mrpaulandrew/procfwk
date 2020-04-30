using System;
using System.IO;
using System.Threading.Tasks;
using System.Net.Mail;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using ADFprocfwk.Helpers;

namespace ADFprocfwk
{
    public static class SendEmail
    {
        [FunctionName("SendEmail")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("SendEmail Function triggered by HTTP request.");
            log.LogInformation("Parsing body from request.");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            string outputString = string.Empty;

            string recipients = data?.emailRecipients;
            string ccRecipients = data?.emailCcRecipients;
            string subject = data?.emailSubject;
            string message = data?.emailBody;
            string passedImportance = data?.emailImportance ?? ""; //Assume normal importance if not provided.

            //Check for minimum values in body
            if (
                recipients == null ||
                subject == null ||
                message == null
                )
            {
                log.LogInformation("Invalid body.");
                return new BadRequestObjectResult("Invalid request body, value(s) missing.");
            }

            //Create email client
            log.LogInformation("Creating smtp client.");

            using (var client = SMTPClient.createSMTPClient())
            {
                //Create mail
                MailAddress from = new MailAddress(SMTPClient.fromEmail);
                MailMessage mail = new MailMessage
                {
                    From = from,
                    IsBodyHtml = true,
                    Subject = subject,
                    Body = message
                };

                //Set mail importance
                if (passedImportance.ToUpper() == "HIGH")
                {
                    mail.Priority = MailPriority.High;
                }
                else if (passedImportance.ToUpper() == "LOW")
                {
                    mail.Priority = MailPriority.Low;
                }
                else
                {
                    mail.Priority = MailPriority.Normal;
                }

                //Parse recipients
                foreach (var address in recipients.Split(new[] { "," }, StringSplitOptions.RemoveEmptyEntries))
                {
                    mail.To.Add(address);
                }

                //Parse cc recipients
                if (!string.IsNullOrEmpty(ccRecipients))
                {
                    foreach (var ccAddress in ccRecipients.Split(new[] { "," }, StringSplitOptions.RemoveEmptyEntries))
                    {
                        mail.CC.Add(ccAddress);
                    }
                }

                //Send email
                try
                {
                    log.LogInformation("Sending email.");

                    client.Send(mail);
                    outputString = "{ \"EmailSent\": true }";
                }
                catch
                {
                    outputString = "{ \"EmailSent\": false }";
                    log.LogInformation("Message has not been sent. Check Azure Function Logs for more information.");
                }
                
            }

            JObject outputJson = JObject.Parse(outputString);

            log.LogInformation("SendEmail Function complete.");
            return new OkObjectResult(outputJson);
        }
    }
}
