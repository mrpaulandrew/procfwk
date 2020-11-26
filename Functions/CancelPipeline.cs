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
    public static class CancelPipeline
    {
        [FunctionName("CancelPipeline")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("CancelPipeline Function triggered by HTTP request.");

            string outputString = string.Empty;

            log.LogInformation("Parsing request body and validating content.");
            RequestHelper requestHelper = new RequestHelper
                (
                "CancelPipeline",
                await new StreamReader(req.Body).ReadToEndAsync()
                );

            #region CancelPipeline
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

                log.LogInformation("Getting ADF pipeline current status.");

                //Get pipeline status with provided run id
                adf.PipelineRun pipelineRun;
                pipelineRun = adfClient.PipelineRuns.Get
                    (
                    requestHelper.ResourceGroupName,
                    requestHelper.OrchestratorName,
                    requestHelper.RunId
                    );

                if (pipelineRun.Status == "InProgress" || pipelineRun.Status == "Queued")
                {
                    log.LogInformation("Attempting to cancel ADF pipeline.");

                    adfClient.PipelineRuns.Cancel
                        (
                        requestHelper.ResourceGroupName,
                        requestHelper.OrchestratorName,
                        requestHelper.RunId,
                        isRecursive : requestHelper.RecursivePipelineCancel
                        );
                }
                else
                {
                    log.LogInformation("ADF pipeline status: " + pipelineRun.Status);
                    return new BadRequestObjectResult("Target pipeline is not in a state that can be cancelled.");
                }

                //Wait until cancellation state is confirmed
                while (true)
                {
                    pipelineRun = adfClient.PipelineRuns.Get
                        (
                        requestHelper.ResourceGroupName,
                        requestHelper.OrchestratorName,
                        requestHelper.RunId
                        );

                    log.LogInformation("ADF pipeline status post cancel request: " + pipelineRun.Status);

                    if (pipelineRun.Status == "Cancelling" || pipelineRun.Status == "Canceling") //microsoft typo
                        System.Threading.Thread.Sleep(10000);
                    else
                        break;
                }
                pipelineRun = adfClient.PipelineRuns.Get
                    (
                    requestHelper.ResourceGroupName,
                    requestHelper.OrchestratorName,
                    requestHelper.RunId
                    );

                //Create return detail
                outputString = CreateOutputString(requestHelper.PipelineName, requestHelper.RunId, pipelineRun.Status);
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

                synClient.CancelPipelineRun
                    (
                    requestHelper.RunId,
                    isRecursive : requestHelper.RecursivePipelineCancel
                    );
                
                //Create return detail
                outputString = CreateOutputString(requestHelper.PipelineName, requestHelper.RunId);
            }
            else
            {
                log.LogError("Invalid orchestrator type provided.");
                return new BadRequestObjectResult("Invalid orchestrator type provided. Expected ADF or SYN.");
            }
            #endregion

            JObject outputJson = JObject.Parse(outputString);

            log.LogInformation("CancelPipeline Function complete.");
            return new OkObjectResult(outputJson);
        }

        private static string CreateOutputString(string pipelineName, string runId, string pipelineStatus = "Unknown")
        {
            string jsonOutputString = "{ \"PipelineName\": \"" + pipelineName +
                                            "\", \"RunId\": \"" + runId +
                                            "\", \"Status\": \"" + pipelineStatus +
                                            "\" }";
            return jsonOutputString;
        }
    }
}
