using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using System;

namespace mrpaulandrew.azure.procfwk.Helpers
{
    internal class KeyVaultClient
    {
        private static readonly DefaultAzureCredential defaultCred = new DefaultAzureCredential();

        public static string GetSecretFromUri(string secretString)
        {
            return GetSecretFromUri(new Uri(secretString));
        }

        public static string GetSecretFromUri(Uri secretUri)
        {
            string keyVaultURL = "https://" + secretUri.Host.ToString();
            string secretName = secretUri.LocalPath.ToString().Replace("secrets/", "").Replace("/", "");
            return CreateKeyVaultClient(keyVaultURL).GetSecret(secretName).Value.Value;
        }

        public static string GetSecretFromName(string keyVaultURL, string secretName)
        {
            return CreateKeyVaultClient(keyVaultURL).GetSecret(secretName).Value.Value;
        }

        private static SecretClient CreateKeyVaultClient(string keyVaultURL)
        {
            return new SecretClient(new Uri(keyVaultURL), defaultCred);
        }
    }
}
