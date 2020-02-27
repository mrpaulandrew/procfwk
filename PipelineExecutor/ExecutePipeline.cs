using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Rest;
using Microsoft.Azure.Management.DataFactory;
using Microsoft.Azure.Management.DataFactory.Models;
using System.Linq;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
using System.Net.Http;

namespace PipelineExecutor
{ 
    public static class ExecutePipeline
    {
        [FunctionName("ExecutePipeline")]
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

            //Check body for values
            if (
                tenantId == null ||
                applicationId == null ||
                authenticationKey == null ||
                subscriptionId == null ||
                factoryName == null ||
                pipelineName == null
                )
            {
                return new BadRequestObjectResult("Invalid request body, value missing.");
            }

            //Create a data factory management client
            var context = new AuthenticationContext("https://login.windows.net/" + tenantId);
            ClientCredential cc = new ClientCredential(applicationId, authenticationKey);
            AuthenticationResult result = context.AcquireTokenAsync("https://management.azure.com/", cc).Result;
            ServiceClientCredentials cred = new TokenCredentials(result.AccessToken);
            var client = new DataFactoryManagementClient(cred)
            {
                SubscriptionId = subscriptionId
            };

            //Run pipeline
            CreateRunResponse runResponse;
            PipelineRun pipelineRun;

            if (data?.pipelineParameters == null)
            {
                log.LogInformation("Called pipeline without parameters.");

                runResponse = client.Pipelines.CreateRunWithHttpMessagesAsync(
                    resourceGroup, factoryName, pipelineName).Result.Body;
            }
            else
            {
                log.LogInformation("Called pipeline with parameters.");

                JObject jObj = JObject.Parse(requestBody);
                Dictionary<string, object> parameters = jObj["pipelineParameters"].ToObject<Dictionary<string, object>>();

                log.LogInformation("Number of parameters provided: " + jObj.Count.ToString());

                runResponse = client.Pipelines.CreateRunWithHttpMessagesAsync(
                    resourceGroup, factoryName, pipelineName, parameters: parameters).Result.Body;
            }

            log.LogInformation("Pipeline run ID: " + runResponse.RunId);
            
            //Wait and check for pipeline result
            log.LogInformation("Checking pipeline run status...");
            while (true)
            {
                pipelineRun = client.PipelineRuns.Get(
                    resourceGroup, factoryName, runResponse.RunId);

                log.LogInformation("Status: " + pipelineRun.Status);

                if (pipelineRun.Status == "InProgress" || pipelineRun.Status == "Queued")
                    System.Threading.Thread.Sleep(15000);
                else
                    break;
            }

            //Final return detail
            string outputString = "{ \"PipelineName\": \"" + pipelineName + "\", \"RunIdUsed\": \"" + pipelineRun.RunId + "\", \"Status\": \"" + pipelineRun.Status + "\" }";
            JObject outputJson = JObject.Parse(outputString);
            return new OkObjectResult(outputJson);
        }
    }
}
