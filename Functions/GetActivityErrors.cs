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
using Microsoft.Azure.Management.DataFactory;
using Microsoft.Azure.Management.DataFactory.Models;
using ADFprocfwk.Helpers;

namespace ADFprocfwk
{
    public static class GetActivityErrors
    {
        [FunctionName("GetActivityErrors")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("GetActivityErrors Function triggered by HTTP request.");

            #region ParseRequestBody
            log.LogInformation("Parsing body from request.");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic inputData = JsonConvert.DeserializeObject(requestBody);

            string tenantId = inputData?.tenantId;
            string applicationId = inputData?.applicationId;
            string authenticationKey = inputData?.authenticationKey;
            string subscriptionId = inputData?.subscriptionId;
            string resourceGroup = inputData?.resourceGroup;
            string factoryName = inputData?.factoryName;
            string pipelineName = inputData?.pipelineName;
            string runId = inputData?.runId;

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

            //Query and output support variables
            int daysOfRuns = 7; //max duration for mandatory RunFilterParameters
            DateTime today = DateTime.Now;
            DateTime lastWeek = DateTime.Now.AddDays(-daysOfRuns);
            dynamic outputBlock = new JObject();
            dynamic outputBlockInner;

            //Create a data factory management client
            log.LogInformation("Creating ADF connectivity client.");

            using (var client = DataFactoryClient.CreateDataFactoryClient(tenantId, applicationId, authenticationKey, subscriptionId))
            {
                #region SetPipelineRunDetails

                //Get pipeline details
                PipelineRun pipelineRun;
                pipelineRun = client.PipelineRuns.Get(resourceGroup, factoryName, runId);

                log.LogInformation("Querying ADF pipeline for Activity Runs.");

                RunFilterParameters filterParams = new RunFilterParameters(lastWeek, today);
                ActivityRunsQueryResponse queryResponse = client.ActivityRuns.QueryByPipelineRun(resourceGroup, factoryName, runId, filterParams);

                //Create initial output content
                outputBlock.PipelineName = pipelineName;
                outputBlock.PipelineStatus = pipelineRun.Status;
                outputBlock.RunId = runId;
                outputBlock.ResponseCount = queryResponse.Value.Count;
                outputBlock.ResponseErrorCount = 0;
                outputBlock.Errors = new JArray();
                JObject errorDetails;

                #endregion

                log.LogInformation("Pipeline status: " + pipelineRun.Status);
                log.LogInformation("Activities found in pipeline response: " + queryResponse.Value.Count.ToString());

                #region GetActivityDetails

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
                #endregion
            }
            log.LogInformation("GetActivityErrors Function complete.");

            return new OkObjectResult(outputBlock);
        }
    }
}
