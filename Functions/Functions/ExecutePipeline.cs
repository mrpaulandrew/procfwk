using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using mrpaulandrew.azure.procfwk.Helpers;
using mrpaulandrew.azure.procfwk.Services;

namespace mrpaulandrew.azure.procfwk
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
            PipelineRequest request = await new BodyReader(httpRequest).GetRequestBodyAsync();
            request.Validate(logger);

            using (var service = PipelineService.GetServiceForRequest(request, logger))
            {
                PipelineRunStatus result = service.ExecutePipeline(request);
                logger.LogInformation("ExecutePipeline Function complete.");
                return new OkObjectResult(JsonConvert.SerializeObject(result));
            }
        }
    }
}
