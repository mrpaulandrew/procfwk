using System;
using System.Net.Mail;

namespace ADFprocfwk.Helpers
{
    internal class SMTPClient
    {
        public static string FromEmail { get; set; }

        public static SmtpClient CreateSMTPClient()
        {
            string smtpHost = Environment.GetEnvironmentVariable("AppSettingSmtpHost");
            int smtpPort = int.Parse(Environment.GetEnvironmentVariable("AppSettingSmtpPort"));
            string smtpUser = Environment.GetEnvironmentVariable("AppSettingSmtpUser");
            string smtpPass = Environment.GetEnvironmentVariable("AppSettingSmtpPass");
            
            FromEmail = Environment.GetEnvironmentVariable("AppSettingFromEmail");

            SmtpClient emailClient = new SmtpClient
            {
                EnableSsl = true,
                UseDefaultCredentials = false, //order properties are set is important
                Credentials = new System.Net.NetworkCredential(smtpUser, smtpPass),
                DeliveryMethod = SmtpDeliveryMethod.Network,
                Host = smtpHost,
                Port = smtpPort
            };

            return emailClient;
        }
    }
}
