using ADFprocfwk.Helpers;
using ADFprocfwk.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.IO;
using System.Threading.Tasks;

namespace ADFprocfwk
{
    public static class GetActivityErrors
    {
        [FunctionName("GetActivityErrors")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest httpRequest,
            ILogger logger)
        {
            logger.LogInformation("GetActivityErrors Function triggered by HTTP request.");

            logger.LogInformation("Parsing body from request.");
            string json = await new StreamReader(httpRequest.Body).ReadToEndAsync();
            var request = JsonConvert.DeserializeObject<PipelineRunRequest>(json);
            request.Validate(logger);

            using (var service = PipelineService.GetServiceForRequest(request, logger))
            {
                var result = service.GetPipelineRunActivityErrors(request);
                logger.LogInformation("GetActivityErrors Function complete.");
                return new OkObjectResult(JsonConvert.SerializeObject(result));
            }
        }
    }
}
