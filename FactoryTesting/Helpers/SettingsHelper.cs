using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using NUnit.Framework;
using System;

namespace FactoryTesting.Helpers
{
    public class SettingsHelper<T>
    {
        public string GetSetting(string settingName)
        {
            // return environment variable "settingName", if present
            var value = Environment.GetEnvironmentVariable(settingName);
            if (value?.Length > 0)
                return value;

            // return value of runsettings parameter "settingName", if present
            value = TestContext.Parameters[settingName];
            if (value?.Length > 0)
                return value;

            // if a key vault is specified, return the value of secret "settingName", if present
            if (_keyVaultClient != null)
            {
                value = _keyVaultClient.GetSecret(settingName).Value.Value;
                if (value?.Length > 0)
                    return value;
            }

            throw new Exception($"Test setting '{settingName}' not found");
        }

        private readonly SecretClient _keyVaultClient;

        public SettingsHelper()
        {
            var kvUrl = TestContext.Parameters["KeyVaultUrl"];
            if (kvUrl?.Length > 0)
                _keyVaultClient = new SecretClient(new Uri(kvUrl), new DefaultAzureCredential());
        }
    }
}