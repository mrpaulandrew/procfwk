using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace mrpaulandrew.azure.procfwk.Helpers
{
    public class BodyReader
    {
        public string Body;
        public BodyReader(HttpRequest httpRequest)
        {
            Body = new StreamReader(httpRequest.Body).ReadToEnd();
        }

        public Task<PipelineRequest> GetRequestBody()
        {
            PipelineRequest request = JsonConvert.DeserializeObject<PipelineRequest>(Body);
            return Task.FromResult(request);
        }

        public async Task<PipelineRequest> GetRequestBodyAsync()
        {
            PipelineRequest request = await GetRequestBody();
            return request;
        }

        public Task<PipelineRunRequest> GetRunRequestBody()
        {
            PipelineRunRequest request = JsonConvert.DeserializeObject<PipelineRunRequest>(Body);
            return Task.FromResult(request);
        }

        public async Task<PipelineRunRequest> GetRunRequestBodyAsync()
        {
            PipelineRunRequest request = await GetRunRequestBody();
            return request;
        }
    }
}
