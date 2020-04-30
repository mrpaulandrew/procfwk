using System;
using System.Collections.Generic;
using System.Text;
using System.Net.Mail;
using Microsoft.IdentityModel.Clients.ActiveDirectory;

namespace ADFprocfwk.Helpers
{
    internal class SMTPClient
    {
        public static string fromEmail { get; set; }

        public static SmtpClient createSMTPClient()
        {
            string smtpHost = Environment.GetEnvironmentVariable("AppSettingSmtpHost");
            int smtpPort = int.Parse(Environment.GetEnvironmentVariable("AppSettingSmtpPort"));
            string smtpUser = Environment.GetEnvironmentVariable("AppSettingSmtpUser");
            string smtpPass = Environment.GetEnvironmentVariable("AppSettingSmtpPass");
            
            fromEmail = Environment.GetEnvironmentVariable("AppSettingFromEmail");

            SmtpClient emailClient = new SmtpClient();

            emailClient.EnableSsl = true;
            emailClient.DeliveryMethod = SmtpDeliveryMethod.Network;
            emailClient.UseDefaultCredentials = false;
            emailClient.Host = smtpHost;
            emailClient.Port = smtpPort;
            emailClient.Credentials = new System.Net.NetworkCredential(smtpUser, smtpPass);

            return emailClient;
        }
    }
}
