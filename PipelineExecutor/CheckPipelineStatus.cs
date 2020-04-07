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

namespace PipelineExecutor
{
    public static class CheckPipelineStatus
    {
        [FunctionName("CheckPipelineStatus")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);

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
                factoryName == null ||
                pipelineName == null ||
                runId == null
                )
            {
                return new BadRequestObjectResult("Invalid request body, value missing.");
            }

            //Create a data factory management client
            var client = Helpers.DataFactoryClient.createDataFactoryClient(tenantId, applicationId, authenticationKey, subscriptionId);

            //Get pipeline status with provided run id
            PipelineRun pipelineRun;
            pipelineRun = client.PipelineRuns.Get(resourceGroup, factoryName, runId);

            //Final return detail
            string outputString = "{ \"PipelineName\": \"" + pipelineName +
                                    "\", \"RunId\": \"" + pipelineRun.RunId +
                                    "\", \"Status\": \"" + pipelineRun.Status +
                                    "\" }";

            JObject outputJson = JObject.Parse(outputString);
            return new OkObjectResult(outputJson);
        }
    }
}
