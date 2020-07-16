using System;
using System.Collections.Generic;
using System.Text;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.AspNetCore.Http;
using Microsoft.Identity.Client;

namespace ADFprocfwk.Helpers
{
    internal class KeyVaultClient
    {
        private static readonly DefaultAzureCredential defaultCred = new DefaultAzureCredential();

        private static SecretClient kvClient;

        public static string GetSecretFromUri(string secretString)
        {
            return GetSecretFromUri(new Uri(secretString));
        }
        
        public static string GetSecretFromUri(Uri secretUri)
        {
            string keyVaultURL = "https://" + secretUri.Host.ToString();
            string secretName = secretUri.LocalPath.ToString().Replace("secrets/", "").Replace("/", "");

            var value = CreateKeyVaultClient(keyVaultURL).GetSecret(secretName).Value.Value;

            return value;
        }

        public static string GetSecretFromName(string keyVaultURL, string secretName)
        {
            var value = CreateKeyVaultClient(keyVaultURL).GetSecret(secretName).Value.Value;

            return value;
        }

        private static SecretClient CreateKeyVaultClient()
        {
            string keyVaultURL = Environment.GetEnvironmentVariable("keyVaultURL");

            kvClient = new SecretClient(new Uri(keyVaultURL), defaultCred);

            return kvClient;
        }

        private static SecretClient CreateKeyVaultClient(string keyVaultURL)
        {
            kvClient = new SecretClient(new Uri(keyVaultURL), defaultCred);

            return kvClient;
        }

        private static SecretClient CreateKeyVaultClient(Uri keyVaultURL)
        {
            kvClient = new SecretClient(keyVaultURL, defaultCred);

            return kvClient;
        }  
    }
}
