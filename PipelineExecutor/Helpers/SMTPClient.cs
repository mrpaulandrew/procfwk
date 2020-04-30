using System;
using System.Collections.Generic;
using System.Text;
using System.Net.Mail;
using Microsoft.IdentityModel.Clients.ActiveDirectory;

namespace ADFprocfwk.Helpers
{
    internal class SMTPClient
    {
        private static string smtpHost { get; set; }
        private static string smtpUser { get; set; }
        private static string smtpPass { get; set; }
        private static int smtpPort { get; set; }
        public static string fromEmail { get; set; }

        public static SmtpClient createSMTPClient()
        {
            smtpHost = Environment.GetEnvironmentVariable("AppSettingSmtpHost");
            smtpPort = int.Parse(Environment.GetEnvironmentVariable("AppSettingSmtpPort"));
            smtpUser = Environment.GetEnvironmentVariable("AppSettingSmtpUser");
            smtpPass = Environment.GetEnvironmentVariable("AppSettingSmtpPass");
            fromEmail = Environment.GetEnvironmentVariable("AppSettingFromEmail");

            SmtpClient emailClient = new SmtpClient();

            emailClient.EnableSsl = true;
            emailClient.DeliveryMethod = SmtpDeliveryMethod.Network;
            emailClient.UseDefaultCredentials = false;
            emailClient.Host = smtpHost;
            emailClient.Port = smtpPort;
            emailClient.Credentials = new System.Net.NetworkCredential(smtpUser, smtpPass);

            Console.WriteLine(smtpHost);

            return emailClient;
        }
    }
}
