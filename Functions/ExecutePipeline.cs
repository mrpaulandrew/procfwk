using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using ADFprocfwk.Helpers;
using ADFprocfwk.Services;

namespace ADFprocfwk
{
    public static class ExecutePipeline
    {
        [FunctionName("ExecutePipeline")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest httpRequest,
            ILogger logger)
        {
            logger.LogInformation("ExecutePipeline Function triggered by HTTP request.");

            logger.LogInformation("Parsing body from request.");
            string json = await new StreamReader(httpRequest.Body).ReadToEndAsync();
            var request = JsonConvert.DeserializeObject<PipelineRequest>(json);
            request.Validate(logger);

            using (var service = PipelineService.GetServiceForRequest(request, logger))
            {
                var result = service.ExecutePipeline(request);
                logger.LogInformation("ExecutePipeline Function complete.");
                return new OkObjectResult(JsonConvert.SerializeObject(result));
            }
        }
    }
}
