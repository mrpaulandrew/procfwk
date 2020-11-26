using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using procfwk.Helpers;

using Microsoft.Azure.Management.DataFactory;
using Microsoft.Azure.Management.Synapse;

using adf = Microsoft.Azure.Management.DataFactory.Models;
using syn = Azure.Analytics.Synapse.Artifacts.Models;

namespace procfwk
{
    public static class GetActivityErrors
    {
        [FunctionName("GetActivityErrors")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("GetActivityErrors Function triggered by HTTP request.");

            string outputString = string.Empty;

            log.LogInformation("Parsing request body and validating content.");
            RequestHelper requestHelper = new RequestHelper
                (
                "GetActivityErrors",
                await new StreamReader(req.Body).ReadToEndAsync()
                );

            #region GetActivityRun

            //Query and output support variables
            int daysOfRuns = 1; //max duration for mandatory RunFilterParameters
            DateTime today = DateTime.Now;
            DateTime lastWeek = DateTime.Now.AddDays(-daysOfRuns);
            dynamic outputBlock = new JObject();
            dynamic outputBlockInner;

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

                //Get pipeline details
                adf.PipelineRun pipelineRun;
                pipelineRun = adfClient.PipelineRuns.Get
                    (
                    requestHelper.ResourceGroupName,
                    requestHelper.OrchestratorName,
                    requestHelper.RunId
                    );

                log.LogInformation("Querying ADF pipeline for Activity Runs.");

                adf.RunFilterParameters filterParams = new adf.RunFilterParameters(lastWeek, today);
                adf.ActivityRunsQueryResponse queryResponse = adfClient.ActivityRuns.QueryByPipelineRun
                    (
                     requestHelper.ResourceGroupName,
                     requestHelper.OrchestratorName,
                     requestHelper.RunId,
                     filterParams
                     );

                //Create initial output content
                outputBlock.PipelineName = requestHelper.PipelineName;
                outputBlock.PipelineStatus = pipelineRun.Status;
                outputBlock.RunId = requestHelper.RunId;
                outputBlock.ResponseCount = queryResponse.Value.Count;
                outputBlock.ResponseErrorCount = 0;
                outputBlock.Errors = new JArray();
                JObject errorDetails;

                log.LogInformation("Pipeline status: " + pipelineRun.Status);
                log.LogInformation("Activities found in pipeline response: " + queryResponse.Value.Count.ToString());

                //Loop over activities in pipeline run
                foreach (var activity in queryResponse.Value)
                {
                    if (string.IsNullOrEmpty(activity.Error.ToString()))
                    {
                        continue; //just incase
                    }

                    //Parse error output to customise output
                    outputBlockInner = JsonConvert.DeserializeObject(activity.Error.ToString());

                    string errorCode = outputBlockInner?.errorCode;
                    string errorType = outputBlockInner?.failureType;
                    string errorMessage = outputBlockInner?.message;

                    //Get output details
                    if (!string.IsNullOrEmpty(errorCode))
                    {
                        log.LogInformation("Activity run id: " + activity.ActivityRunId);
                        log.LogInformation("Activity name: " + activity.ActivityName);
                        log.LogInformation("Activity type: " + activity.ActivityType);
                        log.LogInformation("Error message: " + errorMessage);

                        outputBlock.ResponseErrorCount += 1;

                        //Construct custom error information block
                        errorDetails = JObject.Parse("{ \"ActivityRunId\": \"" + activity.ActivityRunId +
                                        "\", \"ActivityName\": \"" + activity.ActivityName +
                                        "\", \"ActivityType\": \"" + activity.ActivityType +
                                        "\", \"ErrorCode\": \"" + errorCode +
                                        "\", \"ErrorType\": \"" + errorType +
                                        "\", \"ErrorMessage\": \"" + errorMessage +
                                        "\" }");

                        outputBlock.Errors.Add(errorDetails);
                    }
                }
            }
            else if(requestHelper.OrchestratorType == "SYN")
            {
                log.LogInformation("Creating SYN connectivity client.");

                var synClient = SynapseClients.CreatePipelineRunClient
                    (
                    requestHelper.TenantId,
                    requestHelper.OrchestratorName,
                    requestHelper.ApplicationId,
                    requestHelper.AuthenticationKey
                    );

                syn.PipelineRun pipelineRun;
                pipelineRun = synClient.GetPipelineRun
                    (
                    requestHelper.RunId
                    );

                log.LogInformation("Querying SYN pipeline for Activity Runs.");

                syn.RunFilterParameters filterParams = new syn.RunFilterParameters(lastWeek, today);
                syn.ActivityRunsQueryResponse queryResponse = synClient.QueryActivityRuns
                    (
                     requestHelper.PipelineName,
                     requestHelper.RunId,
                     filterParams
                     );

                log.LogInformation("Pipeline status: " + pipelineRun.Status);
                log.LogInformation("Activities found in pipeline response: " + queryResponse.Value.Count.ToString());
            }   
            else
            {
                log.LogError("Invalid orchestrator type provided.");
                return new BadRequestObjectResult("Invalid orchestrator type provided. Expected ADF or SYN.");
            }
            #endregion
            log.LogInformation("GetActivityErrors Function complete.");

            return new OkObjectResult(outputBlock);
        }
    }
}
