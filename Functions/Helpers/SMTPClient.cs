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

        public static SmtpClient CreateSMTPClient()
        {
            string smtpHost = Environment.GetEnvironmentVariable("AppSettingSmtpHost");
            int smtpPort = int.Parse(Environment.GetEnvironmentVariable("AppSettingSmtpPort"));
            string smtpUser = Environment.GetEnvironmentVariable("AppSettingSmtpUser");
            string smtpPass = Environment.GetEnvironmentVariable("AppSettingSmtpPass");
            
            fromEmail = Environment.GetEnvironmentVariable("AppSettingFromEmail");

            SmtpClient emailClient = new SmtpClient
            {
                EnableSsl = true,
                DeliveryMethod = SmtpDeliveryMethod.Network,
                UseDefaultCredentials = false,
                Host = smtpHost,
                Port = smtpPort,
                Credentials = new System.Net.NetworkCredential(smtpUser, smtpPass)
            };

            return emailClient;
        }
    }
}
