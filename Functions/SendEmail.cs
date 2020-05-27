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
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using System.Linq;

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

            #region ParseRequestBody
            log.LogInformation("Parsing body from request.");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            string outputString = string.Empty;
            JObject outputJson;

            string recipients = data?.emailRecipients;
            string ccRecipients = data?.emailCcRecipients;
            string bccRecipients = data?.emailBccRecipients;
            string subject = data?.emailSubject;
            string message = data?.emailBody;
            string passedImportance = data?.emailImportance ?? ""; //Set normal importance if not provided.
            #endregion

            #region ValidateRequestBody
            //Check for minimum mailing values in request body
            if (
                subject == null ||
                message == null
                )
            {
                log.LogInformation("Invalid body - Subject/Body.");
                
                outputString = "{ \"EmailSent\": false, \"Details\": \"Email subject or body values missing.\"}";
                outputJson = JObject.Parse(outputString);
                
                return new BadRequestObjectResult(outputJson);
            }

            if (
                recipients == null &&
                ccRecipients == null &&
                bccRecipients == null
                )
            {
                log.LogInformation("Invalid body - To/CC/BCC.");
                
                outputString = "{ \"EmailSent\": false, \"Details\": \"No email recipients provided as To/CC/BCC.\"}";
                outputJson = JObject.Parse(outputString);
                
                return new BadRequestObjectResult(outputJson);
            }
            #endregion

            //Create email client
            log.LogInformation("Creating smtp client.");

            using (var client = SMTPClient.CreateSMTPClient())
            {
                #region CreateMail                
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
                #endregion

                #region SetRecipients
                //to recipients
                if (!string.IsNullOrEmpty(ccRecipients))
                {
                    foreach (var address in recipients.Split(new[] { "," }, StringSplitOptions.RemoveEmptyEntries))
                    {
                        mail.To.Add(address);
                    }
                    log.LogInformation("To Recipients Added: " + recipients.Split(new[] { "," }, StringSplitOptions.RemoveEmptyEntries).Count().ToString());
                }
                else
                {
                    log.LogInformation("To Recipients Added: 0");
                }

                //cc recipients
                if (!string.IsNullOrEmpty(ccRecipients))
                {
                    foreach (var ccAddress in ccRecipients.Split(new[] { "," }, StringSplitOptions.RemoveEmptyEntries))
                    {
                        mail.CC.Add(ccAddress);
                    }
                    log.LogInformation("CC Recipients Added: " + ccRecipients.Split(new[] { "," }, StringSplitOptions.RemoveEmptyEntries).Count().ToString());
                }
                else
                {
                    log.LogInformation("CC Recipients Added: 0");
                }

                //bcc recipients
                if (!string.IsNullOrEmpty(bccRecipients))
                {
                    foreach (var bccAddress in bccRecipients.Split(new[] { "," }, StringSplitOptions.RemoveEmptyEntries))
                    {
                        mail.Bcc.Add(bccAddress);
                    }
                    log.LogInformation("BCC Recipients Added: " + bccRecipients.Split(new[] { "," }, StringSplitOptions.RemoveEmptyEntries).Count().ToString());
                }
                else
                {
                    log.LogInformation("BCC Recipients Added: 0");
                }
                #endregion

                #region SendEmail
                try
                {
                    log.LogInformation("Sending email.");

                    client.Send(mail);
                    outputString = "{ \"EmailSent\": true }";

                    log.LogInformation("Sent email.");
                }
                catch (SmtpException smtpEx)
                {
                    outputString = "{ \"EmailSent\": false, \"Details\": \"SMTP exception caught and logged to error output.\"}";

                    log.LogError(smtpEx.Message);
                    log.LogInformation("Message has not been sent. Check Azure Function Logs for more information.");
                }
                catch (Exception ex)
                {
                    outputString = "{ \"EmailSent\": false, \"Details\": \"Other exception caught and logged to error output.\"}";

                    log.LogError(ex.Message);
                    log.LogInformation("Message has not been sent. Check Azure Function Logs for more information.");
                }
                #endregion
            }

            outputJson = JObject.Parse(outputString);

            log.LogInformation("SendEmail Function complete.");
            return new OkObjectResult(outputJson);
        }
    }
}
