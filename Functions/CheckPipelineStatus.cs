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

            log.LogInformation(RequestHelper.CheckGuid(applicationId).ToString());

            if (!RequestHelper.CheckGuid(applicationId) && RequestHelper.CheckUri(applicationId))
            {
                log.LogInformation("Getting applicationId from Key Vault");
                applicationId = KeyVaultClient.GetSecretFromUri(applicationId);
            }

            if (RequestHelper.CheckUri(authenticationKey))
            {
                log.LogInformation("Getting authenticationKey from Key Vault");
                authenticationKey = KeyVaultClient.GetSecretFromUri(authenticationKey);
            }
            #endregion

            #region GetPipelineStatus
            //Create a data factory management client
            log.LogInformation("Creating ADF connectivity client.");
            
            using (var adfClient = DataFactoryClient.CreateDataFactoryClient(tenantId, applicationId, authenticationKey, subscriptionId))
            {
                //Get pipeline status with provided run id
                PipelineRun pipelineRun;
                pipelineRun = adfClient.PipelineRuns.Get(resourceGroup, factoryName, runId);
                log.LogInformation("Checking ADF pipeline status.");

                //Create simple status for Data Factory Until comparison checks
                string simpleStatus;

                switch (pipelineRun.Status)
                {
                    case "InProgress":
                        simpleStatus = "Running";
                        break;
                    case "Cancelling":
                        simpleStatus = "Cancelling";
                        break;
                    default:
                        simpleStatus = "Done";
                        break;
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
