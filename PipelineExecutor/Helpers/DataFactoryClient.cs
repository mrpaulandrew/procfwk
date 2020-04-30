using System;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Rest;
using Microsoft.Azure.Management.DataFactory;

namespace ADFprocfwk.Helpers
{
    internal class DataFactoryClient
    {
        public static DataFactoryManagementClient CreateDataFactoryClient(string tenantId, string applicationId, string authenticationKey, string subscriptionId)
        {
            var context = new AuthenticationContext("https://login.windows.net/" + tenantId);

            ClientCredential cc = new ClientCredential(applicationId, authenticationKey);
            AuthenticationResult result = context.AcquireTokenAsync("https://management.azure.com/", cc).Result;
            ServiceClientCredentials cred = new TokenCredentials(result.AccessToken);
            
            var adfClient = new DataFactoryManagementClient(cred)
            {
                SubscriptionId = subscriptionId
            };
            
            return adfClient;
        }
    }
}
