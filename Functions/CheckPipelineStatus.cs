using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using procfwk.Helpers;

using Microsoft.Azure.Management.DataFactory;
using Microsoft.Azure.Management.Synapse;

using adf = Microsoft.Azure.Management.DataFactory.Models;
using syn = Azure.Analytics.Synapse.Artifacts.Models;

namespace procfwk
{
    public static class CheckPipelineStatus
    {
        [FunctionName("CheckPipelineStatus")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("CheckPipelineStatus Function triggered by HTTP request.");

            string outputString = string.Empty;

            log.LogInformation("Parsing request body and validating content.");
            RequestHelper requestHelper = new RequestHelper
                (
                "CheckPipelineStatus",
                await new StreamReader(req.Body).ReadToEndAsync()
                );

            #region GetPipelineStatus
            if (requestHelper.OrchestratorType == "ADF")
            {
                //Create a data factory management client
                log.LogInformation("Creating ADF connectivity client.");

                using var adfClient = DataFactoryClient.CreateDataFactoryClient
                     (
                     requestHelper.TenantId,
                     requestHelper.ApplicationId,
                     requestHelper.AuthenticationKey,
                     requestHelper.SubscriptionId
                     );

                log.LogInformation("Getting ADF pipeline status.");

                //Get pipeline status with provided run id
                adf.PipelineRun pipelineRun;
                pipelineRun = adfClient.PipelineRuns.Get
                    (
                    requestHelper.ResourceGroupName,
                    requestHelper.OrchestratorName,
                    requestHelper.RunId
                    );

                log.LogInformation("ADF pipeline status: " + pipelineRun.Status);

                //Create return detail
                outputString = CreateOutputString(requestHelper.PipelineName, pipelineRun.RunId, pipelineRun.Status);
            }
            else if (requestHelper.OrchestratorType == "SYN")
            {
                log.LogInformation("Creating SYN connectivity client.");
                
                var synClient = SynapseClients.CreatePipelineRunClient
                    (
                    requestHelper.TenantId,
                    requestHelper.OrchestratorName,
                    requestHelper.ApplicationId,
                    requestHelper.AuthenticationKey
                    );

                log.LogInformation("Getting SYN pipeline status.");

                //Get pipeline status with provided run id
                syn.PipelineRun pipelineRun;
                pipelineRun = synClient.GetPipelineRun
                    (
                    requestHelper.RunId
                    );

                log.LogInformation("SYN pipeline status: " + pipelineRun.Status);
                    
                //Create return detail
                outputString = CreateOutputString(requestHelper.PipelineName, pipelineRun.RunId, pipelineRun.Status);
            }
            else
            {
                log.LogError("Invalid orchestrator type provided.");
                return new BadRequestObjectResult("Invalid orchestrator type provided. Expected ADF or SYN.");
            }
            #endregion

            JObject outputJson = JObject.Parse(outputString);

            log.LogInformation("CheckPipelineStatus Function complete.");
            return new OkObjectResult(outputJson);
        }
        private static string CreateOutputString(string pipelineName, string runId, string pipelineStatus = "Unknown")
        {
            string simpleStatus;

            //Create simple status for Data Factory Until comparison checks
            switch (pipelineStatus)
            {
                case "InProgress":
                    simpleStatus = "Running";
                    break;
                case "Canceling": //microsoft typo
                    simpleStatus = "Running";
                    break;
                case "Cancelling":
                    simpleStatus = "Running";
                    break;
                default:
                    simpleStatus = "Done";
                    break;
            }

            string jsonOutputString = "{ \"PipelineName\": \"" + pipelineName +
                                        "\", \"RunId\": \"" + runId +
                                        "\", \"SimpleStatus\": \"" + simpleStatus +
                                        "\", \"Status\": \"" + pipelineStatus.Replace("Canceling", "Cancelling") + //deal with microsoft typo
                                        "\" }";
            return jsonOutputString;
        }
    }
}
