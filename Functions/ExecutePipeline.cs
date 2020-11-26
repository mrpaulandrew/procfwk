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
    public static class ExecutePipeline
    {
        [FunctionName("ExecutePipeline")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("ExecutePipeline Function triggered by HTTP request.");

            string outputString = string.Empty;
            
            log.LogInformation("Parsing request body and validating content.");
            RequestHelper requestHelper = new RequestHelper
                (
                "ExecutePipeline",
                await new StreamReader(req.Body).ReadToEndAsync()
                );

            #region CreatePipelineRun
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
                
                //Run pipeline
                adf.CreateRunResponse runResponse;
                adf.PipelineRun pipelineRun;

                if (requestHelper.PipelineParametersProvided)
                {
                    log.LogInformation("Called pipeline with parameters.");

                    runResponse = adfClient.Pipelines.CreateRunWithHttpMessagesAsync
                         (
                         requestHelper.ResourceGroupName,
                         requestHelper.OrchestratorName,
                         requestHelper.PipelineName,
                         parameters: requestHelper.PipelineParameters
                         ).Result.Body;
                }
                else
                {
                    log.LogInformation("Called pipeline without parameters.");

                    runResponse = adfClient.Pipelines.CreateRunWithHttpMessagesAsync
                        (
                        requestHelper.ResourceGroupName,
                        requestHelper.OrchestratorName,
                        requestHelper.PipelineName
                        ).Result.Body;
                }

                log.LogInformation("Pipeline run ID: " + runResponse.RunId);

                //Wait and check for pipeline to start...
                log.LogInformation("Checking ADF pipeline status.");
                while (true)
                {
                    pipelineRun = adfClient.PipelineRuns.Get
                        (
                        requestHelper.ResourceGroupName,
                        requestHelper.OrchestratorName,
                        runResponse.RunId
                        );

                    log.LogInformation("ADF pipeline status: " + pipelineRun.Status);

                    if (pipelineRun.Status == "Queued")
                        System.Threading.Thread.Sleep(15000);
                    else
                        break;
                }

                //Create return detail
                outputString = CreateOutputString(requestHelper.PipelineName, runResponse.RunId, pipelineRun.Status);
            }
            else if (requestHelper.OrchestratorType == "SYN")
            {
                log.LogInformation("Creating SYN connectivity client.");
                
                var synClient = SynapseClients.CreatePipelineClient
                    (
                    requestHelper.TenantId, 
                    requestHelper.OrchestratorName, 
                    requestHelper.ApplicationId,
                    requestHelper.AuthenticationKey
                    );

                //Run pipeline
                syn.CreateRunResponse runResponse;
                if (requestHelper.PipelineParametersProvided)
                {
                    log.LogInformation("Calling pipeline with parameters.");
                    runResponse = synClient.CreatePipelineRun
                        (
                        requestHelper.PipelineName,
                        parameters: requestHelper.PipelineParameters
                        );
                }
                else
                {
                    log.LogInformation("Calling pipeline without parameters.");
                    runResponse = synClient.CreatePipelineRun
                        (
                        requestHelper.PipelineName                        
                        );
                }

                //Create return detail
                outputString = CreateOutputString(requestHelper.PipelineName, runResponse.RunId);
            }
            else
            {
                log.LogError("Invalid orchestrator type provided.");
                return new BadRequestObjectResult("Invalid orchestrator type provided. Expected ADF or SYN.");
            }
            #endregion
            
            JObject outputJson = JObject.Parse(outputString);

            log.LogInformation("ExecutePipeline Function complete.");
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
