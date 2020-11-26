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
    public static class ValidatePipeline
    {
        [FunctionName("ValidatePipeline")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("ValidatePipeline Function triggered by HTTP request.");

            string outputString = string.Empty;

            log.LogInformation("Parsing request body and validating content.");
            RequestHelper requestHelper = new RequestHelper
                (
                "ValidatePipeline",
                await new StreamReader(req.Body).ReadToEndAsync()
                );

            #region ValidatePipeline
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

                adf.PipelineResource pipelineResource;

                try
                {
                    log.LogInformation("Validating ADF pipeline.");

                    pipelineResource = adfClient.Pipelines.Get
                        (
                        requestHelper.ResourceGroupName,
                        requestHelper.OrchestratorName,
                        requestHelper.PipelineName
                        );

                    outputString = CreateOutputString(true, pipelineResource.Name, pipelineResource.Id, pipelineResource.Type, pipelineResource.Activities.Count);
                }
                catch (Exception ex)
                {
                    outputString = CreateOutputString(false, requestHelper.PipelineName);

                    log.LogInformation(ex.Message);
                }
                
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

                syn.PipelineResource pipelineResource;

                try
                {
                    log.LogInformation("Validating SYN pipeline.");

                    pipelineResource = synClient.GetPipeline
                        (
                        requestHelper.PipelineName
                        );

                    outputString = CreateOutputString(true, pipelineResource.Name, pipelineResource.Id, pipelineResource.Type, pipelineResource.Activities.Count);
                }
                catch (Exception ex)
                {
                    outputString = CreateOutputString(false, requestHelper.PipelineName);

                    log.LogError(ex.Message);
                }
            }
            else
            {
                log.LogError("Invalid orchestrator type provided.");
                return new BadRequestObjectResult("Invalid orchestrator type provided. Expected ADF or SYN.");
            }
            #endregion

            JObject outputJson = JObject.Parse(outputString);

            log.LogInformation("CheckPipelineStatus Function complete.");

            //return false positive so PipelineExists result can be evaluated by Data Factory
            return new OkObjectResult(outputJson);
        }

        private static string CreateOutputString(bool pipelineValid, string pipelineName, string resourceId = null, string resourceType = null, int activityCount = 0)
        {
            string jsonOutputString;

            if (pipelineValid)
            {
                jsonOutputString = "{ \"PipelineExists\": \"" + pipelineValid.ToString() +
                                "\", \"PipelineName\": \"" + pipelineName +
                                "\", \"PipelineId\": \"" + resourceId +
                                "\", \"PipelineType\": \"" + resourceType +
                                "\", \"ActivityCount\": \"" + activityCount.ToString() +
                                "\" }";
            }
            else
            {
                jsonOutputString = "{ \"PipelineExists\": \"" + pipelineValid.ToString() +
                                "\", \"ProvidedPipelineName\": \"" + pipelineName +
                                "\" }";
            }
            return jsonOutputString;
        }
    }
}
