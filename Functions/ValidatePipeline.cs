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
    public static class ValidatePipeline
    {
        [FunctionName("ValidatePipeline")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("ValidatePipeline Function triggered by HTTP request.");

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

            //Check body for values
            if (
                tenantId == null ||
                applicationId == null ||
                authenticationKey == null ||
                subscriptionId == null ||
                resourceGroup == null ||
                factoryName == null ||
                pipelineName == null
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

            #region ValidatePipeline
            //Create a data factory management client
            log.LogInformation("Creating ADF connectivity client.");

            using (var adfClient = DataFactoryClient.CreateDataFactoryClient(tenantId, applicationId, authenticationKey, subscriptionId))
            {
                PipelineResource pipelineResource;

                try
                {
                    pipelineResource = adfClient.Pipelines.Get(resourceGroup, factoryName, pipelineName);

                    log.LogInformation(pipelineResource.Id.ToString());
                    log.LogInformation(pipelineResource.Name.ToString());

                    outputString = "{ \"PipelineExists\": \"" + true.ToString() +
                                "\", \"PipelineName\": \"" + pipelineResource.Name.ToString() +
                                "\", \"PipelineId\": \"" + pipelineResource.Id.ToString() +
                                "\", \"PipelineType\": \"" + pipelineResource.Type.ToString() +
                                "\", \"ActivityCount\": \"" + pipelineResource.Activities.Count.ToString() +
                                "\" }";
                }
                catch (Exception ex)
                {
                    outputString = "{ \"PipelineExists\": \"" + false.ToString() +
                                "\", \"ProvidedPipelineName\": \"" + pipelineName +
                                "\" }";

                    log.LogInformation(ex.Message);
                }
            }
            #endregion

            JObject outputJson = JObject.Parse(outputString);

            log.LogInformation("CheckPipelineStatus Function complete.");

            //return false positive so PipelineExists result can be evaluated by Data Factory
            return new OkObjectResult(outputJson);
        }
    }
}
