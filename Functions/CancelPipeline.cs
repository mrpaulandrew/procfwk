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
    public static class CancelPipeline
    {
        [FunctionName("CancelPipeline")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("CancelPipeline Function triggered by HTTP request.");

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
            string recursiveCancel = data?.recursiveCancel;

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

            #region CancelPipeline
            //Create a data factory management client
            log.LogInformation("Creating ADF connectivity client.");
            using (var adfClient = DataFactoryClient.CreateDataFactoryClient(tenantId, applicationId, authenticationKey, subscriptionId))
            {
                //Cancelling pipeline                
                bool recursive;
                if (!String.IsNullOrEmpty(recursiveCancel))
                {
                    recursive = bool.Parse(recursiveCancel);
                }
                else
                {
                    recursive = true;
                }

                //Get pipeline status with provided run id
                PipelineRun pipelineRun;
                pipelineRun = adfClient.PipelineRuns.Get(resourceGroup, factoryName, runId);

                if (pipelineRun.Status == "InProgress" || pipelineRun.Status == "Queued")
                {
                    adfClient.PipelineRuns.Cancel(resourceGroup, factoryName, runId, recursive);
                }
                else
                {
                    log.LogInformation("ADF pipeline status: " + pipelineRun.Status);
                    return new BadRequestObjectResult("Target pipeline is not in a state that can be cancelled.");
                }

                //Wait until cancellation state is confirmed
                while (true)
                {
                    pipelineRun = adfClient.PipelineRuns.Get(resourceGroup, factoryName, runId);

                    log.LogInformation("ADF pipeline status: " + pipelineRun.Status);

                    if (pipelineRun.Status == "Cancelling" || pipelineRun.Status == "Canceling") //microsoft typo
                        System.Threading.Thread.Sleep(10000);
                    else
                        break;
                }
                pipelineRun = adfClient.PipelineRuns.Get(resourceGroup, factoryName, runId);

                //Final return detail
                outputString = "{ \"PipelineName\": \"" + pipelineName +
                                        "\", \"RunId\": \"" + pipelineRun.RunId +
                                        "\", \"Status\": \"" + pipelineRun.Status +
                                        "\" }";
            }
            #endregion

            JObject outputJson = JObject.Parse(outputString);

            log.LogInformation("CancelPipeline Function complete.");
            return new OkObjectResult(outputJson);
        }
    }
}
