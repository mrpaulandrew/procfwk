using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Azure.Management.DataFactory;
using Microsoft.Azure.Management.DataFactory.Models;
using Newtonsoft.Json.Linq;
using ADFprocfwk.Helpers;

using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

namespace ADFprocfwk
{
    public static class CheckPipelineStatus
    {
        [FunctionName("CheckPipelineStatus")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("CheckPipelineStatus Function triggered by HTTP request.");
            
            #region ParseRequestBody
            log.LogInformation("Parsing body from request.");        

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            string outputString = string.Empty;

            string tenantId = data?.tenantId;
            string applicationId = data?.applicationId;
            string authenticationKey = data?.authenticationKey;
            string subscriptionId = data?.subscriptionId;
            string resourceGroup = data?.resourceGroup;
            string factoryName = data?.factoryName;
            string pipelineName = data?.pipelineName;
            string runId = data?.runId;

            //Check body for values
            if (
                tenantId == null ||
                applicationId == null ||
                authenticationKey == null ||
                subscriptionId == null ||
                resourceGroup == null ||
                factoryName == null ||
                pipelineName == null ||
                runId == null
                )
            {
                log.LogInformation("Invalid body.");
                return new BadRequestObjectResult("Invalid request body, value(s) missing.");
            }
            #endregion

            #region ResolveKeyVaultValues

            Uri uriResult;
            bool result = Uri.TryCreate(applicationId, UriKind.Absolute, out uriResult)
                && (uriResult.Scheme == Uri.UriSchemeHttp || uriResult.Scheme == Uri.UriSchemeHttps);

            if (result)
            {
                log.LogInformation("ApplicationId provided as a URL. Querying Key Vault");
                log.LogInformation(uriResult.ToString());
                
                string keyVaultURL = "https://" + uriResult.Host.ToString();
                string secretName = uriResult.LocalPath.ToString().Replace("secrets/", "").Replace("/", "");

                log.LogInformation(keyVaultURL);
                log.LogInformation(secretName);

                var _keyVaultClient = new SecretClient(new Uri(keyVaultURL), new DefaultAzureCredential());
                var value = _keyVaultClient.GetSecret(secretName).Value.Value;

                applicationId = value.ToString();

                log.LogInformation(applicationId);
            }

            #endregion


            #region GetPipelineStatus
            //Create a data factory management client
            log.LogInformation("Creating ADF connectivity client.");
            
            using (var client = DataFactoryClient.CreateDataFactoryClient(tenantId, applicationId, authenticationKey, subscriptionId))
            {
                //Get pipeline status with provided run id
                PipelineRun pipelineRun;
                pipelineRun = client.PipelineRuns.Get(resourceGroup, factoryName, runId);
                log.LogInformation("Checking ADF pipeline status.");

                //Create simple status for Data Factory Until comparison checks
                string simpleStatus;

                if (pipelineRun.Status == "InProgress")
                {
                    simpleStatus = "Running";
                }
                else
                {
                    simpleStatus = "Done";
                }

                log.LogInformation("ADF pipeline status: " + pipelineRun.Status);

                //Final return detail
                outputString = "{ \"PipelineName\": \"" + pipelineName +
                                        "\", \"RunId\": \"" + pipelineRun.RunId +
                                        "\", \"SimpleStatus\": \"" + simpleStatus +
                                        "\", \"Status\": \"" + pipelineRun.Status +
                                        "\" }";
            }

            #endregion

            JObject outputJson = JObject.Parse(outputString);

            log.LogInformation("CheckPipelineStatus Function complete.");
            return new OkObjectResult(outputJson);
        }
    }
}
